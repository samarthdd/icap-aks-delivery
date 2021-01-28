resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
  lower   = false
}

# Create Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region

  tags = {
    created_by         = "Glasswall Solutions"
    deployment_version = "1.0.0"
  }
}

# Create Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "gwstorageacc${random_string.name.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_kind             = var.account_kind
  access_tier              = var.access_tier
  account_replication_type = var.application_replication_type
  
  tags = {
    created_by         = "Glasswall Solutions"
    deployment_version = "1.0.0"
  }
}

# Create file shares
resource "azurerm_storage_share" "transactions" {
  name                 = var.file_share_name01
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 100
}

resource "azurerm_storage_share" "policies" {
  name                 = var.file_share_name02
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 100
}
