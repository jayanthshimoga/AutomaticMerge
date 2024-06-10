# Fetch all branches
git fetch --all --prune

# Ensure the branch exists
CURRENT_BRANCH="rebase-1"
if ! git rev-parse --verify $CURRENT_BRANCH >/dev/null 2>&1; then
  echo "Branch $CURRENT_BRANCH does not exist."
  exit 1
fi

# List all branches except the current one
POTENTIAL_PARENTS=$(git for-each-ref --format='%(refname:short)' refs/heads/ | grep -v "^$CURRENT_BRANCH$")
echo "Potential parent branches: $POTENTIAL_PARENTS"

BEST_PARENT=""
BEST_BASE=""
for PARENT in $POTENTIAL_PARENTS; do
  MERGE_BASE=$(git merge-base $CURRENT_BRANCH $PARENT)
  echo "Common ancestor of $CURRENT_BRANCH and $PARENT is $MERGE_BASE"

  if [ -z "$BEST_BASE" ] || git log --oneline $MERGE_BASE..$CURRENT_BRANCH | grep -q '.'; then
    BEST_PARENT=$PARENT
    BEST_BASE=$MERGE_BASE
  fi
done

echo "Best parent branch: $BEST_PARENT"