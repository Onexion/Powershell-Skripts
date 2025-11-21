# Autor: onexions alias: James.dellw on Discord
# Feel free to use it or change stuff
# Always give the user the opertunity to look over the code

# WARNING!!!

# Do not use this script if you are not aware of what it does.
# Always be aware of the dangers on the Internet.
# If you encounter any form of suspicious behavior, always report it to others.
# This is a warning!

# Before banning a user of this script pleas check in Eventlogs yourself
# The system might have bugged or had an error

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)

if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`nThis script is not running as admin."
    Write-Host "Run it again as admin? (Y/N)"
    $answer = Read-Host
    if ($answer -match "^[Yy]") {
        $start = New-Object System.Diagnostics.ProcessStartInfo
        $start.FileName = "powershell.exe"
        $start.Arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
        $start.Verb = "runas"
        try {
            [System.Diagnostics.Process]::Start($start) | Out-Null
        } catch {}
        exit
    } else {
        Write-Host "Exiting script."
        exit
    }
}

Clear-Host
Write-Host
Write-Host
Write-Host "    ███████╗██╗   ██╗███████╗███╗   ██╗████████╗██╗      ██████╗  ██████╗ ███████╗" -ForegroundColor Cyan
Write-Host "    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██║     ██╔═══██╗██╔════╝ ██╔════╝" -ForegroundColor Cyan
Write-Host "    █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ██║     ██║   ██║██║  ███╗███████╗" -ForegroundColor Cyan
Write-Host "    ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ██║     ██║   ██║██║   ██║╚════██║" -ForegroundColor Cyan
Write-Host "    ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████╗╚██████╔╝╚██████╔╝███████║" -ForegroundColor Cyan
Write-Host "    ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝" -ForegroundColor Cyan
Write-Host

$searches = @(
    @{ Log = "Security"; IDs = 1102 }
    @{ Log = "Application"; IDs = 104 }
    @{ Log = "System"; IDs = 104 }
    @{ Log = "Microsoft-Windows-Eventlog"; IDs = 1040 }
    @{ Log = "Microsoft-Windows-Eventlog"; IDs = 1100 }
    @{ Log = "Microsoft-Windows-Eventlog"; IDs = 1101 }
    @{ Log = "Security"; IDs = 4719 }
    @{ Log = "Security"; IDs = 1108 }
    @{ Log = "System"; IDs = 7036 }
    @{ Log = "Security"; IDs = 4720 }
    @{ Log = "System"; IDs = 8193 }
    @{ Log = "System"; IDs = 12289 }
    @{ Log = "Microsoft-Windows-VSS"; IDs = 13 }
    @{ Log = "Microsoft-Windows-VSS"; IDs = 14 }
    @{ Log = "Microsoft-Windows-VSS"; IDs = 8224 }
    @{ Log = "Microsoft-Windows-VSS"; IDs = 8228 }
)

$foundEvents = @()

foreach ($search in $searches) {
    try {
        $events = Get-WinEvent -FilterHashtable @{ LogName = $search.Log; Id = $search.IDs } -ErrorAction Stop
        if ($events) {
            $foundEvents += $events
        }
    } catch {
        # Falls Log nicht existiert oder Zugriff verweigert wird -> ignorieren
    }
}

if ($foundEvents.Count -gt 0) {
    $foundEvents |
        Sort-Object TimeCreated |
        Select-Object TimeCreated, Id, LogName, @{Name="Message";Expression={$_.Message -replace "`r`n","\n"}} |
        Format-Table -AutoSize
} else {
    Write-Host "`n45 76 65 6E 74 6C 6F 67 73 20 63 6C 65 61 6E`n" -ForegroundColor Green
}
