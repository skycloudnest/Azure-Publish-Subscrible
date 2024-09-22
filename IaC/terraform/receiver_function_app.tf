# prepare container with built Function code

locals {
  zip_path = tolist(fileset(var.workspace_directory, "**/${var.function_project_name}.zip"))[0]
}

module "storage_container_deployments" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/storage_container"

  storage_container_name = "deployments"
  storage_account_name   = module.storage_account.name
}

module "function_app_storage_blob" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/storage_blob"

  local_source              = "${var.workspace_directory}/${local.zip_path}"
  remote_file_name          = "src/function_app_${formatdate("YYYYMMDDhhmmss", timestamp())}.zip"
  storage_account_name      = module.storage_account.name
  storage_container_name    = module.storage_container_deployments.storage_container_name
  storage_connection_string = module.storage_account.primary_connection_string
}

module "func_service_plan" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/service_plan"

  resource_group_name = module.resource_group.name
  name                = "asp-${var.project_prefix}-${var.env}"
  os_type             = "Linux"
  sku_name            = "Y1"
  enable_autoscaling  = false
  location            = var.location
}

module "function_app" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/function_app_linux"

  name                       = "func-${var.project_prefix}-receiver-${var.env}"
  service_plan_id            = module.func_service_plan.id
  runtime_version            = "~4"
  dotnet_version             = "8.0"
  dotnet_isolated            = true
  resource_group_name        = module.resource_group.name
  storage_account_name       = module.storage_account.name
  storage_account_access_key = module.storage_account.primary_access_key
  location                   = var.location
  user_assigned_identity_ids = [module.user_assigned_identity.id]

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY                = module.common_application_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING         = module.common_application_insights.connection_string
    FUNCTIONS_WORKER_RUNTIME                      = "dotnet-isolated"
    WEBSITE_RUN_FROM_PACKAGE                      = module.function_app_storage_blob.storage_blob_url
    ServiceBusConnection__fullyQualifiedNamespace = "${module.service_bus.name}.servicebus.windows.net"
    ServiceBusConnection__credential              = "managedIdentity"
    ServiceBusConnection__clientID                = module.user_assigned_identity.client_id
    TopicName                                     = module.service_bus_topic.name
    SubscriptionName                              = module.service_bus_subscription_fa_receiver.name
  }

  depends_on = [
    module.function_app_storage_blob
  ]
}
