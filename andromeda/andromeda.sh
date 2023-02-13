#!/bin/bash

echo -e "\033[1;36m"
echo " ::::::'##:'########:'########:'########::'####:'##::::'## ";
echo " :::::: ##: ##.....::... ##..:: ##.... ##:. ##::. ##::'## ";
echo " :::::: ##: ##:::::::::: ##:::: ##:::: ##:: ##:::. ##'## ";
echo " :::::: ##: ######:::::: ##:::: ########::: ##::::. ### ";
echo " '##::: ##: ##...::::::: ##:::: ##.. ##:::: ##:::: ## ## ";
echo "  ##::: ##: ##:::::::::: ##:::: ##::. ##::: ##::: ##:. ## ";
echo " . ######:: ########:::: ##:::: ##:::. ##:'####: ##:::. ## ";
echo " :......:::........:::::..:::::..:::::..::....::..:::::..::";
echo -e "\e[0m"

sleep 2


if [ ! $MONIKER_AND ]; then
	read -p "Enter node name: " MONIKER_AND
	echo 'export MONIKER_AND='$MONIKER_AND >> $HOME/.bash_profile
fi
if [ ! $AND_PORT ]; then
	read -p "Enter port number: " AND_PORT
	echo 'export AND_PORT='$AND_PORT >> $HOME/.bash_profile
fi


echo -e "Your node name: \e[1m\e[32m$MONIKER_AND\e[0m"
echo -e "Your port: \e[1m\e[32m$AND_PORT\e[0m"


git clone https://github.com/andromedaprotocol/andromedad.git
cd andromedad
git checkout galileo-3-v1.1.0-beta1
make install
cd

andromedad config chain-id galileo-3
andromedad config keyring-backend test

andromedad init $MONIKER_AND --chain-id galileo-3

wget https://raw.githubusercontent.com/JeTr1x/addrbook/main/andromeda/genesis.json
mv genesis.json ~/.andromedad/config

PEERS=06d4ab2369406136c00a839efc30ea5df9acaf11@10.128.0.44:26656,43d667323445c8f4d450d5d5352f499fa04839a8@192.168.0.237:26656,29a9c5bfb54343d25c89d7119fade8b18201c503@192.168.101.79:26656,6006190d5a3a9686bbcce26abc79c7f3f868f43a@37.252.184.230:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.andromedad/config/config.toml

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${AND_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${AND_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${AND_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${AND_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${AND_PORT}660\"%" $HOME/.andromedad/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${AND_PORT}317\"%; s%^address = \":8080\"%address = \":${AND_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${AND_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${AND_PORT}091\"%" $HOME/.andromedad/config/app.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.andromedad/config/app.toml




sudo tee /etc/systemd/system/andromedad.service > /dev/null <<EOF
[Unit]
Description=andromeda node
After=network-online.target

[Service]
User=$USER
ExecStart=$(which andromedad) start --home $HOME/.andromedad
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable andromedad
sudo systemctl restart andromedad

journalctl -fu andromedad -o cat
