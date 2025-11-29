@echo off
REM ============================================================
REM SSH Key Generator Script (Windows Batch)
REM This script creates a new SSH key pair with a custom name
REM and comment inside %USERPROFILE%\.ssh
REM ============================================================

setlocal enabledelayedexpansion

REM --- Default settings ---
set "sshDir=%USERPROFILE%\.ssh"
set "keyType=ed25519"
set "kdfRounds=100"
set "defaultName=id_%keyType%"

REM --- Ask for user input ---
set /p serverName=Enter a name for the server/project (e.g., server1): 
if "%serverName%"=="" set "serverName=default"

REM --- Final key file path ---
set "keyFile=%sshDir%\%defaultName%_%serverName%"

REM --- Create .ssh directory if not exists ---
if not exist "%sshDir%" (
    echo [*] Creating %sshDir% directory...
    mkdir "%sshDir%"
)

REM --- Check if the key already exists ---
if exist "%keyFile%" (
    echo [!] Key already exists: %keyFile%
    echo     Please choose a different name or backup/remove the old key.
    pause
    exit /b
)

REM --- Generate SSH key pair ---
echo [*] Generating new SSH key...
ssh-keygen -t %keyType% -a %kdfRounds% -f "%keyFile%" -C "%serverName%_key"

REM --- Output results ---
echo [*] SSH key created successfully!
echo     Private key: %keyFile%
echo     Public key : %keyFile%.pub
echo.
echo [!] IMPORTANT: Keep your private key secure. Share only the public key.

endlocal
pause
