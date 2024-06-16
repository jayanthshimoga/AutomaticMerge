# Ensure we have the latest information
git fetch --all

# Define the current branch
CURRENT_BRANCH="feature-rebase1-child2"  # Replace this with your current branch or make it dynamic

# Remove trailing whitespace
CURRENT_BRANCH=$(echo "$CURRENT_BRANCH" | sed 's/[[:space:]]*$//')

echo "Finding exact parent branch for $CURRENT_BRANCH..."
# Set the current branch (replace 'current-branch-name' with your actual branch name)
CURRENT_BRANCH="$1"

# Check out the branch to ensure it's the current context
git checkout "$CURRENT_BRANCH"

# Use git show-branch to find the parent branch
PARENT_BRANCH=$(git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//')

# Output the parent branch
echo "Parent branch of $CURRENT_BRANCH: $PARENT_BRANCH"
