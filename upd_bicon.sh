cd mee-node-deployment
sed -i 's|"rpc": *"https://ethereum-sepolia\.blockpi\.network/v1/rpc/[^"]*"|"rpc": "http://176.9.48.61:18545"|' chains-testnet/11155111.json
sed -i 's|image: bcnmy/mee-node:1.1.19|image: bcnmy/mee-node:1.1.70|' docker-compose.yml
docker compose up -d
docker compose logs -f
