@echo off
"C:\Program Files (x86)\Steam\steamapps\common\skyrim\Papyrus Compiler\PapyrusCompiler.exe" "%1\scripts\Source" -all -f="TESV_Papyrus_Flags.flg" -i="%1\scripts\Source;C:\Program Files (x86)\Steam\steamapps\common\skyrim\Data\Scripts\source;%userprofile%\Dropbox\SkyrimMod\MYC\dist\dep\scripts\Source\effheaders" -o="%1\scripts"
IF %ERRORLEVEL% NEQ 0 pause
