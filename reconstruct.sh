#!/bin/bash

set -euo pipefail

# Get on master
git switch master

# Make sure we're locally all up to date.
git pull origin master

# Rename master to main locally.
git branch -m master main

# Push main up to Github. This leaves master intact on origin.
git push -u origin main

# Interactive bit. User needs to go reconfigure github.
url=$(git config --get remote.origin.url)
base="${url#*/}"
repo="${base%.git}"
base2="${url%/*}"
org_or_user="${base2#*:}"

echo "Please reset the default branch and remove any branch protection rules on master at:"
echo ""
echo "  https://github.com/${org_or_user}/${repo}/settings/branches"
echo ""

read -p "Is the default branch on Github set correctly? " -r yesno
if [[ $(echo "$yesno" | tr '[:upper:]' '[:lower:]') != "yes" ]]; then
    exit 1
fi

read -p "Is the master branch now unprotected (i.e. pushes are allowed)? " -r yesno
if [[ $(echo "$yesno" | tr '[:upper:]' '[:lower:]') != "yes" ]]; then
    exit 1
fi

# Make our default branch on origin the default from Github. Might now
# be main or might be something else like staging.
git remote set-head origin --auto

# Another interactive bit. Need to fix the base branch of any open PRs.
echo "You should also change the base branch of any open PRs by clicking the"
echo "Edit button on the PR like you were going to edit the subject line."
echo "Then the master in 'wants to merge n commits into master from ...'"
echo "will change to a drop down from which you can select main."
echo ""
echo "  https://github.com/${org_or_user}/${repo}/pulls"
echo ""

read -p "Have you fixed the base of all your PRs? " -r yesno
if [[ $(echo "$yesno" | tr '[:upper:]' '[:lower:]') != "yes" ]]; then
    exit 1
fi

# Delete the master branch from origin.
git push origin --delete master

# And some other things that may need to be changed
echo "And you may need to adjust branch names in Travis and/or Jenkins."
echo
echo "Also think about whether there are docs (README's, Confluence, etc.) "
echo "that should be updated."
