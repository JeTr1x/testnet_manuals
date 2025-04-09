



read -rp "Enter L1RPC: " L1RPC
read -rp "Enter CHAINRPC: " CHAINRPC


cd mee-node-deployment
sed -ie 's|"rpc": "https://ethereum-sepolia.blockpi.network/v1/rpc/840aeeac9c2a1733b55ca7aca3d2d287797be72f"|"rpc": "'$CHAINRPC'"|' 11155111.json
sed -ie 's|"rpc": "https://optimism-sepolia.blockpi.network/v1/rpc/6807fa355fdc9325ea697b5d52efeb4d1adf13f9f"|"rpc": "'$CHAINRPC'"|' 11155420.json
sed -ie 's|"rpc": "https://base-sepolia.blockpi.network/v1/rpc/19b755f222187861ca7e009cfd2a3deec41a676e"|"rpc": "'$CHAINRPC'"|' 84532.json
sed -ie 's|"rpc": "https://arbitrum-sepolia.blockpi.network/v1/rpc/39dfe10c6563716d3d3b141908f8789b72bfa5e6"|"rpc": "'$CHAINRPC'"|' 421614.json
sed -ie 's|"rpc": "https://ethereum.blockpi.network/v1/rpc/73bb047999c50700b9890a056d06f87a9df3ba66"|"rpc": "'$L1RPC'"|' 1.json

cat /root/mee-node-deployment/chains-testnet/* | grep rpc

docker compose down
docker compose up -d
docker logs -f mee-node-deployment-node-1

