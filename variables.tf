variable "tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "subscription_id" {
  type        = string
  description = "Azure Subscription ID for Folding At Home resources"
}

variable "client_id" {
  type        = string
  description = "Service Principal Client ID"
}

variable "client_secret" {
  type        = string
  description = "Service Principal Secret"
}

variable "location" {
  type        = string
  description = "Location of azure resources"
}

variable "clientip" {
    type = string
    description = "The Public IP Address for your remote management"
}

variable "fahvmcount" {
    type = number
    description = "Number of Linux VMs to deploy for Folding At Home client"
    default = 1  
}

variable "fahvmname" {
    type = string
    description = "Name Prefix for Virtual Machine resources"
    default = "fah"
}

variable "fahvmsize" {
    type = string
    description = "Size of the Virtual Machines"
    default = "Standard_F4s_v2"
}

variable "fahvmusername" {
    type = string
    description = "Username for admin user"
}

variable "fahvmpassword" {
    type = string
    description = "Password for admin user"
}

variable "fahvmgpuenabled" {
  type = bool
  description = "Deploy a GPU enabled virtul machine"
  default = false
}
