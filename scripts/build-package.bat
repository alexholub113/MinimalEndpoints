@echo off
REM MinimalEndpoints NuGet Package Generator (Batch Script)
REM Simple script to build and create .nupkg file

setlocal enabledelayedexpansion

set PROJECT_PATH=src\MinimapEndpoints\MinimalEndpoints.csproj
set OUTPUT_PATH=nupkg
set CONFIGURATION=Release

echo =====================================
echo MinimalEndpoints Package Generator
echo =====================================
echo Configuration: %CONFIGURATION%
echo Output Path: %OUTPUT_PATH%
echo Project Path: %PROJECT_PATH%
echo.

REM Check if dotnet is installed
echo Checking .NET installation...
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: .NET CLI not found. Please install .NET 9 SDK.
    echo Download from: https://dotnet.microsoft.com/download/dotnet/9.0
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('dotnet --version') do set DOTNET_VERSION=%%i
echo .NET version: %DOTNET_VERSION%

REM Check if project file exists
if not exist "%PROJECT_PATH%" (
    echo ERROR: Project file not found: %PROJECT_PATH%
    pause
    exit /b 1
)
echo Project file found: %PROJECT_PATH%
echo.

REM Clean previous builds
echo Cleaning previous builds...
if exist "%OUTPUT_PATH%" (
    rmdir /s /q "%OUTPUT_PATH%"
    echo Cleaned output directory: %OUTPUT_PATH%
)

REM Create output directory
mkdir "%OUTPUT_PATH%" 2>nul
echo Created output directory: %OUTPUT_PATH%
echo.

REM Restore packages
echo Restoring NuGet packages...
dotnet restore "%PROJECT_PATH%"
if errorlevel 1 (
    echo ERROR: Package restore failed!
    pause
    exit /b 1
)
echo Package restore completed
echo.

REM Build project
echo Building project...
dotnet build "%PROJECT_PATH%" --configuration %CONFIGURATION% --no-restore
if errorlevel 1 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)
echo Build completed successfully
echo.

REM Create NuGet package
echo Creating NuGet package...
dotnet pack "%PROJECT_PATH%" --configuration %CONFIGURATION% --output "%OUTPUT_PATH%" --no-build
if errorlevel 1 (
    echo ERROR: Package creation failed!
    pause
    exit /b 1
)

echo.
echo ==================================================
echo Package creation completed successfully!
echo ==================================================
echo.

REM Display generated files
echo Generated packages:
dir "%OUTPUT_PATH%\*.nupkg" /b 2>nul
if errorlevel 1 (
    echo ERROR: No package files found in %OUTPUT_PATH%
    pause
    exit /b 1
)

echo.
echo Package files created in: %OUTPUT_PATH%
echo.
echo Next steps:
echo 1. Test locally: dotnet add package MinimalEndpoints --source "%OUTPUT_PATH%"
echo 2. Publish to NuGet: dotnet nuget push "%OUTPUT_PATH%\MinimalEndpoints.*.nupkg" --api-key YOUR_API_KEY --source https://api.nuget.org/v3/index.json
echo.
echo Ready to publish to NuGet!
pause