if [ ! $MONIKERNAME ]; then
	read -p "Enter node name: " MONIKERNAME
	echo 'export MONIKERNAME='$MONIKERNAME >> $HOME/.bash_profile
fi
netstat -tulpn | grep 657
if [ ! $KYVE_PORT ]; then
	read -p "Enter port number: " KYVE_PORT
	echo 'export KYVE_PORT='$KYVE_PORT >> $HOME/.bash_profile
fi

go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0
wget https://files.kyve.network/chain/v1.0.0-rc0/kyved_linux_amd64.tar.gz
tar -xvzf kyved_linux_amd64.tar.gz
chmod +x kyved
sudo cp kyved /usr/local/bin/kyved
rm kyved_linux_amd64.tar.gz
kyved init MONIKERNAME --chain-id kaon-1
mkdir -p ~/.kyve/cosmovisor/genesis/bin
mkdir -p ~/.kyve/cosmovisor/upgrades
cp /usr/local/bin/kyved ~/.kyve/cosmovisor/genesis/bin
curl https://raw.githubusercontent.com/KYVENetwork/networks/main/kaon-1/genesis.json > ~/.kyve/config/genesis.json
wget -qO $HOME/.kyve/config/addrbook.json wget "https://snapshot.yeksin.net/kyve/addrbook.json"

sed -i 's|^pruning *=.*|pruning = "custom"|g' $HOME/.kyve/config/app.toml
sed -i 's|^pruning-keep-recent  *=.*|pruning-keep-recent = "100"|g' $HOME/.kyve/config/app.toml
sed -i 's|^pruning-interval *=.*|pruning-interval = "'10'"|g' $HOME/.kyve/config/app.toml

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${KYVE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${KYVE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${KYVE_PORT}060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${KYVE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${KYVE_PORT}660\"%" $HOME/.kyve/config/config.toml
sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:${KYVE_PORT}317\"%; s%^address = \":8080\"%address = \":${KYVE_PORT}080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${KYVE_PORT}090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${KYVE_PORT}091\"%" $HOME/.kyve/config/app.toml
PEERS="7258cf2c1867cc5b997baa19ff4a3e13681f14f4@68.183.143.17:26656, f5f83485ce4fc708dfa8b4de22361fdd15fba3ee@192.168.0.97:26656, aaa8a6f7eab9d20e87bcc01ddd53616cbd203c36@136.243.88.91:26656"
sed -i -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.kyve/config/config.toml
sudo tee <<EOF >/dev/null /etc/systemd/system/kyved.service
[Unit]
Description="kyved node"
After=network-online.target



sudo tee <<EOF >/dev/null /etc/systemd/system/kyved.service
[Unit]
Description="kyved node"
After=network-online.target

[Service]
User=root
ExecStart=/root/go/bin/cosmovisor start
Restart=always
RestartSec=3
LimitNOFILE=4096
Environment="DAEMON_NAME=kyved"
Environment="DAEMON_HOME=/root/.kyve"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && sudo systemctl enable kyved && sudo systemctl restart kyved

sleep 10

sudo systemctl stop kyved
cp $HOME/.kyve/data/priv_validator_state.json $HOME/.kyve/priv_validator_state.json.backup
kyved tendermint unsafe-reset-all --home $HOME/.kyve --keep-addr-book
curl -L https://snapshot.yeksin.net/kyve/data.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.kyve
mv $HOME/.kyve/priv_validator_state.json.backup $HOME/.kyve/data/priv_validator_state.json


sudo systemctl restart kyved && journalctl -u kyved -f -o cat



