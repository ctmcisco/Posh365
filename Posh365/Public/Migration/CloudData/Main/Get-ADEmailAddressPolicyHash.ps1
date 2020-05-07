function Get-ADEmailAddressPolicyHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $DomainController
    )
    if (-not (Get-Module -Name 'ActiveDirectory' -ListAvailable)) {
        Write-Host "ActiveDirectory Module not present. Halting." -ForegroundColor Red
        contine
    }
    $BadEAPHash = @{ }
    $ADUserList = Get-ADUser -server $DomainController -Filter * -Properties msExchPoliciesIncluded, msExchPoliciesExcluded, DisplayName
    foreach ($ADUser in $ADUserList) {
        if ($ADUser.msExchPoliciesIncluded -or
            $ADUser.msExchPoliciesExcluded.Count -gt 1 -or
            ($ADUser.msExchPoliciesExcluded -and $ADUser.msExchPoliciesExcluded -ne '{26491CFC-9E50-4857-861B-0CB8DF22B5D7}')) {
            $BadEAPHash[$ADUser.ObjectGUID] = @{
                msExchPoliciesIncluded = $ADUser.msExchPoliciesIncluded
                msExchPoliciesExcluded = $ADUser.msExchPoliciesExcluded
                DisplayName            = $ADUser.DisplayName
                UserPrincipalName      = $ADUser.UserPrincipalName
            }
        }
    }
    $BadEAPHash
}
