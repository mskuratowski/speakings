param appName string {
    default: 'bicepms'
    maxLength: 30
  }
  
  param storageAccountType string {
    default: 'Standard_LRS'
    allowed: [
      'Standard_LRS'
      'Standard_GRS'
      'Standard_RAGRS'
    ]
  }
  
  param location string = resourceGroup().location
  
  param runtime string {
    default: 'dotnet'
    allowed: [
      'node'
      'dotnet'
      'java'
    ]
  }
  
  param env string {
    default: 'dev'
    allowed: [
      'dev'
      'stg'
      'prod'
    ]
  }
  
  var functionAppName = 'func-${appName}-${env}'
  var hostingPlanName = 'func-${appName}-${env}'
  var applicationInsightsName = 'appi-${appName}-${env}'
  var storageAccountName = 'st${appName}${env}' 
  var functionWorkerRuntime = runtime
  
  resource st 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName
    location: location
    sku: {
      name: storageAccountType
    }
    kind: 'StorageV2'
  }
  
  resource hostingPlan 'Microsoft.Web/serverfarms@2020-06-01' = {
    name: hostingPlanName
    location: location
    sku: {
      name: 'Y1'
      tier: 'Dynamic'
    }
  }
  
  resource web 'Microsoft.Web/sites@2020-06-01' = {
    name: functionAppName
    location: location
    kind: 'functionapp'
    properties: {
      serverFarmId: hostingPlan.name
      siteConfig: {
          appSettings: [
              {
                  name: 'AzureWebJobsStorage'
                  value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(st.id, '2019-06-01').keys[0].value}'
              }
              {
                  name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
                  value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(st.id, '2019-06-01').keys[0].value}'
              }
              {
                  name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
                  value: '${reference(appi.id, '2018-05-01-preview').InstrumentationKey}'
              }
              {
                  name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
                  value: 'InstrumentationKey=${reference(appi.id, '2020-02-02-preview').InstrumentationKey}'
              }
              {
                  name: 'FUNCTIONS_WORKER_RUNTIME'
                  value: runtime
              }
              {
                  name: 'FUNCTIONS_EXTENSION_VERSION'
                  value: '~3'
              }
              {
                name: 'WEBSITE_NODE_DEFAULT_VERSION'
                value: '~10'
              }
          ]
      }
    }
  }
  
  resource appi 'Microsoft.Insights/components@2020-02-02-preview' = {
    name: applicationInsightsName
    location: location
    kind: 'web'
    properties: {
      Application_Type: 'web'
      publicNetworkAccessForIngestion: 'Enabled'
      publicNetworkAccessForQuery: 'Enabled'    
    }
  }