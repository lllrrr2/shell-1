#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

check_install() {
    if [ ! -d "${filePath}/flycloud/statics" ]; then
      echo -e "[INFO] 检测到当前不存在静态文件夹statics，即将下载文件"
      cd flycloud || exit
      wget -O ${filePath}/flycloud/statics.tar.gz  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/statics.tar.gz
      if [ $? -ne 0 ]; then
        echo -e "[Error] 下载静态文件失败，请检查网络或重新执行本脚本" && exit 2
      fi
      tar -zxvf statics.tar.gz && rm -rf statics.tar.gz
      echo -e "[SUCCESS] statics下载静态成功"
    fi
    if [ ! -f "${filePath}/flycloud/app.jar" ]; then
       echo -e "[INFO] 检测到当前不存在jar文件，即将下载文件"
       mkdir -p flycloud && cd flycloud || exit
       wget -O ${filePath}/flycloud/app.jar  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar >/dev/null 2>&1
       if [ $? -ne 0 ]; then
         echo -e "[Error] 下载二进制文件失败，请检查网络或重新执行本脚本" && exit 2
       fi
       cd ${filePath}/flycloud && docker restart flycloud
    fi
}

update_soft() {
  if [ -d "${filePath}/flycloud" ]; then
    cd "${filePath}" || exit
    echo -e "[INFO] 检测到当前已安装FlyCloud，即将下载更新文件"
    mkdir -p tmp && cd tmp || exit
    wget -O ${filePath}/flycloud/app.jar  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar >/dev/null 2>&1
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
      echo -e "[Error] 下载文件失败，请检查网络或重新执行本脚本" && cd .. && rm -rf tmp && exit 2
    fi
    if [ ! -d "${filePath}/flycloud/statics" ]; then
      echo -e "[INFO] 检测到当前不存在静态文件夹statics，即将下载文件"
      cd flycloud || exit
      wget -O ${filePath}/flycloud/statics.tar.gz  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/statics.tar.gz
      if [ $? -ne 0 ]; then
        echo -e "[Error] 下载静态文件失败，请检查网络或重新执行本脚本" && exit 2
      fi
      tar -zxvf statics.tar.gz && rm -rf statics.tar.gz
      echo -e "[SUCCESS] 下载静态成功"
    fi
    cd .. && rm -rf tmp
    cd ${filePath}/flycloud && docker restart flycloud
    echo -e "[SUCCESS] 更新flycloud文件成功"
  fi
}

check_update() {
  new_version=$(curl -s "https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/new_version")

  echo -e "[SUCCESS] 当前最新版本为：${new_version}"
  if [ -d "${filePath}/flycloud" ]; then
    cd ${filePath} || exit
    old_version=$(curl -s "https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/old_version")
    if version_gt "${new_version}" "${old_version}"; then
      update_soft
    fi
  else
    check_install
  fi
}

version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }



echo -e "${yellow}正在升级安装flycloud中...${plain}";


#使用模式
num=""

echo -e "\n请输入数字选择启动脚本模式:"
echo "   1) 使用--link redis:redis模式"
echo "   2) 普通模式"
echo "   0) 退出"
echo -ne "\n你的选择: "
read param
num=$param
case $param in
    0) echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
    1) echo -e "${yellow}使用--link redis:redis模式启动脚本${plain}";
       read -r -p "请确定使用该脚本的前提是，application.yml配置文件在flycloud文件夹，同时redis和flycloud两个容器是在同时关联启动? [y/n]: " link_input
       case $link_input in
         [yY][eE][sS]|[yY]) ;;
		 [nN][oO]|[nN]) exit 1 ;;
		 esac
		;;
    2) echo -e "${yellow}以普通模式启动脚本${plain}"; echo -e "\n";;
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
				    #直接重置当前路径
				    path=$PWD
					echo -e "${yellow}检测到当前路径$flycloud_path下无application.yml配置文件，开始下载一份示例文件用于初始化...${plain}\n"
                    echo -e "${yellow}下载配置文件application.yml模式${plain}";
                    echo "   1) 国内模式，启用加速下载"
                    echo "   2) 国外模式，不加速"
                    echo -ne "\n你的选择："
                    read  is_speed_yml_file
                    case $is_speed_yml_file in
                        1) 	echo "国内模式下载配置文件application.yml中。。。"
                            wget -O $path/flycloud/application.yml  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/application.yml
                            echo -e "${yellow}当前新下载的application.yml文件所在路径为：$path/flycloud${plain}"
                            path=$path/flycloud
                        ;;
                        2) 	echo "国外模式下载配置文件application.yml中。。。"
                            wget -O $path/flycloud/application.yml  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/flycloud/application.yml
                            echo -e "${yellow}当前新下载的application.yml文件所在路径为：$path/flycloud${plain}"
                            path=$path/flycloud
                        ;;
                    esac
                    #跳转至application.yml文件夹下
                    cd $path
                    # 替换脚本内容
                    echo -e "\n   ${yellow}开始配置启动文件：${plain}"
                    # 配置host
                    echo -e "   ${yellow}设置redis的连接地址host: ${plain}"
                    echo "   1) host使用默认redis"
                    echo "   2) host使用ip或者域名（当使用公网时，请放行redis使用的公网端口）"
                    echo "   0) 退出"
                    echo -ne "\n你的选择: "
                    read host
                    case $host in
                        0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
                        1)	echo -e "${yellow}host使用默认redis${plain}";
                    		grep -rnl 'host:'  $path/application.yml | xargs sed -i -r "s/host:.*$/host: redis/g" >/dev/null 2>&1
                    		echo -e "\n";;
                        2)	echo -e "${yellow}host使用ip或者域名（当使用公网时，请放行redis使用的公网端口）${plain}"; echo -e "\n"
                    		read -r -p "请输入ip或者域名：" url
                    		if  [ ! -n "${url}" ] ;then
                    			#url=$(curl -s ifconfig.me)
                    			echo -e "${red}未输入ip地址，退出程序${plain}"
                    			exit 1
                    		fi
                    		grep -rnl 'host:'  $path/application.yml | xargs sed -i -r "s/host:.*$/host: $url/g" >/dev/null 2>&1
                    	;;
                    esac
                    # 配置密码
                    echo -e "\n${yellow}设置redis的密码(默认为空): ${plain}"
                    read -r -p "请输入启动redis时设置的密码，不带特殊字符：" password
                    grep -rnl 'password:'  $path/application.yml | xargs sed -i -r "s/password:.*$/password: $password/g" >/dev/null 2>&1
                    # 配置端口
                    echo -e "\n${yellow}设置redis的端口(回车默认6379，当使用--link模式启动时，请使用6379端口)${plain}"
                    echo -e "${yellow}请输入端口(建议使用6379)：${plain}"
                    read port
                    if  [ ! -n "${port}" ] ;then
                    	port=6379;
                    	echo -e "${yellow}未输入端口，使用默认端口6379${plain}"
                    fi
                    grep -rnl 'port: '  $path/application.yml | xargs sed -i -r "s/port: [^port: 1170].*$/port: $port/g" >/dev/null 2>&1

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


# 检测容器是否启动了
id=$(docker ps | grep "flycloud" | awk '{print $1}')
id1=$(docker ps -a | grep "flycloud" | awk '{print $1}')
if [ -n "$id" ]; then
  #docker rm -f $id
  #检测是否存在文件 && 下载更新文件
  check_update
elif [ -n "$id1" ]; then
  #docker rm -f $id1
  #检测是否存在文件 && 下载更新文件
  check_update
else
  # 先更新flycloud镜像
  docker pull yuanter/flycloud:latest
  #启动容器
  if  [ $num -eq 1 ];then
  	docker run -d --privileged=true --restart=always  --name flycloud -p 1170:1170  -v $path:/root/flycloud --link redis:redis yuanter/flycloud
      echo -e "${yellow}使用--link redis:redis模式启动成功${plain}"
  else if [ $num -eq 2 ];then
  	docker run -d --privileged=true --restart=always  --name flycloud -p 1170:1170  -v $path:/root/flycloud yuanter/flycloud
      echo -e "${yellow}普通模式启动成功${plain}"
  	fi
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




