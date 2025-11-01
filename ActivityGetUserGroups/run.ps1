param($param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Getting user groups"

$userGroups = @(
    "UserGroupA"
    "UserGroupB"
    "UserGroupC"
)

Write-Log "Found $($userGroups.Count) user groups"
return $userGroups
