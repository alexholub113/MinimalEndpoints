# Quick NuGet Package Generator for MinimalEndpoints
# Single command to build and pack

param(
    [string]$Version
)

$ProjectPath = "src\MinimapEndpoints\MinimalEndpoints.csproj"
$OutputPath = "nupkg"

if ($Version) {
    Write-Host "Building MinimalEndpoints v$Version..." -ForegroundColor Green
    # Update version in project file
    (Get-Content $ProjectPath) -replace '<Version>.*?</Version>', "<Version>$Version</Version>" | Set-Content $ProjectPath
} else {
    Write-Host "Building MinimalEndpoints package..." -ForegroundColor Green
}

# Clean and create output directory
if (Test-Path $OutputPath) { Remove-Item $OutputPath -Recurse -Force }
New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null

# Build and pack in one command
dotnet pack $ProjectPath --configuration Release --output $OutputPath

if ($LASTEXITCODE -eq 0) {
    $packages = Get-ChildItem $OutputPath -Filter "*.nupkg"
    Write-Host "`n? Package created successfully!" -ForegroundColor Green
    foreach ($pkg in $packages) {
        Write-Host "  ?? $($pkg.Name)" -ForegroundColor Cyan
    }
    Write-Host "`nLocation: $((Get-Item $OutputPath).FullName)" -ForegroundColor Yellow
} else {
    Write-Host "? Package creation failed!" -ForegroundColor Red
}