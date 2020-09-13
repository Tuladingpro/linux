#!/bin/bash
#It's a script for initialization on Centos 7 which installed minimal.
#You should connect with Internet if you want use this script.
shopt -s extglob
if [[ ! "${USER}" == root ]];then
    echo "Please use root to run this script"
fi
netinit(){
    ip a
    read -p "If you have set IP correctly, input [n/N/no/NO] to cancle set network, other input will begin set up the network: " action
    shopt -s extglob
    case ${action} in
        [nN]|[nN][oO])
    	    nicdev=$(nmcli d | grep -v unmanaged | tail -n +2 | awk '{print $1}')
            ipdefault=$(ip a | grep "${nicdev}" |tail -n +2| awk '{print $2}' |sed -r 's#/.*##')
            break;;
        *)
            read -p "Please input the name of your NIC exactly : " nicname
            read -p "Please input the IP address which you want to use (example 192.168.122.10/24): " ipaddress
    	    nicdevtest=$(nmcli d | grep disconnected |head -1 | awk '{print $1}')
    	    nicdevtest1=$(nmcli c | tail -n +2 | awk '{print $1}')
            [[ "${nicdevtest}" == "${nicdevtest1}" ]] && nmcli c delete ${nicdevtest}
    	    nicdev=$(nmcli d | grep -v unmanaged | tail -n +2 | awk '{print $1}')
            ipdefault=$(echo ${ipaddress} | sed -r 's#/.*##')
            gwdefault=$(echo ${ipdefault} | sed -r 's#([0-9]+$)#1#')
            if [[ $nicdev == $nicname ]];then
                nmcli c add type ethernet con-name $nicname ifname $nicname ipv4.address "${ipaddress}" gw4 "${gwdefault}" ipv4.dns "${gwdefault}" ipv4.method manual autoconnect yes
            else
                read -p "Please recheck your NIC's name, input it again: " niccon
                nmcli c add type ethernet con-name $niccon ifname $niccon ipv4.address "${ipaddress}" gw4 "${gwdefault}" ipv4.dns ${gwdefault}"" ipv4.method manual autoconnect yes
            fi
            ;;
        esac
}

localyum(){
osver=centos76
rm -rf /etc/yum.repos.d/*
cat > /etc/yum.repos.d/my.repo << EOF
[localyum]
name=$osver
baseurl=file:///media/$osver
enabled=1
gpgcheck=0
EOF
[[ ! -e "/media/$osver" ]] && mkdir -p /media/$osver
fstab=$(sed -n '/sr0/p' /etc/fstab)
if [[ -z "${fstab}" ]];then
   echo "/dev/sr0 /media/$osver iso9660 defaults 0 0" >> /etc/fstab
   mount -a
else 
    echo "Fstab had been setup!"
fi
    yum clean all && yum makecache
    yum install -y vim bash-completion wget curl 
    yum groups install -y "Development Tools"
    yum install -y yum-utils
    source /etc/profile.d/bash_completion.sh
}

hostnameset(){
    read -p "If you have set hostname finished, input [n/N] to cancle set hostname and other input to continue set :" hostact
    if [[ ! ${hostact} == [nN] ]];then
        echo -e "10.20.100.101 kvm kvm.test.com\n10.20.100.10 node01 node01.test.com\n10.20.100.20 node02 node02.test.com\n10.20.100.30 node03 node03.test.com\n192.168.122.12 zaserver\n192.168.122.11 rhel82\n192.168.122.13 zaproxy\n192.168.122.14 zaagent" >> /etc/hosts
        read -p "Please input the hostname : " pcname
        echo "${ipdefault} ${pcname}" >> /etc/hosts
        hostnamectl set-hostname "${pcname}"
    fi
}

baseset(){
    systemctl disable firewalld --now
    sed -i '/SELINUX=/cSELINUX=disabled' /etc/selinux/config
    setenforce 0
    ps=$(sed -n '/export PS1=/p'  /root/.bashrc)
    if [[ -z "${ps}" ]];then
        echo "export PS1='\[\e[32;40m\][\u@\h \W] > \[\e[0m\]'" >> /root/.bashrc
        source /root/.bashrc
    fi
}

aliyunyum(){
    yum install -y yum-utils
    wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
    sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
    yum-config-manager --add-repo http://mirrors.aliyun.com/repo/epel-7.repo 
}

aliyundocker(){
    mkdir -p /etc/docker
    tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://y5wbw67l.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart docker
#上述中括号内的双引号引起来的内容应为你自己的阿里云加速源
}

basemain(){
    netinit && hostnameset
    baseset
    localyum
    baseset
}

zabbixserver_netinstall(){
    dir=/root/zabbix-server-mysql/
    webdir=/root/zabbix-web-mysql/
    agentdir=/root/zabbix-agent/
    yum info mariadb-server |grep -i available
    if [[ $? -eq 0 ]] ;then
        yum install -y mariadb-server
    fi
    [[ ! -e ${dir} ]] && mkdir -p ${dir}
    [[ ! -e ${webdir} ]] && mkdir -p ${webdir}
    [[ ! -e ${agentdir} ]] && mkdir -p ${agentdir}
    yum groups install "Development Tools" -y
    #zabbix-apache-conf zabbix-agent
    rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
    yum clean all && yum makecache
    while true
    do
        yumdownloader --resolve zabbix-server-mysql --destdir=${dir}
        test001=$?
        yumdownloader --resolve zabbix-web-mysql --destdir=${webdir}
        test002=$?
        yumdownloader --resolve zabbix-agent --destdir=${agentdir}
        test003=$?
        yum install -y zabbix-server-mysql zabbix-web-mysql zabbix-agent
        test004=$?
        if [[ ${test001} -eq 0 && ${test002} -eq 0 && ${test003} -eq 0 && ${test004} -eq 0 ]];then
            break
        fi
    done
    systemctl enable mariadb --now
    mariadb_init
    mariadb_zabbix_server_net
    systemctl enable httpd --now
}

mariadb_init(){
systemctl enable mariadb --now
mysql -uzabbix -predhat -e "show databases;"
if [[ $? -ne 0 ]] ;then
mysql_secure_installation << EOF


redhat
redhat
y
n
y
y
EOF
systemctl restart mariadb
fi
}

mariadb_zabbix_server_net(){
    mysql -uzabbix -predhat -e "show databases;" | grep zabbix
    if [[ $? -ne 0 ]];then
        mysql -uroot -predhat -e "drop database zabbix;"
        mysql -uroot -predhat -e "create database zabbix character set utf8 collate utf8_bin;"
        mysql -uroot -predhat -e "grant all on zabbix.* to 'zabbix'@'localhost' identified by 'redhat';"
        mysql -uroot -predhat -e "flush privileges;"
        zcat /usr/share/doc/zabbix-server-mysql-4.0.24/create.sql.gz | mysql -uzabbix -predhat zabbix
        systemctl restart mariadb
    fi
}

zabbix_serverset(){
    sed -i "s/#ServerName www.example.com:80/ServerName 127.0.0.1:80/g" /etc/httpd/conf/httpd.conf
    sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /etc/php.ini
    sed -i "s/max_input_time = 60/max_input_time = 600/g" /etc/php.ini
    sed -i "s/post_max_size = 8M/post_max_size = 16M/g" /etc/php.ini
    sed -i "s/;date.timezone =/date.timezone = Asia\/Shanghai/g" /etc/php.ini
    sed -i "s/# DBPassword=/DBPassword=redhat/" /etc/zabbix/zabbix_server.conf
    systemctl enable zabbix-server zabbix-agent --now
    systemctl restart httpd
}

read -p "If you have set base option finished, you should input [n/N] to continue and other to exit : " baseaction
case ${baseaction} in
    +([nN]))
        basemain
        aliyunyum;;
    *)
        aliyunyum;;
esac
zabbixserver_netinstall
zabbix_serverset

