# Enabling PCI Passthrough with Intel iGPU on Proxmox VE

This guide details the steps to enable PCI passthrough for an Intel iGPU (integrated graphics processing unit) on a Proxmox Virtual Environment (PVE) host. This process involves modifying the GRUB bootloader, kernel modules, and VM configuration.

## 1. Modify GRUB Configuration

1.  **Open the GRUB configuration file:**

    ```bash
    nano /etc/default/grub
    ```

2.  **Comment out the default `GRUB_CMDLINE_LINUX_DEFAULT` line (if present):**

    ```
    #GRUB_CMDLINE_LINUX_DEFAULT="quiet"
    ```

3.  **Paste the following line, which includes necessary kernel parameters for IOMMU and PCI passthrough:**

    ```
    GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction initcall_blacklist=sysfb_init video=simplefb:off video=vesafb:off video=efifb:off video=vesa:off disable_vga=1 vfio_iommu_type1.allow_unsafe_interrupts=1 kvm.ignore_msrs=1 modprobe.blacklist=radeon,nouveau,nvidia,nvidiafb,nvidia-gpu,snd_hda_intel,snd_hda_codec_hdmi,i915"
    ```

    * `intel_iommu=on`: Enables Intel IOMMU.
    * `iommu=pt`: Enables IOMMU pass-through.
    * `pcie_acs_override=downstream,multifunction`: Overrides ACS (Access Control Services) for PCI devices.
    * `initcall_blacklist=sysfb_init video=simplefb:off video=vesafb:off video=efifb:off video=vesa:off disable_vga=1`: Disables framebuffer drivers to prevent conflicts.
    * `vfio_iommu_type1.allow_unsafe_interrupts=1`: Allows unsafe interrupts for VFIO (Virtual Function I/O).
    * `kvm.ignore_msrs=1`: Ignores Model Specific Registers (MSRs) for KVM.
    * `modprobe.blacklist=radeon,nouveau,nvidia,nvidiafb,nvidia-gpu,snd_hda_intel,snd_hda_codec_hdmi,i915`: Blacklists conflicting graphics and audio drivers.
<br>
4.  **Update GRUB and Proxmox boot tool:**

    ```bash
    update-grub
    proxmox-boot-tool refresh
    ```

## 2. Configure Kernel Modules

1.  **Open the `/etc/modules` file:**

    ```bash
    nano /etc/modules
    ```

2.  **Add the following lines to load the required VFIO modules:**

    ```
    # Modules required for PCI passthrough
    vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd
    ```

3.  **Update the initial ramdisk:**

    ```bash
    update-initramfs -u -k all
    ```

## 3. Reboot and Verify IOMMU

1.  **Reboot the Proxmox host:**

    ```bash
    reboot
    ```

2.  **Verify that IOMMU is enabled:**

    ```bash
    dmesg | grep -e DMAR -e IOMMU -e iommu
    ```

    Look for output indicating "DMAR: IOMMU enabled" or "DMAR: IOMMU enabled (translated)".

## 4. Identify the iGPU

1.  **Search for the iGPU using `lspci`:**

    ```bash
    lspci -nnv | grep VGA
    ```

2.  **Note the PCI device ID (e.g., `00:02.0`).**

    Example output:

    ```
    00:02.0 VGA compatible controller [0300]: Intel Corporation CometLake-S GT2 [UHD Graphics 630]
    ```

## 5. Pass Through the iGPU to a VM

1.  **Navigate to the VM's hardware settings in the Proxmox web interface.**

2.  **Click "Add" and select "PCI Device".**

3.  **Select the RAW Device corresponding to the iGPU (e.g., `00:02.0`).**

4.  **Check "All functions" and "Primary GPU".**

5.  **Click "Add".**

6.  **Reboot the VM.**

After the VM reboots, the iGPU should be available within the guest operating system.

## 6. Solve conflict between VNC and iGPU display

1.  **Make sure that the VM configuration does not have conflicting display settings when using a passed-through GPU. If you're passing through the iGPU, Proxmox should default to VNC or spice, but if it's configured for no display or another display method, the VNC might not work.**
<br>

    Edit the VM configuration file to ensure it is using spice or VNC for display:

    ```bash
    nano /etc/pve/qemu-server/<VMID>.conf
    ```

    Append to file 

    ```bash
    vga: virtio
    display: vnc
    ```
