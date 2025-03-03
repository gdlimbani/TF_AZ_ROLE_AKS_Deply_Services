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

  principal_id        = "da165c26-bbff-4494-80c8-80e91bfc07aa"
  role_definition_name = azurerm_role_definition.aks_role.name
  scope               = azurerm_kubernetes_cluster.aks.id  
}

resource "azurerm_kubernetes_cluster_node_pool" "aks_np" {
  name                  = "gdlnp"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 2
}

resource "kubernetes_namespace" "gdlns" {
  depends_on = [azurerm_kubernetes_cluster.aks]

  metadata {
    name = "gdlns"
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend-deployment"
    namespace = kubernetes_namespace.gdlns.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = "gdlimbani/smartpps-frontend:20241101"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend-deployment"
    namespace = kubernetes_namespace.gdlns.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name  = "backend"
          image = "gdlimbani/smartpps-backend:20241101"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend-service"
    namespace = kubernetes_namespace.gdlns.metadata[0].name
  }

  spec {
    selector = {
      app = "frontend"
    }

    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace.gdlns.metadata[0].name
  }

  spec {
    selector = {
      app = "backend"
    }

    type = "ClusterIP"

    port {
      port        = 80
      target_port = 80
    }
  }
}