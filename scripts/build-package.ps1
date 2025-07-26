# MinimalEndpoints NuGet Package Generator
# This script builds and creates the .nupkg file for MinimalEndpoints

param(
    [Parameter(Mandatory=$false)]
    [string]$Configuration = "Release",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "nupkg",
    
    [Parameter(Mandatory=$false)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

$ProjectPath = "src\MinimapEndpoints\MinimalEndpoints.csproj"
$SolutionRoot = $PSScriptRoot

Write-Host "MinimalEndpoints NuGet Package Generator" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Configuration: $Configuration" -ForegroundColor Cyan
Write-Host "Output Path: $OutputPath" -ForegroundColor Cyan
Write-Host "Project Path: $ProjectPath" -ForegroundColor Cyan

# Verify .NET 9 is installed
Write-Host "`nChecking .NET installation..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host "? .NET version: $dotnetVersion" -ForegroundColor Green
    
    if (-not $dotnetVersion.StartsWith("9.")) {
        Write-Warning "This project targets .NET 9. Current version is $dotnetVersion"
        Write-Host "Please install .NET 9 SDK from: https://dotnet.microsoft.com/download/dotnet/9.0" -ForegroundColor Yellow
    }
} catch {
    Write-Error "? .NET CLI not found. Please install .NET 9 SDK."
    exit 1
}

# Verify project file exists
if (-not (Test-Path $ProjectPath)) {
    Write-Error "? Project file not found: $ProjectPath"
    exit 1
}

Write-Host "? Project file found: $ProjectPath" -ForegroundColor Green

# Clean previous builds if requested
if ($Clean -or (Test-Path $OutputPath)) {
    Write-Host "`nCleaning previous builds..." -ForegroundColor Yellow
    if (Test-Path $OutputPath) {
        Remove-Item $OutputPath -Recurse -Force
        Write-Host "? Cleaned output directory: $OutputPath" -ForegroundColor Green
    }
    
    # Clean bin/obj directories
    Get-ChildItem -Path "src" -Include "bin", "obj" -Recurse -Directory | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "? Cleaned bin/obj directories" -ForegroundColor Green
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    Write-Host "? Created output directory: $OutputPath" -ForegroundColor Green
}

# Update version if specified
if ($Version) {
    Write-Host "`nUpdating project version to $Version..." -ForegroundColor Yellow
    
    $projectContent = Get-Content $ProjectPath -Raw
    $projectContent = $projectContent -replace '<Version>.*?</Version>', "<Version>$Version</Version>"
    $projectContent = $projectContent -replace '<AssemblyVersion>.*?</AssemblyVersion>', "<AssemblyVersion>$Version.0</AssemblyVersion>"
    $projectContent = $projectContent -replace '<FileVersion>.*?</FileVersion>', "<FileVersion>$Version.0</FileVersion>"
    
    Set-Content $ProjectPath -Value $projectContent -NoNewline
    Write-Host "? Updated version to $Version" -ForegroundColor Green
}

# Restore dependencies
Write-Host "`nRestoring NuGet packages..." -ForegroundColor Yellow
$restoreArgs = @("restore", $ProjectPath)
if ($Verbose) { $restoreArgs += "--verbosity", "detailed" }

$restoreResult = & dotnet @restoreArgs
if ($LASTEXITCODE -ne 0) {
    Write-Error "? Package restore failed!"
    exit 1
}
Write-Host "? Package restore completed" -ForegroundColor Green

# Build the project
Write-Host "`nBuilding project..." -ForegroundColor Yellow
$buildArgs = @("build", $ProjectPath, "--configuration", $Configuration, "--no-restore")
if ($Verbose) { $buildArgs += "--verbosity", "detailed" }

$buildResult = & dotnet @buildArgs
if ($LASTEXITCODE -ne 0) {
    Write-Error "? Build failed!"
    exit 1
}
Write-Host "? Build completed successfully" -ForegroundColor Green

# Create NuGet package
Write-Host "`nCreating NuGet package..." -ForegroundColor Yellow
$packArgs = @("pack", $ProjectPath, "--configuration", $Configuration, "--output", $OutputPath, "--no-build")
if ($Verbose) { $packArgs += "--verbosity", "detailed" }

$packResult = & dotnet @packArgs
if ($LASTEXITCODE -ne 0) {
    Write-Error "? Package creation failed!"
    exit 1
}

# Display results
Write-Host "`n" + "="*50 -ForegroundColor Green
Write-Host "? Package creation completed successfully!" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Green

$packageFiles = Get-ChildItem $OutputPath -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending

if ($packageFiles.Count -eq 0) {
    Write-Error "? No package files found in $OutputPath"
    exit 1
}

Write-Host "`nGenerated packages:" -ForegroundColor Cyan
foreach ($package in $packageFiles) {
    $size = [math]::Round($package.Length / 1KB, 2)
    Write-Host "  ?? $($package.Name) ($size KB)" -ForegroundColor White
    Write-Host "     Path: $($package.FullName)" -ForegroundColor Gray
}

# Extract package info
$mainPackage = $packageFiles | Where-Object { $_.Name -notlike "*symbols*" } | Select-Object -First 1
if ($mainPackage) {
    Write-Host "`nPackage Information:" -ForegroundColor Cyan
    Write-Host "  Name: $($mainPackage.BaseName)" -ForegroundColor White
    Write-Host "  Size: $([math]::Round($mainPackage.Length / 1KB, 2)) KB" -ForegroundColor White
    Write-Host "  Created: $($mainPackage.LastWriteTime)" -ForegroundColor White
}

Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Test the package locally:" -ForegroundColor White
Write-Host "   dotnet add package MinimalEndpoints --source `"$($OutputPath)`"" -ForegroundColor Gray
Write-Host "`n2. Publish to NuGet.org:" -ForegroundColor White
Write-Host "   dotnet nuget push `"$($mainPackage.FullName)`" --api-key YOUR_API_KEY --source https://api.nuget.org/v3/index.json" -ForegroundColor Gray
Write-Host "`n3. Or use the NuGet Package Manager UI in Visual Studio" -ForegroundColor White

Write-Host "`n?? Ready to publish to NuGet!" -ForegroundColor Green