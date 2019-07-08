function Get-MailboxSyncLicense {
    <#
    .SYNOPSIS
    Gets Office 365 licenses during a migration project
    Either CSV or Excel file from SharePoint can be used
    Out-GridView is used for each user.
    Helpful for a maximum of 10-20 users as each user opens in their own window

    .DESCRIPTION
    Gets Office 365 licenses during a migration project
    Either CSV or Excel file from SharePoint can be used
    Out-GridView is used for each user.
    Helpful for a maximum of 10-20 users as each user opens in their own window

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batchex.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER Tenant
    This is the tenant domain - where you are migrating to.
    Example if tenant is contoso.mail.onmicrosoft.com use contoso

    .EXAMPLE
    Get-MailboxSyncLicense -Tenant Contoso -MailboxCSV c:\scripts\batches.csv -GroupsToAddUserTo "Office 365 E3"

    .EXAMPLE
    Get-MailboxSyncLicense -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx' -Tenant Contoso

    .NOTES
    General notes
    #>

    [CmdletBinding(DefaultParameterSetName = 'SharePoint')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $SharePointURL,

        [Parameter(Mandatory, ParameterSetName = 'SharePoint')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ExcelFile,

        [Parameter(Mandatory, ParameterSetName = 'CSV')]
        [ValidateNotNullOrEmpty()]
        [string]
        $MailboxCSV,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Tenant
    )
    end {
        if ($Tenant -notmatch '.mail.onmicrosoft.com') {
            $Tenant = '{0}.mail.onmicrosoft.com' -f $Tenant
        }
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                    Tenant        = $Tenant
                }
                $UserChoice = Import-SharePointExcelDecision @SharePointSplat
            }
            'CSV' {
                $UserChoice = Import-MailboxCsvDecision -MailboxCSV $MailboxCSV
            }
        }
        if ($UserChoice -ne 'Quit' ) {
            ($UserChoice).UserPrincipalName | Set-CloudLicense -ReportUserLicensesEnabled
        }
    }
}