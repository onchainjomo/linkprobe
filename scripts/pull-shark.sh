#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

COUNT=${1:-2}

echo -e "${GREEN}=== Pull Shark Achievement ===${NC}"
if [ "$COUNT" -ge 128 ]; then
  echo "Target: Gold (128+ merged PRs)"
elif [ "$COUNT" -ge 16 ]; then
  echo "Target: Silver (16+ merged PRs)"
else
  echo "Target: Bronze (2+ merged PRs)"
fi
echo ""

if ! gh auth status &>/dev/null; then
  echo -e "${RED}ERROR: Not authenticated. Run: gh auth login${NC}"; exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
if [ -z "$REPO" ]; then
  echo -e "${RED}ERROR: Not in a GitHub repo.${NC}"; exit 1
fi

echo -e "${YELLOW}Repo: $REPO — creating $COUNT PRs...${NC}"

DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')

for i in $(seq 1 $COUNT); do
  TS=$(date +%s%N)
  BRANCH="pull-shark-$i-$TS"
  echo -n "  PR $i/$COUNT... "

  git checkout "$DEFAULT_BRANCH" &>/dev/null
  git pull origin "$DEFAULT_BRANCH" &>/dev/null
  git checkout -b "$BRANCH" &>/dev/null
  echo "pull-shark $i [$TS]" >> .pull-shark-log
  git add .pull-shark-log &>/dev/null
  git commit -m "chore: pull shark $i [$TS]" &>/dev/null
  git push origin "$BRANCH" &>/dev/null

  PR_URL=$(gh pr create --title "Pull Shark $i [$TS]" --body "PR $i of $COUNT for Pull Shark achievement." --head "$BRANCH" 2>/dev/null | tail -1)
  PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')
  gh pr merge "$PR_NUM" --merge --delete-branch &>/dev/null

  echo -e "${GREEN}merged${NC}"
  sleep 1
done

git checkout "$DEFAULT_BRANCH" &>/dev/null
git pull origin "$DEFAULT_BRANCH" &>/dev/null

echo ""
echo -e "${GREEN}✅ Pull Shark ($COUNT PRs) complete!${NC}"
echo "Check: https://github.com/$(gh api user -q .login)"
