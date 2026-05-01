#!/bin/bash

# --- Configuration Variables ---
POOL_NAME="hub-sp"
POOL_PATH="/home/ppacific/virt-manager/hub-sp"

echo "Setting up storage pool: $POOL_NAME at $POOL_PATH..."

# 1. Create the physical directory if it doesn't exist
mkdir -p "$POOL_PATH"

# 2. Define the pool XML on the fly and define it in libvirt
# We use 'virsh pool-define-as' for a simpler one-liner instead of a full XML file
virsh pool-define-as "$POOL_NAME" dir --target "$POOL_PATH"

# 3. Set the pool to start automatically when the system boots
virsh pool-autostart "$POOL_NAME"

# 4. Start the pool
virsh pool-start "$POOL_NAME"

# 5. Refresh the pool to recognize any existing files
virsh pool-refresh "$POOL_NAME"

if [ $? -eq 0 ]; then
    echo "------------------------------------------------"
    echo "Storage Pool '$POOL_NAME' is now ACTIVE and PERSISTENT."
    echo "Path: $POOL_PATH"
    echo "------------------------------------------------"
    # Show status
    virsh pool-info "$POOL_NAME"
else
    echo "Error: Failed to set up storage pool '$POOL_NAME'."
fi
