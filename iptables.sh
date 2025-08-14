sudo iptables -I OUTPUT 2 -d 10.0.0.0/8 -j DROP
sudo iptables -I OUTPUT 3 -d 172.16.0.0/12 -j DROP
sudo iptables -I OUTPUT 4 -d 192.168.0.0/16 -j DROP
sudo iptables -I OUTPUT 5 -d 100.64.0.0/10 -j DROP
sudo iptables -I OUTPUT 6 -d 198.18.0.0/15 -j DROP
sudo iptables -I OUTPUT 7 -d 169.254.0.0/16 -j DROP
sudo iptables -I OUTPUT 8 -d 100.79.0.0/16 -j DROP
sudo iptables -I OUTPUT 9 -d 100.113.0.0/16 -j DROP
sudo iptables -I OUTPUT 10 -d 172.0.0.0/8 -j DROP
sudo apt install iptables-persistent -y
sudo netfilter-persistent save

