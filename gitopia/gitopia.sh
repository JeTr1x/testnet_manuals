#!/bin/bash

echo -e "\033[0;35m"
echo " :::    ::: ::::::::::: ::::    :::  ::::::::  :::::::::  :::::::::: ::::::::  ";
echo " :+:   :+:      :+:     :+:+:   :+: :+:    :+: :+:    :+: :+:       :+:    :+: ";
echo " +:+  +:+       +:+     :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+       +:+        ";
echo " +#++:++        +#+     +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#++:++#  +#++:++#++ ";
echo " +#+  +#+       +#+     +#+  +#+#+# +#+    +#+ +#+    +#+ +#+              +#+ ";
echo " #+#   #+#  #+# #+#     #+#   #+#+# #+#    #+# #+#    #+# #+#       #+#    #+# ";
echo " ###    ###  #####      ###    ####  ########  #########  ########## ########  ";
echo -e "\e[0m"


sleep 2

# set vars
if [ ! $GIT_NODENAME ]; then
	read -p "Enter node name: " GIT_NODENAME
	echo 'export GIT_NODENAME='$GIT_NODENAME >> $HOME/.bash_profile
fi
if [ ! $GIT_PORT ]; then
	read -p "Enter node port: " GIT_PORT
	echo 'export GIT_PORT='$GIT_PORT >> $HOME/.bash_profile
fi
echo "export WALLET=wallet" >> $HOME/.bash_profile
echo "export GITCHAIN_ID=gitopia-janus-testnet" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo 'Your node name: ' $GIT_NODENAME
echo 'Your port num: ' $GIT_PORT
echo 'Your wallet name: ' $WALLET
echo 'Your chain name: ' $GITCHAIN_ID
echo '================================================='
sleep 2

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

# install go
ver="1.18.2"
cd $HOME
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# install gitopia helper
curl https://get.gitopia.com | bash

# download binary
cd $HOME
git clone -b v1.2.0 gitopia://gitopia/gitopia
cd gitopia && make install

# config
gitopiad config chain-id $GITCHAIN_ID
gitopiad config keyring-backend test
gitopiad config node tcp://localhost:${GIT_PORT}657

# init
gitopiad init $GIT_NODENAME --chain-id $GITCHAIN_ID

# download addrbook and genesis
cd $HOME
wget https://server.gitopia.com/raw/gitopia/testnets/master/gitopia-janus-testnet-2/genesis.json.gz
gunzip genesis.json.gz
mv genesis.json $HOME/.gitopia/config/genesis.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001utlore\"/" $HOME/.gitopia/config/app.toml

# set peers and seeds
SEEDS="399d4e19186577b04c23296c4f7ecc53e61080cb@seed.gitopia.com:26656"
PEERS=""
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.gitopia/config/config.toml

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${GIT_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${GIT_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${GIT_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${GIT_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${GIT_PORT}660\"%" $HOME/.gitopia/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${GIT_PORT}317\"%; s%^address = \":8080\"%address = \":${GIT_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${GIT_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${GIT_PORT}091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:${GIT_PORT}545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:${GIT_PORT}546\"%" $HOME/.gitopia/config/app.toml

pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.gitopia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.gitopia/config/app.toml


# reset
gitopiad unsafe-reset-all

# create service
tee $HOME/gitopiad.service > /dev/null <<EOF
[Unit]
Description=gitopia
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which gitopiad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo mv $HOME/gitopiad.service /etc/systemd/system/

# start service
sudo systemctl daemon-reload
sudo systemctl enable gitopiad
sudo systemctl restart gitopiad

echo '=============== SETUP FINISHED ==================='
echo -e 'To check logs: \e[1m\e[32mjournalctl -u gitopiad -f -o cat\e[0m'
echo -e 'To check sync status: \e[1m\e[32mcurl -s localhost:26657/status | jq .result.sync_info\e[0m'
