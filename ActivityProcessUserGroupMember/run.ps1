param($param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

$start = (Get-Date).ToString()
Write-Log "Processing member '$($param.UserGroupMemberName)' from user group '$($param.UserGroupName)': started=$($start)"

Start-Sleep -Seconds $param.Seconds
$end = (Get-Date).ToString()

Write-Log "Finished processing member '$($param.UserGroupMemberName)' from user group '$($param.UserGroupName)': started=$($start), ended=$($end)"
