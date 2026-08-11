#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
TS=$(date +%s)

CO_NAME="${1:-Collaborator}"
CO_EMAIL="${2:-collaborator@example.com}"

echo -e "${GREEN}=== Pair Extraordinaire Achievement ===${NC}"
echo "Co-author: $CO_NAME <$CO_EMAIL>"
echo ""

if ! gh auth status &>/dev/null; then
  echo -e "${RED}ERROR: Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
  echo -e "${RED}ERROR: Not in a GitHub repo.${NC}"; exit 1
fi

BRANCH="pair-extraordinaire-$TS"
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')

git checkout "$DEFAULT_BRANCH" &>/dev/null
git pull &>/dev/null
git checkout -b "$BRANCH"

echo "Pair Extraordinaire [$TS]" >> .pair-log
git add .pair-log
git commit -m "feat: pair extraordinaire collaboration [$TS]

Co-authored-by: $CO_NAME <$CO_EMAIL>"

git push origin "$BRANCH"

PR_URL=$(gh pr create \
  --title "Pair Extraordinaire [$TS]" \
  --body "Co-authored commit for Pair Extraordinaire achievement.

Co-authored-by: $CO_NAME <$CO_EMAIL>" \
  --head "$BRANCH")
PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')

sleep 2
gh pr merge "$PR_NUM" --merge --delete-branch

git checkout "$DEFAULT_BRANCH"
git pull

echo ""
echo -e "${GREEN}✅ Pair Extraordinaire unlocked!${NC}"
echo "Check: https://github.com/$(gh api user -q .login)"
