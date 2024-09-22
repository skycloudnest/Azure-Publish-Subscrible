module "service_bus" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/service_bus"

  name                = "sbns-${var.project_prefix}-${var.env}"
  location            = var.location
  resource_group_name = module.resource_group.name
}

module "service_bus_topic" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/service_bus_topic"

  name         = "sbt-sample-information"
  namespace_id = module.service_bus.namespace_id
}

module "service_bus_subscription_la_receiver" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/service_bus_subscription"

  name     = "sbs-la-reader"
  topic_id = module.service_bus_topic.id
}

module "service_bus_subscription_fa_receiver" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/service_bus_subscription"

  name     = "sbs-fa-reader"
  topic_id = module.service_bus_topic.id
}


