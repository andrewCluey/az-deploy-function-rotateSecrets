@description('The name to asign to the Function App Storage Account.')
param funcStorageAccountName string = 'safuncdevsecrets'

param appName string = 'secret'



// resource lookups
resource azFuncStorageDetails 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: funcStorageAccountName
}


// Resource Deployments
module functionApp 'br:ascbicep.azurecr.io/bicep/modules/functionapp:v1.5' = {
  name: 'devFuncRotateSecrets'
  params: {
    appName: appName
    environment: 'dev'
    storageAccountName: funcStorageAccountName
  }
}

module functionAppSettings 'br:ascbicep.azurecr.io/bicep/modules/functionappsettings:v1.3' = {
  name: 'devFuncRotateSecretsSettings'
  params: {
    appInsightsInstrumentationKey: functionApp.outputs.appInsightsInstrumentationKey
    functionAppName: functionApp.outputs.functionAppName
    functionAppStagingSlotName: functionApp.outputs.functionAppSlot
    storageAccountName: funcStorageAccountName
    storageAccountAccessKey: azFuncStorageDetails.listKeys().keys[0].value
  }
}


//outputs
output appInsightsInstrumentationKey string = functionApp.outputs.appInsightsInstrumentationKey
output functionAppName string = functionApp.outputs.functionAppName
output functionAppSlot string = functionApp.outputs.functionAppSlot
