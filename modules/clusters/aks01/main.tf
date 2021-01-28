data "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  resource_group_name = var.vault_resourcegroup_name
}

data "azurerm_key_vault_secret" "spusername" {
  name         = var.secret_sp_1
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

data "azurerm_key_vault_secret" "sppassword" {
  name         = var.secret_sp_2
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group
  location = var.region

  tags = {
    created_by         = "Glasswall Solutions"
    deployment_version = "1.0.0"
  }
}

resource "azurerm_kubernetes_cluster" "icap-deploy" {
  name                = var.cluster_name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  dns_prefix          = "${var.cluster_name}-k8s"

  default_node_pool {
    name            = var.node_name
    node_count      = 4
    vm_size         = "Standard_DS4_v2"
    os_disk_size_gb = 100

    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count
  }

  service_principal {
    client_id     = data.azurerm_key_vault_secret.spusername.value
    client_secret = data.azurerm_key_vault_secret.sppassword.value
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    created_by         = "Glasswall Solutions"
    deployment_version = "1.0.0"
  }
}