<#
.SYNOPSIS
    This Intune remediation script automates the process of setting the '_LabelFromReg' registry key
    for multiple servers and drives. It ensures that network drives are labeled consistently across
    all managed devices, enhancing user experience by providing clear and standardized naming for shared resources.

.DESCRIPTION
    The script iterates through a list of servers and drives, updating the '_LabelFromReg' registry key
    for each combination. It checks if the registry path exists and if the current label value differs
    from the desired one before making changes. This prevents unnecessary writes to the registry.

.PARAMETER Server
    The server hosting the network drive.

.PARAMETER DriveName
    The name of the network drive.

.PARAMETER LabelValue
    The label to set for the network drive.

.EXAMPLE
    Set-LabelFromReg -Server "server1.domain.local" -DriveName "driveA" -LabelValue "DRIVE_A"

.NOTES
    Author: Maxime Guillemin
    - This script is intended to be used as an Intune remediation script.
    - Ensure that the script runs under the user context, as it modifies HKCU (Current User) registry keys.
    - Test the script in a controlled environment before deploying it organization-wide.

#>

# Intune Remediation Script: Set _LabelFromReg Registry Key for Multiple Servers and Drives

# Define the list of servers
$servers = @(
    "server1.domain.local",
    "server2.domain.local",
    "server3.file.core.windows.net"
)

# Define the list of drives and their corresponding label values
$drives = @(
    @{ Name = "driveA"; Label = "DRIVE_A" },
    @{ Name = "driveB"; Label = "DRIVE_B" },
    @{ Name = "driveC"; Label = "DRIVE_C" },
    @{ Name = "driveD"; Label = "DRIVE_D" },
    @{ Name = "driveE"; Label = "DRIVE_E" },
    @{ Name = "driveF"; Label = "DRIVE_F" },
    @{ Name = "driveG"; Label = "DRIVE_G" },
    @{ Name = "driveH"; Label = "DRIVE_H" },
    @{ Name = "driveI"; Label = "DRIVE_I" },
    @{ Name = "driveJ"; Label = "DRIVE_J" },
    @{ Name = "driveK"; Label = "DRIVE_K" },
    @{ Name = "driveL"; Label = "DRIVE_L" },
    @{ Name = "driveM"; Label = "DRIVE_M" },
    @{ Name = "driveN"; Label = "DRIVE_N" }
    # Add more drives with their label values as needed
)

# Function to set the registry key
function Set-LabelFromReg {
    param (
        [string]$Server,
        [string]$DriveName,
        [string]$LabelValue
    )

    # Construct the registry path
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\##$($Server)#$($DriveName)"

    try {
        # Check if the registry path exists
        if (-not (Test-Path -Path $regPath)) {
            Write-Host "Registry path not found: $regPath"
            return
        }

        # Get the current value of _LabelFromReg
        $currentValue = (Get-ItemProperty -Path $regPath -Name '_LabelFromReg' -ErrorAction SilentlyContinue)._LabelFromReg

        # Set the registry key only if the value is different or doesn't exist
        if ($currentValue -ne $LabelValue) {
            New-ItemProperty -Path $regPath -Name '_LabelFromReg' -Value $LabelValue -PropertyType ExpandString -Force
            Write-Host "Set '_LabelFromReg' to '$LabelValue' for path '$regPath'"
        }
        else {
            Write-Host "'_LabelFromReg' is already set to '$LabelValue' for path '$regPath'"
        }
    }
    catch {
        $errMsg = $_.Exception.Message
        Write-Host "Error setting '_LabelFromReg' for path '$regPath': $errMsg"
        Exit 1
    }
}

try {
    # Loop through each server and drive
    foreach ($server in $servers) {
        foreach ($drive in $drives) {
            Set-LabelFromReg -Server $server -DriveName $drive.Name -LabelValue $drive.Label
        }
    }
    Exit 0
}
catch {
    Exit 1
}
