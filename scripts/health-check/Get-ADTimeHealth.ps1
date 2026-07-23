#requires -Version 5.1
#requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [string]$ExportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'
Import-Module ActiveDirectory

$pdc = (Get-ADDomain).PDCEmulator
$computers = Get-ADDomainController -Filter * | Sort-Object HostName

$results = foreach ($dc in $computers) {
    $name = $dc.HostName
    $source = (& w32tm /query /computer:$name /source 2>&1 | Out-String).Trim()
    $status = (& w32tm /query /computer:$name /status 2>&1 | Out-String).Trim()
    $offset = $null
    $lastSync = $null

    if ($status -match 'Phase Offset:\s+([^\r\n]+)') { $offset = $matches[1].Trim() }
    if ($status -match 'Last Successful Sync Time:\s+([^\r\n]+)') { $lastSync = $matches[1].Trim() }

    [pscustomobject]@{
        DomainController = $name
        Site             = $dc.Site
        IsPDCEmulator    = ($name -ieq $pdc)
        TimeSource       = $source
        PhaseOffset      = $offset
        LastSync         = $lastSync
        QuerySucceeded   = ($LASTEXITCODE -eq 0)
    }
}

$results | Format-Table -AutoSize

Write-Host "`nForest-root domain PDC Emulator: $pdc" -ForegroundColor Cyan
Write-Host 'Expected: PDC uses an approved external source; other DCs use the domain hierarchy.' -ForegroundColor Cyan

if ($ExportPath) {
    $parent = Split-Path -Parent $ExportPath
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    Write-Host "Report exported to $ExportPath" -ForegroundColor Green
}
