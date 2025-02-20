<#
.SYNOPSIS
  Detects and remediates the current user's Downloads folder to point to OneDrive.

.DESCRIPTION
  1. Checks if the current known folder for Downloads is already set to OneDrive\Downloads.
  2. If not, it moves existing files from the old Downloads folder, creates a OneDrive\Downloads folder if needed,
     and updates registry keys so that Windows recognizes the new location as "Downloads."
  3. Returns 0 (success) if already compliant or successfully remediated, 1 (error) if it fails.

.NOTES
  Run in user context, because it edits HKCU keys.

#>

try {
    # ------------------------------------------------------------
    # 1) Identify OneDrive path and desired Downloads path
    # ------------------------------------------------------------
    $oneDrivePath = $env:OneDrive

    if (-not $oneDrivePath) {
        Write-Host "OneDrive is not configured or the environment variable is missing."
        Write-Host "Not Compliant"
        exit 1
    }

    # Normalize the OneDrive path (if it exists on the system)
    $oneDriveFullPath = Resolve-Path -Path $oneDrivePath -ErrorAction Stop

    # Construct the target Downloads path inside OneDrive
    $desiredDownloadsPath = Join-Path $oneDriveFullPath "Downloads"

    # ------------------------------------------------------------
    # 2) Detect: Check if current Downloads folder is already pointing there
    #    Known Folder GUID for Downloads = {374DE290-123F-4565-9164-39C4925E467B}
    # ------------------------------------------------------------
    $currentRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    $currentDownloadsValue = (Get-ItemProperty -Path $currentRegPath -Name "{374DE290-123F-4565-9164-39C4925E467B}" -ErrorAction SilentlyContinue)."{374DE290-123F-4565-9164-39C4925E467B}"

    if ($currentDownloadsValue -and (Split-Path $currentDownloadsValue -Parent) -eq (Split-Path $desiredDownloadsPath -Parent)) {
        # The registry path might be the same or a slightly different format, let's do a direct string compare
        if ([string]::Equals($currentDownloadsValue, $desiredDownloadsPath, "InvariantCultureIgnoreCase")) {
            Write-Host "Downloads folder is already mapped to OneDrive. Compliant."
            exit 0
        }
    }

    # ------------------------------------------------------------
    # 3) Remediate
    # ------------------------------------------------------------
    Write-Host "Remediation needed. Setting Downloads to: $desiredDownloadsPath"

    # Create the OneDrive\Downloads directory if it does not exist
    if (-not (Test-Path $desiredDownloadsPath)) {
        New-Item -ItemType Directory -Path $desiredDownloadsPath -ErrorAction Stop | Out-Null
        Write-Host "Created new directory: $desiredDownloadsPath"
    }

    # Move existing files from old Downloads to new location (if old folder exists)
    $oldDownloadsPath = Join-Path $env:USERPROFILE "Downloads"

    if (Test-Path $oldDownloadsPath) {
        $itemsToMove = Get-ChildItem -Path $oldDownloadsPath -Force -ErrorAction SilentlyContinue
        if ($itemsToMove) {
            Write-Host "Moving existing files from '$oldDownloadsPath' to '$desiredDownloadsPath'..."
            Move-Item -Path (Join-Path $oldDownloadsPath "*") -Destination $desiredDownloadsPath -Force -ErrorAction Stop
        }
    }

    # Update the registry to change the known folder path
    Set-ItemProperty -Path $currentRegPath `
                     -Name "{374DE290-123F-4565-9164-39C4925E467B}" `
                     -Value $desiredDownloadsPath

    # Also update the older 'Shell Folders' for compatibility
    $shellFoldersRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
    if (Test-Path $shellFoldersRegPath) {
        Set-ItemProperty -Path $shellFoldersRegPath -Name "Downloads" -Value $desiredDownloadsPath
    }

    Write-Host "Downloads folder successfully remapped to OneDrive."

    # ------------------------------------------------------------
    # 4) Indicate success and compliance
    # ------------------------------------------------------------
    Write-Host "Remediated"
    exit 0
}
catch {
    Write-Host "An error occurred during remediation: $($_.Exception.Message)"
    Write-Host "Not Compliant"
    exit 1
}
