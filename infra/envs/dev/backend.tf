terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-dev"
    storage_account_name = "sttest1774"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
