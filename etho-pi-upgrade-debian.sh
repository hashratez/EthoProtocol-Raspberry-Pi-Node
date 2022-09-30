#!/usr/bin/env sh
[ $SUDO_USER ] && _user=$SUDO_USER || _user=`whoami`

while getopts ":n:u:w:" opt; do
  case $opt in
    n) _nodetype="$OPTARG"
    ;;
    u) _usertoken="$OPTARG"
    ;;
    w) _wallet="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

if [ $_nodetype = "gatewaynode" ] ; then
  echo "ethoFS Gateway Node Setup Initiated"
fi
if [ $_nodetype = "masternode" ] ; then
  echo "Ether-1 Masternode Setup Initiated"
fi
if [ $_nodetype = "servicenode" ] ; then
  echo "Ether-1 Service Node Setup Initiated"
fi

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'
# install dependencies
sudo apt-get update && sudo apt-get install systemd libcap2-bin policykit-1 unzip wget -y

echo '**************************'
echo 'Removing Old Node bins'
echo '**************************'
# Remove Geth
sudo rm /usr/sbin/geth
sudo systemctl stop ether1node && sudo systemctl disable ether1node
sudo rm /etc/systemd/system/ether1node.service
# Remove IPFS
sudo rm /usr/sbin/ifps
sudo rm -r $HOME/.ipfs
sudo systemctl stop ipfs && sudo systemctl disable ipfs
sudo rm /etc/systemd/system/ipfs.service
# Remove ethoFS
sudo rm /usr/sbin/ethoFS
sudo systemctl stop ethoFS && sudo systemctl disable ethoFS
sudo rm /etc/systemd/system/ethoFS.service

sudo rm $HOME/.ether1/ethofs/swarm.key

echo '**************************'
echo 'Installing ETHO Protocol Node binary'
echo '**************************'
# Download node binary
sudo wget https://github.com/Ether1Project/Ether1/releases/download/V2.1.0/geth-arm64 
sudo chmod +x geth-arm64
# Move Binaries
sudo mv geth-arm64 /usr/sbin/geth

echo '**************************'
echo 'Initiating (Geth, IPFS & ethoFS)'
echo '**************************'

if [ $_nodetype = "gatewaynode" ] ; then
  sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/geth
  /usr/sbin/geth --ethofs=gn --ethofsUser=$_usertoken --ethofsWallet=$_wallet --ethofsInit
  sleep 7
  /usr/sbin/geth --ethofs=gn --ethofsUser=$_usertoken --ethofsWallet=$_wallet --ethofsConfig
  sleep 7
  cat > /tmp/ether1node.service << EOL
  [Unit]
  Description=ETHO Gateway Node
  After=network.target

  [Service]

  User=$_user
  Group=$_user

  Type=simple
  Restart=always

  ExecStart=/usr/sbin/geth --syncmode=fast --cache=512 --datadir=$HOME/.ether1 --ethofs=gn --ethofsUser=$_usertoken --ethofsWallet=$_wallet

  [Install]
  WantedBy=default.target
EOL
  sudo mv /tmp/ether1node.service /etc/systemd/system
  sudo systemctl daemon-reload
  sudo systemctl enable ether1node && sudo systemctl start ether1node
  sudo systemctl restart ether1node
  sudo systemctl status ether1node --no-pager --full
fi

if [ $_nodetype = "masternode" ] ; then
  /usr/sbin/geth --ethofs=mn --ethofsUser=$_usertoken --ethofsWallet=$_wallet --ethofsInit
  sleep 7
  /usr/sbin/geth --ethofs=mn --ethofsUser=$_usertoken --ethofsWallet=$_wallet --ethofsConfig
  sleep 7
  cat > /tmp/ether1node.service << EOL
  [Unit]
  Description=ETHO Masternode
  After=network.target

  [Service]

  User=$_user
  Group=$_user

  Type=simple
  Restart=always

  ExecStart=/usr/sbin/geth --syncmode=fast --cache=512 --datadir=$HOME/.ether1 --ethofs=mn --ethofsUser=$_usertoken --ethofsWallet=$_wallet

  [Install]
  WantedBy=default.target
EOL
  sudo mv /tmp/ether1node.service /etc/systemd/system
  sudo systemctl daemon-reload
  sudo systemctl enable ether1node && sudo systemctl start ether1node
  sudo systemctl restart ether1node
  sudo systemctl status ether1node --no-pager --full
fi

if [ $_nodetype = "servicenode" ] ; then
  /usr/sbin/geth --ethofs=sn --ethofsUser=$_usertoken --ethofsWallet=$_wallet --ethofsInit
  sleep 7
  /usr/sbin/geth --ethofs=sn --ethofsUser=$_usertoken --ethofsWallet=$_wallet --ethofsConfig
  sleep 7
  cat > /tmp/ether1node.service << EOL
  [Unit]
  Description=ETHO Service Node
  After=network.target

  [Service]

  User=$_user
  Group=$_user

  Type=simple
  Restart=always

  ExecStart=/usr/sbin/geth --syncmode=fast --cache=512 --datadir=$HOME/.ether1 --ethofs=sn --ethofsUser=$_usertoken --ethofsWallet=$_wallet

  [Install]
  WantedBy=default.target
EOL
  sudo mv /tmp/ether1node.service /etc/systemd/system
  sudo systemctl daemon-reload
  sudo systemctl enable ether1node && sudo systemctl start ether1node
  sudo systemctl restart ether1node
  sudo systemctl status ether1node --no-pager --full
fi

echo '**************************'
echo 'Setup Complete'
echo '**************************'
