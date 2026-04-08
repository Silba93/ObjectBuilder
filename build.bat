@echo off
setlocal EnableExtensions

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

if exist "%ROOT%\build.config.bat" call "%ROOT%\build.config.bat"

if not defined JAVA (
  if defined JAVA_HOME set "JAVA=%JAVA_HOME%\bin\java.exe"
)
if not defined FLEX_SDK if defined APACHE_FLEX_HOME set "FLEX_SDK=%APACHE_FLEX_HOME%"
if not defined MXMLC if defined FLEX_SDK set "MXMLC=%FLEX_SDK%\lib\mxmlc.jar"
if not defined FLEXLIB if defined FLEX_SDK set "FLEXLIB=%FLEX_SDK%\frameworks"

if not defined AIR_SDK if defined AIR_HOME set "AIR_SDK=%AIR_HOME%"
if not defined ADT if defined AIR_SDK set "ADT=%AIR_SDK%\bin\adt.bat"

if not defined AIRLIBS if defined AIR_LIBS set "AIRLIBS=%AIR_LIBS%"
if not defined AIRLIBS if defined AIR_SDK set "AIRLIBS=%AIR_SDK%\frameworks\libs\air"

if not defined KEYSTORE set "KEYSTORE=%ROOT%\object_builder.p12"
if not defined STOREPASS set "STOREPASS=objectbuilder"

if not defined JAVA ( echo JAVA not set. Set JAVA or JAVA_HOME in build.config.bat. & exit /b 1 )
if not exist "%JAVA%" ( echo JAVA not found at "%JAVA%". & exit /b 1 )
if not defined MXMLC ( echo MXMLC not set. Set MXMLC or FLEX_SDK in build.config.bat. & exit /b 1 )
if not exist "%MXMLC%" ( echo MXMLC jar not found at "%MXMLC%". & exit /b 1 )
if not defined FLEXLIB ( echo FLEXLIB not set. Set FLEXLIB or FLEX_SDK in build.config.bat. & exit /b 1 )
if not exist "%FLEXLIB%" ( echo FLEXLIB not found at "%FLEXLIB%". & exit /b 1 )
if not defined AIRLIBS ( echo AIRLIBS not set. Set AIRLIBS or AIR_SDK in build.config.bat. & exit /b 1 )
if not exist "%AIRLIBS%" ( echo AIRLIBS not found at "%AIRLIBS%". & exit /b 1 )
if not defined ADT ( echo ADT not set. Set ADT or AIR_SDK in build.config.bat. & exit /b 1 )
if not exist "%ADT%" ( echo ADT not found at "%ADT%". & exit /b 1 )
if not defined KEYSTORE ( echo KEYSTORE not set. & exit /b 1 )
if not exist "%KEYSTORE%" ( echo KEYSTORE not found at "%KEYSTORE%". & exit /b 1 )
if not defined STOREPASS ( echo STOREPASS not set. & exit /b 1 )

echo [1/3] Compiling worker...
"%JAVA%" -Xms32m -Xmx512m -Dsun.io.useCanonCaches=false -Djava.util.Arrays.useLegacyMergeSort=true -jar "%MXMLC%" "+flexlib=%FLEXLIB%" +configname=air --source-path+=src --library-path+=libs "--library-path+=%AIRLIBS%" -locale=en_US,es_ES,pt_BR "-source-path=locale/{locale}" -allow-source-path-overlap=true -debug=false --output=workerswfs/ObjectBuilderWorker.swf src/ObjectBuilderWorker.as
if errorlevel 1 ( echo Worker compile failed. & exit /b 1 )

echo [2/3] Compiling main app...
"%JAVA%" -Xms32m -Xmx512m -Dsun.io.useCanonCaches=false -Djava.util.Arrays.useLegacyMergeSort=true -jar "%MXMLC%" "+flexlib=%FLEXLIB%" +configname=air --source-path+=src --library-path+=libs "--library-path+=%AIRLIBS%" -locale=en_US,es_ES,pt_BR "-source-path=locale/{locale}" -allow-source-path-overlap=true -debug=false --output=bin-debug/ObjectBuilder.swf src/ObjectBuilder.mxml
if errorlevel 1 ( echo Main app compile failed. & exit /b 1 )

echo [3/3] Packaging bundle...
if exist bin\ObjectBuilder rmdir /s /q bin\ObjectBuilder
call "%ADT%" -package -storetype pkcs12 -keystore %KEYSTORE% -storepass %STOREPASS% -tsa https://freetsa.org/tsr -target bundle bin/ObjectBuilder bin-debug/ObjectBuilder-app.xml -C bin-debug ObjectBuilder.swf icon config -C . workerswfs
if errorlevel 1 ( echo Packaging failed. & exit /b 1 )

echo.
echo Build complete: bin\ObjectBuilder\ObjectBuilder.exe
endlocal
