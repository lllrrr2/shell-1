#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# 一键脚本
echo -e "\n   ${yellow}欢迎使用jd_cookie一键脚本：${plain}"


# 配置host
echo -e "   ${yellow}jd_cookie安装与升级聚合脚本 ${plain}"
echo "   1) 安装jd_cookie"
echo "   2) 升级jd_cookie"
echo "   3) 安装redis容器（额外脚本，非必选）"
echo "   0) 退出"
echo -ne "\n你的选择: "
read input
case $input in
    0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
    1)	echo -e "${yellow}正在拉取安装jd_cookie脚本${plain}"; echo -e "\n"
        echo -e "${yellow}是否使用加速镜像(适用国内网络)下载安装脚本${plain}"; echo -e "\n"
        read  is_speed_one
        if  [ ! -n "${is_speed_one}" ] ;then
            wget -O start_jd_cookie.sh  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/start_jd_cookie.sh;chmod +x *sh;bash start_jd_cookie.sh
        else
            wget -O start_jd_cookie.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/start_jd_cookie.sh;chmod +x *sh;bash start_jd_cookie.sh
        fi

    ;;
    2)	echo -e "${yellow}正在拉取升级jd_cookie脚本${plain}"; echo -e "\n"
        echo -e "${yellow}是否使用加速镜像(适用国内网络)下载安装脚本${plain}"; echo -e "\n"
        read  is_speed_two
        if  [ ! -n "${is_speed_two}" ] ;then
            wget -O update_jd_cookie.sh  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/update_jd_cookie.sh;chmod +x *sh;bash update_jd_cookie.sh
        else
            wget -O update_jd_cookie.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/update_jd_cookie.sh;chmod +x *sh;bash update_jd_cookie.sh
        fi

    ;;
    3)	echo -e "${yellow}正在拉取安装redis脚本${plain}"; echo -e "\n"
        echo -e "${yellow}是否使用加速镜像(适用国内网络)下载安装脚本${plain}"; echo -e "\n"
        read  is_speed_three
        if  [ ! -n "${is_speed_three}" ] ;then
            wget -O redis_install.sh  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh;chmod +x *sh;bash redis_install.sh
        else
            wget -O redis_install.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh;chmod +x *sh;bash redis_install.sh
        fi
	;;
esac
