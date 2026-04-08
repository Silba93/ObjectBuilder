# Building ObjectBuilder

## Prerequisites

| Tool | Path |
|------|------|
| Java 8 JRE | `C:\Program Files\Java\jre1.8.0_461` |
| Apache Flex 4.16.1 SDK | `C:\Users\hypo_\Desktop\adobe flex` |
| Moonshine AIR SDK (for AIR libs) | `C:\MoonshineSDKs\Flex_SDK\Flex_4.16.1_AIR_32.0` |
| Adobe AIR SDK 51.2.1 (for packaging) | `C:\Adobe Air\AIRSDK_51.2.1` |

> **Why two SDKs?** The Moonshine SDK ships with Apache Royale's `mxmlc` (v2.0.0) which lacks locale support. The desktop Apache Flex 4.16.1 SDK has the real `mxmlc` but is missing `airglobal.swc`. The build uses the real `mxmlc.jar` from the desktop SDK with the AIR libs from the Moonshine SDK.
>
> `airglobal.swc` was manually copied from the Moonshine SDK into `C:\Users\hypo_\Desktop\adobe flex\frameworks\libs\air\` as a one-time setup step.

## Release build

Run `build.bat` from the project root:

```bat
build.bat
```

This does three things:
1. Compiles `src/ObjectBuilderWorker.as` → `workerswfs/ObjectBuilderWorker.swf`
2. Compiles `src/ObjectBuilder.mxml` → `bin-debug/ObjectBuilder.swf`
3. Packages a captive runtime Windows bundle → `bin/ObjectBuilder/`

Output: `bin\ObjectBuilder\ObjectBuilder.exe`

## Debug build (run without packaging)

Compile the SWFs (same as steps 1–2 above, but omit `-debug=false` or keep it — both work for `adl`), then launch with ADL:

```bat
"C:\MoonshineSDKs\Flex_SDK\Flex_4.16.1_AIR_32.0\bin\adl.exe" bin-debug\ObjectBuilder-app.xml
```

## Code signing

The release build is signed with `object_builder.p12` (password: `objectbuilder`). This is a self-signed certificate generated with:

```bat
"C:\MoonshineSDKs\Flex_SDK\Flex_4.16.1_AIR_32.0\bin\adt.bat" -certificate -cn "ObjectBuilder" -ou "OTTools" -o "ObjectBuilder" -c "US" 2048-RSA object_builder.p12 objectbuilder
```

The `.p12` file is **not committed** to the repository. Keep it in the project root when building.
