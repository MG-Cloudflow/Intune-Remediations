# Detect if the device is Arm64 and CHPE is not disabled
$cpuArch = (Get-CimInstance Win32_Processor).Architecture
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
$registryName = "HotPatchRestrictions"

# Architecture 12 = ARM64
if ($cpuArch -eq 12) {
    try {
        $value = Get-ItemPropertyValue -Path $registryPath -Name $registryName -ErrorAction Stop
        if ($value -ne 1) {
            Write-Output "HotPatchRestrictions not set to 1 on ARM64 device."
            exit 1
        } else {
            Write-Output "CHPE already disabled for Hotpatch."
            exit 0
        }
    } catch {
        Write-Output "HotPatchRestrictions key not found."
        exit 1
    }
} else {
    Write-Output "Device is not ARM64 no action needed."
    exit 0
}
# The script checks if the device is ARM64 and if the HotPatchRestrictions registry key is set to 1.