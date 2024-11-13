# BuildZED.ps1

This PowerShell script automates the process of building the ZED project on Windows. It checks for the necessary tools, specifically CMake, and installs them if they are not already present. The script utilizes Chocolatey for installation when available, and falls back to a manual download if Chocolatey is not installed.

## Features:
- Checks for the presence of CMake and installs it automatically.
- Cleans and rebuilds the ZED project using Cargo.
- Provides feedback on the installation process and any errors encountered.

## Prerequisites:
- PowerShell must be installed on your Windows machine.
- Chocolatey is recommended for easier installation of CMake.

## Usage:
1. Clone the repository or download the script.
2. Open PowerShell as an administrator.
3. Navigate to the directory containing the script.
4. Run the script using the command: `.\BuildZED.ps1`

## Notes:
- Ensure that you have the necessary permissions to install software on your system.
- This script is designed for Windows environments and may not work on other operating systems.

## Author:
[Your Name]

## License:
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
