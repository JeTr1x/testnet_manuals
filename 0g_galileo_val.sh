


wget -O galileo.tar.gz https://github.com/0glabs/0gchain-NG/releases/download/v1.2.0/galileo-v1.2.0.tar.gz
tar -xzvf galileo.tar.gz -C ~
mv galileo-v1.2.0  galileo

mkdir -p /root/.0gchaind
mkdir -p /root/go/bin
cd galileo
cp -r 0g-home /root/.0gchaind
sudo chmod 777 ./bin/geth
sudo chmod 777 ./bin/0gchaind
./bin/geth init --datadir /root/.0gchaind/0g-home/geth-home ./genesis.json

./bin/0gchaind init validator --home /root/.0gchaind/tmp

mkdir -p /root/go/bin
cp  ./bin/geth /root/go/bin/geth
cp  ./bin/0gchaind /root/go/bin/0gchaind

cp /root/.0gchaind/tmp/data/priv_validator_state.json /root/.0gchaind/0g-home/0gchaind-home/data/
cp /root/.0gchaind/tmp/config/node_key.json /root/.0gchaind/0g-home/0gchaind-home/config/
cp /root/.0gchaind/tmp/config/priv_validator_key.json /root/.0gchaind/0g-home/0gchaind-home/config/

sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.0gchaind/0g-home/0gchaind-home/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.0gchaind/0g-home/0gchaind-home/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.0gchaind/0g-home/0gchaind-home/config/app.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.0gchaind/0g-home/0gchaind-home/config/config.toml

sudo tee /etc/systemd/system/0gchaind.service > /dev/null <<EOF
[Unit]
Description=0gchaind Node Service
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/0gchaind start \
    --rpc.laddr tcp://0.0.0.0:26657 \
	--chaincfg.chain-spec devnet \
    --chaincfg.kzg.trusted-setup-path=$HOME/galileo/kzg-trusted-setup.json \
    --chaincfg.engine.jwt-secret-path=$HOME/galileo/jwt-secret.hex \
    --chaincfg.kzg.implementation=crate-crypto/go-kzg-4844 \
    --chaincfg.block-store-service.enabled \
    --chaincfg.node-api.enabled \
    --chaincfg.node-api.logging \
    --chaincfg.node-api.address 0.0.0.0:3500 \
    --pruning=custom \
    --home $HOME/.0gchaind/0g-home/0gchaind-home \
    --p2p.external_address $(curl -s http://ipv4.icanhazip.com):26656 \
    --p2p.seeds 85a9b9a1b7fa0969704db2bc37f7c100855a75d9@8.218.88.60:26656
Environment=CHAIN_SPEC=devnet
WorkingDirectory=$HOME/galileo
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


sudo tee /etc/systemd/system/0ggeth.service > /dev/null <<EOF
[Unit]
Description=0g Geth Node Service
After=network-online.target

[Service]
User=$USER
ExecStart=$HOME/go/bin/geth \
    --config $HOME/galileo/geth-config.toml \
    --datadir $HOME/.0gchaind/0g-home/geth-home \
    --networkid 16601 \
    --http.port 8545 \
    --ws.port 8546 \
    --authrpc.port 8551 \
    --bootnodes enode://de7b86d8ac452b1413983049c20eafa2ea0851a3219c2cc12649b971c1677bd83fe24c5331e078471e52a94d95e8cde84cb9d866574fec957124e57ac6056699@8.218.88.60:30303 \
    --port 30303
Restart=always
WorkingDirectory=$HOME/galileo
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable 0ggeth.service
sudo systemctl restart 0ggeth.service
sudo systemctl enable 0gchaind.service
sudo systemctl restart 0gchaind.service

sleep 2
sudo journalctl -u 0gchaind -u 0ggeth 
sleep 2

systemctl stop 0gchaind 0ggeth


cd $HOME/.0gchaind/0g-home/0gchaind-home
rm -rf data
wget http://65.108.46.162:1514/0gchain_data.tar.gz
tar xvzf 0gchain_data.tar.gz
rm 0gchain_data.tar.gz



cd $HOME/.0gchaind/0g-home/geth-home
mv geth/nodekey nodekey
rm -rf geth
wget http://65.108.46.162:1514/0ggeth_data.tar.gz
tar xvzf 0ggeth_data.tar.gz
rm 0ggeth_data.tar.gz
mv nodekey geth/nodekey


sudo systemctl restart 0gchaind 0ggeth

sudo journalctl -u 0gchaind -u 0ggeth -f
















