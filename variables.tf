variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  default = "95eba7e9-db83-4900-a7a9-695be8543900"
}

variable "client_id" {
  description = "The Azure client ID"
  type        = string
  default = "8778c87a-82d8-4950-9cac-36609e466085"
}

variable "client_secret" {
  description = "The Azure client secret"
  type        = string
  default = "uiE8Q~b9xzbEIu7fmT7QFB5ynWWK-A1EsnPeuapd"
}

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
  default = "3da2b7e8-16b9-4850-a1a1-cebdc35e74a0"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "gdl"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "gdl-aks"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "location" {
  description = "Azure location for the resources"
  type        = string
  default     = "East US"
}

variable "role_name" {
  description = "The name of the custom role"
  type        = string
  default     = "AksClusterAdmin"
}

variable "role_description" {
  description = "Description of the role"
  type        = string
  default     = "Role to manage AKS cluster"
}

variable "created_by" {
    description = "who created the resource"
    type = string
    default = "Gautam Limbani"
}

variable "tags" {
  default = {
    environment = "gdl-dev"
    project     = "gdl-aks-deployment"
    created_by       = "Gautam Limbani"
  }
}

variable "service_principal_id" {
  description = "The service principal is nothing the app registered using app registration in Microsoft Entra ID in Azure"
  type = string
}