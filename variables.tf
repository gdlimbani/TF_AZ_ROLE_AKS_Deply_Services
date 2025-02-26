variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "client_id" {
  description = "The Azure client ID"
  type        = string
}

variable "client_secret" {
  description = "The Azure client secret"
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "myResourceGroup"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "myAKSCluster"
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