## Powershell Scripts explaination and execution:

1. Eventlogs-Tampering.ps1
   
   This Powershell Tool checks for manipulation in Eventviewer.
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

   This Tool looks for several suspicious commands form Powershell.
```
iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Onexion/Powershell-Skripts/main/PowershellCommands.ps1").Content
```
