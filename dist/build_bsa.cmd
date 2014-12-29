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
echo Recompiling scripts...
del %DATA%\scripts\*.pex
call build_ScriptCompile.bat %DATA%
echo Creating file list...
del %DATA%\*.bsa
del %DATA%\*.bsl
attrib /s +h %DATA%\skse\*
attrib +h %DATA%\skse
for /f "tokens=%I%* delims=\" %%A in ('dir %DATA%\* /a-D-H /b /s') DO echo %%B >> filelist.txt
attrib -h %DATA%\skse
attrib /s -h %DATA%\skse\*
echo Building archive...
Archive.exe bsascript.txt
endlocal
goto End
:TooManyLevels
echo Couldn't find Data 12 levels deep, aborting!
:End