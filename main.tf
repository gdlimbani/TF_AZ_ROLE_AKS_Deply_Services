provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Create a resource group
# resource "azurerm_resource_group" "rg" {
#   name     = var.resource_group_name
#   location = var.location
#   tags = var.tags
# }


# Define the role definition
resource "azurerm_role_definition" "aks_role" {
  name        = var.role_name
  description = var.role_description
  scope = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  permissions {
    actions = [
      "Microsoft.ContainerService/managedClusters/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  ]
}


# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  dns_prefix          = "gdl-aks"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Assign role to user
resource "azurerm_role_assignment" "aks_role_assignment" {
  principal_id        = "${var.service_principal_id}"
  role_definition_name = azurerm_role_definition.aks_role.name
  scope               = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"  
}
