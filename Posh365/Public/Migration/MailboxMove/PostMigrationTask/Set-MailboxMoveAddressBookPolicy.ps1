function Set-MailboxMoveAddressBookPolicy {
    <#
    .SYNOPSIS
    Sets Office 365 Address Book Policy during a migration project
    Either CSV or Excel file from SharePoint can be used

    .DESCRIPTION
    Sets Office 365 Address Book Policy during a migration project
    Either CSV or Excel file from SharePoint can be used

    .PARAMETER SharePointURL
    Sharepoint url ex. https://fabrikam.sharepoint.com/sites/Contoso

    .PARAMETER ExcelFile
    Excel file found in "Shared Documents" of SharePoint site specified in SharePointURL
    ex. "Batches.xlsx"
    Minimum headers required are: BatchName, UserPrincipalName

    .PARAMETER MailboxCSV
    Path to csv of mailboxes. Minimum headers required are: BatchName, UserPrincipalName

    .EXAMPLE
    Set-MailboxMoveAddressBookPolicy -MailboxCSV c:\scripts\batches.csv

    .EXAMPLE
    Set-MailboxMoveAddressBookPolicy -SharePointURL 'https://fabrikam.sharepoint.com/sites/Contoso' -ExcelFile 'Batches.xlsx'

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
        $MailboxCSV
    )
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'SharePoint' {
                $SharePointSplat = @{
                    SharePointURL = $SharePointURL
                    ExcelFile     = $ExcelFile
                }
                Invoke-SetMailboxMoveAddressBookPolicy @SharePointSplat | Out-GridView -Title "Results of Set Mailbox Address Book Policy"
            }
            'CSV' {
                $CSVSplat = @{
                    MailboxCSV = $MailboxCSV
                }
                Invoke-SetMailboxMoveAddressBookPolicy @CSVSplat | Out-GridView -Title "Results of Set Mailbox Address Book Policy"
            }
        }
    }
}
