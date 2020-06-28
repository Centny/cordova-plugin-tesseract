cd %~dp0
set install_dir=%1\windows\
msbuild tessjs\tessjs.csproj /t:Restore /t:Build /p:Configuration="Release" /p:Platform="x86" /p:BuildProjectReferences=true
msbuild tessjs\tessjs.csproj /t:Restore /t:Build /p:Configuration="Release" /p:Platform="x64" /p:BuildProjectReferences=true
mkdir %install_dir%\x86\uwp\
xcopy /y /d Release\x86\* %install_dir%\x86\uwp\
mkdir -p %install_dir%\x64\uwp\
xcopy /y /d Release\x64\* %install_dir%\x64\uwp\
