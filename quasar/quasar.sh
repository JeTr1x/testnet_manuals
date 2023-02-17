
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



if [ ! $QUAS_MONIKER ]; then
	read -p "Enter node name: " QUAS_MONIKER
	echo 'export MONIKER_AND='$QUAS_MONIKER >> $HOME/.bash_profile
fi


echo -e "Your node name: \e[1m\e[32m$QUAS_MONIKER\e[0m"

sleep 1





# Download project binaries
mkdir -p $HOME/.quasarnode/cosmovisor/genesis/bin
wget -O $HOME/.quasarnode/cosmovisor/genesis/bin/quasard https://github.com/quasar-finance/binary-release/raw/main/v0.0.2-alpha-11/quasarnoded-linux-amd64
chmod +x $HOME/.quasarnode/cosmovisor/genesis/bin/*

# Create application symlinks
ln -s $HOME/.quasarnode/cosmovisor/genesis $HOME/.quasarnode/cosmovisor/current
sudo ln -s $HOME/.quasarnode/cosmovisor/current/bin/quasard /usr/local/bin/quasard


# Download and install Cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0

# Create service
sudo tee /etc/systemd/system/quasard.service > /dev/null << EOF
[Unit]
Description=quasar-testnet node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.quasarnode"
Environment="DAEMON_NAME=quasard"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable quasard







# Set node configuration
quasard config chain-id qsr-questnet-04
quasard config keyring-backend test
quasard config node tcp://localhost:48657

# Initialize the node
quasard init $QUAS_MONIKER --chain-id qsr-questnet-04

# Download genesis and addrbook
curl -Ls https://snapshots.kjnodes.com/quasar-testnet/genesis.json > $HOME/.quasarnode/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/quasar-testnet/addrbook.json > $HOME/.quasarnode/config/addrbook.json

# Add seeds
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@quasar-testnet.rpc.kjnodes.com:48659\"|" $HOME/.quasarnode/config/config.toml

# Set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0uqsr\"|" $HOME/.quasarnode/config/app.toml

# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "10"|' \
  $HOME/.quasarnode/config/app.toml

# Set custom ports
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:48658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:48657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:48060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:48656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":48660\"%" $HOME/.quasarnode/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:48317\"%; s%^address = \":8080\"%address = \":48080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:48090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:48091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:48545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:48546\"%" $HOME/.quasarnode/config/app.toml


curl -L https://snapshots.kjnodes.com/quasar-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.quasarnode
[[ -f $HOME/.quasarnode/data/upgrade-info.json ]] && cp $HOME/.quasarnode/data/upgrade-info.json $HOME/.quasarnode/cosmovisor/genesis/upgrade-info.json

sudo systemctl start quasard && sudo journalctl -u quasard -f --no-hostname -o cat








