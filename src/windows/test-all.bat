@echo off
cmd /c test-arch.bat x86 Debug
if %errorlevel% neq 0 pause
cmd /c test-arch.bat x86 Release
if %errorlevel% neq 0 pause
cmd /c test-arch.bat x64 Debug
if %errorlevel% neq 0 pause
cmd /c test-arch.bat x64 Release
if %errorlevel% neq 0 pause
echo all done
pause