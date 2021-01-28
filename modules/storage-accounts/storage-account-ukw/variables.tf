variable "resource_group_name" {
  description = "This is a consolidated name based on org, environment, region"
  type        = string
  default 	  = "gw-icap-aks-delivery-storage"
}

variable "region" {
  description = "The Azure Region/location the resource will be installed"
  type        = string
  default     = "UKWEST"
}

variable "file_share_name01" {
  description = "The name of the file share"
  type        = string
  default     = "transactions"
}

variable "file_share_name02" {
  description = "The name of the file share"
  type        = string
  default     = "policies"
}

variable "account_tier" {
  description = "The tier of storage account"
  type        = string
  default     = "Premium"
}

variable "account_kind" {
  description = "The kind of the storage account (cool, hot, archive)"
  type        = string
  default     = "FileStorage"
}

variable "application_replication_type" {
  description = "The Storage Account replication type"
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "The Storage Account replication type"
  type        = string
  default     = "Hot"
}