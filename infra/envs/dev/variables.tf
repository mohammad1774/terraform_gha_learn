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

variable "aks_name" {
  type = string 
  description = "AKS Cluster name"
}

variable "dns_prefix" {
  type = string 
  description = "DNS Prefix for AKS"
}

variable "node_vm_size" {
  type = string 
  description = "AKIS node VM size"
  default = "Standard_DS2_V2"
}

variable "node_count" {
  type = number 
  description = "Number of nodes"
  default = 2
}