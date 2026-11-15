#!/bin/sh
set -eu
UPSTREAM_URL="https://github.com/netsurf-browser/netsurf.git"
UPSTREAM_BRANCH="master"

git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UPSTREAM_URL"
git fetch upstream

echo "== upstream ahead by =="
git log --oneline HEAD..upstream/$UPSTREAM_BRANCH | head -40 || true
echo "== we are ahead by =="
git log --oneline upstream/$UPSTREAM_BRANCH..HEAD | head -40 || true

if [ "${1:-}" = "--merge" ]; then
  git merge "upstream/$UPSTREAM_BRANCH" || {
    echo "conflict: resolve, then update PATCHES.md"
    exit 1
  }
  echo "merged. Run tools/build.sh for all frontends, then the corpus."
fi
