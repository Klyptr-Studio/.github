#!/bin/sh

PROJECT_NAME="${1}"


IGNORE_LIST="template-react-microservice template-springboot-microservice template-python-microservice template-nodejs-microservice"

issues() {
    name="$1"
    gh issue list --repo Klyptr-Studio/"$name"
    echo ""
}

pull_requests() {
    name="$1"
    gh pr list --repo Klyptr-Studio/"$name"
    echo ""
}

if [ -z "$PROJECT_NAME" ]; then
    REPO_LIST=$(gh repo list Klyptr-Studio --limit 100 | awk 'NR > 1 {split($1, parts, "/"); print parts[2]}')

    for repo in $REPO_LIST; do
        case " $IGNORE_LIST " in
            *" $repo "*) continue ;;
        esac

            issues "$repo"
            pull_requests "$repo"
    done
else
    issues "$PROJECT_NAME"
    pull_requests "$PROJECT_NAME"
fi

