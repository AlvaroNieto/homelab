terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.75.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_api_url
  insecure  = true
  api_token = var.proxmox_apikey
  ssh {
    agent = true
  }
}

resource "proxmox_virtual_environment_vm" "k3s_node0" {
  count     = 1
  name      = "k3s-cp-${count.index + 1}"
  node_name = "pr0"

  vm_id = 1001 + count.index
  clone {
    vm_id = var.template_id_node0
    full  = true
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  scsi_hardware = "virtio-scsi-pci"
  boot_order    = ["scsi0"]

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    vendor_data_file_id = "local:snippets/vendor.yaml"
    datastore_id        = var.storage_pool
    interface           = "scsi1"
    ip_config {
      ipv4 {
        address = "${var.base_ip}.${101 + count.index}/24" # Manual IP
        gateway = "10.1.1.1"
      }
    }
    user_account {
      username = "alvaro"
    }
  }

  agent {
    enabled = true
  }
}

resource "proxmox_virtual_environment_vm" "k3s_node1" {
  count     = 2
  name      = "k3s-cp-${count.index + 2}" # ID 1002 and 1003
  node_name = "pr1"

  vm_id = 1002 + count.index # ID 1002 and 1003
  clone {
    vm_id = var.template_id_node1
    full  = true
  }

  cpu {
    cores   = 2
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = 2048
    floating  = 2048
  }

  scsi_hardware = "virtio-scsi-pci"
  boot_order    = ["scsi0"]

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  initialization {
    vendor_data_file_id = "local:snippets/vendor.yaml"
    datastore_id        = var.storage_pool
    interface           = "scsi1"
    ip_config {
      ipv4 {
        address = "${var.base_ip}.${101 + count.index + 1}/24" # Manual IP
        gateway = "10.1.1.1"
      }
    }
    user_account {
      username = "alvaro"
    }
  }

  agent {
    enabled = true
  }
}