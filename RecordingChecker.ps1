# Autor: Onexion (github.com/Onexion)
# You are free to use it or Fork it from https://github.com/Onexion/Powershell-Skripts
# If any problems accure pleas write a discord message to "Onexions"
# If you anything to add please write me a DM.
# This tool is not ment to harm anyone and i dont asosiate with any abuse with this script.



If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Show-Logo {
    Write-Host "`n"
    Write-Host "  ██████  ███████  ██████  ██████  ██████  ██████  ██ ███    ██  ██████      ██ ██    ██ ██████  ███    ██" -ForegroundColor Cyan
    Write-Host "  ██   ██ ██      ██      ██    ██ ██   ██ ██   ██ ██ ████   ██ ██          ██  ██    ██ ██   ██ ████   ██" -ForegroundColor Cyan
    Write-Host "  ██████  █████   ██      ██    ██ ██████  ██   ██ ██ ██ ██  ██ ██   ███   ██   ██    ██ ██████  ██ ██  ██" -ForegroundColor Cyan
    Write-Host "  ██   ██ ██      ██      ██    ██ ██   ██ ██   ██ ██ ██  ██ ██ ██    ██  ██     ██  ██  ██      ██  ██ ██" -ForegroundColor Cyan
    Write-Host "  ██   ██ ███████  ██████  ██████  ██   ██ ██████  ██ ██   ████  ██████  ██       ████   ██      ██   ████" -ForegroundColor Cyan
    Write-Host "`n"
}

Show-Logo

Clear-Host
Show-Logo

$recordingProcesses = @(
    "mirillis","wmcap","playclaw","XSplit","Screencast","camtasia","dxtory","nvcontainer",
    "obs64","bdcam","RadeonSettings","Fraps","CamRecorder","XSplit.Core","ShareX","Action",
    "lightstream","streamlabs","webrtcvad","openbroadcastsoftware","movavi.screen.recorder",
    "icecreamscreenrecorder","smartpixel","d3dgear","gadwinprintscreen","apowersoftfreescreenrecorder",
    "bandicamlauncher","hypercam","loiloilgamerecorder","nchexpressions","captura","vokoscreenNG",
    "simple.screen.recorder","recordmydesktop","kazam","gtk-recordmydesktop","screenstudio","screenkey",
    "jupyter-notebook"
)

foreach ($proc in $recordingProcesses) {
    if (Get-Process -Name $proc -ErrorAction SilentlyContinue) {
        $answer = Read-Host "$proc is running. Do you want to close it? (Y/N)"
        if ($answer -eq "Y") {
            Stop-Process -Name $proc -Force
        }
    }
}

$vpnProcesses = @(
    "pia-client","ProtonVPNService","IpVanish","WindScribe","ExpressVPN","NordVPN",
    "CyberGhost","pia-tray","SurfShark","VyprVPN","HSSCP","TunnelBear","ProtonVPN"
)

foreach ($vpn in $vpnProcesses) {
    if (Get-Process -Name $vpn -ErrorAction SilentlyContinue) {
        Write-Host "A VPN is running on the user's computer! ($vpn)" -ForegroundColor Yellow
        $choice = Read-Host "[1] Continue Screenshare  [2] End Screenshare"
        if ($choice -eq "1") {
            Stop-Process -Name $vpn -Force
        } elseif ($choice -eq "2") {
            exit
        }
    }
}

try {
    $ip = (Invoke-WebRequest -Uri "https://ifconfig.me/ip").Content.Trim()
    $proxyCheck = Invoke-WebRequest -Uri "https://proxycheck.io/v2/$ip?vpn=1&asn=1" | Select-String "proxy"
    if ($proxyCheck) {
        Write-Host "`n Proxy/VPN detected!" -ForegroundColor Red
    } else {
        Write-Host "`nNo Proxy/VPN detected." -ForegroundColor Green
    }
} catch {
    Write-Host "`nCould not check Proxy/VPN." -ForegroundColor Red
}

Write-Host "`nDone! Have a nice day!" -ForegroundColor Cyan
