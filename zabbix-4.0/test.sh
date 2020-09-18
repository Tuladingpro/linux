#!/bin/bash
LANG=en_US.UTF-8
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
            LEVEL1_MENU
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
"Please choose one or more options you want to set ：" 25 60 4 \
"01" "network init" OFF \
"02" "hostname set" OFF \
"03" "local yum repository" OFF \
"04" "net yum repository" OFF 3>&1 1>&2 2>&3)
local exitstatus=$?
if [ $exitstatus = 0 ]; then
    [[ ${OPTION2_1} =~ "01" ]] && netinit
    [[ ${OPTION2_1} =~ "02" ]] && hostinit
    [[ ${OPTION2_1} =~ "03" ]] && localyum
    [[ ${OPTION2_1} =~ "04" ]] && netyum
else
    LEVEL1_MENU
fi
}

ipinit(){
local exitstatus=$1
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
netdev=($(nmcli d | grep -E "connected|unmanaged|disconnected" | awk '{print $1}' | sed '/lo/d' ))

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
if [[ $exitstatus -eq 0 ]]; then
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
    else
        hostinit
    fi
else
    LEVEL2_MENU1
fi

}

localyum(){
    echo
}

netyum(){
    echo
}

INITMAIN(){
    echo    
}

#yesnobox
#LEVEL2_MENU1
LEVEL1_MENU
