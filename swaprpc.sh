



read -rp "Enter L1RPC: " L1RPC
read -rp "Enter CHAINRPC: " CHAINRPC

echo ""
echo ""
cat /root/mee-node-deployment/chains-testnet/* | grep rpc
echo ""
echo ""
cd mee-node-deployment
sed -i 's|"rpc": "https://ethereum-sepolia.blockpi.network/v1/rpc/840aeeac9c2a1733b55ca7aca3d2d287797be72f"|"rpc": "'$CHAINRPC'"|' /root/mee-node-deployment/chains-testnet/11155111.json
sed -i 's|"rpc": "https://optimism-sepolia.blockpi.network/v1/rpc/6807fa355fdc9325ea697b5d52efeb4d1adf13f9"|"rpc": "'$CHAINRPC'"|' /root/mee-node-deployment/chains-testnet/11155420.json
sed -i 's|"rpc": "https://base-sepolia.blockpi.network/v1/rpc/19b755f222187861ca7e009cfd2a3deec41a676e"|"rpc": "'$CHAINRPC'"|' /root/mee-node-deployment/chains-testnet/84532.json
sed -i 's|"rpc": "https://arbitrum-sepolia.blockpi.network/v1/rpc/39dfe10c6563716d3d3b141908f8789b72bfa5e6"|"rpc": "'$CHAINRPC'"|' /root/mee-node-deployment/chains-testnet/421614.json
sed -i 's|"rpc": "https://ethereum.blockpi.network/v1/rpc/73bb047999c50700b9890a056d06f87a9df3ba66"|"rpc": "'$L1RPC'"|' /root/mee-node-deployment/chains-testnet/1.json
echo ""
echo ""
cat /root/mee-node-deployment/chains-testnet/* | grep rpc

docker compose down
docker compose up -d
docker logs -f mee-node-deployment-node-1

