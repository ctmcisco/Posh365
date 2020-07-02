function Get-GraphMailFolderMessage {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory)]
        [string]
        $Tenant,

        [Parameter(Mandatory)]
        [ValidateSet('archive', 'clutter', 'conflicts', 'conversationhistory', 'DeletedItems', 'drafts', 'Inbox', 'junkemail', 'localfailures', 'msgfolderroot', 'outbox', 'recoverableitemsdeletions', 'scheduled', 'searchfolders', 'sentitems', 'serverfailures', 'syncissues')]
        $WellKnownFolder,

        [Parameter()]
        [datetime]
        $MessagesOlderThan,

        [Parameter()]
        [datetime]
        $MessagesNewerThan,

        [Parameter(ValueFromPipeline)]
        $MailboxList

    )
    begin {
        if ($MessagesOlderThan -and $MessagesNewerThan) {
            Write-Host 'Choose only one date, MessagesOlderThan OR MessagesNewerThan' -ForegroundColor Red
            return
        }
        if ($MessagesOlderThan) {
            $filter = "/?`$filter=ReceivedDateTime le {0}" -f $MessagesOlderThan.ToUniversalTime().ToString('O')
            $Uri = "/messages{0}" -f $filter
        }
        if ($MessagesNewerThan) {
            $filter = "/?`$filter=ReceivedDateTime ge {0}" -f $MessagesNewerThan.ToUniversalTime().ToString('O')
            $Uri = "/messages{0}" -f $filter
        }
        else {
            $Uri = "/messages"
        }
    }
    process {
        foreach ($Mailbox in $MailboxList) {
            $RestSplat = @{
                Uri     = "https://graph.microsoft.com/beta/users/{0}/mailFolders('{1}'){2}" -f $Mailbox.UserPrincipalName, $WellKnownFolder, $Uri
                Headers = @{ "Authorization" = "Bearer $Token" }
                Method  = 'Get'
            }
            do {
                if ([datetime]::UtcNow -ge $Script:TimeToRefresh) { Connect-PoshGraphRefresh}
                try {
                    $MessageList = Invoke-RestMethod @RestSplat -Verbose:$false
                    if ($MessageList.'@odata.nextLink' -match 'skip') { $Next = $MessageList.'@odata.nextLink' }
                    else { $Next = $null }

                    $RestSplat = @{
                        Uri     = $Next
                        Headers = @{ "Authorization" = "Bearer $Token" }
                        Method  = 'Get'
                    }
                    foreach ($Message in $MessageList.Value) {
                        [PSCustomObject]@{
                            DisplayName          = $Mailbox.DisplayName
                            UserPrincipalName    = $Mailbox.UserPrincipalName
                            Mail                 = $Mailbox.Mail
                            Sender               = $Message.Sender
                            from                 = $Message.from
                            replyTo              = $Message.replyTo
                            toRecipients         = $Message.toRecipients
                            Subject              = $Message.Subject
                            Body                 = $Message.Body
                            BodyPreview          = $Message.BodyPreview
                            Id                   = $Message.Id
                            ParentFolderId       = $Message.parentFolderId
                            ReceivedDateTime     = $Message.ReceivedDateTime
                            sentDateTime         = $Message.sentDateTime
                            createdDateTime      = $Message.createdDateTime
                            lastModifiedDateTime = $Message.lastModifiedDateTime
                        }
                    }
                }
                catch { Write-Host "$($Mailbox.UserPrincipalName) ERROR: $($_.Exception.Message)" -ForegroundColor Red }
            } until (-not $next)
        }
    }
}