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
        Select-Object TimeCreated, Id, ProviderName, @{Name="Message";Expression={$_.Message -replace "`r`n","\n"}} |
        Format-Table -AutoSize
} else {
    Write-Host "`n45 76 65 6E 74 6C 6F 67 73 20 63 6C 65 61 6E`n" -ForegroundColor Green
}


