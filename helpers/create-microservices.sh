#!/bin/bash

################################################################################
# Klyptr Studio - Microservice Creation Orchestrator
# 
# Purpose: Create all microservices in batch, then create GitHub issues
# Usage: ./create-microservices.sh <path-to-services-config.json>
# 
# Flow:
# 1. Validate JSON input file
# 2. For each service: run init-klyptr-studio-microservice
# 3. Call Node.js script to create GitHub issues & labels
# 4. Generate summary report
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CONFIG_FILE="${1:-services-config.json}"
LOG_FILE="microservice-creation-$(date +%Y%m%d-%H%M%S).log"
SERVICES_CREATED=0
SERVICES_FAILED=0

################################################################################
# Utility Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}\n" | tee -a "$LOG_FILE"
}

################################################################################
# Validation Functions
################################################################################

validate_prerequisites() {
    log_section "VALIDATING PREREQUISITES"
    
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed or not in PATH"
        exit 1
    fi
    log_success "GitHub CLI (gh) found"
    
    # Check if init script exists
    if ! command -v init-klyptr-studio-microservice &> /dev/null; then
        log_error "init-klyptr-studio-microservice script not found in PATH"
        exit 1
    fi
    log_success "init-klyptr-studio-microservice script found"
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed"
        exit 1
    fi
    log_success "Node.js found: $(node --version)"
    
    # Check if jq is installed (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        log_warning "jq (JSON processor) not found. Installing may improve debugging."
    else
        log_success "jq (JSON processor) found"
    fi
}

validate_config_file() {
    log_section "VALIDATING CONFIGURATION FILE"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    log_success "Configuration file found: $CONFIG_FILE"
    
    # Validate JSON syntax
    if ! node -e "require('fs').readFileSync('$CONFIG_FILE', 'utf8')" &> /dev/null; then
        log_error "Invalid JSON syntax in configuration file"
        exit 1
    fi
    log_success "Configuration file has valid JSON syntax"
}

################################################################################
# Microservice Creation Functions
################################################################################

create_microservices_from_json() {
    log_section "CREATING MICROSERVICES"
    
    # Extract services array from JSON
    local services_count=$(node -e "
        const fs = require('fs');
        const config = JSON.parse(fs.readFileSync('$CONFIG_FILE'));
        console.log(config.services.length);
    ")
    
    log_info "Found $services_count services to create"
    
    # Iterate through each service
    local index=0
    node -e "
        const fs = require('fs');
        const config = JSON.parse(fs.readFileSync('$CONFIG_FILE'));
        config.services.forEach(service => {
            console.log(JSON.stringify(service));
        });
    " | while read -r service_json; do
        
        # Parse service details
        local name=$(echo "$service_json" | node -e "const line = require('fs').readFileSync(0, 'utf8'); console.log(JSON.parse(line).name)")
        local tech_stack=$(echo "$service_json" | node -e "const line = require('fs').readFileSync(0, 'utf8'); console.log(JSON.parse(line).techStack)")
        
        index=$((index + 1))
        
        log_info "[$index/$services_count] Creating: $name (Stack: $tech_stack)"
        
        # Run init script
        if init-klyptr-studio-microservice "$tech_stack" "$name" >> "$LOG_FILE" 2>&1; then
            log_success "[$index/$services_count] Created: $name"
            SERVICES_CREATED=$((SERVICES_CREATED + 1))
        else
            log_error "[$index/$services_count] Failed to create: $name"
            SERVICES_FAILED=$((SERVICES_FAILED + 1))
        fi
        
        # Small delay between creations (avoid rate limiting)
        sleep 2
    done
}

################################################################################
# Main Execution
################################################################################

main() {
    log_section "KLYPTR STUDIO - MICROSERVICE CREATION"
    log_info "Start Time: $(date)"
    log_info "Log File: $LOG_FILE"
    
    # Step 1: Validate prerequisites
    validate_prerequisites
    
    # Step 2: Validate configuration
    validate_config_file
    
    # Step 3: Create microservices
    create_microservices_from_json
    
    # Step 4: Create GitHub issues
    log_section "CREATING GITHUB ISSUES & LABELS"
    log_info "Delegating to Node.js script for GitHub operations"
    
    if node "$(dirname "$0")/create-github-issues.js" "$CONFIG_FILE" >> "$LOG_FILE" 2>&1; then
        log_success "GitHub issues & labels creation completed"
    else
        log_error "GitHub issues & labels creation encountered errors (see log for details)"
    fi
    
    # Step 5: Summary
    log_section "SUMMARY"
    log_info "Services Created Successfully: $SERVICES_CREATED"
    log_info "Services Failed: $SERVICES_FAILED"
    log_info "End Time: $(date)"
    log_info "Log File: $LOG_FILE"
    
    if [ $SERVICES_FAILED -gt 0 ]; then
        log_warning "Some services failed. Please review the log file above."
        exit 1
    else
        log_success "All operations completed successfully!"
        exit 0
    fi
}

# Run main function
main "$@"