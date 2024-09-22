locals {
  sender_logic_app_name = "logic-${var.project_prefix}-sender-${var.env}"
}

module "sender_service_bus_connection" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/api_connectors/service_bus_managed_identity"

  resource_group_name            = module.resource_group.name
  connection_name                = "sb-connection-${var.project_prefix}-sender-${var.env}"
  service_bus_namespace_endpoint = "sb://${module.service_bus.name}.servicebus.windows.net"
  location                       = var.location
}

module "sender_logic_app" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/logic_app"

  module_dir           = "../../logic_apps/logic_app_sender"
  location             = var.location
  logic_app_name       = local.sender_logic_app_name
  resource_group_name  = module.resource_group.name
  enabled              = true
  use_managed_identity = true

  arm_parameters = {
    workflow_name               = local.sender_logic_app_name
    location                    = var.location
    service_bus_connection_name = module.sender_service_bus_connection.name
    service_bus_topic_name      = module.service_bus_topic.name
  }
  templates_files = {
    bicep_path = "./workflow.bicep"
  }
}

