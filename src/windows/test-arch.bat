@echo off
msbuild tessrawc\tessrawc.vcxproj /t:Clean,Build /p:Configuration=%2 /p:Platform=%1 /p:BuildProjectReferences=true /p:OutDir=..\console\bin\%1\%2
if %errorlevel% neq 0 exit /b %errorlevel%
msbuild console\console.csproj  /t:Clean,Build /p:Configuration=%2 /p:Platform=%1 /p:BuildProjectReferences=true /p:OutputPath=..\console\bin\%1\%2
if %errorlevel% neq 0 exit /b %errorlevel%
cd console\bin\%1\%2
dumpbin tessrawc.dll /headers | find "machine"
dumpbin console.exe /headers | find "machine"
echo start testing on %1 %2
console.exe
if %errorlevel% neq 0 exit /b %errorlevel%
cd ..\..\..\