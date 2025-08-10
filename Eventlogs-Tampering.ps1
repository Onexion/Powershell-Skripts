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
    @{ Log = "Security";    IDs = 1102 },
    @{ Log = "Application"; IDs = 104 },
    @{ Log = "Application"; IDs = 3079 },
    @{ Log = "Security";    IDs = 4663 },
    @{ Log = "Security";    IDs = 4660 },
    @{ Log = "Security";    IDs = 4656 },
    @{ Log = "Microsoft-Windows-Windows Defender/Operational"; IDs = 5001 },
    @{ Log = "Microsoft-Windows-Windows Defender/Operational"; IDs = 5004 },
    @{ Log = "Microsoft-Windows-VHDMP/Operational"; IDs = 100 },
    @{ Log = "Microsoft-Windows-VHDMP/Operational"; IDs = 101 }
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
        Select-Object TimeCreated, Id, ProviderName, @{Name="Message";Expression={$_.Message -replace "`r`n","\n"}} |
        Format-Table -AutoSize
} else {
    Write-Host "`n45 76 65 6E 74 6C 6F 67 73 20 63 6C 65 61 6E`n" -ForegroundColor Green
}
