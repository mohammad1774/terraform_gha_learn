variable "location" {
  type        = string
  description = "Azure region for resources."
  default     = "canadaeast"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group."
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique storage account name (3-24 lowercase letters/numbers)"
}

variable "blob_container_name" {
  type        = string
  description = "Blob Container name."
  default     = "appdata"
}

variable "tfstate_container_name" {
  type        = string
  description = "Blob container for Terraform remote state"
  default     = "tfstate"

}