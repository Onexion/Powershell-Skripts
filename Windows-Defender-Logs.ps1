Write-Host
Clear-Host

Write-Host
Write-Host
Write-Host "    ███████╗██╗   ██╗███████╗███╗   ██╗████████╗ ██╗      ██████╗  ██████╗ ███████╗" -ForegroundColor Cyan
Write-Host "    ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝ ██║     ██╔═══██╗██╔════╝ ██╔════╝" -ForegroundColor Cyan
Write-Host "    █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║    ██║     ██║   ██║██║  ███╗███████╗" -ForegroundColor Cyan
Write-Host "    ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║    ██║     ██║   ██║██║   ██║╚════██║" -ForegroundColor Cyan
Write-Host "    ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║    ███████╗╚██████╔╝╚██████╔╝███████║" -ForegroundColor Cyan
Write-Host "    ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝    ╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝" -ForegroundColor Cyan
Write-Host
Write-Host
Write-Host "Windows Protection History" -ForegroundColor Cyan
Write-Host 


function Get-DefenderCompleteHistory {

    $results = @()

    try {
        $threats = Get-MpThreatDetection -ErrorAction Stop
        foreach ($t in $threats) {
            $results += [PSCustomObject]@{
                Source       = "ProtectionHistory"
                Time         = $t.InitialDetectionTime
                Type         = "Detection"
                Threat       = $t.ThreatName
                Category     = $t.Category
                Path         = ($t.Resources | Select-Object -First 1).Path
                Process      = ""
                Action       = if ($t.ActionSuccess) { "Success" } else { "Failed" }
                EventID      = "-"
            }
        }
    } catch {
        Write-Warning "Get-MpThreatDetection is not available or no threats found."
    }

    $logName = "Microsoft-Windows-Windows Defender/Operational"
    if (Get-WinEvent -ListLog $logName -ErrorAction SilentlyContinue) {
        $events = Get-WinEvent -LogName $logName -FilterXPath "*[System[(EventID=1116 or EventID=1117)]]" -ErrorAction SilentlyContinue |
            Sort-Object TimeCreated -Descending

        foreach ($event in $events) {
            $text = $event.Message

            $threat   = if ($text -match "Name:\s*(.+)") { $matches[1].Trim() } else { "" }
            $category = if ($text -match "Kategorie:\s*(.+)") { $matches[1].Trim() } else { "" }
            $path     = if ($text -match "Pfad:\s*(.+)") { $matches[1].Trim() } else { "" }
            $source   = if ($text -match "Erkennungsquelle:\s*(.+)") { $matches[1].Trim() } else { "" }
            $process  = if ($text -match "Prozessname:\s*(.+)") { $matches[1].Trim() } else { "" }
            $action   = if ($text -match "Aktion:\s*(.+)") { $matches[1].Trim() } else { "" }

            $results += [PSCustomObject]@{
                Source       = "EventLog $($event.Id)"
                Time         = $event.TimeCreated
                Type         = if ($event.Id -eq 1116) { "Detection" } else { "Action" }
                Threat       = $threat
                Category     = $category
                Path         = $path
                Process      = $process
                Action       = $action
                EventID      = $event.Id
            }
        }
    } else {
        Write-Warning "Event log not found: $logName"
    }

    if ($results.Count -gt 0) {
        $results | Sort-Object Time -Descending | Out-GridView -Title "Windows Defender: Full Detection History"
    } else {
        Write-Warning "No Defender entries found in Event Log or Protection History."
    }
}


Get-DefenderCompleteHistory

