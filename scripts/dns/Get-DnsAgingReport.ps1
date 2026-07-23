#requires -Version 5.1
#requires -Modules DnsServer

[CmdletBinding()]
param(
    [string]$DnsServer = $env:COMPUTERNAME,
    [string[]]$ZoneName,
    [string]$ExportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module DnsServer

try {
    $serverScavenging = Get-DnsServerScavenging -ComputerName $DnsServer
    Write-Host "DNS server: $DnsServer" -ForegroundColor Cyan
    $serverScavenging | Format-List

    $zones = if ($ZoneName) {
        foreach ($zone in $ZoneName) {
            Get-DnsServerZone -ComputerName $DnsServer -Name $zone
        }
    }
    else {
        Get-DnsServerZone -ComputerName $DnsServer |
            Where-Object { -not $_.IsAutoCreated -and -not $_.IsReverseLookupZone }
    }

    $report = foreach ($zone in $zones) {
        $aging = Get-DnsServerZoneAging -ComputerName $DnsServer -Name $zone.ZoneName
        $records = Get-DnsServerResourceRecord -ComputerName $DnsServer -ZoneName $zone.ZoneName

        [pscustomobject]@{
            ZoneName          = $zone.ZoneName
            ZoneType          = $zone.ZoneType
            IsDsIntegrated    = $zone.IsDsIntegrated
            AgingEnabled      = $aging.AgingEnabled
            NoRefreshInterval = $aging.NoRefreshInterval
            RefreshInterval   = $aging.RefreshInterval
            DynamicRecords    = @($records | Where-Object Timestamp).Count
            StaticRecords     = @($records | Where-Object { -not $_.Timestamp }).Count
            TotalRecords      = @($records).Count
        }
    }

    $report | Sort-Object ZoneName | Format-Table -AutoSize

    if ($ExportPath) {
        $parent = Split-Path -Parent $ExportPath
        if ($parent -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        $report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        Write-Host "Report exported to $ExportPath" -ForegroundColor Green
    }
}
catch {
    Write-Error "DNS aging report failed: $($_.Exception.Message)"
    exit 1
}
