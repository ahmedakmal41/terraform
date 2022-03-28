//------------------------------------Service Principal---------------\\
variable "azure_subscription_id" {
  type        = string
  default     = ""
  description = "description"
}

variable "azure_client_id" {
  type        = string
  default     = ""
  description = "description"
}

variable "azure_client_secret" {
  type        = string
  default     = ""
  description = "description"
}

variable "azure_tenant_id" {
  type        = string
  default     = ""
  description = "description"
}

//--------------------------------General Properties----------------------\\
variable "rgname" {
  type    = string
  default = "RG-CMP-DEMO-WINDOWS-VM"
}
variable "vmname" {
  type    = string
  default = "cpm-demo-windows-vm"
}

variable "location" {
  type    = string
  default = "East US"
}
//-------------------------------VM Configurations--------------------------\\
variable "adminuser" {
  type    = string
  default = "vmuser"
}
variable "adminpassword" {
  type    = string
  default = "M@nage!q1234"
}
variable "vmsize" {
  type    = string
  default = "Standard_F2"
}
variable "sku" {
  type        = string
  default     = "2019-Datacenter"
  description = "Enter storage account name"
}
variable "command" {
  type    = string
  default = "apply"
}
variable "workspacekey" {
  type    = string
  default = "OS4PnAEOJW2+6ekDkOYh7Awja6sgCfvQKYUxvYg/XZ+ziRIpHrCxyuGIWRM2Z9sdjRThPqRmGY3RcN/BcR9y/w=="
}
variable "workspaceid" {
  type    = string
  default = "41d62148-ac40-4d9b-a790-b93c0e47c4e6"
}
//------------------------------------TAGS-------------------------------------\\
variable "owner" {
  type        = string
  default     = "Asif Bilgrami"
  description = "description"
}

variable "Environment" {
  type        = string
  default     = "Prd"
  description = "Enter storage account name"
}

variable "Buisness_unit" {
  type        = string
  default     = "Accounts"
  description = "Enter storage account name"
}

variable "Application" {
  type        = string
  default     = "AccountsDbServer"
  description = "Enter storage account name"
}

variable "Platform" {
  type        = string
  default     = "Linux"
  description = "Enter storage account name"
}

variable "Type" {
  type        = string
  default     = "Node Exporter"
  description = "Enter storage account name"
}

//------------------------------------------TF Errors------------------------\\
variable "init_stderr" {
  type    = string
  default = "error"
}
variable "init_stdout" {
  type    = string
  default = "error"
}
variable "stderr" {
  type    = string
  default = "error"
}
variable "stdout" {
  type = list(any)
  default = [
    {
      id   = 1
      name   = "error"
      description = "error"
    }
  ]
}

