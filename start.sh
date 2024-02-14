#!/bin/sh
# shellcheck shell=sh

# Check if node is installed
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js is not installed. Please install it from https://nodejs.org/"
    exit 1
fi

# Check if yarn is installed
if ! command -v yarn >/dev/null 2>&1; then
    echo "yarn is not installed. After installing Node.js, please install yarn from https://classic.yarnpkg.com/en/docs/install/"
    exit 1
fi

# Check if git is installed
if ! command -v git > /dev/null 2>&1; then
    echo "git is not installed. Please install it from https://git-scm.com/downloads"
    exit 1
fi

# Prompt user to update
printf "Before running Omnitool, do you want to update the project from Github first? (y/n) " && read -r REPLY
echo  # move to a new line

if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
    # Pull latest changes from git
    if ! output=$(git pull --verbose); then
        echo "Error occurred during git pull: $output" ; echo "Exiting."
        exit 1
    fi
fi

# Run yarn commands
yarn
yarn start -u -rb "$@"  # Pass all arguments to yarn start
