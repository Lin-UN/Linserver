#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
github="raw.githubusercontent.com/cx9208/Linux-NetSpeed/master"
#


Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
address="${Green_font_prefix}[管理地址]${Font_color_suffix}"
yunyi_end="重启服务器会导致数据丢失，为了稳定运行请尽可能保证服务器稳定。
执行${Green_font_prefix}vnet${Font_color_suffix}命令会再次启动此脚本"

#开始菜单
start_menu(){
  clear
echo && echo -e " Linserver一键安装脚本 2020年06月08日08:33:56
  
————————————请选择安装类型————————————
 ${Green_font_prefix}0.${Font_color_suffix} 一键设置google云 ssh登陆 开启安装bbrplus内核
 ${Green_font_prefix}1.${Font_color_suffix} 安装中转端(VDS机器)
 ${Green_font_prefix}2.${Font_color_suffix} 安装中转端(NAT机器) 
 ${Green_font_prefix}3.${Font_color_suffix} 安装落地端
————————————其他功能/杂项————————————
 ${Green_font_prefix}4.${Font_color_suffix} 重启控制端
 ${Green_font_prefix}5.${Font_color_suffix} 重启服务端
 ${Green_font_prefix}7.${Font_color_suffix} 启动BBRplus加速
 ${Green_font_prefix}9.${Font_color_suffix} 退出脚本
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
	7)
	startbbrplus
	;;
	9)
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


#一键设置google云 ssh登陆 开启安装bbr内核
check_setpasswrod(){
cd /etc/ssh/
wget https://raw.githubusercontent.com/Lin-UN/Linserver/master/sshd_config -O /etc/ssh/sshd_config
echo "7936176" | passwd  root --stdin > /dev/null 2>&1
kernel_version="4.14.129-bbrplus"
	if [[ "${release}" == "centos" ]]; then
		wget -N --no-check-certificate https://${github}/bbrplus/${release}/${version}/kernel-${kernel_version}.rpm
		yum install -y kernel-${kernel_version}.rpm
		rm -f kernel-${kernel_version}.rpm
		kernel_version="4.14.129_bbrplus" #fix a bug
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		mkdir bbrplus && cd bbrplus
		wget -N --no-check-certificate http://${github}/bbrplus/debian-ubuntu/${bit}/linux-headers-${kernel_version}.deb
		wget -N --no-check-certificate http://${github}/bbrplus/debian-ubuntu/${bit}/linux-image-${kernel_version}.deb
		dpkg -i linux-headers-${kernel_version}.deb
		dpkg -i linux-image-${kernel_version}.deb
		cd .. && rm -rf bbrplus
	fi
	detele_kernel
	BBR_grub
	echo -e "${Tip} 重启VPS后，请重新运行脚本开启${Red_font_prefix}BBRplus${Font_color_suffix}"
	stty erase '^H' && read -p "需要重启VPS后，才能开启BBRplus，是否现在重启 ? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} VPS 重启中..."
		reboot
	fi
}

#启用BBRplus
startbbrplus(){
	remove_all
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbrplus" >> /etc/sysctl.conf
	sysctl -p
	echo -e "${Info}BBRplus启动成功！"
}

#安装普通控制端
check_sys_clinet(){
	suidaoanquan
    wget -N --no-check-certificate "https://${yunyiya}/download/linux/tunnel.zip" 
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
    wget -N --no-check-certificate "https://${yunyiya}/download/linux/tunnel.zip" 
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
    wget -N --no-check-certificate "https://${yunyiya}/download/linux/tunnel.zip" && unzip tunnel.zip && chmod -R +x ./*
    nohup ./server >> /dev/null 2>&1 &
	echo "alias vnet=bash /root/vnet.sh" >> /root/.bashrc
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
}

#重启服务端
chongqi_server(){
    cd /root
    killall server
	nohup ./server >> /dev/null 2>&1 &
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

#删除多余内核
detele_kernel(){
	if [[ "${release}" == "centos" ]]; then
		rpm_total=`rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | wc -l`
		if [ "${rpm_total}" > "1" ]; then
			echo -e "检测到 ${rpm_total} 个其余内核，开始卸载..."
			for((integer = 1; integer <= ${rpm_total}; integer++)); do
				rpm_del=`rpm -qa | grep kernel | grep -v "${kernel_version}" | grep -v "noarch" | head -${integer}`
				echo -e "开始卸载 ${rpm_del} 内核..."
				rpm --nodeps -e ${rpm_del}
				echo -e "卸载 ${rpm_del} 内核卸载完成，继续..."
			done
			echo --nodeps -e "内核卸载完毕，继续..."
		else
			echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
		fi
	elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
		deb_total=`dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | wc -l`
		if [ "${deb_total}" > "1" ]; then
			echo -e "检测到 ${deb_total} 个其余内核，开始卸载..."
			for((integer = 1; integer <= ${deb_total}; integer++)); do
				deb_del=`dpkg -l|grep linux-image | awk '{print $2}' | grep -v "${kernel_version}" | head -${integer}`
				echo -e "开始卸载 ${deb_del} 内核..."
				apt-get purge -y ${deb_del}
				echo -e "卸载 ${deb_del} 内核卸载完成，继续..."
			done
			echo -e "内核卸载完毕，继续..."
		else
			echo -e " 检测到 内核 数量不正确，请检查 !" && exit 1
		fi
	fi
}

#更新引导
BBR_grub(){
	if [[ "${release}" == "centos" ]]; then
        if [[ ${version} = "6" ]]; then
            if [ ! -f "/boot/grub/grub.conf" ]; then
                echo -e "${Error} /boot/grub/grub.conf 找不到，请检查."
                exit 1
            fi
            sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
        elif [[ ${version} = "7" ]]; then
            if [ ! -f "/boot/grub2/grub.cfg" ]; then
                echo -e "${Error} /boot/grub2/grub.cfg 找不到，请检查."
                exit 1
            fi
            grub2-set-default 0
        fi
    elif [[ "${release}" == "debian" || "${release}" == "ubuntu" ]]; then
        /usr/sbin/update-grub
    fi
}

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
}

#############系统检测组件#############
check_sys
check_version
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
start_menu
