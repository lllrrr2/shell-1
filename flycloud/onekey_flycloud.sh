#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

#获取当前路径
path=$PWD
#当前文件路径
filePath=$PWD


#检测是否安装redis
check_redis(){
    #判断是否已安装redis镜像
    id=$(docker ps | grep "redis" | awk '{print $1}')
    id1=$(docker ps -a | grep "redis" | awk '{print $1}')
    if [ -n "$id" ]; then
      #docker rm -f $id
      echo -e "${yellow}检测到已安装redis镜像，跳过安装redis镜像过程${plain}"
      docker restart redis
    elif [ -n "$id1" ]; then
      #docker rm -f $id1
      echo -e "${yellow}检测到已安装redis镜像，跳过安装redis镜像过程${plain}"
      docker restart redis
    else
      echo -e "${yellow}检测到还未安装redis镜像，本项目依赖redis数据库，是否安装redis镜像${plain}";
      echo "   1) 安装redis"
      echo "   0) 退出整个脚本安装程序"
      read input
      case $input in
            0)	echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
            1)	echo -e "${yellow}正在拉取安装redis脚本${plain}";
                echo -e "${yellow}下载脚本模式${plain}";
                echo "   1) 国内模式，启用加速"
                echo "   2) 国外模式，不加速"
                echo -ne "\n你的选择："
                read  is_speed_two
                case $is_speed_two in
                    1) 	echo "国内模式下载安装脚本中。。。"
                        wget -O redis_install.sh  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh >/dev/null 2>&1
                        chmod +x *sh
                        bash redis_install.sh
                    ;;
                    2) 	echo "国外模式下载安装脚本中。。。"
                        wget -O redis_install.sh  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/redis_install.sh >/dev/null 2>&1
                        chmod +x *sh
                        bash redis_install.sh
                    ;;
                esac
            ;;
      esac
    fi
}



#判断是否已经下载application.yml
check_yml(){
    echo -e "${yellow}检测application.yml配置文件中...${plain}\n"
    if [ ! -f "${filePath}/flycloud/application.yml" ]; then
    	if [ ! -f "$path/application.yml" ]; then
    		if [ ! -f "$path/flycloud/application.yml" ]; then
    			echo -e "${yellow}检测到application.yml配置文件不存在，开始下载一份示例文件用于初始化...${plain}\n"
    			echo -e "${yellow}下载配置文件application.yml模式${plain}";
                echo "   1) 国内模式，启用加速下载"
                echo "   2) 国外模式，不加速"
                echo -ne "\n你的选择："
                read  is_speed_yml_file
                case $is_speed_yml_file in
                    1) 	echo "国内模式下载配置文件application.yml中。。。"
                        wget -O $path/flycloud/application.yml  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/application.yml >/dev/null 2>&1
                        echo -e "${yellow}当前新下载的application.yml文件所在路径为：$path/flycloud${plain}"
                        path=$path/flycloud
                    ;;
                    2) 	echo "国外模式下载配置文件application.yml中。。。"
                        wget -O $path/flycloud/application.yml  --no-check-certificate https://raw.githubusercontent.com/yuanter/shell/main/flycloud/application.yml >/dev/null 2>&1
                        echo -e "${yellow}当前新下载的application.yml文件所在路径为：$path/flycloud${plain}"
                        path=$path/flycloud
                    ;;
                esac

    		else
    			path=$path/flycloud
    		fi
    	fi
    else
    	path="/root/flycloud";
    fi

    #跳转至application.yml文件夹下
    cd $path
    echo -e "application.yml文件所在路径为：$path"

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
    echo -e "${yellow}设置redis的密码(默认为空): ${plain}"
    read -r -p "请输入启动redis时设置的密码，不带特殊字符：" password
    grep -rnl 'password:'  $path/application.yml | xargs sed -i -r "s/password:.*$/password: $password/g" >/dev/null 2>&1
    # 配置端口
    echo -e "${yellow}设置redis的端口(回车默认6379，当使用--link模式启动时，请使用6379端口)${plain}"
    echo -e "${yellow}请输入端口(建议使用6379)：${plain}"
    read port
    if  [ ! -n "${port}" ] ;then
    	port=6379;
    	echo -e "${yellow}未输入端口，使用默认端口6379${plain}"
    fi
    grep -rnl 'port: '  $path/application.yml | xargs sed -i -r "s/port: [^port: 1170].*$/port: $port/g" >/dev/null 2>&1

    # 卡密
    echo -e "${yellow}设置授权token: ${plain}"
    read -r -p "请输入请输入您的授权码：" token
    grep -rnl 'token:'  $path/application.yml | xargs sed -i -r "s/token:.*$/token: $token/g" >/dev/null 2>&1
    # 授权地址
    echo -e "${yellow}设置授权网址: ${plain}"
    read -r -p "请输入请输入您的授权网址：" url
    grep -rnl 'url:'  $path/application.yml | xargs sed -i -r "s/url:.*$/url: $url/g" >/dev/null 2>&1


    # 移除容器
    id=$(docker ps | grep "flycloud" | awk '{print $1}')
    id1=$(docker ps -a | grep "flycloud" | awk '{print $1}')
    if [ -n "$id" ]; then
      docker rm -f $id
    else if [ -n "$id1" ]; then
      docker rm -f $id1
      fi
    fi


    # 更新镜像
    echo -e "\n${yellow}更新最新镜像中...${plain}"
    docker pull yuanter/flycloud:latest

    #使用模式
    num=""

    echo -e "\n${yellow}请输入数字选择启动脚本模式：${plain}"
    echo "   1) 使用--link模式启动(redis容器和flycloud容器在同一主机，符合条件推荐使用该模式)"
    echo "   2) 以普通模式启动"
    echo "   0) 退出"
    echo -ne "\n你的选择："
    read param
    num=$param
    case $param in
        0) echo -e "${yellow}退出脚本程序${plain}";exit 1 ;;
        1) echo -e "${yellow}使用--link模式启动脚本${plain}"; echo -e "\n"
           read -r -p "请确定使用该脚本的前提是redis是使用本脚本安装的容器且redis端口为6379，同时和flycloud容器在同一个主机? [y/n]: " link_input
           case $link_input in
             [yY][eE][sS]|[yY]) ;;
    		 [nN][oO]|[nN]) exit 1 ;;
    		 esac
    		;;
        2) echo -e "${yellow}以普通模式启动脚本${plain}"; echo -e "\n";;
    esac

    #启动容器
    if  [ $num -eq 1 ];then
    	docker run -d --privileged=true --restart=always  --name flycloud -p 1170:1170  -v $path:/root/flycloud --link redis:redis yuanter/flycloud
        echo -e "${yellow}使用--link模式启动成功${plain}"
    else if [ $num -eq 2 ];then
    	docker run -d --privileged=true --restart=always  --name flycloud -p 1170:1170  -v $path:/root/flycloud yuanter/flycloud
        echo -e "${yellow}以普通模式启动成功${plain}"
    	fi
    fi

}


check_install() {
    #检测静态文件
    if [ ! -d "${filePath}/flycloud/statics" ]; then
      echo -e "[INFO] 检测到当前不存在静态文件夹statics，即将下载文件"
      mkdir -p flycloud && cd flycloud || exit
      wget -O ${filePath}/flycloud/statics.tar.gz  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/statics.tar.gz >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo -e "[Error] 下载静态文件失败，请检查网络或重新执行本脚本" && exit 2
      fi
      tar -zxvf statics.tar.gz  >/dev/null 2>&1 && rm -rf statics.tar.gz
      echo -e "[SUCCESS] statics下载静态成功"
    fi
    #检测app.jar
    if [ ! -f "${filePath}/flycloud/app.jar" ]; then
       echo -e "[INFO] 检测到当前不存在jar文件，即将下载文件"
       cd ${filePath}/flycloud || exit
       wget -O ${filePath}/flycloud/app.jar  --no-check-certificate https://ghproxy.com/https://github.com/yuanter/shell/raw/main/flycloud/app.jar >/dev/null 2>&1
       if [ $? -ne 0 ]; then
         echo -e "[Error] 下载二进制文件失败，请检查网络或重新执行本脚本" && exit 2
       fi
    fi

    #检测是否安装redis
    check_redis
    #检测application.yml文件
    check_yml
}

update_soft() {
  if [ -d "${filePath}/flycloud" ]; then
    cd "${filePath}/flycloud" || exit
    echo -e "[INFO] 检测到当前已安装FlyCloud，即将下载更新文件"
    wget -O ${filePath}/flycloud/app.jar  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/app.jar >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo -e "[Error] 下载文件失败，请检查网络或重新执行本脚本"  && exit 2
    fi
    if [ ! -d "${filePath}/flycloud/statics" ]; then
      echo -e "[INFO] 检测到当前不存在静态文件夹statics，即将下载文件"
      cd ${filePath}/flycloud || exit
      wget -O ${filePath}/flycloud/statics.tar.gz  --no-check-certificate https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/statics.tar.gz >/dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo -e "[Error] 下载静态文件失败，请检查网络或重新执行本脚本" && exit 2
      fi
      tar -zxvf statics.tar.gz && rm -rf statics.tar.gz
      echo -e "[SUCCESS] 下载静态成功"
    fi

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

    cd ${filePath}/flycloud && docker restart flycloud
    echo -e "[SUCCESS] 更新flycloud文件成功"
  fi
}

check_update() {
  new_version=$(curl -s "https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/new_version")

  echo -e "[SUCCESS] 当前最新版本为：${new_version}"
  if [ -d "${filePath}/flycloud" ]; then
    cd ${filePath} || exit
    old_version=$(curl -s "https://ghproxy.com/https://raw.githubusercontent.com/yuanter/shell/main/flycloud/old_version")
    if version_gt "${new_version}" "${old_version}"; then
      update_soft
    fi
  else
    check_install
  fi
}

version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }





main() {
  #检测是否存在文件 && 下载更新文件
  check_update

  #删除脚本
  if [ -f "$filePath/start_flycloud.sh" ]; then
  	rm -rf $filePath/start_flycloud.sh
  	echo  -e "${yellow}删除当前脚本文件成功${plain}"
  fi

  echo  -e "${green}flycloud启动成功${plain}"
  ip_url=$(curl -s ifconfig.me)
  echo  -e "${yellow}请网页打开本项目地址：http://$ip_url:1170${plain}"
}

main