@echo off
set DATESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set DATESTAMP=%DATESTAMP: =0%
cd /d "%~dp0"
git add -A
git commit -m "Backup: %DATESTAMP%"
git push origin master