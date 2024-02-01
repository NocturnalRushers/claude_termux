#!/bin/bash

echo "  
_____                 _____
___                     ___
_                         _
一键安卓搭建酒馆+clewd脚本
_                         _
___                     ___
_____                 _____
"

echo -e "\033[0;31m记得开魔法！开魔法！开魔法！\033[0m\n"

read -p "确保开了魔法后按回车继续"

current=/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu

yes | apt update

yes | apt upgrade

# 安装proot-distro
pkg install proot-distro -y

# 创建并安装Ubuntu
proot-distro install ubuntu

# Check Ubuntu installed successfully
 if [ ! -d "$current" ]; then
   echo "Ubuntu安装失败了，请更换魔法或者手动安装Ubuntu"
    exit 1
 fi

    echo "Ubuntu成功安装到Termux"

echo "正在安装相应软件"

pkg install git vim curl xz-utils -y

if [ -d "SillyTavern" ]; then
  cp -r SillyTavern $current/root/
fi

cd $current/root

echo "正在为Ubuntu安装node"
if [ ! -d node-v20.10.0-linux-arm64.tar.xz ]; then
    curl -O https://nodejs.org/dist/v20.10.0/node-v20.10.0-linux-arm64.tar.xz

tar xf node-v20.10.0-linux-arm64.tar.xz

echo "export PATH=\$PATH:/root/node-v20.10.0-linux-arm64/bin" >>$current/etc/profile
fi

echo "正在安装SillyTavern————耐心等待……"
if [ ! -d "SillyTavern" ]; then
git clone https://github.com/SillyTavern/SillyTavern
fi
echo "正在安装clewd————耐心等待……"
git clone -b test https://github.com/teralomaniac/clewd

echo -e "\033[0;33m本操作仅为破限下载提供方便，所有破限皆为收录，不具有破限所有权\033[0m"
read -p "回车进行导入"
git clone https://github.com/NocturnalRushers/promot.git st_promot
if  [ ! -d "st_promot" ]; then
    echo -e "\n\033[0;33m 因网络波动预设文件下载失败了，更换网络后再试\n\033[0m"
else
    cp -r $current/root/st_promot/. $current/root/SillyTavern/public/'OpenAI Settings'/
    echo -e "\033[0;33m破限已成功导入，安装完毕后启动酒馆即可看到\033[0m"
fi

curl -O https://raw.githubusercontent.com/NocturnalRushers/claude_termux/main/sac.sh

if [ ! -f "$current/root/sac.sh" ]; then
   echo "启动文件下载失败了，换个魔法或者手动下载试试吧"
   exit
fi

ln -s /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/root

echo "bash /root/sac.sh" >>$current/root/.bashrc

echo "proot-distro login ubuntu" >>/data/data/com.termux/files/home/.bashrc

source /data/data/com.termux/files/home/.bashrc

exit
