#!/bin/sh

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

echo -e "${yellow}正在升级安装flycloud中...${plain}";


#使用模式
num=""

echo -e "\n请输入数字选择启动脚本模式:"
echo "   1) 使用--link redis:redis模式启动"
echo "   2) 删除--link redis:redis模式启动"
echo "   0) 退出"
echo -ne "\n你的选择: "
read param
num=$param
case $param in
    0) echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
    1) echo -e "${yellow}使用--link redis:redis模式启动脚本${plain}";
       read -r -p "请确定使用该脚本的前提是，application.yml配置文件在flycloud文件夹，同时redis和flycloud两个容器是在同时关联启动? [Y/n]: " link_input
       case $link_input in
         [yY][eE][sS]|[yY]) ;;
		 [nN][oO]|[nN]) exit 1 ;;
		 esac
		;;
    2) echo -e "${yellow}删除--link redis:redis模式启动脚本${plain}"; echo -e "\n";;
esac



#获取当前路径
path=$PWD
#当前文件路径
filePath=$PWD


# 先自行判断路径是否有配置文件跳
if [ ! -f "/root/flycloud/application.yml" ]; then
	if [ ! -f "$path/application.yml" ]; then
		if [ ! -f "$path/flycloud/application.yml" ]; then
			read -r -p "请输入文件application.yml所在文件夹的绝对路径：" flycloud_path
			path=$flycloud_path
			if [ ! -f "$flycloud_path/application.yml" ]; then
				echo -e "${yellow}当前路径$flycloud_path下无application.yml文件，请重新输入路径：${plain}"
				read -r -p "请再次输入application.yml的绝对路径：" flycloud_path
				path=$flycloud_path
				if [ ! -f "$flycloud_path/application.yml" ]; then
					echo -e "${red}当前路径$flycloud_path下无application.yml文件，程序错误，请重新安装flycloud，退出程序：${plain}"
					exit 1
				else
					path=$flycloud_path
				fi
			fi
		else
			path=$path/flycloud
		fi
	fi
else
	path="/root/flycloud";
fi

#跳转至application.yml文件夹下
cd $path
echo -e "application.yml文件所在路径为：$PWD"


#判断redis是否启动了
redis_id=$(docker ps -a | grep "redis" | awk '{print $1}')
redis_id1=$(docker ps -a | grep "redis" | awk '{print $1}')
if [ -n "$redis_id" ]; then
  #docker rm -f $redis_id
  docker restart $redis_id
else if [ -n "$redis_id1" ]; then
  #docker rm -f $redis_id1
  docker restart $redis_id1
  fi
fi


# 移除容器
id=$(docker ps | grep "flycloud" | awk '{print $1}')
id1=$(docker ps -a | grep "flycloud" | awk '{print $1}')
if [ -n "$id" ]; then
  docker rm -f $id
else if [ -n "$id1" ]; then
  docker rm -f $id1
  fi
fi

# 先更新flycloud镜像
docker pull yuanter/flycloud:latest

#启动容器
if  [ $num -eq 1 ];then
	docker run -d --privileged=true --restart=always  --name flycloud -p 1170:1170  -v $path:/root/flycloud --link redis:redis yuanter/flycloud
    echo -e "${yellow}使用--link redis:redis模式启动成功${plain}"
else if [ $num -eq 2 ];then
	docker run -d --privileged=true --restart=always  --name flycloud -p 1170:1170  -v $path:/root/flycloud yuanter/flycloud
    echo -e "${yellow}删除--link redis:redis模式启动成功${plain}"
	fi
fi

#删除脚本
if [ -f "$filePath/update_flycloud.sh" ]; then
	rm -rf $filePath/update_flycloud.sh
	echo  -e "${yellow}删除当前脚本文件成功${plain}"
fi

echo  -e "${green}升级成功${plain}"
ip_url=$(curl -s ifconfig.me)
echo  -e "${yellow}请网页打开本项目地址：http://$ip_url:1170${plain}"