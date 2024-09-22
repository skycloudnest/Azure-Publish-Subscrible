module "user_assigned_identity" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/user_assigned_identity"

  location            = var.location
  name                = "id-${var.project_prefix}-sb-receiver-${var.env}"
  resource_group_name = module.resource_group.name
}

module "service_bus_role" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/iam"

  roles = [
    {
      role_name      = "Azure Service Bus Data Sender"
      object_id      = module.sender_logic_app.principal_id
      scope          = module.service_bus_topic.id
      principal_type = "ServicePrincipal"
    },
    {
      role_name      = "Azure Service Bus Data Receiver"
      object_id      = module.user_assigned_identity.principal_id
      scope          = module.service_bus_topic.id
      principal_type = "ServicePrincipal"
    }
  ]
}