variable "proxmox_api_url" {
  description = "URL of the Proxmox API endpoint"
  type        = string
}

variable "proxmox_apikey" {
  description = "Proxmox API Key"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Target Proxmox node name"
  type        = string
}

variable "template_id_node0" {
  type    = string
  default = "8001" # ID Ubuntu 24.04 cloud-init template
}

variable "template_id_node1" {
  type    = string
  default = "8002" # ID Ubuntu 24.04 cloud-init template
}

variable "network_bridge" {
  default = "vmbr0"
}

variable "base_ip" {
  default = "10.1.1"
}

variable "gateway" {
  default = "10.1.1.1"
}

variable "target_nodes" {
  type = list(string)
}

variable "storage_pool" {
  description = "Proxmox storage pool name"
  type        = string
}