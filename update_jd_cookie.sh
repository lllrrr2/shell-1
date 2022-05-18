#!/bin/sh

# 先更新镜像
docker pull yuanter/jd_cookie
# 跳转至jd_cookie目录
cd /root/jd_cookie
# 移除容器
docker rm -f jd_cookie
#启动容器
docker run -d --privileged=true --restart=always  --name jd_cookie -p 1170:1170  -v $PWD/application.yml:/application.yml --link redis:redis yuanter/jd_cookie
