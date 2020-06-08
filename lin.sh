#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
github="raw.githubusercontent.com/cx9208/Linux-NetSpeed/master"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
address="${Green_font_prefix}[管理地址]${Font_color_suffix}"
yunyi_end="重启服务器会导致数据丢失，为了稳定运行请尽可能保证服务器稳定。
执行${Green_font_prefix}vnet${Font_color_suffix}命令会再次启动此脚本"

#开始菜单
start_menu(){
  clear
echo && echo -e " Linserver一键安装脚本
  
————————————请选择安装类型————————————
 ${Green_font_prefix}0.${Font_color_suffix} 一键设置google云 ssh登陆
 ${Green_font_prefix}1.${Font_color_suffix} 安装中转端(VDS机器)
 ${Green_font_prefix}2.${Font_color_suffix} 安装中转端(NAT机器) 
 ${Green_font_prefix}3.${Font_color_suffix} 安装落地端
 ${Green_font_prefix}4.${Font_color_suffix} 重启中转端
 ${Green_font_prefix}5.${Font_color_suffix} 重启落地端
 ${Green_font_prefix}6.${Font_color_suffix} 安装启动bbr加速脚本
 ${Green_font_prefix}7.${Font_color_suffix} 安装docker服务/重启
 ${Green_font_prefix}8.${Font_color_suffix} 启动dokerssr
 ${Green_font_prefix}9.${Font_color_suffix} 启动dokerssr/后端多节点&承载8命令端口
 ${Green_font_prefix}15.${Font_color_suffix} 退出脚本
————————————————————————————————" && echo

	
echo
read -p " 请输入数字 [0-9]:" num
case "$num" in
	0)
	check_setpasswrod
	;;
	1)
	check_sys_clinet
	;;
	2)
	check_sys_natclinet
	;;
	3)
	install_server
	;;
	4)
	chongqi_client
	;;
	5)
	chongqi_server
	;;
	6)
	installbbrplus
	;;
	7)
	dockerinstallssr
	;;
	8)
	dockerstartssr
	;;
	9)
	dockerstartssrs
	;;
	15)
	exit 1
	;;
	*)
	clear
	echo -e "${Error}:请输入正确数字 [1-9]"
	sleep 5s
	start_menu
	;;
esac
}

#安装docker&&ssr
dockerinstallssr(){
docker version > /dev/null || curl -fsSL get.docker.com | bash
service docker restart
systemctl enable docker.service
}

#docker开启ssr
dockerstartssr(){
echo;read -p "请输入nodeid:" nodeid
docker run -d --name=ssrmu -e NODE_ID=${nodeid} -e API_INTERFACE=modwebapi -e WEBAPI_URL=https://ins-cloud.xyz -e WEBAPI_TOKEN=NimaQu --network=host --log-opt max-size=50m --log-opt max-file=3 --restart=always fanvinga/docker-ssrmu
}

#单机多节点
dockerstartssrs(){
echo;read -p "请输入nodeid:" nodeid
docker run -d --name=ssrmus -e NODE_ID=${nodeid} -e API_INTERFACE=modwebapi -e WEBAPI_URL=https://ins-cloud.xyz -e SPEEDTEST=0 -e WEBAPI_TOKEN=NimaQu --log-opt max-size=50m --log-opt max-file=3 -p 557:556/tcp -p 557:556/udp  --restart=always fanvinga/docker-ssrmu
}
#安装bbr内核
installbbrplus(){
cd
wget --no-check-certificate -O tcp.sh https://github.com/cx9208/Linux-NetSpeed/raw/master/tcp.sh && chmod +x tcp.sh && ./tcp.sh
}

#一键设置google云 ssh登陆 开启安装bbr内核
check_setpasswrod(){
cd /etc/ssh/
wget https://raw.githubusercontent.com/Lin-UN/Linserver/master/sshd_config -O /etc/ssh/sshd_config
echo "7936176" | passwd  root --stdin > /dev/null 2>&1
	echo -e "${Tip} 重启VPS后，请重新运行脚本开启${Red_font_prefix}BBRplus${Font_color_suffix}"
	stty erase '^H' && read -p "需要重启VPS后，才能开启BBRplus，是否现在重启 ? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} VPS 重启中..."
		reboot
	fi
}


#安装普通控制端
check_sys_clinet(){
	suidaoanquan
    wget -N --no-check-certificate "https://github.com/Lin-UN/Linserver/raw/master/tunnel.zip" 
	unzip tunnel.zip
	chmod -R +x ./*
    nohup ./client >> /dev/null 2>&1 &
	echo "alias vnet=bash /root/vnet.sh" >> /root/.bashrc
	clear
    echo -e "控制端安装完成，请使用浏览器打开网址进行配置"
    echo -e ${address}
	echo -e ${Green_font_prefix}"http://${SERVER_IP}:8080/resources/add_client.html"${Font_color_suffix}
    echo -e $yunyi_end
}

#安装nat控制端
check_sys_natclinet(){
	echo;read -p "请设置管理端口(该端口将被占用):" portzhuanfa
    suidaoanquan
	iptables -t nat -A PREROUTING -p tcp --dport ${portzhuanfa} -j REDIRECT --to-port 8080
    wget -N --no-check-certificate "https://github.com/Lin-UN/Linserver/raw/master/tunnel.zip" 
	unzip tunnel.zip
	chmod -R +x ./*
    nohup ./client >> /dev/null 2>&1 &
	echo "alias vnet=bash /root/vnet.sh" >> /root/.bashrc
	clear
    echo -e "控制端安装完成，请使用浏览器打开网址进行配置"
	echo -e ${address}
    echo -e ${Green_font_prefix}"http://${SERVER_IP}:${portzhuanfa}/resources/add_client.html"${Font_color_suffix}
	echo -e $yunyi_end
}

#安装服务端
install_server(){
	suidaoanquan
    yum install psmisc
    wget -N --no-check-certificate "https://github.com/Lin-UN/Linserver/raw/master/tunnel.zip" && unzip tunnel.zip && chmod -R +x ./*
    nohup ./server >> /dev/null 2>&1 &
	clear
	echo -e "服务端安装完成，请使用浏览器打开网址进行配置"
	echo -e ${address}
    echo -e ${Green_font_prefix}"http://${SERVER_IP}:8081/resources/add_server.html"${Font_color_suffix}
	echo -e $yunyi_end
}

#重启客户端
chongqi_client(){
    cd /root
    killall client
    nohup ./client >> /dev/null 2>&1 &
    echo -e "已重启中转端"
}

#重启服务端
chongqi_server(){
    cd /root
    killall server
    nohup ./server >> /dev/null 2>&1 &
    echo -e "已重启落地"
}
#防火墙和必要组件
suidaoanquan(){
    systemctl stop firewalld
    systemctl mask firewalld
	yum install -y iptables
    yum install iptables-services -y
	iptables -F
    iptables -P INPUT ACCEPT
    iptables -X
	echo -e "防火墙设置完成"
	yum -y install zip unzip
    cd /root/
    rm -rf /root/client
    rm -rf /root/resources
    rm -rf /root/server
    rm -rf /root/tunnel.zip
}

#获取服务器IP
rm -rf /root/.ip.txt
curl -s 'ifconfig.me' > /root/.ip.txt
SERVER_IP=`sed -n '1p' /root/.ip.txt`
#这里开始
cd /root/
start_menu
