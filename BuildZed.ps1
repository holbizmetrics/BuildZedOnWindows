<#
.SYNOPSIS
    This script builds the ZED project on Windows by checking for necessary tools and installing them if they are not present.

.DESCRIPTION
    The script checks for the presence of CMake and Visual Studio build tools, installs them if necessary, and ensures that the required Spectre-mitigated libraries are available for building the project.

.PARAMETER command
    The command to check for its existence in the system.

.EXAMPLE
    .\BuildZED.ps1
    This command runs the script to build the ZED project.

.NOTES
    Author: [Your Name]
    Date: [Date]
    Version: 1.2
#>

function Test-Command($command) {
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try { 
        if (Get-Command $command -ErrorAction SilentlyContinue) { 
            return $true 
        } 
    }
    catch { 
        return $false 
    }
    finally { 
        $ErrorActionPreference = $oldPreference 
    }
}

$env:CARGO_HTTP_CHECK_REVOKE = "false"

# Load configuration from JSON file
$configPath = ".\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Configuration file not found: $configPath"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$projectPath = $config.projectPath

# Check if Visual Studio is installed and has the necessary components
function Check-VisualStudio {
    $vsInstalled = Test-Command "devenv"
    if (-not $vsInstalled) {
        Write-Error "Visual Studio is not installed. Please install Visual Studio with the C++ build tools."
        exit 1
    }

    # Check for Spectre-mitigated libraries
    $spectreLibsPath = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build"
    if (-not (Test-Path $spectreLibsPath)) {
        Write-Error "Spectre-mitigated libraries are not found. Please modify your Visual Studio installation to include them."
        Write-Host "You can do this by running the Visual Studio Installer and ensuring the following components are selected:"
        Write-Host "- MSVC v142 - VS 2019 C++ x64/x86 build tools"
        Write-Host "- Spectre mitigated libraries"
        exit 1
    }
}

# Check if CMake is installed
if (-not (Test-Command cmake)) {
    Write-Host "CMake is not found. Installing CMake..."

    # You can use Chocolatey to install CMake if it's available
    if (Test-Command choco) {
        Write-Host "Using Chocolatey to install CMake..."
        choco install cmake -y
    } else {
        # Alternative: Download and install CMake manually
        $cmakeUrl = "https://github.com/Kitware/CMake/releases/download/v3.23.0/cmake-3.23.0-windows-x86_64.msi"
        $cmakeInstaller = "$env:TEMP\cmake-installer.msi"
        try {
            Invoke-WebRequest -Uri $cmakeUrl -OutFile $cmakeInstaller -ErrorAction Stop
            Start-Process msiexec.exe -Wait -ArgumentList "/I $cmakeInstaller /quiet"
            Remove-Item $cmakeInstaller -ErrorAction SilentlyContinue
        } catch {
            Write-Error "Failed to download or install CMake. Please install it manually."
            exit 1
        }
    }

    # Refresh environment variables
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Verify CMake installation
if (Test-Command cmake) {
    Write-Host "CMake is installed. Version: $(cmake --version)"
} else {
    Write-Error "CMake installation failed. Please install it manually."
    exit 1
}

# Check Visual Studio installation and components
Check-VisualStudio

# Clean and rebuild the project
Set-Location $projectPath
cargo clean
cargo run

Write-Host "Build process completed."
