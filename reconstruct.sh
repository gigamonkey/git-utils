#!/bin/bash

set -euo pipefail

# Get on master
git switch master

# Make sure we're locally all up to date.
git pull origin master

# Rename master to main locally.
git branch -m master main

# Push main up to Github. This leaves master intact] on origin.
git push -u origin main

# Interactive bit. User needs to go reconfigure github.
url=$(git config --get remote.origin.url)
base="${url#*/}"
repo="${base%.git}"

echo "Please reset the default branch and remove any branch protection rules on master at:"
echo ""
echo "  https://github.com/democrats/${repo}/settings/branches"
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

# Delete the master branch from origin.
git push origin --delete master

# PRs may need to be rebased
echo "If you have open PRs against master, you can change them to be based on main."

# And some other things that may need to be changed
echo "And you may need to adjust branch names in Travis and/or Jenkins."
echo
echo "Also think about whether there are docs (README's, Confluence, etc.) "
echo "that should be updated."
