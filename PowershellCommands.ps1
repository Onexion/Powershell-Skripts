Write-Host
Clear-Host
@"

███████╗██╗   ██╗███████╗     ██████╗ ██████╗ ███╗   ███╗███╗   ███╗ █████╗ ███╗   ██╗██████╗ ███████╗
██╔════╝██║   ██║██╔════╝    ██╔════╝██╔═══██╗████╗ ████║████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝
███████╗██║   ██║███████╗    ██║     ██║   ██║██╔████╔██║██╔████╔██║███████║██╔██╗ ██║██║  ██║███████╗
╚════██║██║   ██║╚════██║    ██║     ██║   ██║██║╚██╔╝██║██║╚██╔╝██║██╔══██║██║╚██╗██║██║  ██║╚════██║
███████║╚██████╔╝███████║    ╚██████╗╚██████╔╝██║ ╚═╝ ██║██║ ╚═╝ ██║██║  ██║██║ ╚████║██████╔╝███████║
╚══════╝ ╚═════╝ ╚══════╝     ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝

"@ | Write-Host -ForegroundColor Cyan


$patterns = @{
    "Fileless Execution" = @(
        "IEX",
        "Invoke-Expression",
        "DownloadString",
        "Invoke-WebRequest",
        "-EncodedCommand",
        "-ExecutionPolicy\s+Bypass",
        "FromBase64String",
        "System\.Convert"
    )
    "EventLog Cleaning" = @(
        "wevtutil\s+cl",
        "Clear-EventLog",
        "Remove-EventLog"
    )
    "ADS Creation" = @(
        ":\w+(\.\w+)?",
        "Set-Content.+-Stream",
        "Get-Content.+:\w+",
        "Zone\.Identifier"
    )
    "Process Injection" = @(
        "CreateRemoteThread",
        "WriteProcessMemory",
        "VirtualAllocEx",
        "OpenProcess"
    )
    "Network Activity" = @(
        "Invoke-WebRequest",
        "Invoke-RestMethod",
        "New-Object\s+System.Net.WebClient"
    )
    "Local Script Execution" = @(
        "\\.\\"
    )
}

$allowedExtensions = @('ps1','exe','bat')

function Get-SuspicionScore {
    param($command)
    $score = 0
    foreach ($cat in $patterns.Keys) {
        foreach ($pat in $patterns[$cat]) {
            if ($command -match $pat) { $score += 1 }
        }
    }
    return $score
}

function Is-AdminUser {
    param($userName)
    $adminIndicators = @('administrator','system')
    foreach ($adm in $adminIndicators) {
        if ($userName -match ("(?i)" + [regex]::Escape($adm))) { return $true }
    }
    return $false
}

Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" `
    -FilterXPath "*[System[(EventID=4104)]]" -ErrorAction SilentlyContinue |
ForEach-Object {
    try {
        $command = $_.Properties[2].Value
        $time    = $_.TimeCreated
        $user    = $_.Properties[1].Value
        $pid_    = $_.Properties[0].Value
    }
    catch { return }

    if ($command -match '(?mi)^#\s*requires\s+-version\s+\d+(\.\d+)?') { return }

    $tags = @()
    foreach ($category in $patterns.Keys) {
        foreach ($pattern in $patterns[$category]) {
            if ($command -match $pattern) {
                if ($category -in @("Fileless Execution","ADS Creation")) {
                    if ($command -notmatch '\.(ps1|exe|bat)(\s|$|\\|")') { continue }
                }
                $tags += $category
                break
            }
        }
    }

    if ($tags.Count -gt 0) {
        $score = Get-SuspicionScore -command $command

        $execPolicyBypass = $false
        if ($command -match "-ExecutionPolicy\s+Bypass") { $execPolicyBypass = $true }

        $isAdmin = Is-AdminUser -userName $user

        if ($score -ge 2) {
            [PSCustomObject]@{
                Time                 = $time
                User                 = $user
                PID                  = $pid_
                Category             = ($tags | Sort-Object -Unique) -join ", "
                Score                = $score
                ExecutionPolicyBypass = $execPolicyBypass
                AdminContext         = $isAdmin
                Command              = $command -replace "`r?`n", " "
            }
        }
    }
} |
Sort-Object -Property Score, Time -Descending |
Out-GridView -Title "Suspicious PowerShell Commands – Prioritized by Score"

Write-Host ""
Write-Host "Options:"
Write-Host "1 - Open PSReadLine folder"
Write-Host "2 - Exit script"
Write-Host ""

$userInput = Read-Host "Please enter 1 or 2"

switch ($userInput) {
    '1' {
        $user = $env:USERNAME
        $path = "C:\Users\$user\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine"
        if (Test-Path $path) {
            Write-Host "Opening folder: $path"
            Start-Process explorer.exe $path
        }
        else {
            Write-Warning "Path not found: $path"
        }
    }
    '2' {
        Write-Host "Exiting script."
    }
    default {
        Write-Warning "Invalid input: $userInput"
    }
}
