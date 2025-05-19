$cpuArch = (Get-CimInstance Win32_Processor).Architecture
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
$registryName = "HotPatchRestrictions"

function Show-RebootReminderScheduledTask {
    try {
        # Get logged-on user
        $user = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty UserName
        if (-not $user) {
            Write-Output "No active user session found. Skipping popup."
            return
        }

        $taskName = "NotifyUser-RebootForHotpatch"
        $popupScript = @'
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("To complete the configuration for Windows Hotpatch updates, your device needs to reboot. Please save your work and restart as soon as possible.", "Windows Hotpatch Configuration", "OK", "Information") | Out-Null
'@

        $popupScriptPath = "$env:ProgramData\HotpatchReminder.ps1"
        Set-Content -Path $popupScriptPath -Value $popupScript -Force -Encoding UTF8

        # Define task action
        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$popupScriptPath`""

        # Define task trigger (one-time immediate)
        $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)

        # Register the task to run as the currently logged-in user
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -User $user -RunLevel Limited -Force | Out-Null

        # Start the task immediately
        Start-ScheduledTask -TaskName $taskName

        Write-Output "Scheduled Task created and triggered for user $user."
    } catch {
        Write-Error "Failed to create user notification task: $_"
    }
}

# Main logic
if ($cpuArch -eq 12) {
    try {
        if (-not (Test-Path $registryPath)) {
            New-Item -Path $registryPath -Force | Out-Null
        }

        Set-ItemProperty -Path $registryPath -Name $registryName -Value 1 -Type DWord
        Write-Output "HotPatchRestrictions set to 1 for ARM64 device."

        Show-RebootReminderScheduledTask
    } catch {
        Write-Error "Failed to set HotPatchRestrictions: $_"
        exit 1
    }
} else {
    Write-Output "Device is not ARM64 no changes made."
}
