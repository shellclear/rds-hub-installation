#!/bin/bash

# --- Configuration Variables ---
CLUSTER_NAME="hub"
NET_NAME="hub-net"
VM_NAME="${CLUSTER_NAME}"
DISK_DIR="/home/ppacific/virt-manager/hub-sp"

# Resource Variables
VM_VCPUS=20
VM_MEM_MB=42000
OS_VARIANT="rhel9.6"

# Disk Size Variables (in GB)
ROOT_DISK_SIZE=500
VOL1_DISK_SIZE=100
VOL2_DISK_SIZE=100

# Set to "false" to only define the VM without starting it
START_VM="false"

# Ensure directories exist
mkdir -p "$DISK_DIR"

echo "Processing virtual machine: $VM_NAME..."

# Build the base command
cmd=(
  virt-install
  --name "$VM_NAME"
  --vcpus "$VM_VCPUS"
  --memory "$VM_MEM_MB"
  --memorybacking source.type=memfd,access.mode=shared
  --cpu host-passthrough,migratable=on
  --os-variant "$OS_VARIANT"
  --machine pc-q35-10.1
  --boot hd,network,cdrom,menu=on
  --disk path="${DISK_DIR}/${VM_NAME}-root.qcow2",size="$ROOT_DISK_SIZE",bus=virtio,format=qcow2,sparse=yes,boot.order=1
  --disk path="${DISK_DIR}/${VM_NAME}-vol1.qcow2",size="$VOL1_DISK_SIZE",bus=virtio,format=qcow2,sparse=yes
  --disk path="${DISK_DIR}/${VM_NAME}-vol2.qcow2",size="$VOL2_DISK_SIZE",bus=virtio,format=qcow2,sparse=yes
  --disk device=cdrom,bus=sata,boot.order=3
  --network network="${NET_NAME}",model=virtio,boot.order=2
  --network network="${NET_NAME}",model=virtio
  --network network="${NET_NAME}",model=virtio
  --controller type=usb,model=qemu-xhci
  --controller type=scsi,model=virtio-scsi
  --controller type=virtio-serial
  --graphics spice
  --channel spicevmc,target.type=virtio,target.name=com.redhat.spice.0
  --channel unix,target.type=virtio,target.name=org.qemu.guest_agent.0
  --input tablet,bus=usb
  --audio id=1,type=spice
  --video model=virtio
  --rng device=/dev/urandom,model=virtio
  --watchdog model=itco,action=reset
  --memballoon model=virtio
  --noautoconsole
  --wait 0
  --check disk_size=off
)

# Logic to handle starting or just defining
if [ "$START_VM" = "false" ]; then
    echo "Action: Defining VM only (will not start)."
    # --noreboot prevents the VM from starting after the initial "install"
    # --install no_install=yes tells it to just setup the VM and stop
    "${cmd[@]}" --noreboot --install no_install=yes
else
    echo "Action: Creating and starting VM."
    "${cmd[@]}"
fi

if [ $? -eq 0 ]; then
    echo "------------------------------------------------"
    echo "Success! VM $VM_NAME has been created."
    if [ "$START_VM" = "false" ]; then
        echo "The VM is currently SHUT OFF. Use 'virsh start $VM_NAME' to boot it."
    fi
    echo "------------------------------------------------"
else
    echo "Error: Failed to create VM $VM_NAME."
fi
