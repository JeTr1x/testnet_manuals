

read -rp "Enter CHAIN: " CHAIN
read -rp "Enter PRIVKEY: " PRIVKEY

# Install docker
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

rm -rf mee-node-deployment && git clone https://github.com/JeTr1x/mee-node-deployment/
cd mee-node-deployment

if [ "$CHAIN" = "eth_sepolia" ]; then
    rm chains-testnet/11155420.json chains-testnet/421614.json chains-testnet/84532.json
fi

if [ "$CHAIN" = "optimism_sepolia" ]; then
    rm chains-testnet/11155111.json chains-testnet/421614.json chains-testnet/84532.json
fi

if [ "$CHAIN" = "arbitrum_sepolia" ]; then
    rm chains-testnet/11155420.json chains-testnet/11155111.json chains-testnet/84532.json
fi

if [ "$CHAIN" = "base_sepolia" ]; then
    rm chains-testnet/11155420.json chains-testnet/421614.json chains-testnet/11155111.json
fi

sed -ie 's|KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80|KEY='$PRIVKEY'|' docker-compose.yml
docker compose up -d
docker logs -f mee-node-deployment-node-1
