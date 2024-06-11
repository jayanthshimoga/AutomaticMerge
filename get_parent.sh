#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Fetch all branches from the remote
git fetch --all

#test
# Define the current branch
CURRENT_BRANCH="feature-rebase1-child2"  # Replace this with your current branch or make it dynamic

# Remove trailing whitespace
CURRENT_BRANCH=$(echo "$CURRENT_BRANCH" | sed 's/[[:space:]]*$//')

echo "Finding exact parent branch for $CURRENT_BRANCH..."

# Ensure the current branch exists
if ! git show-ref --verify --quiet "refs/remotes/origin/$CURRENT_BRANCH"; then
  echo "Branch $CURRENT_BRANCH does not exist or is not a valid branch."
  exit 1
fi

# Checkout the branch
git checkout "$CURRENT_BRANCH"

# Function to find the closest parent branch
find_parent_branch() {
  local current_branch=$1

  # List all branches that are not the current branch
  local parent_branch=$(git show-branch -a | sed "s/].*//" | grep "\*" | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed "s/^.*\[//")

  if [ -n "$parent_branch" ]; then
    echo "$parent_branch"
  else
    echo "No parent branch found for $current_branch"
    exit 1
  fi
}

# Find the exact parent branch
EXACT_PARENT_BRANCH=$(find_parent_branch "$CURRENT_BRANCH")
echo "Exact parent branch for $CURRENT_BRANCH is $EXACT_PARENT_BRANCH"
echo "parent_branch=$EXACT_PARENT_BRANCH"
