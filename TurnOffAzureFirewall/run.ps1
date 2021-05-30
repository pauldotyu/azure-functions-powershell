using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Write-Host "Retrieving firewall details from request body"
$rg = $Request.Body.resourceGroup
$fw = $Request.Body.firewallName

Write-Host "Retrieving Azure Firewall resource"
$firewall=Get-AzFirewall -ResourceGroupName $rg -Name $fw
$firewall.Deallocate()

Write-Host "Deallocating Azure Firewall"
$firewall | Set-AzFirewall

Write-Host "Returning Azure Firewall ProvisioningState"
if ($firewall.ProvisioningState -eq "Succeeded") {
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $firewall.ProvisioningState
    })
} else {
    # Associate values to output bindings by calling 'Push-OutputBinding'.
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body = $firewall.ProvisioningState
    })
}