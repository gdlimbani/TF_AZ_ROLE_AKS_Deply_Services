provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

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
  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_role_definition.aks_role
  ]

  principal_id        = "${var.service_principal_id}"
  role_definition_name = azurerm_role_definition.aks_role.name
  scope               = azurerm_kubernetes_cluster.aks.id  
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_np" {
  name                  = "gdlnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "${var.vm_size}"
  node_count            = 2
}

resource "kubernetes_namespace" "gdlns" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = "${var.aks_namespace}"
  }
}

output "kubeconfig" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

# resource "null_resource" "apply_frontend_deployment" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f frontend-deployment.yaml --namespace=${var.aks_namespace}"
#   }

#   depends_on = [azurerm_kubernetes_cluster.aks]
# }

# resource "null_resource" "apply_backend_deployment" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f backend-deployment.yaml --namespace=${var.aks_namespace}"
#   }

#   depends_on = [azurerm_kubernetes_cluster.aks]
# }

# resource "null_resource" "apply_frontend_service" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f frontend-service.yaml --namespace=${var.aks_namespace}"
#   }

#   depends_on = [azurerm_kubernetes_cluster.aks]
# }

# resource "null_resource" "apply_backend_service" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f backend-service.yaml --namespace=${var.aks_namespace}"
#   }

#   depends_on = [azurerm_kubernetes_cluster.aks]
# }
