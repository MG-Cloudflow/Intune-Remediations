# Variables to customize
$ApplicationDisplayName = "7-Zip*"
$VersionToCompare      = "24.19.00.0"

# Properties to retrieve from each Uninstall key
$PropertyNames = @(
    'DisplayName',
    'DisplayVersion',
    'Publisher', 
    'InstallDate', 
    'UninstallString', 
    'QuietUninstallString', 
    'SystemComponent',
    'WindowsInstaller',
    @{Label = 'RegistryKey';     Expression = { $_.PSChildName } },
    @{Label = 'RegistryKeyFull'; Expression = { $_.PSPath -replace 'Microsoft.PowerShell.Core\\Registry::' } }
)

# Build list of all Uninstall registry paths in both hives and architectures
$AllPathsToSearch = foreach ($Hive in 'HKEY_CURRENT_USER', 'HKEY_LOCAL_MACHINE') {
    foreach ($Arch in 'SOFTWARE', 'SOFTWARE\WOW6432Node') {
        "registry::${Hive}\$Arch\Microsoft\Windows\CurrentVersion\Uninstall\*"
    }
}

# Gather all installed-app entries that have a DisplayName
try {
    $AllFoundObjects = Get-ItemProperty -Path $AllPathsToSearch -ErrorAction Stop |
        Where-Object { -not [String]::IsNullOrWhiteSpace($_.DisplayName) } |
        Select-Object -Property $PropertyNames
}
catch {
    Write-Verbose "Error gathering registry data: $($_.Exception.Message)" -Verbose
    throw
}

function Get-Installations {
    param(
        [array]$AllFoundObjects,
        [string]$ApplicationDisplayName,
        [string]$VersionToCompare
    )

    # Find matching installations
    $apps = $AllFoundObjects | Where-Object { $_.DisplayName -cmatch $ApplicationDisplayName }

    if ($apps.Count -ge 2) {
        # Multiple entries: check if all the same DisplayName
        $uniqueNames = $apps.DisplayName | Sort-Object -Unique
        if ($uniqueNames.Count -eq 1) {
            # Same product, pick highest version
            $maxVersion = ($apps.DisplayVersion | Sort-Object -Descending)[0]
            return ($maxVersion -ne $VersionToCompare) ? 1 : 0
        }
        else {
            # Different display names—treat as “up to date”
            return 0
        }
    }
    else {
        # Zero or one entry: if version mismatches, flag it
        foreach ($app in $apps) {
            if ($app.DisplayVersion -ne $VersionToCompare) {
                return 1
            }
        }
        return 0
    }
}

Get-Installations -AllFoundObjects $AllFoundObjects `
                            -ApplicationDisplayName $ApplicationDisplayName `
                            -VersionToCompare $VersionToCompare

