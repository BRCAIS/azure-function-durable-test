param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Running sub orchestrator for user group member '$($Context.Input.UserGroupMemberName)'" -OrchestrationContext $Context

$retryPolicyParameters = @{
    BackoffCoefficient  = 2.0
    FirstRetryInterval  = (New-TimeSpan -Seconds 3)
    MaxNumberOfAttempts = 3
}
$retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

# Optionally throw random error
$EncounterError = $false
if ($EncounterError)
{
    $EncounterRandomErrorParameters = @{
        FunctionName = "ActGetRandomError"
        RetryOptions = $retryPolicy
    }
    Invoke-DurableActivity @EncounterRandomErrorParameters
}

# Invoke activity function to process member of user group
try
{
    $processUserGroupMemberInput = @{
        UserGroupMemberName = $Context.Input.UserGroupMemberName
        UserGroupName       = $Context.Input.UserGroupName
    }
    $processUserGroupMemberParameters = @{
        FunctionName = "ActProcessUserGroupMember"
        Input        = $processUserGroupMemberInput
        RetryOptions = $retryPolicy
    }
    Invoke-DurableActivity @processUserGroupMemberParameters

    # return @{
    #     Status              = "Processed"
    #     UserGroupMemberName = [String] $Context.Input.UserGroupMemberName
    #     UserGroupName       = [String] $Context.Input.UserGroupName
    # }
}
catch
{
    Write-Log "Failed to invoke activity 'ActProcessUserGroupMember' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}
