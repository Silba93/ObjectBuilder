@echo off
setlocal

set JAVA=C:\Program Files\Java\jre1.8.0_461\bin\java.exe
set MXMLC=C:\Users\hypo_\Desktop\adobe flex\lib\mxmlc.jar
set FLEXLIB=C:\Users\hypo_\Desktop\adobe flex\frameworks
set AIRLIBS=C:\MoonshineSDKs\Flex_SDK\Flex_4.16.1_AIR_32.0\frameworks\libs\air
set ADT=C:\Adobe Air\AIRSDK_51.2.1\bin\adt.bat
set KEYSTORE=object_builder.p12
set STOREPASS=objectbuilder

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
