using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Write-Host "Retrieving deployment details from body of the request"
$rg = $Request.Body.resourceGroup
$fw = $Request.Body.firewallName
$vn = $Request.Body.vnetName
$ip = $Request.Body.publicIpName

Write-Host "Retrieving Azure Firewall resources"
$firewall=Get-AzFirewall -ResourceGroupName $rg -Name $fw
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rg -Name $vn
$pip = Get-AzPublicIpAddress -ResourceGroupName $rg -Name $ip 

Write-Host "Reallocating Azure Firewall"
$firewall.Allocate($vnet, $pip)
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