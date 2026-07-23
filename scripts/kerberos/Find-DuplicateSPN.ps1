#requires -Version 5.1
#requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [string]$SearchBase,
    [string]$ExportPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    Import-Module ActiveDirectory

    $params = @{
        LDAPFilter = '(servicePrincipalName=*)'
        Properties = @('servicePrincipalName')
    }
    if ($SearchBase) { $params.SearchBase = $SearchBase }

    $objects = Get-ADObject @params
    $rows = foreach ($object in $objects) {
        foreach ($spn in $object.servicePrincipalName) {
            [pscustomobject]@{
                SPN               = $spn
                ObjectName        = $object.Name
                DistinguishedName = $object.DistinguishedName
                ObjectClass       = $object.ObjectClass
            }
        }
    }

    $duplicates = $rows |
        Group-Object SPN |
        Where-Object Count -gt 1 |
        ForEach-Object { $_.Group } |
        Sort-Object SPN, DistinguishedName

    if (-not $duplicates) {
        Write-Host 'No duplicate SPNs were found.' -ForegroundColor Green
        return
    }

    $duplicates | Format-Table -AutoSize

    if ($ExportPath) {
        $parent = Split-Path -Parent $ExportPath
        if ($parent -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        $duplicates | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
    }

    Write-Warning 'Review ownership before removing any SPN. Prefer setspn -S when adding SPNs.'
}
catch {
    Write-Error "Duplicate SPN scan failed: $($_.Exception.Message)"
    exit 1
}
