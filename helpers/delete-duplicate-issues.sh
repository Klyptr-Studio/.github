#!/bin/bash

################################################################################
# Delete Duplicate GitHub Issues - Klyptr Studio
#
# This script deletes duplicate issues from all microservice repositories
# Use ONLY when you have duplicates (like issue #1 and #2 with same title)
#
# Safe to run multiple times - checks before deleting
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SERVICES=(
    "User-Service"
    "Subscription-Service"
    "Script-Service"
    "Voice-Service"
    "Media-Service"
    "Asset-Manager"
    "Analytics-Service"
    "Notification-Service"
)

ORG="Klyptr-Studio"
DRY_RUN=true

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
}

# ============================================================================
# Main Functions
# ============================================================================

validate_prerequisites() {
    log_section "VALIDATING PREREQUISITES"
    
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) not found"
        exit 1
    fi
    log_success "GitHub CLI found"
    
    if ! gh auth status &> /dev/null; then
        log_error "Not authenticated with GitHub"
        exit 1
    fi
    log_success "GitHub CLI authenticated"
}

count_issues_in_repo() {
    local repo=$1
    gh issue list --repo "$ORG/$repo" --state all --json number | jq 'length'
}

get_issue_titles() {
    local repo=$1
    gh issue list --repo "$ORG/$repo" --state all --json number,title | jq -r '.[] | "\(.number):\(.title)"'
}

find_duplicates_in_repo() {
    local repo=$1
    local titles_file="/tmp/${repo}_titles.txt"
    
    # Get all issues with number and title
    gh issue list --repo "$ORG/$repo" --state all --json number,title | jq -r '.[] | "\(.number)|\(.title)"' > "$titles_file"
    
    # Find duplicate titles
    local duplicates=$(cat "$titles_file" | cut -d'|' -f2 | sort | uniq -d)
    
    if [ -z "$duplicates" ]; then
        return 1  # No duplicates
    fi
    
    # For each duplicate title, show the issue numbers
    while IFS= read -r dup_title; do
        log_warning "Found duplicate: '$dup_title'"
        echo "Issue numbers to delete (keep highest number, delete lower):"
        grep "|$dup_title\$" "$titles_file" | cut -d'|' -f1 | sort -n | head -n -1 | while read -r issue_num; do
            echo "  #$issue_num"
        done
    done <<< "$duplicates"
    
    rm -f "$titles_file"
}

delete_issue() {
    local repo=$1
    local issue_num=$2
    
    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY-RUN] Would delete: $ORG/$repo#$issue_num"
    else
        log_info "Deleting: $ORG/$repo#$issue_num"
        gh issue delete "$issue_num" --repo "$ORG/$repo" --yes 2>/dev/null || log_warning "Could not delete $issue_num (may not exist)"
        log_success "Deleted: #$issue_num"
    fi
}

process_service() {
    local service=$1
    
    log_info "Processing: $service"
    
    local count=$(count_issues_in_repo "$service")
    log_info "Found $count issues"
    
    if [ "$count" -lt 2 ]; then
        log_info "No duplicates (less than 2 issues)"
        return
    fi
    
    # Check for duplicates
    if find_duplicates_in_repo "$service"; then
        log_warning "Duplicates found in $service"
        
        # Get all issues with their titles
        local issues_file="/tmp/${service}_issues.txt"
        gh issue list --repo "$ORG/$service" --state all --json number,title | jq -r '.[] | "\(.number)|\(.title)"' > "$issues_file"
        
        # Find and delete older duplicates (lower issue numbers)
        local current_title=""
        local prev_issue=""
        
        sort -t'|' -k2 "$issues_file" | while IFS='|' read -r issue_num title; do
            if [ "$title" = "$current_title" ]; then
                # Duplicate found - delete the previous one (lower number)
                delete_issue "$service" "$prev_issue"
            fi
            current_title="$title"
            prev_issue="$issue_num"
        done
        
        rm -f "$issues_file"
    else
        log_success "No duplicates in $service"
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    log_section "DELETE DUPLICATE GITHUB ISSUES"
    
    # Parse arguments
    if [ "$1" = "--delete" ]; then
        DRY_RUN=false
        log_warning "⚠️  DELETE MODE ENABLED - Issues will be permanently deleted!"
    else
        log_info "Running in DRY-RUN mode (no issues will be deleted)"
        log_info "To actually delete issues, run: $0 --delete"
    fi
    
    validate_prerequisites
    
    # Process each service
    log_section "CHECKING FOR DUPLICATES IN ALL SERVICES"
    
    local total_issues=0
    for service in "${SERVICES[@]}"; do
        log_info ""
        log_info "[$service]"
        process_service "$service"
        total_issues=$((total_issues + 1))
    done
    
    # Summary
    log_section "SUMMARY"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "DRY-RUN Complete"
        log_info ""
        log_info "To delete the issues shown above, run:"
        log_info "  $0 --delete"
    else
        log_success "Deletion complete!"
        log_info "Verify by checking:"
        log_info "  gh issue list --repo $ORG/User-Service"
    fi
}

main "$@"