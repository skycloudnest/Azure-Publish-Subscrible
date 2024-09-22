locals {
  receiver_logic_app_name = "logic-${var.project_prefix}-receiver-${var.env}"
}

module "receiver_service_bus_connection" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/api_connectors/service_bus_managed_identity"

  resource_group_name            = module.resource_group.name
  connection_name                = "sb-connection-${var.project_prefix}-receiver-${var.env}"
  service_bus_namespace_endpoint = "sb://${module.service_bus.name}.servicebus.windows.net"
  location                       = var.location
}

module "receiver_logic_app" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/logic_app"

  module_dir                 = "../../logic_apps/logic_app_receiver"
  location                   = var.location
  logic_app_name             = local.receiver_logic_app_name
  resource_group_name        = module.resource_group.name
  enabled                    = true
  user_assigned_identity_ids = [module.user_assigned_identity.id]

  arm_parameters = {
    workflow_name                       = local.receiver_logic_app_name
    location                            = var.location
    identity_id                         = module.user_assigned_identity.id
    service_bus_connection_name         = module.receiver_service_bus_connection.name
    service_bus_topic_name              = module.service_bus_topic.name
    service_bus_topic_subscription_name = module.service_bus_subscription_la_receiver.name
  }
  templates_files = {
    bicep_path = "./workflow.bicep"
  }
}

