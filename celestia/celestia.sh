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

# set vars
read -p "Enter node name: " MONIKERCEL

sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.21.1.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)

cd $HOME
systemctl stop celestia-appd
rm -rf celestia-app .celestia-app
git clone https://github.com/celestiaorg/celestia-app.git
cd celestia-app
git checkout v1.0.0-rc14
make build
mkdir -p $HOME/.celestia-app/cosmovisor/genesis/bin
mv build/celestia-appd $HOME/.celestia-app/cosmovisor/genesis/bin/
rm -rf build
sudo ln -s $HOME/.celestia-app/cosmovisor/genesis $HOME/.celestia-app/cosmovisor/current -f
sudo ln -s $HOME/.celestia-app/cosmovisor/current/bin/celestia-appd /usr/local/bin/celestia-appd -f
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0



sudo tee /etc/systemd/system/celestia-appd.service > /dev/null << EOF
[Unit]
Description=celestia node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.celestia-app"
Environment="DAEMON_NAME=celestia-appd"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.celestia-app/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable celestia-appd


celestia-appd config chain-id mocha-4
celestia-appd config keyring-backend test
celestia-appd config node tcp://localhost:12057

# Initialize the node
celestia-appd init $MONIKERCEL --chain-id mocha-4


curl -Ls https://snapshots.kjnodes.com/celestia-testnet/genesis.json > $HOME/.celestia-app/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/celestia-testnet/addrbook.json > $HOME/.celestia-app/config/addrbook.json



sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@celestia-testnet.rpc.kjnodes.com:12059\"|" $HOME/.celestia-app/config/config.toml

# Set commit timeout
sed -i -e "s|^target_height_duration *=.*|timeout_commit = \"11s\"|" $HOME/.celestia-app/config/config.toml

# Set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.005utia\"|" $HOME/.celestia-app/config/app.toml

# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "nothing"|' \
  $HOME/.celestia-app/config/app.toml

# Set custom ports
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:12058\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:12057\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:12060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:12056\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":12066\"%" $HOME/.celestia-app/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:12017\"%; s%^address = \":8080\"%address = \":12080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:12090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:12091\"%; s%:8545%:12045%; s%:8546%:12046%; s%:6065%:12065%" $HOME/.celestia-app/config/app.toml


curl -L https://snapshots.kjnodes.com/celestia-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.celestia-app
[[ -f $HOME/.celestia-app/data/upgrade-info.json ]] && cp $HOME/.celestia-app/data/upgrade-info.json $HOME/.celestia-app/cosmovisor/genesis/upgrade-info.json

sudo systemctl start celestia-appd && sudo journalctl -u celestia-appd -f --no-hostname -o cat
