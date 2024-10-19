@echo off
SETLOCAL EnableDelayedExpansion

REM Fetch all remote branches
git fetch --all

REM List remote branches and process each one
FOR /F "tokens=*" %%i IN ('git branch -r ^| findstr /V /C:"->"') DO (
    SET remote=%%i
    REM Remove ANSI escape sequences with PowerShell
    FOR /F "delims=" %%a IN ('echo !remote! ^| powershell -Command "$input -replace '\x1B\[[0-9;]*[a-zA-Z]', ''"') DO SET clean_remote=%%a
    REM Remove 'origin/' from branch name for local branch
    SET local_branch=!clean_remote:origin/ =!
    REM Track the branch
    git branch --track !local_branch! !clean_remote!
)

REM Pull all updates
git pull --all

ENDLOCAL
