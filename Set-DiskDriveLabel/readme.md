# README

## Intune Remediation Script: Set `_LabelFromReg` Registry Key for Multiple Servers and Drives

---

### Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Script Details](#script-details)
- [Deployment Instructions](#deployment-instructions)
- [Usage](#usage)
- [Customization](#customization)
- [Testing](#testing)
- [Notes](#notes)
- [License](#license)
- [Contact Information](#contact-information)

---

## Overview

This PowerShell script is designed to be used as an **Intune remediation script**. It automates the process of setting the `_LabelFromReg` registry key for multiple servers and drives. By doing so, it ensures that network drives are labeled consistently across all managed devices, enhancing the user experience by providing clear and standardized naming for shared resources.

## Prerequisites

- **Microsoft Intune**: The script is intended for deployment via Microsoft Intune.
- **Permissions**: Ensure that the script runs under the user context, as it modifies `HKCU` (Current User) registry keys.
- **PowerShell Execution Policy**: The devices should allow the execution of PowerShell scripts.
- **Network Access**: Devices must have access to the specified servers and drives.

## Script Details

- **Script Name**: `Set-LabelFromReg.ps1`
- **Author**: Maxime Guillemin
- **Description**: Updates the `_LabelFromReg` registry key for specified network drives to ensure consistent labeling.

### Parameters

The script does not accept external parameters but defines the following internally:

- `$servers`: An array of server names hosting the network drives.
- `$drives`: An array of hashtables containing drive names and their corresponding label values.

### Functions

- `Set-LabelFromReg`: A function that sets the `_LabelFromReg` registry key for a given server and drive combination.

## Deployment Instructions

### 1. Customize the Script

- **Servers**: Update the `$servers` array with the actual server names in your environment.
- **Drives**: Update the `$drives` array with the actual drive names and desired labels.

### 2. Save the Script

- Save the script as `Set-LabelFromReg.ps1`.

### 3. Deploy via Intune

1. **Sign In**: Log into the [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com).
2. **Navigate**: Go to **Devices** > **Scripts** > **Add** > **Windows 10 and later**.
3. **Basic Information**:
   - **Name**: Enter a name for the script (e.g., "Set Network Drive Labels").
   - **Description**: Provide a description if desired.
4. **Script Settings**:
   - **Upload Script**: Upload the `Set-LabelFromReg.ps1` script file.
   - **Run this script using the logged-on credentials**: Set to `Yes`.
   - **Script signature check**: Configure based on your organization's policy.
   - **Run script as 32-bit process on 64-bit clients**: Set based on your environment.
5. **Assignments**:
   - Assign the script to the desired user or device groups.
6. **Review and Create**:
   - Review the settings and create the script deployment.

## Usage

Once deployed, the script will:

- Iterate through each server and drive specified.
- Check if the `_LabelFromReg` registry key exists for the network drive.
- Update the key with the specified label if it doesn't exist or differs from the desired value.

### Logging

The script outputs messages indicating:

- Whether the registry path was found.
- If the `_LabelFromReg` value was updated or already set.
- Any errors encountered during execution.

These messages can be viewed in the Intune script output logs for each device.

## Customization

- **Adding Servers**: Add additional server names to the `$servers` array.
- **Adding Drives**: Add additional drives to the `$drives` array with their corresponding labels.
- **Error Handling**: Modify the `try-catch` blocks if you wish to implement additional error handling or logging mechanisms.
- **Verbose Output**: You can adjust the `Write-Host` statements for more detailed logging if necessary.

## Testing

Before deploying the script widely, it's recommended to:

1. **Test on a Single Device**: Assign the script to a test group containing a single device.
2. **Verify Functionality**:
   - Ensure the network drives are mapped on the test device.
   - Run the script and check if the drive labels are updated as expected.
3. **Review Logs**: Check the Intune script output and device event logs for any errors.

## Notes

- **User Context**: The script modifies `HKCU` registry keys and must run in the user context.
- **Network Drives**: The drives must be mapped on the user's device for the registry paths to exist.
- **Registry Backup**: While the script is safe, consider backing up the registry or creating a restore point as a precaution.

## License

This script is provided "as-is" without any warranty. Use at your own risk. You are free to modify and distribute the script within your organization.

## Contact Information

For questions, suggestions, or assistance, please contact:

- **Author**: Maxime Guillemin
- **Email**: [mg@cloudflow.be](mailto:mg@cloudflow.be)
- **LinkedIn**: [https://www.linkedin.com/in/maxime-guillemin-526618161/](https://www.linkedin.com/in/maximeguillemin)

---

**Disclaimer**: Always ensure scripts are thoroughly tested in a controlled environment before deployment. Modifying the Windows Registry can have unintended consequences if not done carefully.

---
