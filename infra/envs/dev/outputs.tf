output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  value = azurerm_resource_group.rg.location
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "blob_container_name" {
  value = azurerm_storage_container.appdata.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name 
}

output "aks_config"{
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
