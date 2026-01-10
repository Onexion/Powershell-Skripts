## Powershell Scripts explaination and execution:

1. Eventlogs-Tampering.ps1
   
   This Powershell Tool checks for manipulation in Eventviewer.
   
| Event ID | Log Source | Description |
|----------|------------|-------------|
| **13** | Microsoft-Windows-VSS | Shadow copy created. |
| **14** | Microsoft-Windows-VSS | Shadow copy deleted. |
| **100** | Microsoft-Windows-VHDMP/Operational | Virtual Hard Disk attached. |
| **101** | Microsoft-Windows-VHDMP/Operational | Virtual Hard Disk detached. |
| **104** | Application | Application log was cleared. |
| **104** | System | System log was cleared. |
| **3079** | Application | Application-specific log cleared (varies by system). |
| **4660** | Security | A protected object (file/folder) was deleted. |
| **4663** | Security | Attempted access to a protected file, folder, or object. |
| **4656** | Security | Handle request to a protected file or object. |
| **4719** | Security | System audit policy was changed. |
| **4720** | Security | A user account was created. |
| **5001** | Microsoft-Windows-Windows Defender/Operational | Windows Defender real-time protection disabled. |
| **5004** | Microsoft-Windows-Windows Defender/Operational | Windows Defender service stopped. |
| **7036** | System | A service entered a running or stopped state. |
| **8193** | System | VSS encountered an error (often backup or shadow copy manipulation). |
| **1100** | Microsoft-Windows-Eventlog | The event logging service was shut down. |
| **1101** | Microsoft-Windows-Eventlog | Audit events could not be written. |
| **1102** | Security | Security audit log was cleared. |
| **1108** | Security | Windows security auditing was unable to write to the log. |
| **12289** | System | VSS operation started/failed (shadow copy creation or deletion). |
| **1040** | Microsoft-Windows-Eventlog | Event log configuration was modified. |
| **8224** | Microsoft-Windows-VSS | VSS internal server error. |
| **8228** | Microsoft-Windows-VSS | VSS component encountered an error or failure. |

```
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/Eventlogs-Tampering.ps1").Content
```
2. Services.ps1

   This Tool shows important windows services with start time and if they are running or had been stopped.

    Checks when and if following services are running: PcaSvc, DPS, DiagTrack, SysMain, EventLog, SgrmBroker, explorer, lsass, taskhostw and csrss. 
```
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/Services.ps1").Content
```
3. Windows-Defender-Logs.ps1
   
   This Tool shows the windows defender history even when deleted.
```
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/Windows-Defender-Logs.ps1").Content
```

4. Recording Checker.ps1

      This script checks if a user is Recording or running a VPN.
```
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/RecordingChecker.ps1").Content
```
