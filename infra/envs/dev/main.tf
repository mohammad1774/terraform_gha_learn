resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "appdata" {
  name                  = var.blob_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = var.aks_name
  location = azurerm_resource_group.rg.location 
  resource_group_name = azurerm_resource_group.rg.name 
  dns_prefix = var.dns_prefix

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name = "system"
    node_count = var.node_count
    vm_size = var.node_vm_size
  }

  network_profile {
    network_plugin = "azure"
  }

}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "app"
  }
}

resource "kubernetes_persistent_volume_claim" "app_pvc" {
  metadata {
    name = "app-pvc"
    namespace = kubernetes_namespace.app.metadata[0].name 
  }
  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}
