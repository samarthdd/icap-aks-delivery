variable "azure_region" {
  description = "Metadata Azure Region"
  type        = string
  default     = "UKWEST"
}

variable "resource_group" {
  description = "Azure Resource Group"
  type        = string
  default     = "gw-icap-aks-delivery-keyvault"
}

variable "kv_name" {
  description = "The name of the key vault"
  type        = string
  default     = "aks-delivery-keyvault-01"
}