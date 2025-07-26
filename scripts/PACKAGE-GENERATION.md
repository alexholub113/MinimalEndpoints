# NuGet Package Generation Guide

This document explains how to generate .nupkg files for the MinimalEndpoints library.

## Available Scripts

### 1. PowerShell Script (Recommended for Windows)
**File:** `build-package.ps1`

**Features:**
- ? Comprehensive error checking
- ? Version management
- ? Clean builds
- ? Detailed output
- ? Package verification

**Usage:**
```powershell
# Basic build
.\build-package.ps1

# Build with specific version
.\build-package.ps1 -Version "1.0.1"

# Clean build with verbose output
.\build-package.ps1 -Clean -Verbose

# Custom configuration and output path
.\build-package.ps1 -Configuration "Debug" -OutputPath "packages"
```

**Parameters:**
- `-Configuration`: Build configuration (Release/Debug) - Default: Release
- `-OutputPath`: Output directory for packages - Default: nupkg
- `-Version`: Update project version before building
- `-Clean`: Clean previous builds
- `-Verbose`: Detailed build output

### 2. Batch Script (Windows Command Prompt)
**File:** `build-package.bat`

**Usage:**
```cmd
build-package.bat
```

Simple script for users who prefer batch files over PowerShell.

### 3. Shell Script (Linux/macOS)
**File:** `build-package.sh`

**Usage:**
```bash
# Make executable
chmod +x build-package.sh

# Run script
./build-package.sh
```

Cross-platform script with colored output for Unix-based systems.

### 4. Quick Pack Script
**File:** `quick-pack.ps1`

**Usage:**
```powershell
# Quick build
.\quick-pack.ps1

# Build with version update
.\quick-pack.ps1 -Version "1.0.2"
```

Minimal script for fast package generation.

## Manual Commands

If you prefer to run commands manually:

### Basic Package Creation
```bash
# Navigate to project directory
cd src/MinimapEndpoints

# Create package
dotnet pack --configuration Release --output ../../nupkg
```

### With Version Update
```bash
# Build and pack with specific output
dotnet pack MinimalEndpoints.csproj -c Release -o ../../nupkg -p:Version=1.0.1
```

### Full Build Process
```bash
# 1. Clean previous builds
dotnet clean

# 2. Restore packages
dotnet restore

# 3. Build project
dotnet build --configuration Release

# 4. Create package
dotnet pack --configuration Release --output nupkg --no-build
```

## Output Files

After running any of the scripts, you'll find these files in the `nupkg` directory:

- **MinimalEndpoints.x.x.x.nupkg** - Main package file
- **MinimalEndpoints.x.x.x.snupkg** - Symbol package (for debugging)

## Package Verification

### Inspect Package Contents
```bash
# Extract and view package contents (requires 7-zip or similar)
7z l nupkg/MinimalEndpoints.1.0.0.nupkg

# Or use dotnet CLI
dotnet nuget locals global-packages --list
```

### Test Package Locally
```bash
# Add package from local folder
dotnet add package MinimalEndpoints --source "./nupkg"

# Or test in new project
dotnet new console -n TestProject
cd TestProject
dotnet add package MinimalEndpoints --source "../nupkg"
```

## Publishing to NuGet

### Prerequisites
1. Create account at [nuget.org](https://nuget.org)
2. Generate API key from your account settings
3. Install/update dotnet CLI

### Publish Command
```bash
# Publish main package
dotnet nuget push nupkg/MinimalEndpoints.1.0.0.nupkg --api-key YOUR_API_KEY --source https://api.nuget.org/v3/index.json

# Publish with symbols
dotnet nuget push nupkg/MinimalEndpoints.1.0.0.snupkg --api-key YOUR_API_KEY --source https://api.nuget.org/v3/index.json
```

### Environment Variable (Recommended)
```bash
# Set API key as environment variable
# Windows
set NUGET_API_KEY=your_api_key_here

# Linux/macOS
export NUGET_API_KEY=your_api_key_here

# Then publish without exposing key
dotnet nuget push nupkg/MinimalEndpoints.1.0.0.nupkg --api-key $NUGET_API_KEY --source https://api.nuget.org/v3/index.json
```

## Troubleshooting

### Common Issues

**1. Project file not found**
```
Error: Project file not found: src\MinimapEndpoints\MinimalEndpoints.csproj
```
- Ensure you're running the script from the repository root
- Check if the project path has changed

**2. .NET version mismatch**
```
Warning: This project targets .NET 9. Current version is 8.x.x
```
- Install .NET 9 SDK from [dotnet.microsoft.com](https://dotnet.microsoft.com/download/dotnet/9.0)

**3. Package already exists**
```
Error: Package 'MinimalEndpoints 1.0.0' already exists
```
- Increment the version number in MinimalEndpoints.csproj
- Or use `--skip-duplicate` flag

**4. Missing README in package**
```
Warning: The referenced file 'README.md' does not exist
```
- Ensure README.md exists in the repository root
- Check the project file's PackageReadmeFile setting

### Script Permissions

**PowerShell Execution Policy:**
```powershell
# Check current policy
Get-ExecutionPolicy

# Allow script execution (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Shell Script Permissions:**
```bash
# Make script executable
chmod +x build-package.sh
```

## Version Management

The project version is defined in `src/MinimapEndpoints/MinimalEndpoints.csproj`:

```xml
<Version>1.0.0</Version>
<AssemblyVersion>1.0.0.0</AssemblyVersion>
<FileVersion>1.0.0.0</FileVersion>
```

### Semantic Versioning
- **Major.Minor.Patch** (e.g., 1.0.0)
- **Major**: Breaking changes
- **Minor**: New features (backward compatible)
- **Patch**: Bug fixes (backward compatible)

### Update Version
1. Edit the .csproj file manually
2. Use the `-Version` parameter in PowerShell scripts
3. Use dotnet CLI: `dotnet pack -p:Version=1.0.1`

## Continuous Integration

For automated builds, see `.github/workflows/publish-nuget.yml` for GitHub Actions integration.

## Support

If you encounter issues:
1. Check this documentation
2. Review the error messages carefully
3. Ensure all prerequisites are installed
4. Create an issue in the repository