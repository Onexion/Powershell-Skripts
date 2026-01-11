Clear-Host

If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ASCII-Banner
@"

      ░██████                                  ░██                                 
     ░██   ░██                                                                     
    ░██          ░███████  ░██░████ ░██    ░██ ░██ ░███████   ░███████   ░███████  
     ░████████  ░██    ░██ ░███     ░██    ░██ ░██░██    ░██ ░██    ░██ ░██        
            ░██ ░█████████ ░██       ░██  ░██  ░██░██        ░█████████  ░███████  
     ░██   ░██  ░██        ░██        ░██░██   ░██░██    ░██ ░██               ░██ 
      ░██████    ░███████  ░██         ░███    ░██ ░███████   ░███████   ░███████  
                                                                               
                                                                               
"@ | Write-Host -ForegroundColor Cyan

$servicesToCheck = @(
    "PcaSvc",
    "DPS",
    "DiagTrack",
    "SysMain",
    "EventLog",
    "SgrmBroker"
)

$servicesToCheck = @(
    "PcaSvc",
    "DPS",
    "DiagTrack",
    "SysMain",
    "EventLog",
    "SgrmBroker"
)

$cdpDynamic = Get-Service | Where-Object { $_.Name -like "CDPUserSvc*" } | Select-Object -ExpandProperty Name
$servicesToCheck += $cdpDynamic

$processesToCheck = @(
    "explorer",
    "lsass",
    "taskhostw",
    "csrss"
)

Write-Host ""
Write-Host ("{0,-25} {1,-12} {2,-8} {3}" -f "Name", "Status", "PID", "Startzeit") -ForegroundColor Yellow
Write-Host ("".PadRight(70, "-"))

foreach ($name in $servicesToCheck) {
    $svc = Get-CimInstance Win32_Service -Filter "Name = '$name'" -ErrorAction SilentlyContinue
    if ($svc) {
        $proc = Get-Process -Id $svc.ProcessId -ErrorAction SilentlyContinue
        $start = if ($proc) { $proc.StartTime } else { "-" }
        Write-Host ("{0,-25} {1,-12} {2,-8} {3}" -f $svc.Name, $svc.State, $svc.ProcessId, $start)
    } else {
        Write-Host ("{0,-25} {1,-12} {2,-8} {3}" -f $name, "Stopped", "-", "-") -ForegroundColor Red
    }
}

foreach ($procName in $processesToCheck) {
    $procs = Get-Process -Name $procName -ErrorAction SilentlyContinue
    if ($procs) {
        foreach ($proc in $procs) {
            try {
                $start = $proc.StartTime
                $status = "Running"
            } catch {
                $start = "-"
                $status = "Zugriff verweigert"
            }
            Write-Host ("{0,-25} {1,-12} {2,-8} {3}" -f $proc.ProcessName, $status, $proc.Id, $start)
        }
    } else {
        Write-Host ("{0,-25} {1,-12} {2,-8} {3}" -f $procName, "Nicht gefunden", "-", "-") -ForegroundColor DarkGray
    }

}





