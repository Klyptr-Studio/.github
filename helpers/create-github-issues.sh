#!/bin/bash

###############################################################################
# Klyptr Studio - GitHub Issues & Labels Creator (Standalone)
# 
# This script ONLY creates GitHub labels and issues
# Use this when services already exist in GitHub but issues haven't been created yet
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CONFIG_FILE="${1:-services-config.json}"
LOG_FILE="github-issues-creation-$(date +%Y%m%d-%H%M%S).log"

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}\n" | tee -a "$LOG_FILE"
}

# ============================================================================
# Main
# ============================================================================

main() {
    log_section "GITHUB ISSUES & LABELS CREATOR (STANDALONE)"
    log_info "Start Time: $(date)"
    log_info "Config File: $CONFIG_FILE"
    log_info "Log File: $LOG_FILE"
    
    # Validate prerequisites
    log_section "VALIDATING PREREQUISITES"
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) not found"
        exit 1
    fi
    log_success "GitHub CLI found"
    
    if ! command -v node &> /dev/null; then
        log_error "Node.js not found"
        exit 1
    fi
    log_success "Node.js found: $(node --version)"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    log_success "Configuration file found"
    
    # Validate GitHub auth
    log_section "VALIDATING GITHUB AUTHENTICATION"
    
    if ! gh auth status &> /dev/null; then
        log_error "Not authenticated with GitHub. Run: gh auth login"
        exit 1
    fi
    log_success "GitHub CLI authenticated"
    
    # Run Node.js script
    log_section "CREATING GITHUB ISSUES & LABELS"
    
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    NODE_SCRIPT="$SCRIPT_DIR/create-github-issues.js"
    
    if [ ! -f "$NODE_SCRIPT" ]; then
        log_error "Node.js script not found: $NODE_SCRIPT"
        log_error "Make sure create-github-issues.js is in the same directory"
        exit 1
    fi
    log_info "Running: node $NODE_SCRIPT $CONFIG_FILE"
    
    if node "$NODE_SCRIPT" "$CONFIG_FILE" >> "$LOG_FILE" 2>&1; then
        log_success "GitHub operations completed successfully"
    else
        log_error "GitHub operations encountered errors (see log)"
        cat "$LOG_FILE" | grep -A 2 "ERROR\|error" || true
    fi
    
    log_section "SUMMARY"
    log_info "End Time: $(date)"
    log_info "Log File: $LOG_FILE"
    log_info ""
    log_info "Verify results:"
    log_info "  gh label list --repo Klyptr-Studio/User-Service"
    log_info "  gh issue list --repo Klyptr-Studio/User-Service"
}

main "$@"