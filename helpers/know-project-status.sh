#!/bin/sh

PROJECT_NAME="${1}"

ORG="Klyptr-Studio"

IGNORE_LIST="
template-react-microservice
template-springboot-microservice
template-python-microservice
template-nodejs-microservice
"

TOTAL_OPEN_ISSUES=0
TOTAL_OPEN_PULL_REQUESTS=0
TOTAL_REPOS=0
ACTIVE_REPOS=0

# ─────────────────────────────────────────────
# Terminal colors
# ─────────────────────────────────────────────

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
MAGENTA="\033[35m"
WHITE="\033[97m"

# Box width:
# ╭────────────────────────────────────────────────────────────╮
# │                                                            │
# ╰────────────────────────────────────────────────────────────╯
#
# Content width = 60 characters
WIDTH=60

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────

is_ignored() {
    repo="$1"

    case " $IGNORE_LIST " in
        *" $repo "*) return 0 ;;
        *) return 1 ;;
    esac
}

print_top() {
    printf "${BOLD}${MAGENTA}╭────────────────────────────────────────────────────────────╮${RESET}\n"
    printf "${BOLD}${MAGENTA}│${RESET}${BOLD}${WHITE}%60s${RESET}${BOLD}${MAGENTA}│${RESET}\n" \
        "KLYPTR STUDIO STATUS"
    printf "${BOLD}${MAGENTA}╰────────────────────────────────────────────────────────────╯${RESET}\n"
}

print_repo_header() {
    repo="$1"
    issue_count="$2"
    pr_count="$3"

    # Truncate very long repository names.
    repo_display=$(printf '%s' "$repo" | cut -c1-32)

    printf "\n"
    printf "${BOLD}${CYAN}╭────────────────────────────────────────────────────────────╮${RESET}\n"
    printf "${BOLD}${CYAN}│${RESET} ${BOLD}%-32s${RESET}  ${YELLOW}Issues: %-2s${RESET}  ${GREEN}PRs: %-2s${RESET} ${BOLD}${CYAN}│${RESET}\n" \
        "$repo_display" "$issue_count" "$pr_count"
    printf "${BOLD}${CYAN}╰────────────────────────────────────────────────────────────╯${RESET}\n"
}

print_section() {
    title="$1"

    printf "\n"
    printf "  ${BOLD}%s${RESET}\n" "$title"
    printf "  ${DIM}────────────────────────────────────────────────────────────${RESET}\n"
}

# ─────────────────────────────────────────────
# Process repository
# ─────────────────────────────────────────────

process_repo() {
    repo="$1"

    if is_ignored "$repo"; then
        return
    fi

    ISSUE_DATA=$(gh issue list \
        --repo "$ORG/$repo" \
        --limit 1000 \
        --json number,title)

    PR_DATA=$(gh pr list \
        --repo "$ORG/$repo" \
        --limit 1000 \
        --json number,title,headRefName)

    ISSUE_COUNT=$(printf '%s' "$ISSUE_DATA" | jq 'length')
    PR_COUNT=$(printf '%s' "$PR_DATA" | jq 'length')

    TOTAL_REPOS=$((TOTAL_REPOS + 1))

    # Skip completely empty repositories.
    if [ "$ISSUE_COUNT" -eq 0 ] && [ "$PR_COUNT" -eq 0 ]; then
        return
    fi

    ACTIVE_REPOS=$((ACTIVE_REPOS + 1))

    TOTAL_OPEN_ISSUES=$((TOTAL_OPEN_ISSUES + ISSUE_COUNT))
    TOTAL_OPEN_PULL_REQUESTS=$((TOTAL_OPEN_PULL_REQUESTS + PR_COUNT))

    print_repo_header "$repo" "$ISSUE_COUNT" "$PR_COUNT"

    # ─────────────────────────────────────────
    # Issues
    # ─────────────────────────────────────────

    if [ "$ISSUE_COUNT" -gt 0 ]; then
        print_section "Issues ($ISSUE_COUNT)"

        printf '%s\n' "$ISSUE_DATA" |
            jq -r '.[] | "\(.number)\t\(.title)"' |
            while IFS="$(printf '\t')" read -r number title; do
                printf "  ${YELLOW}#%-4s${RESET} %s\n" "$number" "$title"
            done
    fi

    # ─────────────────────────────────────────
    # Pull Requests
    # ─────────────────────────────────────────

    if [ "$PR_COUNT" -gt 0 ]; then
        print_section "Pull Requests ($PR_COUNT)"

        printf '%s\n' "$PR_DATA" |
            jq -r '.[] | "\(.number)\t\(.title)\t\(.headRefName)"' |
            while IFS="$(printf '\t')" read -r number title branch; do
                printf "  ${GREEN}#%-4s${RESET} %s ${DIM}[%s]${RESET}\n" \
                    "$number" "$title" "$branch"
            done
    fi
}

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────

printf "\n"
print_top

if [ -n "$PROJECT_NAME" ]; then
    process_repo "$PROJECT_NAME"
else
    REPO_LIST=$(gh repo list "$ORG" --limit 100 |
        awk 'NR > 1 {split($1, parts, "/"); print parts[2]}')

    for repo in $REPO_LIST; do
        process_repo "$repo"
    done
fi

# ─────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────

printf "\n"
printf "${BOLD}${CYAN}╭────────────────────────────────────────────────────────────╮${RESET}\n"
printf "${BOLD}${CYAN}│${RESET}${BOLD}${WHITE}%60s${RESET}${BOLD}${CYAN}│${RESET}\n" "SUMMARY"
printf "${BOLD}${CYAN}├────────────────────────────────────────────────────────────┤${RESET}\n"
printf "${BOLD}${CYAN}│${RESET}  Repositories        %-35s${BOLD}${CYAN}│${RESET}\n" "$TOTAL_REPOS"
printf "${BOLD}${CYAN}│${RESET}  Active Repositories %-35s${BOLD}${CYAN}│${RESET}\n" "$ACTIVE_REPOS"
printf "${BOLD}${CYAN}│${RESET}  Open Issues         ${YELLOW}%-35s${RESET}${BOLD}${CYAN}│${RESET}\n" "$TOTAL_OPEN_ISSUES"
printf "${BOLD}${CYAN}│${RESET}  Open Pull Requests  ${GREEN}%-35s${RESET}${BOLD}${CYAN}│${RESET}\n" "$TOTAL_OPEN_PULL_REQUESTS"
printf "${BOLD}${CYAN}╰────────────────────────────────────────────────────────────╯${RESET}\n"
printf "\n"
