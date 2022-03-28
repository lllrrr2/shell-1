cd /root/
wget -O xray-linux-amd64.zip https://ghproxy.com/https://github.com/yuanter/shell/raw/main/809ml/xray-linux-amd64.zip
unzip -o xray-linux-amd64.zip
rm -rf /usr/local/x-ui/bin/xray-linux-amd64
cp xray-linux-amd64 /usr/local/x-ui/bin/xray-linux-amd64
chmod 777 /usr/local/x-ui/bin/xray-linux-amd64
systemctl restart x-ui
rm -rf xray-linux-amd64.zip
rm -rf install.sh
echo "809专用内核替换成功"
