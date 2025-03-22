#!/bin/bash

# Menghapus versi lama
print_time
echo -e "🗑️ Deleting old version."
loading 1
rm -f executor-linux-*.tar.gz
rm -rf t3rn
sleep 2

#!/bin/bash

print_time
echo -e "📥 Downloading new version"
loading 1

# Create and navigate to t3rn directory
mkdir t3rn
cd t3rn

# Download latest release
curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
grep -Po '"tag_name": "\K.*?(?=")' | \
xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz

# Extract the archive
tar -xzf executor-linux-*.tar.gz

# Navigate to the executor binary location
cd executor/executor/bin
# Meminta input PRIVATE_KEY_LOCAL
print_time
loading 2
echo -n "🔑 Input your PRIVATE KEY : "
read PRIVATE_KEY_LOCAL
echo ""

# Meminta input GAS FEE
echo -n "⛽ Set GAS FEE ( Enter for default 1000 ): "
read EXECUTOR_MAX_L3_GAS_PRICE
if [ -z "$EXECUTOR_MAX_L3_GAS_PRICE" ]; then
  EXECUTOR_MAX_L3_GAS_PRICE=1000
fi

print_time
loading 2
echo "⛽ GAS FEE : $EXECUTOR_MAX_L3_GAS_PRICE"

# Menyiapkan variabel lingkungan
export ENVIRONMENT=testnet
export LOG_LEVEL=debug
export LOG_PRETTY=false
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_PROCESS_ORDERS_ENABLED=true
export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,unichain-sepolia,l2rn'
export PRIVATE_KEY_LOCAL="$PRIVATE_KEY_LOCAL"
export EXECUTOR_PROCESS_BIDS_ENABLED=true
export EXECUTOR_ENABLE_BATCH_BIDING=true
export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
export RPC_ENDPOINTS='{
    "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
    "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
    "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
    "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
    "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"],
    "bssp": ["https://base-sepolia-rpc.publicnode.com/", "https://sepolia.base.org"]
}'
export EXECUTOR_MAX_L3_GAS_PRICE="$EXECUTOR_MAX_L3_GAS_PRICE"

# Menjalankan executor dengan screen
print_time
loading 2
echo -e "🚀 Running the executor inside a screen session."
sleep 2

# Membuat screen session otomatis
screen -dmS executor bash -c './executor; exec bash'
echo -e "✅ Executor is now running in a screen session. Use 'screen -r executor' to attach."
