$UserName = ((az ad signed-in-user show | ConvertFrom-Json).userPrincipalName -replace '@.*$','' -replace '\W','').ToLower()

az group create --name rg-fingerflitzer-obef --location swedencentral | Out-Null


az appservice plan create `
  --name asp-fingerflitzer `
  --sku P0V3 `
  --is-linux `
  --resource-group rg-fingerflitzer-obef | Out-Null

az webapp create `
  --name wa-fingerflitzer-obef-$UserName `
  --runtime DOTNETCORE:8.0 `
  --assign-identity `
  --https-only true `
  --public-network-access Enabled `
  --plan asp-fingerflitzer `
  --resource-group rg-fingerflitzer-obef | Out-Null

# Allow access from web app to database
# see https://learn.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-azure-database
# az extension add --name serviceconnector-passwordless --upgrade
# az webapp connection create postgres-flexible `
#   --connection fingerflitzer-obef_webapp `
#   --resource-group rg-fingerflitzer-obef `
#   --name wa-fingerflitzer-obef-$UserName `
#   --target-resource-group rg-fingerflitzer-obef `
#   --server db-fingerflitzer-obef-$UserName `
#   --database fingerflitzer-obef `
#   --system-identity `
#   --client-type dotnet | Out-Null

# az extension add --name rdbms-connect
# $User = az ad signed-in-user show | ConvertFrom-Json
# $AccessToken = az account get-access-token --resource-type oss-rdbms | ConvertFrom-Json
# az postgres flexible-server execute `
#   --querytext "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO `"aad_fingerflitzer-obef_webapp`";GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO `"aad_fingerflitzer-obef_webapp`";" `
#   --database-name fingerflitzer-obef `
#   --admin-user $User.userPrincipalName `
#   --admin-password $AccessToken.accessToken `
#   --name db-fingerflitzer-obef-$UserName

$WebApp = az webapp show `
  --name wa-fingerflitzer-obef-$UserName `
  --resource-group rg-fingerflitzer-obef | ConvertFrom-Json
Write-Host "### Web app: https://$($WebApp.defaultHostName)"

<#
az group delete --name rg-fingerflitzer-obef --no-wait
#>
