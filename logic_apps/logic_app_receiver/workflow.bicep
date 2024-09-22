@description('Name of the workflow to create based on this template.')
param workflow_name string

@description('Name of the Service Bus connection resource')
param service_bus_connection_name string

@description('Name of the Service Bus topic')
param service_bus_topic_name string

@description('Name of the Service Bus topic')
param identity_id string

@description('Name of the Service Bus topic subscription')
param service_bus_topic_subscription_name string

@description('location')
param location string = resourceGroup().location

resource logic_app 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflow_name
  location: location
  properties: {
    definition: loadJsonContent('./workflow_definition.json').definition
    parameters: {
      '$connections': {
        value: {
          servicebus: {
            connectionId: resourceId('Microsoft.Web/connections', service_bus_connection_name)
            connectionName: service_bus_connection_name
            id: '${subscription().id}/providers/Microsoft.Web/locations/${location}/managedApis/servicebus'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
                identity: identity_id
              }
            }
          }
        }
      }
      service_bus_topic_name : {
        value: service_bus_topic_name
      }
      service_bus_topic_subscription_name : {
        value: service_bus_topic_subscription_name
      }
    }
  }
}
