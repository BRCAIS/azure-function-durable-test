param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

try {
    Write-Log "Running sub orchestrator for user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context

    $retryPolicyParameters = @{
        BackoffCoefficient  = 2.0
        FirstRetryInterval  = (New-TimeSpan -Seconds 2)
        MaxNumberOfAttempts = 5
    }
    $retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

    $userGroupMembersInput = @{
        UserGroupName = $Context.Input.UserGroupName
    }
    $userGroupMembersParameters = @{
        FunctionName = "ActivityGetUserGroupMembers"
        Input        = $userGroupMembersInput
        RetryOptions = $retryPolicy
    }
    $userGroupMembers = Invoke-DurableActivity @userGroupMembersParameters
    $userGroupMemberTasks = foreach ($userGroupMemberName in $userGroupMembers) {
        $userGroupMemberInput = @{
            UserGroupMemberName = $userGroupMemberName
            UserGroupName       = $Context.Input.UserGroupName
        }
        $userGroupMemberParameters = @{
            FunctionName = "SubOrchestratorUserGroupMember"
            Input        = $userGroupMemberInput
            NoWait       = $true
        }
        Write-Log "Invoking sub orchestrator for member '$userGroupMemberName' in user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context
        Invoke-DurableSubOrchestrator @userGroupMemberParameters
    }

    Write-Log "Waiting for member sub orchestrators for user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context
    $userGroupMemberResults = Wait-DurableTask -Task $userGroupMemberTasks

    # Write-Log "user group member sub orchestrator results: $($userGroupMemberResults | ConvertTo-Json -Depth 100)" -OrchestrationContext $Context
    # return $userGroupMemberResults
} catch {
    Write-Log "Caught error during user group $($Context.Input.UserGroupName) - $($PSItem.Exception.Message)" -OrchestrationContext $Context
    throw $PSItem
}
