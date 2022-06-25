#!/bin/sh

# 先更新镜像
docker pull yuanter/jd_cookie
# 跳转至jd_cookie目录
cd /root/jd_cookie
# 移除容器
id=$(docker ps | grep "jd_cookie" | awk '{print $1}')
echo -e '$id'
if [ -n "$id" ]; then
  docker rm -f $id
fi
#docker rm -f jd_cookie
#启动容器
docker run -d --privileged=true --restart=always  --name jd_cookie -p 1170:1170  -v $PWD/application.yml:/application.yml --link redis:redis yuanter/jd_cookie
#删除脚本
if [ -f "update_jd_cookie.sh" ]; then
  echo "文件存在"
  rm -rf update_jd_cookie.sh
fi
