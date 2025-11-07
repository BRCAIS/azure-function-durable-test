param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Running sub orchestrator for user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context

$retryPolicyParameters = @{
    BackoffCoefficient  = 2.0
    FirstRetryInterval  = (New-TimeSpan -Seconds 3)
    MaxNumberOfAttempts = 3
}
$retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

# Invoke activity function to get members of user group
try
{
    $userGroupMembersInput = @{
        UserGroupMemberCount = $Context.Input.UserGroupMemberCount
        UserGroupName        = $Context.Input.UserGroupName
    }
    $userGroupMembersParameters = @{
        FunctionName = "ActGetUserGroupMembers"
        Input        = $userGroupMembersInput
        RetryOptions = $retryPolicy
    }
    $userGroupMembers = Invoke-DurableActivity @userGroupMembersParameters
}
catch
{
    Write-Log "Failed to invoke activity 'ActGetUserGroupMembers' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}

# Invoke sub orchestrator function for each user group member
$userGroupMemberTasks = [System.Collections.Generic.List[Object]]::new()
foreach ($userGroupMemberName in $userGroupMembers)
{
    try
    {
        $userGroupMemberInput = @{
            UserGroupMemberName = $userGroupMemberName
            UserGroupName       = $Context.Input.UserGroupName
        }
        $instanceId = "sub-orc-user-group-member-$userGroupMemberName"
        $userGroupMemberParameters = @{
            FunctionName = "SubOrcUserGroupMember"
            Input        = $userGroupMemberInput
            InstanceId   = $instanceId
            NoWait       = $true
        }
        Write-Log "Invoking sub orchestrator with ID '$instanceId'" -OrchestrationContext $Context
        $userGroupMemberTask = Invoke-DurableSubOrchestrator @userGroupMemberParameters
        $userGroupMemberTasks.Add($userGroupMemberTask)
    }
    catch
    {
        Write-Log "Failed to invoke sub orchestrator 'SubOrcUserGroupMember' for member '$userGroupMemberName' in user group '$($Context.Input.UserGroupName)' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
        continue
        # throw $PSItem
    }
}

# Wait for sub orchestrator functions for each user group member
try
{
    Write-Log "Waiting for member sub orchestrators for user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context
    Wait-DurableTask -Task $userGroupMemberTasks | Out-Null

    # $userGroupMemberResults = Wait-DurableTask -Task $userGroupMemberTasks
    # Write-Log "user group member sub orchestrator results: $($userGroupMemberResults | ConvertTo-Json -Depth 100)" -OrchestrationContext $Context
    # return $userGroupMemberResults
}
catch
{
    Write-Log "Failed waiting for sub orchestrator 'SubOrcUserGroupMember' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}
