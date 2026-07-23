#requires -Version 5.1
#requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [string]$ExportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
Import-Module ActiveDirectory

$domainControllers = Get-ADDomainController -Filter * | Sort-Object HostName
$results = foreach ($dc in $domainControllers) {
    $partnerMetadata = Get-ADReplicationPartnerMetadata -Target $dc.HostName -Scope Server -ErrorAction SilentlyContinue

    if (-not $partnerMetadata) {
        [pscustomobject]@{
            DomainController      = $dc.HostName
            Site                  = $dc.Site
            Partner               = $null
            Partition             = $null
            LastSuccess           = $null
            ConsecutiveFailures   = $null
            LastResult            = 'No replication metadata returned'
            Healthy               = $false
        }
        continue
    }

    foreach ($partner in $partnerMetadata) {
        [pscustomobject]@{
            DomainController      = $dc.HostName
            Site                  = $dc.Site
            Partner               = $partner.Partner
            Partition             = $partner.Partition
            LastSuccess           = $partner.LastReplicationSuccess
            ConsecutiveFailures   = $partner.ConsecutiveReplicationFailures
            LastResult            = $partner.LastReplicationResult
            Healthy               = ($partner.LastReplicationResult -eq 0 -and $partner.ConsecutiveReplicationFailures -eq 0)
        }
    }
}

$results | Sort-Object Healthy,DomainController,Partition | Format-Table -AutoSize

$failed = @($results | Where-Object { -not $_.Healthy })
Write-Host "`nReplication links checked: $($results.Count)" -ForegroundColor Cyan
if ($failed.Count -eq 0) {
    Write-Host 'No failed inbound replication links were detected.' -ForegroundColor Green
}
else {
    Write-Warning "$($failed.Count) unhealthy or unverified replication links were detected."
    Write-Host 'Recommended follow-up: repadmin /replsummary, repadmin /showrepl * /errorsonly, dcdiag /test:replications' -ForegroundColor Yellow
}

if ($ExportPath) {
    $parent = Split-Path -Parent $ExportPath
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Report exported to $ExportPath" -ForegroundColor Green
}

if ($failed.Count -gt 0) { exit 2 }
