#!/bin/bash
LANG=en_US.UTF-8
shopt -s extglob
# If you want to change the image version of your cobbler server
# Please change  variables under cobblerinstall
# DHCP of cobbler : cobbler_dhcp

osversion(){
osver=centos76
cobbleriso_path="/media/centos76"
cobbleriso_name="centos76"
}

nicfailcount=0
yesnobox(){
    if (whiptail --title "Choose Yes/No Box" --yes-button "Yes" --no-button "No"  --yesno "Please confirm which option you choose." 10 60) then
        echo "You chose Skittles Exit status was $?."
    else
        echo "You chose M&M's. Exit status was $?."
    fi
}
msgbox_msg(){
    [[ ! -n "$1" ]] && break
    case $1 in
        "nicfail")
            nicmsg_suc=$(whiptail --title "Message box" \
            --msgbox "Please recheck the NIC name!" 30 80 3>&1 1>&2 2>&3)
            nicfailcount+=1
            netinit
            ;;
        "ipsuc")
            ipmsg_suc=$(whiptail --title "Message box" \
            --msgbox "The IP address has been set up successfully!" 30 80 3>&1 1>&2 2>&3)
            ;;
        "ipfail")
            ipmsg_fail=$(whiptail --title "Message box" \
            --msgbox "The IP address error! Check it exactly!" 30 80 3>&1 1>&2 2>&3)
            ;;
        "gwsuc")
            gwmsg_suc=$(whiptail --title "Message box" \
            --msgbox "The gateway has been set up successfully!" 30 80 3>&1 1>&2 2>&3)
            ;;
        "gwfail")
            gwmsg_fail=$(whiptail --title "Message box" \
            --msgbox "The gateway is invalid!" 30 80 3>&1 1>&2 2>&3)
            ;;
        "hostname")
            nowhostconfig=$(hostnamectl)
            hostname_suc=$(whiptail --title "Message box" \
            --msgbox "The hostname configuration details:
            ${nowhostconfig} " 30 80 3>&1 1>&2 2>&3)
            ;;
        *)
            echo "test"
    esac

}

LEVEL1_MENU(){
OPTION1=$(whiptail --title "Menu list" --clear --menu "Choose your option" 25 60 4 \
"01" "Initialization set up [hostname,network,yum] " \
"02" "Installation of Cobbler [TFTP,DHCP]" \
"03" "Installation of Zabbix" \
"04" "nothing" 3>&1 1>&2 2>&3)
local exitstatus=$?  
if [ $exitstatus = 0 ]; then  
    case ${OPTION1} in
        01)
            LEVEL2_MENU1
            ;;
        02)
            LEVEL2_MENU2
            ;;
        03)
            LEVEL2_MENU3
            ;;
        04)
            LEVEL2_MENU4
            ;;
        *)
            echo "Some errors occurred!"
            ;;
    esac
else  
    echo "You chose Cancel."
    exit
fi 
}

LEVEL2_MENU1(){
OPTION2_1=$(whiptail --title "Initialzation" --checklist \
"Please choose one or more options you want to set ：" 25 60 6 \
"01" "network init" OFF \
"02" "hostname set" OFF \
"03" "local yum repository" OFF \
"04" "net yum repository" OFF \
"05" "base option (firewalld,selinux)" OFF \
"06" "aliyun docker speed" OFF 3>&1 1>&2 2>&3)
local exitstatus=$?
if [ $exitstatus = 0 ]; then
    [[ ${OPTION2_1} =~ "01" ]] && netinit
    [[ ${OPTION2_1} =~ "02" ]] && hostinit
    [[ ${OPTION2_1} =~ "03" ]] && localyum
    [[ ${OPTION2_1} =~ "04" ]] && netyum
    [[ ${OPTION2_1} =~ "05" ]] && baseoption
    [[ ${OPTION2_1} =~ "06" ]] && aliyundocker
else
    LEVEL1_MENU
fi
}

ipinit(){
local exitstatus=$1
[[ ${nicfailcount} -ge 2 ]] && netdev=${nicname}
if [[ $exitstatus == "0" && ${nicname} =~ ${netdev} ]]; then  
    while true
    do
        ipaddr=$(whiptail --title "Set up your IP address" \
        --inputbox "Which IP address you want to use[example: 192.168.122.10/24]? 
        Please input your IP address correctly. " 20 80  3>&1 1>&2 2>&3)
        local ipaddrcancel=$?
        [[ ! ${ipaddrcancel} -eq 0 ]] && netinit
        ipdefault=$(echo ${ipaddr} | sed -r 's#/.*##')
        gwdefault=$(echo ${ipdefault} | sed -r 's#([0-9]+$)#1#')
        echo ${ipaddr} | grep "/" &>/dev/null ; mask_check=$?
        ipcalc -cs ${ipaddr} ;ipaddr_check=$?
        if [[ ${ipaddr_check} -ne 0 || ${mask_check} -ne 0 ]];then
            msgbox_msg "ipfail"
            continue
        else
            gwinit && break
        fi
    done
elif [[ $exitstatus == "0" && ! ${nicname} =~ ${netdev} ]];then
    msgbox_msg "nicfail"
else
    LEVEL2_MENU1
fi
}

gwinit(){
while true
do
    gwaddr=$(whiptail --title "Set up your Gateway  address" \
        --inputbox "Which gw address you want to use[example: 192.168.122.1]? 
        Please input your gateway correctly. " 20 80  3>&1 1>&2 2>&3)
    local gwaddrcancel=$?
    [[ ! ${gwaddrcancel} -eq 0 ]] && ipinit
    echo ${gwaddr} | grep "/" &>/dev/null ; gwmask_check=$?
    ipcalc -cs ${gwaddr} ;gwaddr_check=$?
    if [[ ${gwaddr_check} -ne 0 || ${gwmask_check} -eq 0 ]];then
        msgbox_msg "gwfail"
        continue
    else
        nmcli c |grep "${nicname}" > /dev/null
        nicdevtest=$?
        [[ ${nicdevtest} -eq 0 ]] && nmcli c delete ${nicname} &> /dev/null
        nmcli c add type ethernet con-name ${nicname} ifname ${nicname} \
            ipv4.address "${ipaddr}" gw4 "${gwaddr}" ipv4.dns "${gwaddr}" \
            ipv4.method manual  autoconnect yes &>/dev/null
        nmcli c up "${nicname}" &>/dev/null
        if [[ $? -eq 0 ]];then
            msgbox_msg "ipsuc"
            break
        fi
    fi
done
}

netinit(){
netdev=$(nmcli d | grep -E "connected|unmanaged|disconnected" | awk '{print $1}' | sed '/lo/d' )

nicname=$(whiptail --title "Please check your network device below" \
    --inputbox "Which nic will you want use? 
   ${netdev}" 30 80  3>&1 1>&2 2>&3)

local exitstatus=$?  
ipinit "$exitstatus" 
}

hostinit(){
nowname=$(hostnamectl)
hostnameset=$(whiptail --title "Hostname Configuration: "\
    --inputbox "What name will you use(Ensure you have set your IP firstly!) ?
    ${nowname} 
    Please input your hostname which you want to set :" 30 80  3>&1 1>&2 2>&3)
local exitstatus=$?
if [[ ${exitstatus} -eq 0 ]]; then
    grep -E "zaserver|kvm|node" /etc/hosts &> /dev/null
    hostact=$?
    hostnamectl set-hostname "${hostnameset}"
    hostjudge=$?
    if [[ ${hostjudge} -eq 0 && ${hostact} -ne 0 ]];then
        echo -e "10.20.100.101 kvm kvm.test.com\n10.20.100.10 node01 node01.test.com\n10.20.100.20 node02 node02.test.com\n10.20.100.30 node03 node03.test.com\n192.168.122.12 zaserver\n192.168.122.11 rhel82\n192.168.122.13 zaproxy\n192.168.122.14 zaagent" >> /etc/hosts
        echo "${ipdefault} ${hostnameset}" >> /etc/hosts
        msgbox_msg "hostname"
    elif [[ ${hostjudge} -eq 0 && ${hostact} -eq 0 ]];then
        tmpname=$(hostnamectl | grep "hostname" |cut -d: -f2 | sed 's#^ ##')
        grep "${tmpname}" /etc/hosts &>/dev/null || echo "${ipdefault} ${tmpname}" >> /etc/hosts
        msgbox_msg "hostname"
        break
    else
        hostinit
    fi
    break
else
    LEVEL2_MENU1
fi

}

localyum(){
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
if [[ ! -n "${fstab}" ]];then
   echo "/dev/sr0 /media/$osver iso9660 defaults 0 0" >> /etc/fstab
   mount -a &> /dev/null
else
    echo "Fstab had been setup!"
fi
    yum clean all && yum makecache &>/dev/null
    yum install -y vim bash-completion wget curl tree sysstat &>/dev/null
    yum install -y yum-utils &>/dev/null
    source /etc/profile.d/bash_completion.sh
}

netyum(){
    osversion
    case ${osver} in
        centos7[0-9])
            echo "You choosed ${osver} !"
            wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
            sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
            yum-config-manager --add-repo http://mirrors.aliyun.com/repo/epel-7.repo
            yum clean all && yum makecache
            ;;
        rhel7[0-9])
            echo "You choosed ${osver} ! Maybe you have no subscripitions for RHEL ! Please recheck and download some rpm packages just in this registory for dependency!"
            localyum
            ;;
        *)
            break
            ;;
        esac
}

baseoption(){
systemctl disable firewalld --now
sed -i '/SELINUX=/cSELINUX=disabled' /etc/selinux/config
setenforce 0
pslogo=$(sed -n '/export PS1=/p'  /root/.bashrc)
if [[ -z "${pslogo}" ]];then
    echo "export PS1='\[\e[32;40m\][\u@\h \W] > \[\e[0m\]'" >> /root/.bashrc
    source /root/.bashrc
fi
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
}

LEVEL2_MENU2(){
    cobblerinstall
}
cobblerinstall(){
    epelcheck=$(yum repolist | grep 'epel')
    repocheck=$(yum repolist |tail -1 |sed -r 's#([^[:digit:]]*)([[:digit:]]+)#\2#;s/,//')
    if [[ ${repocheck} -eq 0 || ! -n ${epelcheck}  ]];then
        echo "Error! Please configure your repository firstly."
        exit
    else
        yum -y install cobbler cobbler-web tftp-server dhcp httpd xinetd
        systemctl enable httpd cobblerd --now
        [[ $? -ne 0 ]] && echo "Error! Please recheck your epel repository!"
    fi
    #防止循环pxe安装
    yum -y install pykickstart 
    yum -y install fence-agents 
    sed -i 's/pxe_just_once: 0/pxe_just_once: 1/' /etc/cobbler/settings
    sed -ri '/allow_dynamic_settings:/c\allow_dynamic_settings: 1' /etc/cobbler/settings 
    cobbler sync
    systemctl restart cobblerd httpd 
    passwddefault=$(openssl passwd -1 -salt `openssl rand -hex 4` 'redhat')
    cobbler setting edit --name=default_password_crypted --value="$passwddefault"
    sed -ri '/^manage_dhcp: 0/cmanage_dhcp: 1' /etc/cobbler/settings 
    sed -ri '/^server:/cserver: 192.168.122.254' /etc/cobbler/settings  
    sed -ri '/^next_server:/cnext_server: 192.168.122.254' /etc/cobbler/settings   
    sed -i '/SELINUX=/cSELINUX=disabled' /etc/selinux/config    
    sed -ri 's/(disable)(.*)(yes)/\1\2no/' /etc/xinetd.d/tftp   
    /usr/bin/cobbler get-loaders
    systemctl enable rsyncd --now   
    cobbler sync
    systemctl restart cobblerd httpd xinetd
    cobbler check | grep -v debmirror| grep -E '[0-9]'
    cobblercheck=$?
    if [[ ${cobblercheck} -eq 0 ]];then
        echo "You should check your cobbler configuration, there is still some errors!"
    else
        echo "Successfully!"
    fi
    cobbler_dhcp
    cobbler_iso
    cobbler_kickstart
}

cobbler_dhcp(){
    SUBNET="192.168.122.0"
    NETMASK="255.255.255.0"
    GATEWAY="192.168.122.1"
    RANGEL="192.168.122.100"
    RANGER="192.168.122.253"
    sed -ri "s/subnet .*\{/subnet ${SUBNET} netmask ${NETMASK} \{/" /etc/cobbler/dhcp.template
    sed -ri "s/(^ *.*subnet-mask)( *)([0-9]+.*)$/\1\2${NETMASK};/" /etc/cobbler/dhcp.template
    sed -ri "s/(^ *.*dynamic-bootp)( +)([.[:digit:]]+)( +)(.*);$/\1\2${RANGEL}\4${RANGER};/" /etc/cobbler/dhcp.template
    systemctl restart cobblerd 
    wait
    sleep 2
    cobbler sync
}

cobbler_iso(){
    [[ ! -e "${cobbleriso_path}" ]] && mkdir -p ${cobbleriso_path}
    if [[ -e "${cobbleriso_path}" ]];then
        cobbler import --path="${cobbleriso_path}" --name="${cobbleriso_name}" --arch=x86_64
        local kickstartfile=$(cobbler profile report --name="${cobbleriso_name}-x86_64" | grep -w 'Kickstart  '|awk '{print $3}')
        local kickstartpath=$(echo ${kickstartfile} |sed -nr 's/[._[:alnum:]]+$//p')
        wait
        if [[ ! -e "${kickstartpath}${cobbleriso_name}.ks" ]];then
        cp ${kickstartfile} "${kickstartpath}${cobbleriso_name}.ks"
        fi
    else
        echo "Please check your repository ! Some errors occurred!"
    fi
}

cobbler_kickstart(){
    local kickstartfile=$(cobbler profile report --name="${cobbleriso_name}-x86_64" | grep -w 'Kickstart  '|awk '{print $3}')
    echo ${kickstartfile}
    local kickstartpath=$(echo ${kickstartfile} |sed -nr 's/[._[:alnum:]]+$//p')
    cobbler profile edit --name="${cobbleriso_name}-x86_64" --kickstart="${kickstartpath}${cobbleriso_name}.ks"
    wait
    local nowfile=$(cobbler profile report --name="${cobbleriso_name}-x86_64" | grep -w 'Kickstart  '|awk '{print $3}')
    local kickstartjudge=$(cobbler profile report --name="${cobbleriso_name}-x86_64" | grep -w 'Kickstart  '|awk '{print $3}')
    if [[ ${nowfile} == ${kickstartjudge} ]];then
       systemctl restart cobblerd
       wait
       sleep 2
       cobbler sync
    else
        echo "Some errors occurred when setting default profile!"
    fi
}
INITMAIN(){
    echo    
}

osversion
LEVEL1_MENU

#cobbler_iso

