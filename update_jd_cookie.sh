#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

mode = ""

read -s -n1 -p "请输入数字选择启动脚本模式:\n0、退出\n1、使用--link redis:redis模式启动 \n2、删除--link redis:redis模式启动 " param
case $param in
    0) echo -e "\n${yellow}退出脚本程序${plain}\n"; exit(1) ;;
    1) echo -e "\n${yellow}使用--link redis:redis模式启动脚本${plain}\n"; echo -e "\n"
       read -r -p "请确定使用该脚本的前提是，application.yml配置文件在jd_cookie文件夹，同时redis和jd_cookie两个容器是在同时关联启动? [Y/n]: " link_input
       case $link_input in
         [yY][eE][sS]|[yY]) 
		 
		 esac
      ;; 
		 
    2) echo -e "\n${yellow}删除--link redis:redis模式启动脚本${plain}\n"; echo -e "\n"
	


#获取当前路径
path=$PWD


# 先自行判断路径是否有配置文件跳
if [ ! -f "/root/jd_cookie/application.yml" ]; then
	if [ ! -f "$path/application.yml" ]; then
		if [ ! -f "$path/jd_cookie/application.yml" ]; then
			read -r -p "请输入文件application.yml所在文件夹的绝对路径：" jd_cookie_path
			if [ ! -f "$jd_cookie_path/application.yml" ]; then
				echo "当前路径$jd_cookie_path下无application.yml文件，请重新输入路径：\n"
				read -r -p "请再次输入application.yml的绝对路径：" jd_cookie_path
				if [ ! -f "$jd_cookie_path/application.yml" ]; then
					echo "当前路径$jd_cookie_path下无application.yml文件，程序错误，退出程序：\n"
					exit(1)
				else
					path = jd_cookie_path
					cd $path
			  fi
			else
				path = jd_cookie_path
				cd $path
			fi
		else
			cd $path/jd_cookie
		fi
	fi
else
	cd /root/jd_cookie
fi


# 先更新镜像
docker pull yuanter/jd_cookie
# 移除容器
id=$(docker ps | grep "jd_cookie" | awk '{print $1}')
echo -e '$id'
if [ -n "$id" ]; then
  docker rm -f $id
fi
#docker rm -f jd_cookie
#启动容器
if  [ "${param}"=="1" ] ;then
	docker run -d --privileged=true --restart=always  --name jd_cookie -p 1170:1170  -v $PWD/application.yml:/application.yml --link redis:redis yuanter/jd_cookie
    echo -e "${yellow}使用--link redis:redis模式启动成功${plain}"
else if [ "${param}"=="2" ] ;then
	docker run -d --privileged=true --restart=always  --name jd_cookie -p 1170:1170  -v $PWD/application.yml:/application.yml yuanter/jd_cookie
    echo -e "${yellow}删除--link redis:redis模式启动成功${plain}"
else
	exit(1)
fi

#删除脚本
if [ -f "$path/update_jd_cookie.sh" ]; then
  echo "删除当前脚本文件"
  rm -rf $path/update_jd_cookie.sh
fi
