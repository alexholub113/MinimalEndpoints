#!/bin/bash

# MinimalEndpoints NuGet Package Generator (Shell Script)
# Cross-platform script to build and create .nupkg file

set -e  # Exit on any error

PROJECT_PATH="src/MinimapEndpoints/MinimalEndpoints.csproj"
OUTPUT_PATH="nupkg"
CONFIGURATION="Release"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}MinimalEndpoints Package Generator${NC}"
echo -e "${GREEN}=====================================${NC}"
echo -e "${CYAN}Configuration: $CONFIGURATION${NC}"
echo -e "${CYAN}Output Path: $OUTPUT_PATH${NC}"
echo -e "${CYAN}Project Path: $PROJECT_PATH${NC}"
echo ""

# Check if dotnet is installed
echo -e "${YELLOW}Checking .NET installation...${NC}"
if ! command -v dotnet &> /dev/null; then
    echo -e "${RED}ERROR: .NET CLI not found. Please install .NET 9 SDK.${NC}"
    echo "Download from: https://dotnet.microsoft.com/download/dotnet/9.0"
    exit 1
fi

DOTNET_VERSION=$(dotnet --version)
echo -e "${GREEN}? .NET version: $DOTNET_VERSION${NC}"

# Check if project file exists
if [ ! -f "$PROJECT_PATH" ]; then
    echo -e "${RED}ERROR: Project file not found: $PROJECT_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}? Project file found: $PROJECT_PATH${NC}"
echo ""

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
if [ -d "$OUTPUT_PATH" ]; then
    rm -rf "$OUTPUT_PATH"
    echo -e "${GREEN}? Cleaned output directory: $OUTPUT_PATH${NC}"
fi

# Create output directory
mkdir -p "$OUTPUT_PATH"
echo -e "${GREEN}? Created output directory: $OUTPUT_PATH${NC}"
echo ""

# Restore packages
echo -e "${YELLOW}Restoring NuGet packages...${NC}"
dotnet restore "$PROJECT_PATH"
echo -e "${GREEN}? Package restore completed${NC}"
echo ""

# Build project
echo -e "${YELLOW}Building project...${NC}"
dotnet build "$PROJECT_PATH" --configuration "$CONFIGURATION" --no-restore
echo -e "${GREEN}? Build completed successfully${NC}"
echo ""

# Create NuGet package
echo -e "${YELLOW}Creating NuGet package...${NC}"
dotnet pack "$PROJECT_PATH" --configuration "$CONFIGURATION" --output "$OUTPUT_PATH" --no-build
echo ""

echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}? Package creation completed successfully!${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""

# Display generated files
echo -e "${CYAN}Generated packages:${NC}"
for file in "$OUTPUT_PATH"/*.nupkg; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        size=$(du -h "$file" | cut -f1)
        echo -e "  ?? $filename ($size)"
    fi
done

echo ""
echo -e "${CYAN}Package files created in: $OUTPUT_PATH${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test locally: dotnet add package MinimalEndpoints --source \"$OUTPUT_PATH\""
echo "2. Publish to NuGet: dotnet nuget push \"$OUTPUT_PATH/MinimalEndpoints.*.nupkg\" --api-key YOUR_API_KEY --source https://api.nuget.org/v3/index.json"
echo ""
echo -e "${GREEN}?? Ready to publish to NuGet!${NC}"