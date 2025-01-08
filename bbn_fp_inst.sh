


git clone https://github.com/babylonlabs-io/finality-provider
cd finality-provider
git checkout v0.14.3
make install 

eotsd init
read -rp "Enter EOTS MNEM: " EOTS_MNEM
echo -e "${EOTS_MNEM}\n" | eotsd keys add eots --recover --keyring-backend test

sleep 3
sudo tee /etc/systemd/system/eotsd.service > /dev/null <<EOF
[Unit]
Description=Babylon Eots  service
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which eotsd) start --home $HOME/.eotsd
Restart=always
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && \
sudo systemctl enable eotsd && \
sudo systemctl restart eotsd && \
sleep 1
sudo journalctl -u eotsd -o cat

fpd init
read -rp "Enter FPD MNEM: " FPD_MNEM
echo -e "${FPD_MNEM}\n" | fpd keys add finality-provider --recover --keyring-backend test

sleep 3

sed -i "s/ChainID = chain-test/ChainID = bbn-test-5/" $HOME/.fpd/fpd.conf
sed -i "s|RPCAddr = http://localhost:26657|RPCAddr = http://195.201.105.225:36657|" $HOME/.fpd/fpd.conf
sed -i "s|GRPCAddr = https://localhost:9090|GRPCAddr = https://195.201.105.225:36090|" $HOME/.fpd/fpd.conf
sed -i "s/RPCListener = 127.0.0.1:12581/RPCListener = 0.0.0.0:12581/" $HOME/.fpd/fpd.conf
sed -i "s/Host = 127.0.0.1/Host = 0.0.0.0/" $HOME/.fpd/fpd.conf


sudo tee /etc/systemd/system/fpd.service > /dev/null <<EOF
[Unit]
Description=Babylon FP service
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$(which fpd) start --home $HOME/.fpd
Restart=always
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && \
sudo systemctl enable fpd && \
sudo systemctl restart fpd && \
sleep 1
sudo journalctl -u fpd -o cat

