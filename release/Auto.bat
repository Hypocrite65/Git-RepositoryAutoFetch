@echo off

rem This is a BAT file to run a shell script at a specific time.

rem Set the time you want to run the shell script.
rem In this example, the shell script will be run at 10:00 AM.
set time=12:00 
set CurrentPath=%cd%

rem Set the path to the shell script.
rem In this example, the shell script is located in the current directory.
set script_path=%CurrentPath%\AutoFetch.sh

rem Run the `at` command to schedule the shell script to run at the specified time.
rem at %time% %script_path%
schtasks.exe /create /sc DAILY /tn "GitRepositoryAutoFetch" /tr %script_path% /st %time%
