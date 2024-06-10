#!/bin/bash

# Set the current branch
CURRENT_BRANCH=$(echo "origin/rebase-child-1" | sed 's/[[:space:]]*$//')

# Ensure the branch name is valid and exists
if ! git rev-parse --verify "$CURRENT_BRANCH" >/dev/null 2>&1; then
  echo "Branch $CURRENT_BRANCH does not exist or is not a valid branch."
  exit 1
fi

echo "Finding exact parent branch for $CURRENT_BRANCH..."

# Fetch all branches to ensure we have the latest information
git fetch --all --prune

# Function to find the closest parent branch
find_parent_branch() {
  local current_branch=$1
  shift
  local potential_parents=("$@")
  local best_parent=""
  local best_base=""
  local earliest_date=""

  for parent in "${potential_parents[@]}"; do
    merge_base=$(git merge-base "$current_branch" "$parent")
    
    if [ -z "$merge_base" ]; then
      continue
    fi

    merge_base_date=$(git show -s --format=%ci "$merge_base")

    if [ -z "$earliest_date" ] || [[ "$merge_base_date" > "$earliest_date" ]]; then
      best_parent="$parent"
      best_base="$merge_base"
      earliest_date="$merge_base_date"
    fi
  done

  if [ -n "$best_parent" ]; then
    echo "$best_parent"
  else
    echo "No parent branch found for $current_branch"
    exit 1
  fi
}

# Get the list of all branches except the current one
POTENTIAL_PARENTS=$(git for-each-ref --format='%(refname:short)' refs/heads/ | grep -v "^$CURRENT_BRANCH$")

# Convert potential parents to array
POTENTIAL_PARENTS_ARRAY=($POTENTIAL_PARENTS)

# Find the exact parent branch
EXACT_PARENT_BRANCH=$(find_parent_branch "$CURRENT_BRANCH" "${POTENTIAL_PARENTS_ARRAY[@]}")
echo "Exact parent branch for $CURRENT_BRANCH is $EXACT_PARENT_BRANCH"
echo "parent_branch=$EXACT_PARENT_BRANCH"
