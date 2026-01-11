Write-Host ""
Clear-Host

If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Show-Spinner {
    param(
        [int]$DurationMs = 2000,
        [int]$Percent = 0 
    )

    $spinner = @('|','/','-','\')
    $startTime = Get-Date
    $i = 0

    while ((Get-Date) -lt $startTime.AddMilliseconds($DurationMs)) {
        $char = $spinner[$i % $spinner.Length]
        Write-Host -NoNewline "`r$char Loading... $Percent%"
        Start-Sleep -Milliseconds 150
        $i++
    }
}

function Get-DefenderCompleteHistory {

    $results = @()

    Show-Spinner -DurationMs 1500 -Percent 10
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

    Show-Spinner -DurationMs 2000 -Percent 40
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

        Show-Spinner -DurationMs 1500 -Percent 70
        $events5007 = Get-WinEvent -LogName $logName -FilterXPath "*[System[(EventID=5007)]]" -ErrorAction SilentlyContinue |
            Sort-Object TimeCreated -Descending

        foreach ($event in $events5007) {
            $xml = [xml]$event.ToXml()
            $oldValue = ($xml.Event.EventData.Data | Where-Object { $_.Name -eq "Old Value" }).'#text'

            if ($oldValue -match "Exclusions\\Paths\\(.+?)\s*=") {
                $path = $matches[1]

                $results += [PSCustomObject]@{
                    Source       = "ExclusionChange"
                    Time         = $event.TimeCreated
                    Type         = "ExclusionRemoved"
                    Threat       = ""
                    Category     = ""
                    Path         = $path
                    Process      = ""
                    Action       = "Removed"
                    EventID      = $event.Id
                }
            }
        }
    } else {
        Write-Warning "Event log not found: $logName"
    }

    Show-Spinner -DurationMs 1000 -Percent 100

    if ($results.Count -gt 0) {
        Clear-Host
        Write-Host "`rDone!`n"
        $results | Sort-Object Time -Descending | Out-GridView -Title "Windows Defender: Full Detection History"
    } else {
        Write-Warning "No Defender entries found in Event Log or Protection History."
    }
}

Get-DefenderCompleteHistory

