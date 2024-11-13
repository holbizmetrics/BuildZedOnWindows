<#
.SYNOPSIS
    This script builds the ZED project on Windows by checking for necessary tools and installing them if they are not present.

.DESCRIPTION
    The script checks for the presence of CMake and installs it using Chocolatey if available. 
    If Chocolatey is not installed, it downloads the CMake installer directly from the official GitHub repository.
    After ensuring CMake is installed, it cleans and rebuilds the ZED project using Cargo.

.PARAMETER command
    The command to check for its existence in the system.

.EXAMPLE
    .\BuildZED.ps1
    This command runs the script to build the ZED project.

.NOTES
    Author: [Your Name]
    Date: [Date]
    Version: 1.0
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

# Clean and rebuild the project
Set-Location C:\Users\MOH1002\source\repos\FromGithubEtc\zed
cargo clean
cargo run

Write-Host "Build process completed."
