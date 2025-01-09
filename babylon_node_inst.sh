

read -p "Enter node name: " BABYLON_MONIK
echo 'export BABYLON_MONIK='$BABYLON_MONIK >> $HOME/.bash_profile
netstat -tulpn | grep 657
read -p "Enter portnum (10-64): " BABYLON_PORT
echo 'export BABYLON_PORT='$BABYLON_PORT >> $HOME/.bash_profile

git clone https://github.com/babylonlabs-io/babylon
cd babylon
git checkout v1.0.0-rc.3
make install

babylond version
babylond init $BABYLON_MONIK --chain-id bbn-test-5 



sed -ie app.toml
sed -i "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.005ubbn\"/" $HOME/.babylond/config/app.toml
sed -i "s/^iavl-cache-size *=.*/iavl-cache-size = \"5000\"/" $HOME/.babylond/config/app.toml
sed -i "s/^network *=.*/network = \"signet\"/" $HOME/.babylond/config/app.toml

sed -i "s/localhost:9090/0.0.0.0:9090/" $HOME/.babylond/config/app.toml


sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.babylond/config/app.toml
  
sed -ie config.toml
seed="26d834efe78949b5ed37454a3949d413d8392886@rpc-t.babylon.nodestake.org:666,366f5eb9ffb2efacf850f0aee5f254afe2781c84@176.9.29.51:26656,1b26db77c9701bef02dafa5aa43715330082bb5b@116.202.233.2:20656"
sed -i.bak -e "s/^seeds *=.*/seeds = \"$seed\"/" ~/.babylond/config/config.toml

sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${BABYLON_PORT}958\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${BABYLON_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${BABYLON_PORT}960\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${BABYLON_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${BABYLON_PORT}966\"%" $HOME/.babylond/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:${BABYLON_PORT}917\"%; s%^address = \":8080\"%address = \":${BABYLON_PORT}980\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:${BABYLON_PORT}990\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${BABYLON_PORT}991\"%; s%:8545%:${BABYLON_PORT}945%; s%:8546%:${BABYLON_PORT}946%; s%:6065%:${BABYLON_PORT}965%" $HOME/.babylond/config/app.toml
sed -i '/\[rpc\]/,/\[/{s/^laddr = "tcp:\/\/127\.0\.0\.1:/laddr = "tcp:\/\/0.0.0.0:/}' $HOME/.babylond/config/config.toml

curl -Ls https://raw.githubusercontent.com/babylonlabs-io/networks/030a0c7b29b1156840383e09816b4187560c41e4/bbn-test-5/network-artifacts/genesis.json > $HOME/.babylond/config/genesis.json 


cp $HOME/.babylond/data/priv_validator_state.json $HOME/.babylond/priv_validator_state.json.backup
rm -rf $HOME/.babylond/data
rm -rf $HOME/.babylond/wasm
rm -rf $HOME/.babylond/ibc_08-wasm
SNAP_NAME=$(curl -s https://ss-t.babylon.nodestake.org/ | egrep -o ">20.*\.tar.lz4" | tr -d ">")
curl -o - -L https://ss-t.babylon.nodestake.org/${SNAP_NAME}  | lz4 -c -d - | tar -x -C $HOME/.babylond
mv $HOME/.babylond/priv_validator_state.json.backup $HOME/.babylond/data/priv_validator_state.json


sudo tee /etc/systemd/system/babylond.service > /dev/null <<EOF
[Unit]
Description=Babylon Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which babylond) start --chain-id bbn-test-5 --x-crisis-skip-assert-invariants
Restart=always
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && \
sudo systemctl enable babylond && \
sudo systemctl restart babylond && \
sudo journalctl -u babylond -f -o cat


