module "resource_group" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/resource_group"

  name     = "rg-${var.project_prefix}-${var.env}-${var.location}"
  location = var.location
  tags = {
    environment = var.env
    ProjectId   = "Publish-Subscribe-Model"
  }
}

module "storage_account" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/storage_account_public"

  name                = replace("st${var.project_prefix}${var.env}", "-", "")
  resource_group_name = module.resource_group.name
  location            = var.location
}

module "common_application_insights" {
  source = "git::https://github.com/skycloudnest/Terraform.git//modules/azure/application_insights"

  name                = "appi-${var.project_prefix}-common-${var.env}"
  resource_group_name = module.resource_group.name
  location            = var.location
  sampling_percentage = 70
}

