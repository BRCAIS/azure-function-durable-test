param($Param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Getting members for user group '$($param.UserGroupName)'"

$userGroups = @{
    "UserGroupA" = @(
        "UserA1"
        "UserA2"
        "UserA3"
    )
    "UserGroupB" = @(
        "UserB1"
        "UserB2"
        "UserB3"
    )
    "UserGroupC" = @(
        "UserC1"
        "UserC2"
        "UserC3"
    )
}

$userGroupMembers = $userGroups.$($param.UserGroupName)

Write-Log "Found $($userGroupMembers.Count) members in user group '$($param.UserGroupName)'"
return $userGroupMembers
