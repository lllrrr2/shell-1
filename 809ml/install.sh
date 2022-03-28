cd /usr/local/x-ui/bin/
rm -rf xray-linux-amd64
wget -O xray-linux-amd64.zip https://ghproxy.com/https://github.com/yuanter/shell/raw/main/809ml/xray-linux-amd64.zip
tar zxvf xray-linux-amd64.tar.gz
chmod 777 /usr/local/x-ui/bin/xray-linux-amd64
systemctl restart x-ui
