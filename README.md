## Powershell Scripts explaination and execution:

1. Eventlogs-Tampering.ps1
   
   This Powershell Tool checks for manipulation in Eventviewer.
   
| Event ID | Description |
|----------|-------------|
| **1102** | Security audit log was cleared. |
| **4663** | Attempted access to a protected file, folder, or object. |
| **4660** | A protected object (file/folder) was deleted. |
| **4656** | Handle request to a protected file or object. |
| **104**  | Application log was cleared. |
| **3079** | Application-specific log cleared (varies by system). |
| **5001** | Windows Defender real-time protection disabled. |
| **5004** | Windows Defender service stopped. |
| **100**  | Virtual Hard Disk attached. |
| **101**  | Virtual Hard Disk detached. |
```
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/Eventlogs-Tampering.ps1").Content
```
2. Services.ps1
   
   This Tool shows important windows services with start time and if they are running or had been stopped.
```
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/Services.ps1").Content
```
3. Windows-Defender-Logs.ps1
   
   This Tool shows the windows defender history even when deleted.
```
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/Windows-Defender-Logs.ps1").Content
```
4. PowershellCommands.ps1

   This Tool looks for several suspicious commands form Powershell. (Not really finished jet)
```
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/PowershellCommands.ps1").Content
```
