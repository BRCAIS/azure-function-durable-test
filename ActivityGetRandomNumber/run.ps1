param($param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

return (Get-Random -Minimum 1 -Maximum 3)
