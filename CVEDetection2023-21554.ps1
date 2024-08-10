<#
    .SYNOPSIS
        CVE Detection - CVE-2023-21554
    .DESCRIPTION
        This script checks whether the Microsoft Message Queuing (MSMQ) service is installed and then checks whether the April 2023 security update KBs have been installed patching for CVE-2023-21554.
    .NOTES
        2023-04-13: Change the comparison logic when testing if the update is installed to use `Compare-Object`.
        2023-04-13: Initial version
    .LINK
        Blog post: https://homotechsual.dev/2023/03/15/CVE-Monitoring-NinjaOne/
#>
[CmdletBinding()]
param ()
# Prepare variables and data sources.
$April2023SecurityUpdateKBs = @(
    'KB5025285',
    'KB5025288',
    'KB5025287',
    'KB5025272',
    'KB5025279',
    'KB5025277',
    'KB5025271',
    'KB5025228',
    'KB5025234',
    'KB5025221',
    'KB5025239',
    'KB5025224',
    'KB5025230'
)
$MSMQServices = Get-WindowsOptionalFeature -FeatureName 'MSMQ*' -Online | Where-Object -Property 'State' -EQ 'Enabled'
$InstalledKBs = [System.Collections.Generic.List[string]]::New()
$Hotfixes = Get-Hotfix | Select-Object -ExpandProperty HotFixID
$WUSession = New-Object -ComObject 'Microsoft.Update.Session'
$WUSearcher = $WUSession.CreateUpdateSearcher()
$WUHistoryCount = $WUSearcher.GetTotalHistoryCount()
# Logic loops
if (-not ($MSMQServices)) {
    Write-Output 'MSMQ services not installed'
    $Vulnerable = $false
}
if ($null -eq $Vulnerable) {
    if ($Hotfixes.count -gt 0) {
        foreach ($Hotfix in $Hotfixes) {
            $InstalledKBs.Add($Hotfix)
        }
    }
    if ($WUHistoryCount -gt 0) {
        $UpdateHistory = $WUSearcher.QueryHistory(0, $WUHistoryCount) | ForEach-Object { [regex]::match($_.Title,'(KB\d+)').Value }
        $UpdateHistory = $UpdateHistory | Where-Object { $_ -Match '\S' } | Sort-Object -Unique
        foreach ($Update in $UpdateHistory) {
            if ($Update.HistoryID -match 'KB\d+') {
                $InstalledKBs.Add($Matches[0])
            }
        }
    }
    Write-Output $InstalledKBs
    $InstalledAprilSecurityUpdates = Compare-Object -ReferenceObject $April2023SecurityUpdateKBs -DifferenceObject $InstalledKBs -IncludeEqual -ExcludeDifferent
    if ($InstalledAprilSecurityUpdates) {
        Write-Output ('Found April 2023 security update.')
        $Vulnerable = $false
    } else {
        $Vulnerable = $true
    }
}
if ($true -eq $Vulnerable) {
    Write-Warning 'Vulnerable to CVE-2023-21554'
    Ninja-Property-Set CVE202321554 1
} elseif ($false -eq $Vulnerable) {
    Write-Output 'Not vulnerable to CVE-2023-21554'
    Ninja-Property-Set CVE202321554 0
} else {
    Write-Warning 'Could not determine vulnerability status.'
}