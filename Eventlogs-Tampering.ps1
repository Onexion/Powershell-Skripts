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
    @{ Log = "Security";    IDs = 4656 }
)


$foundEvents = @()

foreach ($search in $searches) {
    $events = Get-WinEvent -FilterHashtable @{ LogName = $search.Log; Id = $search.IDs } -ErrorAction SilentlyContinue
    if ($events) {
        $foundEvents += $events
    }
}

if ($foundEvents.Count -gt 0) {
    $foundEvents | Select-Object TimeCreated, Id, ProviderName, @{Name="Message";Expression={$_.Message -replace "`r`n","\n"}} | 
        Format-Table -AutoSize
} else {
    Write-Host "
    45 76 65 6E 74 6C 6F 67 73  63 6C 65 61 6E 
" -ForegroundColor Green
}
