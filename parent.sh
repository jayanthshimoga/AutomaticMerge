#!/usr/local/bin/bash

# git show-branch supports 29 branches; reserve 1 for current branch
GIT_SHOW_BRANCH_MAX=28

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if (( $? != 0 )); then
    echo "Failed to determine git branch; is this a git repo?" >&2
    exit 1
fi

# TESTS

##
# Given Params:
#   EXCEPT : $1
#   VALUES : $2..N
#
# Return all values except EXCEPT, in order.
#
function valuesExcept() {
    local except=$1 ; shift
    for value in "$@"; do
        if [[ "$value" != "$except" ]]; then
            echo $value
        fi
    done
}


##
# Given Params:
#   BASE_BRANCH : $1           : base branch; default is current branch
#   BRANCHES    : [ $2 .. $N ] : list of unique branch names (no duplicates);
#                                perhaps possible parents.
#                                Default is all branches except base branch.
#
# For the most recent commit in the commit history for BASE_BRANCH that is
# also in the commit history of at least one branch in BRANCHES: output all
# BRANCHES that share that commit in their commit history.
#
function nearestCommonBranches() {
    local BASE_BRANCH
    if [[ -z "${1+x}" || "$1" == '.' ]]; then
        BASE_BRANCH="$CURRENT_BRANCH"
    else
        BASE_BRANCH="$1"
    fi

    shift
    local -a CANDIDATES
    if [[ -z "${1+x}" ]]; then
        CANDIDATES=( $(git rev-parse --symbolic --branches) )
    else
        CANDIDATES=("$@")
    fi
    local BRANCHES=( $(valuesExcept "$BASE_BRANCH" "${CANDIDATES[@]}") )

    local BRANCH_COUNT=${#BRANCHES[@]}
    if (( $BRANCH_COUNT > $GIT_SHOW_BRANCH_MAX )); then
        echo "Too many branches: limit $GIT_SHOW_BRANCH_MAX" >&2
        exit 1
    fi

    local MAP=( $(git show-branch --topo-order "${BRANCHES[@]}" "$BASE_BRANCH" \
                    | tail -n +$(($BRANCH_COUNT+3)) \
                    | sed "s/ \[.*$//" \
                    | sed "s/ /_/g" \
                    | sed "s/*/+/g" \
                    | egrep '^_*[^_].*[^_]$' \
                    | head -n1 \
                    | sed 's/\(.\)/\1\n/g'
          ) )

    for idx in "${!BRANCHES[@]}"; do
        ## to include "merge", symbolized by '-', use
        ## ALT: if [[ "${MAP[$idx]}" != "_" ]]
        if [[ "${MAP[$idx]}" == "+" ]]; then
            echo "${BRANCHES[$idx]}"
        fi
    done
}

# Usage: gitr [ baseBranch [branchToConsider]* ]
#   baseBranch: '.' (no quotes needed) corresponds to default current branch
#   branchToConsider* : list of unique branch names (no duplicates);
#                        perhaps possible (bias?) parents.
#                        Default is all branches except base branch.
nearestCommonBranches "${@}"
