#!/bin/bash

# Check if a commit message was passed as an argument
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 <commit_message>"
  exit 1
fi

# Add all changes to the staging area
git add .

# Commit the changes with the provided message
git commit -m "$1"

echo "Changes committed with message: $1"
