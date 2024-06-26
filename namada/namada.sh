#install update and libs
if [ ! $VALIDATOR_ALIAS ]; then
	read -p "Enter node name: " VALIDATOR_ALIAS
	echo 'export VALIDATOR_ALIAS='$VALIDATOR_ALIAS >> $HOME/.bash_profile
fi
echo "export NAMADA_TAG=v0.12.2" >> ~/.bash_profile
echo "export TM_HASH=v0.1.4-abciplus" >> ~/.bash_profile
echo "export NAM_CHAIN_ID=public-testnet-1.0.05ab4adb9db" >> ~/.bash_profile
source ~/.bash_profile

echo "Your nodename/alias: " $VALIDATOR_ALIAS 
echo "Chain-id:" $NAM_CHAIN_ID
sleep 2

cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libclang-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
sudo apt install -y uidmap dbus-user-session


cd $HOME && git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG
make build-release
cargo --version

cd $HOME && git clone https://github.com/heliaxdev/tendermint && cd tendermint && git checkout $TM_HASH
make build

cd $HOME && cp $HOME/tendermint/build/tendermint  /usr/local/bin/tendermint && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw
tendermint version
namada --version

sleep 2

#run fullnode
cd $HOME && namada client utils join-network --chain-id $NAM_CHAIN_ID

cd $HOME && wget https://github.com/heliaxdev/anoma-network-config/releases/download/public-testnet-1.0.05ab4adb9db/public-testnet-1.0.05ab4adb9db.tar.gz
tar xvzf "$HOME/public-testnet-1.0.05ab4adb9db.tar.gz"

sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target

[Service]
User=root
WorkingDirectory=$HOME/.namada
Environment=NAMADA_LOG=debug
Environment=ANOMA_TM_STDOUT=true
ExecStart=/usr/local/bin/namada --base-dir=$HOME/.namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable namadad
sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat


