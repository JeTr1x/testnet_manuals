

CHAINRPC="https://ethereum-sepolia.blockpi.network/v1/rpc/840aeeac9c2a1733b55ca7aca3d2d287797be72f"
echo ""
echo ""
cat /root/mee-node-deployment/chains-testnet/* | grep rpc
echo ""
echo ""
cd mee-node-deployment
sed -i 's|"rpc":*.*"|"rpc": "'$CHAINRPC'"|' /root/mee-node-deployment/chains-testnet/11155111.json
echo ""
echo ""
cat /root/mee-node-deployment/chains-testnet/11155111.json | grep rpc

docker compose down
docker compose up -d
docker logs -f mee-node-deployment-node-1

