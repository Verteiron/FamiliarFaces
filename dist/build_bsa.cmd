@echo off
setlocal
set I=0
echo Finding data directory...
:TryAgain
set /A I += 1
if %I% GTR 12 goto TooManyLevels
for /f "tokens=%I% delims=\" %%A in ('dir Data\* /a-D /b /s') DO set DATA=%%A
if /I not %DATA%==data goto TryAgain
if exist filelist.txt del filelist.txt
echo Creating file list...
for /f "tokens=%I%* delims=\" %%A in ('dir Data\* /a-D /b /s') DO echo %%B >> filelist.txt
echo Building archive...
Archive.exe bsascript.txt
endlocal
goto End
:TooManyLevels
echo Couldn't find Data 12 levels deep, aborting!
:End