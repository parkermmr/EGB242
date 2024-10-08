@echo off

REM Check if a commit message was provided
IF "%~1"=="" (
    echo Usage: %0 "commit_message"
    exit /b 1
)

REM Add all changes to the staging area
git add .

REM Commit the changes with the provided message
git commit -m "%~1"

echo Changes committed with message: %~1
