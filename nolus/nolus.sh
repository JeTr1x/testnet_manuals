

# set vars
if [ ! $NOLUS_MONIKER ]; then
	read -p "Enter node name: " NOLUS_MONIKER
	echo 'export NOLUS_MONIKER='$NOLUS_MONIKER >> $HOME/.bash_profile
fi
if [ ! $NOLUS_PORT ]; then
	read -p "Enter PORT NUM: " NOLUS_PORT
	echo 'export NOLUS_PORT='$NOLUS_PORT >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export NOLUS_CHAIN_ID=nolus-rila" >> $HOME/.bash_profile
echo "export NOLUS_PORT=${NOLUS_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NOLUS_MONIKER\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$NOLUS_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$NOLUS_PORT\e[0m"
echo '================================================='
sleep 2




sudo apt-get install -y build-essential

cd $HOME
VER="1.18.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm -rf  "go$VER.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
source $HOME/.bash_profile
go version


cd $HOME
git clone https://github.com/Nolus-Protocol/nolus-core
cd nolus-core
git checkout v0.1.39
make install


nolusd config node tcp://localhost:${NOLUS_PORT}657
nolusd config chain-id $NOLUS_CHAIN_ID
nolusd config keyring-backend test
nolusd init $NOLUS_MONIKER --chain-id $NOLUS_CHAIN_ID

curl https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/genesis.json > ~/.nolus/config/genesis.json

SEEDS=""
PEERS="14f604e40b6725e2099c660c2f20f2327c7591d8@182.253.216.183:13656,535ca6f6a016261b66ea32c693be35cc3c209414@185.217.125.35:26656,55acbb36f6e18ce9d5034c1e0f615bf13ee1ae27@195.2.80.63:43656,9f4512527a9e7eac1847b910f8d4b2c0ef1617de@5.161.180.85:26656,1bd72c18f426cdf31d2f26b5edbb5814387491df@38.242.222.57:26656,95ab3d7bd1c4700f3d7617c3672c65ad66009a7b@38.242.222.59:26656,fcb82df30d2056c3af024fb389e173d683fe8229@65.108.105.48:19756,2d500ae8bddfa548ee0fb0ed969709d78a4015af@144.168.47.230:26656,d694df8e90ddf6102be5c825e57fc58d55217629@143.198.205.193:26656,8b0b427b4567a7a66f05fab1146ee97b52ad7958@93.189.30.119:26656,c2e5fbe1a0acc345889ea778079f6ae8001f6f87@78.159.115.21:26656,e6b3d520d342782129689d5f9aee6c8f12933a61@51.89.7.235:26649,e95c1138763c637ca62a391bc316c9a96283d79f@188.40.122.98:36656,0ac306afff30fe9e04a0f02704251845acea7165@65.108.54.167:26656,0a507a8e774c22e32c91641ce732f29d79dd45a3@146.190.98.207:26656,5c2a752c9b1952dbed075c56c600c3a79b58c395@195.3.220.135:27016,0acc3e90c0c46a102564aa4511d3c6c4136f5548@217.76.57.68:37656,805f69593aeb23e78ae19b4adca24d0ddd513e12@38.242.141.147:26656,94c5f3b73893d6cfccb58cdcadf5d8687dd80b27@134.209.124.202:26656,ea96509508309059b5287b712c2a048b1724df4f@128.199.144.140:29656,71cb32264e19b25fc313d0ff8baf24fe948576a1@65.109.30.12:60656,621c459c333de1a03250bb846647fc858b9c8638@38.242.142.83:26656,c2c7344a10a39040592a8aa156ef9da17700d9a2@45.84.0.252:26656,3944ca0e6cc99e1bf951e7ab7984088c775e4f78@194.163.158.117:26656,236a2626ad46bb671b200883b6105350310372ef@135.181.81.65:37656,65145d3500c535aaa66984b188c90aa7a6a8b51c@167.235.192.148:21656,ef404b6e855c70ee51532ca83407350d2379bdec@5.161.101.185:26656,29ddd26fc5a4cb0177219806d21ff1df7f570dac@178.18.244.184:26656,b6c8dc38a5dba19a3f10d23b3572065db9265fa3@65.109.85.225:9000,10f3f2a8392b6b1340ba69e2743d6224a0ac0132@134.249.85.64:26656,7d1ac536c8451d1b64e9702fb172ac5b1b725778@65.109.85.221:9000,900d1cb2429206af2dea377257cbea0bb27dd625@38.242.233.94:26656,36bf6f60f2914352c93dcc6d827885e3e58b1f2b@158.160.20.18:26656,accae890c5c62f83cbb2d541de462065aaf67724@45.87.104.154:37656,f9212c512c676ba9373eae2e8e6c260167e49d82@4.227.188.37:26656,30e5fbf8fa448a73f780f881a0e81d3f6abb4b8f@138.68.66.69:26656,76b961a70249b7967ee51361807b87302178708e@38.242.200.89:26656,9d761ce1e1dc54ded3ab82ce0256c27631b5e82c@173.212.241.80:43656,d5d0230f2e9f0c0e37dfb6721a98d4b052c8ce95@84.46.241.158:26656,12b146cd82c7142e9d8aeb4f246499927ecb1c0f@217.13.223.167:36656,ab938d7b2af2ecad6af86df956fd61634ce439ff@65.108.234.11:16656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.nolus/config/config.toml

sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${NOLUS_PORT}317\"%;
s%^address = \":8080\"%address = \":${NOLUS_PORT}080\"%;
s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NOLUS_PORT}090\"%; 
s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NOLUS_PORT}091\"%; 
s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${NOLUS_PORT}545\"%; 
s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${NOLUS_PORT}546\"%" $HOME/.nolus/config/app.toml
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NOLUS_PORT}658\"%; 
s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://0.0.0.0:${NOLUS_PORT}657\"%; 
s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NOLUS_PORT}060\"%;
s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NOLUS_PORT}656\"%;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${NOLUS_PORT}656\"%;
s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NOLUS_PORT}660\"%" $HOME/.nolus/config/config.toml


sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.nolus/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.nolus/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" $HOME/.nolus/config/app.toml

sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.nolus/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.nolus/config/config.toml

nolusd tendermint unsafe-reset-all --home $HOME/.nolus --keep-addr-book

sudo tee /etc/systemd/system/nolusd.service > /dev/null <<EOF
[Unit]
Description=nolus
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nolusd) start --home $HOME/.nolus
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nolusd
sudo systemctl restart nolusd && sudo journalctl -u nolusd -f -o cat

