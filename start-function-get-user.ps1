param(
    [int]$Port = 7273,
    [string]$computername = "localhost"
)

$baseUrl = "http://$computername`:$Port"
$startUrl = "$baseUrl/api/getUser?name=hunter"

Write-Information "Starting orchestration at: $startUrl"
Invoke-RestMethod `
    -Uri $startUrl `
    -Method GET `
    -ContentType "application/json" `
    -Body '{}' `
    -TimeoutSec 30
