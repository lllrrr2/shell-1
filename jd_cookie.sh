#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 一键脚本
echo -e "\n   ${yellow}欢迎使用jd_cookie一键脚本：${plain}"


# 配置host
echo -e "   ${yellow}jd_cookie安装与升级聚合脚本 ${plain}"
echo "   1) 安装redis容器"
echo "   2) 安装jd_cookie"
echo "   3) 升级jd_cookie"
echo "   0) 退出"
echo -ne "\n你的选择: "
read input
case $input in
    0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
    1)	echo -e "${yellow}安装redis容器${plain}\n"; 
		echo -e "${yellow}正在拉取redis容器中...${plain}\n"; 
		docker pull redis
		echo -e "${yellow}请输入redis密码：${plain}\n"; 
		read  psw
		if  [ ! -n "${psw}" ] ;then
			psw="";
			echo -e "${yellow}redis未使用密码${plain}\n"
		fi
		
		echo -e "${yellow}请输入redis的端口：${plain}"; 
		read  port
		if  [ ! -n "${port}" ] ;then
			port=6379;
			echo -e "${yellow}redis使用默认端口6379${plain}"
		fi
		
		if  [ "$psw" == "" ];then
			docker run --privileged=true --restart=always --name redis -p $port:6379 -d redis redis-server --appendonly yes
		else 
			docker run --privileged=true --restart=always --name redis -p $port:6379 -d redis redis-server --appendonly yes --requirepass "$psw"
		fi
		echo -e "${yellow}redis启动成功${plain}"
		echo -e "\n";;
    2)	echo -e "${yellow}开始安装jd_cookie${plain}"; echo -e "\n"
		wget -O start_jd_cookie.sh  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/start_jd_cookie.sh;chmod +x *sh;bash start_jd_cookie.sh
	;;
	3)	echo -e "${yellow}开始安装jd_cookie${plain}"; echo -e "\n"
		wget -O update_jd_cookie.sh  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/update_jd_cookie.sh;chmod +x *sh;bash update_jd_cookie.sh
	;;
esac
