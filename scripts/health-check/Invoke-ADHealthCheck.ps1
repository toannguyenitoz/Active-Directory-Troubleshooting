#requires -Version 5.1
<#
.SYNOPSIS
    Performs a read-only starter health check for an Active Directory environment.

.DESCRIPTION
    Collects domain information, FSMO role holders, Domain Controller services,
    SYSVOL/NETLOGON shares, DCDIAG results, replication summary, DNS diagnostics,
    and recent critical AD-related events.

.NOTES
    Author: Xuan Toan Nguyen
    Repository: https://github.com/toannguyenitoz/Active-Directory-Troubleshooting
    Run from an elevated PowerShell session with RSAT/AD DS tools installed.
#>

[CmdletBinding()]
param(
    [string]$OutputPath = (Join-Path $PWD ("AD-HealthCheck-{0}.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))),
    [int]$EventLookbackHours = 24
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

function Write-Section {
    param([Parameter(Mandatory)][string]$Title)
    $line = '=' * 78
    "`n$line`n$Title`n$line" | Tee-Object -FilePath $OutputPath -Append
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory)][string]$Label,
        [Parameter(Mandatory)][scriptblock]$Command
    )

    Write-Section $Label
    try {
        & $Command 2>&1 | Out-String -Width 240 | Tee-Object -FilePath $OutputPath -Append
    }
    catch {
        "ERROR: $($_.Exception.Message)" | Tee-Object -FilePath $OutputPath -Append
    }
}

"Active Directory Health Check" | Set-Content -Path $OutputPath -Encoding UTF8
"Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')" | Add-Content -Path $OutputPath
"Computer: $env:COMPUTERNAME" | Add-Content -Path $OutputPath
"User: $env:USERDOMAIN\$env:USERNAME" | Add-Content -Path $OutputPath

Invoke-LoggedCommand -Label 'Operating System and Host Information' -Command {
    Get-CimInstance Win32_OperatingSystem |
        Select-Object Caption, Version, BuildNumber, LastBootUpTime
    Get-CimInstance Win32_ComputerSystem |
        Select-Object Name, Domain, DomainRole
}

Invoke-LoggedCommand -Label 'Active Directory Domain Information' -Command {
    Import-Module ActiveDirectory -ErrorAction Stop
    Get-ADDomain | Format-List DNSRoot, NetBIOSName, DomainMode, PDCEmulator, RIDMaster, InfrastructureMaster
    Get-ADForest | Format-List Name, ForestMode, SchemaMaster, DomainNamingMaster, GlobalCatalogs, Sites
}

Invoke-LoggedCommand -Label 'Domain Controllers' -Command {
    Get-ADDomainController -Filter * |
        Sort-Object Site, HostName |
        Format-Table HostName, Site, IPv4Address, IsGlobalCatalog, OperationMasterRoles -AutoSize
}

Invoke-LoggedCommand -Label 'Core AD Services on Local Computer' -Command {
    $services = 'NTDS','DNS','DFSR','KDC','Netlogon','W32Time','ADWS'
    Get-Service -Name $services -ErrorAction SilentlyContinue |
        Sort-Object Name |
        Format-Table Name, Status, StartType -AutoSize
}

Invoke-LoggedCommand -Label 'SYSVOL and NETLOGON Shares' -Command {
    Get-SmbShare -Name SYSVOL, NETLOGON -ErrorAction SilentlyContinue |
        Format-Table Name, Path, Description -AutoSize
}

Invoke-LoggedCommand -Label 'DCDIAG Summary' -Command {
    dcdiag /q
    if ($LASTEXITCODE -eq 0) {
        'DCDIAG /q returned no errors.'
    }
}

Invoke-LoggedCommand -Label 'DCDIAG DNS Test' -Command {
    dcdiag /test:dns /e /v
}

Invoke-LoggedCommand -Label 'Replication Summary' -Command {
    repadmin /replsummary
}

Invoke-LoggedCommand -Label 'Replication Details' -Command {
    repadmin /showrepl * /errorsonly
}

Invoke-LoggedCommand -Label 'Time Synchronization' -Command {
    w32tm /query /status
    w32tm /query /source
}

Invoke-LoggedCommand -Label 'Recent Critical AD Events' -Command {
    $start = (Get-Date).AddHours(-1 * $EventLookbackHours)
    $logs = 'Directory Service','DNS Server','DFS Replication','System'

    foreach ($log in $logs) {
        "`n--- $log ---"
        Get-WinEvent -FilterHashtable @{ LogName = $log; StartTime = $start; Level = 1,2 } -ErrorAction SilentlyContinue |
            Select-Object -First 50 TimeCreated, Id, LevelDisplayName, ProviderName, Message |
            Format-List
    }
}

Write-Section 'Completion'
"Report saved to: $OutputPath" | Tee-Object -FilePath $OutputPath -Append
Write-Host "Health check complete. Report: $OutputPath" -ForegroundColor Green
