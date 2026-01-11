# Autor: Onexion (github.com/Onexion)
# You are free to use it or Fork it from https://github.com/Onexion/Powershell-Skripts
# If any problems accure please write a discord message to "Onexions"
# If you anything to add please write me a DM.
# This tool is not ment to harm anyone and i dont asosiate with any abuse with this script.



If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ErrorActionPreference = "SilentlyContinue"
Clear-Host

function Show-Header {
    Clear-Host
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host "|   Checking for VPNs and Recordings   |" -ForegroundColor Yellow
    Write-Host "----------------------------------------`n" -ForegroundColor Yellow
}

function Get-InstalledVPNsAndRecorders {
    param(
        [string[]]$VPNList,
        [string[]]$RecorderList
    )

    $installed = @()

    $installed += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object { $_.DisplayName }
    $installed += Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object { $_.DisplayName }
    $installed += Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ForEach-Object { $_.DisplayName }

    try { $installed += (winget list --accept-source-agreements | ForEach-Object { $_.Name }) } catch { }

    $installed = $installed | Where-Object { $_ } | Sort-Object -Unique

    $foundVPNs = foreach ($vpn in $VPNList) {
        $installed | Where-Object { $_ -match [regex]::Escape($vpn) }
    }

    $foundRecorders = foreach ($rec in $RecorderList) {
        $installed | Where-Object { $_ -match [regex]::Escape($rec) }
    }

    [PSCustomObject]@{
        VPNs      = $foundVPNs | Sort-Object -Unique
        Recorders = $foundRecorders | Sort-Object -Unique
    }
}

$processNames = @(
    "action","amdrsserv","apowersoft","bandicam","bdcam","camtasia","captura",
    "d3dgear","dxtory","fraps","geforce","obs","obs64","streamlabs","xsplit",
    "medal","overwolf","amdrssrcext"
)

$vpnNames = @(
    "PlanetVPN","Nord","NordVPN","Proton","ProtonVPN","Mullvad","Surfshark",
    "ExpressVPN","CyberGhost","PIA","Windscribe","TunnelBear","Hotspot"
)

$runningProcesses = Get-Process | ForEach-Object {
    $p = $_
    try {
        $p.Modules | ForEach-Object {
            [PSCustomObject]@{
                ProcessName = $p.ProcessName
                ModuleName  = $_.ModuleName
            }
        }
    } catch {}
}

$runningPrograms = $runningProcesses |
    Where-Object { $processNames -contains $_.ProcessName } |
    Select-Object -ExpandProperty ProcessName -Unique

$streamingPrograms = @("chrome","msedge","firefox","opera","brave")
$streamingDLLs = @("webrtc.dll","windows.graphics.capture.dll","dxgi.dll")

$runningStreams = $runningProcesses |
    Where-Object {
        ($streamingDLLs -contains $_.ModuleName -and $streamingPrograms -contains $_.ProcessName)
    } |
    Select-Object -ExpandProperty ProcessName -Unique

$vpnProcessMap = @{}

foreach ($vpn in $vpnNames) {
    $matches = $runningProcesses |
        Where-Object { $_.ProcessName -like "*$vpn*" } |
        Select-Object -ExpandProperty ProcessName -Unique

    if ($matches) {
        $displayName = ($matches[0] -replace '(?i)(service|helper|daemon|client|agent|engine)$','')

        if (-not $vpnProcessMap.ContainsKey($displayName)) {
            $vpnProcessMap[$displayName] = @()
        }

        $vpnProcessMap[$displayName] += $matches
    }
}

foreach ($k in $vpnProcessMap.Keys) {
    $vpnProcessMap[$k] = $vpnProcessMap[$k] | Sort-Object -Unique
}

$installedSoftware = Get-InstalledVPNsAndRecorders -VPNList $vpnNames -RecorderList $processNames

Show-Header
$index = 1
$menuMap = @{}

if ($installedSoftware.VPNs.Count) {
    Write-Host "Installed VPN Software:" -ForegroundColor Green
    $installedSoftware.VPNs | ForEach-Object { Write-Host " - $_" }
}

if ($installedSoftware.Recorders.Count) {
    Write-Host "`nInstalled Recording Software:" -ForegroundColor Magenta
    $installedSoftware.Recorders | ForEach-Object { Write-Host " - $_" }
}

if ($runningPrograms) {
    Write-Host "`nRunning Recording Software:" -ForegroundColor Magenta
    foreach ($p in $runningPrograms) {
        Write-Host "[$index] $p"
        $menuMap[$index] = @{ Type="Process"; Name=$p }
        $index++
    }
}

if ($runningStreams) {
    Write-Host "`nPossible Streams:" -ForegroundColor Cyan
    foreach ($s in $runningStreams) {
        Write-Host "[$index] $s"
        $menuMap[$index] = @{ Type="Process"; Name=$s }
        $index++
    }
}

if ($vpnProcessMap.Count) {
    Write-Host "`nVPN Processes Running:" -ForegroundColor Green
    foreach ($vpn in $vpnProcessMap.Keys) {
        Write-Host "[$index] $vpn"
        $menuMap[$index] = @{
            Type="VPN"
            Name=$vpn
            Processes=$vpnProcessMap[$vpn]
        }
        $index++
    }
}


do {
    $choice = Read-Host "`nEnter number to close process/VPN or N to exit"

    if ($choice -match '^[nN]$') { break }

    if ($choice -match '^\d+$' -and $menuMap.ContainsKey([int]$choice)) {

        $sel = $menuMap[[int]$choice]

        if ($sel.Type -eq "VPN") {
            Write-Host "`nClosing VPN $($sel.Name)..."
            foreach ($p in $sel.Processes) {
                Get-Process -Name $p -ErrorAction SilentlyContinue | Stop-Process -Force
            }
            Write-Host "VPN $($sel.Name) closed."
        }
        else {
            Write-Host "`nClosing $($sel.Name)..."
            Get-Process -Name $sel.Name -ErrorAction SilentlyContinue | Stop-Process -Force
            Write-Host "$($sel.Name) closed."
        }

        break
    }

    Write-Host "Invalid input." -ForegroundColor Red
}
while ($true)

Clear-Host


