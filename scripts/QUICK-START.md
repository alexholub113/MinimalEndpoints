# MinimalEndpoints - Quick NuGet Package Commands

## ?? Quick Start (One Command)

```bash
# Generate .nupkg file
dotnet pack src/MinimapEndpoints/MinimalEndpoints.csproj --configuration Release --output nupkg
```

## ?? Available Scripts

| Script | Platform | Description |
|--------|----------|-------------|
| `build-package.ps1` | Windows (PowerShell) | Full-featured script with version management |
| `build-package.bat` | Windows (CMD) | Simple batch script |
| `build-package.sh` | Linux/macOS | Cross-platform shell script |
| `quick-pack.ps1` | Windows (PowerShell) | Minimal script for fast builds |

## ?? Usage Examples

### PowerShell (Recommended)
```powershell
# Basic build
.\build-package.ps1

# Build with version update
.\build-package.ps1 -Version "1.0.1"

# Quick build
.\quick-pack.ps1
```

### Command Line
```cmd
# Windows
build-package.bat

# Linux/macOS
./build-package.sh
```

### Manual Commands
```bash
# Full process
dotnet clean src/MinimapEndpoints/MinimalEndpoints.csproj
dotnet restore src/MinimapEndpoints/MinimalEndpoints.csproj
dotnet build src/MinimapEndpoints/MinimalEndpoints.csproj --configuration Release
dotnet pack src/MinimapEndpoints/MinimalEndpoints.csproj --configuration Release --output nupkg --no-build

# Or single command
dotnet pack src/MinimapEndpoints/MinimalEndpoints.csproj -c Release -o nupkg
```

## ?? Output

Files generated in `nupkg/` directory:
- `MinimalEndpoints.1.0.0.nupkg` - Main package
- `MinimalEndpoints.1.0.0.snupkg` - Symbol package

## ?? Publish to NuGet

```bash
# Set API key (get from nuget.org)
set NUGET_API_KEY=your_api_key_here

# Publish
dotnet nuget push nupkg/MinimalEndpoints.1.0.0.nupkg --api-key %NUGET_API_KEY% --source https://api.nuget.org/v3/index.json
```

## ? Quick Test

```bash
# Test package locally
dotnet new console -n TestApp
cd TestApp
dotnet add package MinimalEndpoints --source "../nupkg"
```

---
?? **For detailed instructions, see [PACKAGE-GENERATION.md](PACKAGE-GENERATION.md)**