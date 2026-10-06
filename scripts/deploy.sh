#!/bin/bash
set -euo pipefail
GIT_BRANCH=$(git symbolic-ref -q HEAD)
GIT_REPO_URL=$(git config --get remote.origin.url)
BUILD_FOLDER=".build"

# Ensure there are no local changes
if ! git diff-index --quiet HEAD --; then
  echo "ERROR: Local file changes. Commit or stash them first! Aborting!" && exit 1
fi

# Build
# npm run build

# Deploy & setup
mkdir $BUILD_FOLDER
cd $BUILD_FOLDER
git init .
git remote add origin $GIT_REPO_URL
git checkout -b gh-pages || (echo "Cannot chekout gh-pages branch!" && exit 1)
# git pull origin gh-pages --rebase || (echo "Unable to pull remote changes on gh-pages branch!" && exit 1)

# Add files and CNAME if present
cp -r ../* .
cp ../CNAME .
rm -rf scripts

# Ensure static assets can be served properly (GitHub thing)
touch .nojekyll

git add .
git commit -am "Static site deploy"

# actions/checkout stores its token on the parent repo only. This deploy
# uses a fresh repo in .build, so CI pushes need the token on this remote.
if [ -n "${GITHUB_TOKEN:-}" ]; then
  git remote set-url origin "https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
fi

git push origin gh-pages --force
cd ..
rm -rf $BUILD_FOLDER

# Restore
git checkout main
