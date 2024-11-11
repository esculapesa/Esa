#!/bin/bash

set -e
set -x  # Enable debug mode to show each command executed

echo "Checking env variables:"
echo "IP: $IP"
echo "OPTIONS: $OPTIONS"
echo "BOOTNODES: $BOOTNODES"
echo "ACCOUNT_PASSWORDS: '$ACCOUNT_PASSWORDS'"
echo "DATADIR: '$DATADIR'"

# Check Geth version
./build/bin/geth version 

# Flush output to ensure visibility
sync

# Path to the flag file and directories
DATADIR="/root/.esa"
CHAINDATA_DIR="$DATADIR/geth/chaindata"
FLAG_FILE="$DATADIR/initialized.flag"
GENESIS_FILE="/root/Esa/esa_genesis.json"
UPDATED_GENESIS_FILE="/root/Esa/updated_genesis.json"
KEYSTORE_DIR="$DATADIR/keystore"

# Flush output to ensure visibility
sync

# Function to create a new account and return the address
create_account() {
  local password=$1
  PASSWORD_FILE=$(mktemp)
  echo "$password" > "$PASSWORD_FILE"
  chmod 600 "$PASSWORD_FILE"
  ACCOUNT_OUTPUT=$(timeout 30 ./build/bin/geth --verbosity 5 --datadir "$DATADIR" account new --password "$PASSWORD_FILE")
  echo "$ACCOUNT_OUTPUT"
  ACCOUNT_ADDRESS=$(echo "$ACCOUNT_OUTPUT" | grep -oP '(?<=Public address of the key:   0x)[0-9a-fA-F]+')
  ACCOUNT_ADDRESS="0x$ACCOUNT_ADDRESS"
  rm -f "$PASSWORD_FILE"
  echo "$ACCOUNT_ADDRESS"
}

# Function to extract only the account address from the account creation output
extract_address() {
  local output=$1
  echo "$output" | grep -oP '(?<=Public address of the key:   0x)[0-9a-fA-F]+'
}

# Check if the initialization has already been done
if [ "$FIRST_NODE" = "true" ] && [ ! -f "$FLAG_FILE" ]; then
  echo "Initializing the first node with accounts..."

  # Split the ACCOUNT_PASSWORDS variable into an array
  IFS=',' read -r -a PASSWORD_ARRAY <<< "$ACCOUNT_PASSWORDS"

  if [ ${#PASSWORD_ARRAY[@]} -ne 3 ]; then
    echo "Error: Exactly three passwords must be provided."
    exit 1
  fi

  # Create three new Ethereum accounts with different passwords
  ACCOUNT_OUTPUT_1=$(create_account "${PASSWORD_ARRAY[0]}")
  ACCOUNT_ADDRESS_1=$(extract_address "$ACCOUNT_OUTPUT_1")

  ACCOUNT_OUTPUT_2=$(create_account "${PASSWORD_ARRAY[1]}")
  ACCOUNT_ADDRESS_2=$(extract_address "$ACCOUNT_OUTPUT_2")

  ACCOUNT_OUTPUT_3=$(create_account "${PASSWORD_ARRAY[2]}")
  ACCOUNT_ADDRESS_3=$(extract_address "$ACCOUNT_OUTPUT_3")

  echo "New account addresses: $ACCOUNT_ADDRESS_1, $ACCOUNT_ADDRESS_2, $ACCOUNT_ADDRESS_3"

  # Update the genesis.json file with the new account addresses and balances
  jq --arg address1 "$ACCOUNT_ADDRESS_1" --arg balance1 "0x341CC4D7E46E7A9F000000" \
     --arg address2 "$ACCOUNT_ADDRESS_2" --arg balance2 "0x457BB11FDB3DF8D4000000" \
     --arg address3 "$ACCOUNT_ADDRESS_3" --arg balance3 "0x341CC4D7E46E7A9F000000" \
     '.alloc[$address1] = { "balance": $balance1 } |
      .alloc[$address2] = { "balance": $balance2 } |
      .alloc[$address3] = { "balance": $balance3 }' \
     "$GENESIS_FILE" > "$UPDATED_GENESIS_FILE"

  # Print the updated genesis file for debugging
  echo "Original genesis file content:"
  cat "$GENESIS_FILE"

  # Print the updated genesis file for debugging
  echo "Updated genesis file content:"
  cat "$UPDATED_GENESIS_FILE"

  # Create the flag file to indicate initialization is done
  touch "$FLAG_FILE"
else
  echo "This node is not the first node or has already been initialized."
fi

# Use the updated genesis file
GENESIS_FILE="$UPDATED_GENESIS_FILE"
echo "Updated genesis file content for following node"
cat "$UPDATED_GENESIS_FILE"

# Flush output to ensure visibility
sync

# Check if chaindata directory exists before initializing
if [ ! -d "$CHAINDATA_DIR" ]; then
  echo "Initializing Geth with the genesis file (no previous data found)..."
  ./build/bin/geth --datadir "$DATADIR" init "$GENESIS_FILE"
  
  # Check if initialization was successful
  if [ $? -ne 0 ]; then
    echo "Failed to initialize Geth with genesis file. Stopping initialization."
    exit 1
  fi
else
  echo "Chaindata directory found. Skipping Geth initialization."
fi

echo "Starting the Geth node now..."

# Flush output to ensure visibility
sync

# Start the Geth node in the background
exec ./build/bin/geth \
  --http \
  --http.addr 0.0.0.0 \
  --http.port "8545" \
  --http.api eth,web3,personal,net,miner \
  --http.corsdomain '*' \
  --http.vhosts "*" \
  --ws \
  --ws.addr "0.0.0.0" \
  --ws.port "8546" \
  --ws.api eth,net,web3,personal \
  --syncmode snap \
  --ipcpath "$DATADIR/geth.ipc" \
  --datadir "$DATADIR" \
  --keystore "$KEYSTORE_DIR" \
  --networkid 64879 \
  ${IP:+--nat extip:"$IP"} \
  --bootnodes "enode://61f649e46c1b9496a6f7d9cadb4009350828cc7b04428712c66bff89fb58437d64564aa4026e528087e9c686a58887468150ff83c42334590aa0ec61593a5248@65.108.151.70:30303,
               enode://9c233bd8939cb53f3775b52a325d0c04421a2cb0be839695de5a89324b594c645ce9708c8c6d5fb0b85c24aa0a5da6b45ce3dbfdf69d0c40e1370d98a5aa2952@94.130.183.160:30303,
               enode://c18182aac6aa94b62b4e447d66cf5168b8a77ee15c38b050e7581b73847ae2adb00d7c2379c8fd54adc5f64d2dfa6768ebac6e41e48493cf5e0c32a64a3e9efe@65.21.111.48:30303"
  # ${BOOTNODES:+--bootnodes "$BOOTNODES"} \
  ${OPTIONS:+$OPTIONS} &

# Wait for Geth to start
# sleep 10

# # Add bootnode manually
# ./build/bin/geth attach /root/.esa/geth.ipc --exec "admin.addPeer(\"enode://1208561ffa896031a1f59807eabd32bacf8067bfe82d55079848505d6a2b839975b4dad1266cb25bb8430b0b695cec7a1cab6a6b1f9c101072d3116303fac225@65.108.151.70:30303\")"

# echo "Bootnode added successfully"

# # Prevent the script from exiting (so that the container doesn't exit)
# wait
