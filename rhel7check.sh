#!/bin/bash
LANG=en_us
if [ -n "$1" ];then
	while getopts :n: opt
	do
		case $opt in
			n)HCResult=$OPTARG
			  ;;
			*)echo "unknown options! script stop!"
			  echo "Usage:"
			  echo "$0 -n <config_log_path>"
			  exit
			  ;;
		esac
	done
fi

echo CES_HC_ITEM_KEY=a23a7e55-33cf-40d4-b160-7feb7c3b81bf >> $HCResult
cat >>/tmp/CES_HC_ITEMaa23a7e5533cf40d4b1607feb7c3b81bf.sh <<CES_EVO_HC_EOF
mcefile=/var/log/mcelog
count1=\`cat \$mcefile |wc -l\`
if [ ! -f \$mcefile ] 
then
	echo "\$mcefile:true"
elif [ \$count1 = 0 ]
then
	echo "\$mcefile:ture"
else
	echo "\$mcefile:false"
fi
count2=\`tail -10000 /var/log/messages | grep -iE "error|fail|Machine Check Exception|Out of memory|soft lockup|EXT4-fs error|qla2xxx|Failing path|Kernel panic" |grep -Ev "failed to assign|sftp-server"|wc -l\`
if [ \$count2 = 0 ]
then
	echo "/var/log/messages:true"
else
	echo "/var/log/messages:false"
fi
count3=\`cat /var/log/dmesg | grep -iE "error|fail|Machine Check Exception|Out of memory|soft lockup| I\/O error|EXT4-fs error|qla2xxx|Failing path|Kernel panic|NIC Link is Down" | grep -v "failed to assign"|wc -l\`
if [ \$count3 = 0 ]
then
        echo "/var/log/dmesg:true"
else
        echo "/var/log/dmesg:false"
fi
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMaa23a7e5533cf40d4b1607feb7c3b81bf.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMaa23a7e5533cf40d4b1607feb7c3b81bf.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=aed0e5c1-abdf-4fc5-a866-4210e7c47eb4 >> $HCResult
cat >>/tmp/CES_HC_ITEMaaed0e5c1abdf4fc5a8664210e7c47eb4.sh <<CES_EVO_HC_EOF
#Uninteruptible sleep
N=\` ps axo user,pid,%cpu,%mem,rss,stat,time,command | grep -e '^[Dd]\$' |wc -l\`
if [ \$N = 0 ];then
	echo "Uninteruptible sleep processes,\$N,1"
else
	echo "Uninteruptible sleep processes,\$N,0"
fi
#Defunct processes
M=\` ps axo user,pid,%cpu,%mem,rss,stat,time,command | grep -e '^[Zz]\$' |wc -l\`
if [ \$M = 0 ];then
	echo "Defunct processes,\$N,1"
else
	echo "Defunct processes,\$N,0"
fi
#Time zone
K=\`timedatectl | grep "Time zone"| awk '{print \$3}'\`
if [ \$K == 'Asia/Shanghai' ];then
	echo "Time zone,\$K,1"
else
	echo "Time zone,\$K,0"
fi
#NTP
L=\`timedatectl | grep "NTP synchronized" | awk -F: '{print \$2}'\`
crontab  -l| grep ntpdate >/dev/null 2>&1
N2=\$?
if [ \$L != 'no' ];then
	echo "NTP synchronized,\$L,1"
elif [ \$N2 = 0 ];then
    echo "NTP synchronized,use ntpdate,1"
else
	echo "NTP synchronized,\$L,0"
fi
#kdump
P=\`systemctl is-enabled kdump\`
if [ \$P == 'enabled' ];then
	echo "kdump service,\$P,1"
else
	echo "kdump service,\$P,0"
fi

#mce check
file=/var/log/mcelog
count=\`cat \$file |wc -l\`
if [ ! -f \$file ] 
then
	echo "mce log,normal,1"
elif [ \$count = 0 ]
then
	echo "mce log,normal,1"
else
	echo "mce log,abnormal,0"
fi
#selinux check
stat=\`getenforce\`
if [ \$stat == 'Disabled' ];then
	echo "selinux service,\$stat,1"	
else

	echo "selinux service,\$stat,0"	
fi
#netif redundancy check
HOSTTYPE=\$(dmidecode -s system-product-name|awk '{print \$1}')
Teamc=\$(nmcli connection show 2>/dev/null | awk '\$3 == "team"  {print \$1}'| wc -l)
if [[ \$HOSTTYPE != "VMware" && \$HOSTTYPE != "KVM" ]];then
  if [ -e /proc/net/bonding ];then
        bond=\`ls  /proc/net/bonding\`
        count=\`ls  /proc/net/bonding |wc -l\`
  fi
  if [[ (! -e /proc/net/bonding || \$count = 0) && \$Teamc = 0 ]];then
        echo "netif redundancy,no,0"
   elif [[  -e /proc/net/bonding && \$count != 0 || \$Teamc != 0 ]];then
        echo "netif redundancy,normal,1"
  fi
else
  echo "netif redundancy,host is virtual,1"
fi
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMaaed0e5c1abdf4fc5a8664210e7c47eb4.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMaaed0e5c1abdf4fc5a8664210e7c47eb4.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=4f608dfe-5845-4824-9382-d17c7b3f1e2b >> $HCResult
cat >>/tmp/CES_HC_ITEMa4f608dfe584548249382d17c7b3f1e2b.sh <<CES_EVO_HC_EOF
echo 8,2019-5-7,2024-5-7,2025-5-7,2029-5-7,TBD
echo 7,2014-6-10,2019-8-6,2020-8-6,2024-6-30,N/A
echo 6,2010-11-10,2016-5-10,2017-5-10,2020-11-30,2024-6-20
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa4f608dfe584548249382d17c7b3f1e2b.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa4f608dfe584548249382d17c7b3f1e2b.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=f634deeb-0059-4d40-b07f-c028660a212b >> $HCResult
cat >>/tmp/CES_HC_ITEMaf634deeb00594d40b07fc028660a212b.sh <<CES_EVO_HC_EOF
echo "hostname:\$(hostname)"
echo "Product Name:\$(dmidecode |grep "Product Name:"|head -n 1| awk -F":" '{print \$2}')"
#echo "Serial Number:\$(dmidecode | grep "Serial Number:"| head -1| awk -F":" '{print \$2}')"
echo "Serial Number:\$(dmidecode -s system-serial-number)"
echo "UUID:\$(dmidecode -t 1 | grep UUID | awk '{print \$2}')"
echo "Arch:\$(hostnamectl | grep Architecture| awk -F ":" '{print \$2}')"
echo "CPUs:\$(cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l)"
echo "Total Memory:\`free -m|grep Mem|awk '{print \$2"MB"}'\`"
echo "IP address:\`ip a|grep -w inet|grep -v "127.0.0"|awk  '{print \$2}'|head -1\`"
echo "Distro:\$(hostnamectl | grep "Operating System"|awk  -F":"  '{print \$2}')"
echo "OS kernel:\$(uname -r)"
echo "Runlevel:\$(runlevel)"
echo "Default Target:\$(systemctl get-default)"
echo "Uptime:\`cat /proc/uptime | awk '{print \$1/60}'\` "
#echo  "Local time:\$(timedatectl  | grep "Local time")"
echo "Local Time:\$(date '+%Y-%m-%d %H:%M:%S')" 
echo "Time zone:\$(timedatectl  | grep "Time zone" | awk  -F":"  '{print \$2}') "
echo "SELinux:\$(sestatus -v | grep "SELinux status" | awk -F":" '{print \$2}')"
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMaf634deeb00594d40b07fc028660a212b.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMaf634deeb00594d40b07fc028660a212b.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=5326334c-c695-478e-9302-be71e4c925e7 >> $HCResult
cat >>/tmp/CES_HC_ITEMa5326334cc695478e9302be71e4c925e7.sh <<CES_EVO_HC_EOF
echo "#Network card info"
lspci| grep "Ethernet controller"
echo "#HBA info"
lspci | grep "Fibre Channel"
echo "#Storage info"
lspci | grep "RAID bus controller"
lspci | grep "SCSI storage controller"
lspci | grep "SATA controller"
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa5326334cc695478e9302be71e4c925e7.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa5326334cc695478e9302be71e4c925e7.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=97164b8f-d28d-47c6-8c16-a1c7da7f577e >> $HCResult
cat >>/tmp/CES_HC_ITEMa97164b8fd28d47c68c16a1c7da7f577e.sh <<CES_EVO_HC_EOF
#cpu info
cat /proc/cpuinfo  | grep "model name"| uniq| awk -F : '{print "cpu modle," \$2}'
echo "Physical CPU Count, \`cat /proc/cpuinfo | grep "physical id" | sort | uniq | wc -l\`"
echo "CPU Core Count,\`cat /proc/cpuinfo | grep "core id" | uniq | wc -l\`"
echo "Logical CPU Count,\`cat /proc/cpuinfo | grep "processor" | wc -l\`"
#cpu load
cat /proc/loadavg | awk '{print "cpu load," \$1,\$2,\$3}'
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa97164b8fd28d47c68c16a1c7da7f577e.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa97164b8fd28d47c68c16a1c7da7f577e.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=20f73cbb-3c6a-49ec-aef3-469c73205fd0 >> $HCResult
cat >>/tmp/CES_HC_ITEMa20f73cbb3c6a49ecaef3469c73205fd0.sh <<CES_EVO_HC_EOF
vmstat  1 10| grep -v procs| grep -v  cache|cat -n | awk '{print \$1","\$2"," \$3 ","\$14","\$15","\$16 ","\$17"," \$18}'
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa20f73cbb3c6a49ecaef3469c73205fd0.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa20f73cbb3c6a49ecaef3469c73205fd0.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=8d6d017c-e552-41ad-913b-aafc167000c8 >> $HCResult
cat >>/tmp/CES_HC_ITEMa8d6d017ce55241ad913baafc167000c8.sh <<CES_EVO_HC_EOF
cat /proc/meminfo  | awk '{print \$1 \$2}' | grep -E 'MemTotal|MemFree|MemAvailable|Buffers|^Cached|SwapTotal|SwapFree' 
cat /proc/meminfo  | grep 'HugePages_Total'| awk '{print \$1 \$2*1024*1024}'
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa8d6d017ce55241ad913baafc167000c8.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa8d6d017ce55241ad913baafc167000c8.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=06a8c5f6-59b7-4f7b-a083-1d86d3c3888f >> $HCResult
cat >>/tmp/CES_HC_ITEMa06a8c5f659b74f7ba0831d86d3c3888f.sh <<CES_EVO_HC_EOF
free -m | sed -n '2p' | awk '{print "Percent_mem_used:"(\$3/\$2)*100"%"}'
free -m | sed -n '2p' | awk '{print "Percent_mem_buffcache:"(\$6/\$2)*100"%"}'
free -m | sed -n '3p' | awk '{if (\$2 != 0) print "Percent_swap_used:"(\$3/\$2)*100"%"}'
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa06a8c5f659b74f7ba0831d86d3c3888f.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa06a8c5f659b74f7ba0831d86d3c3888f.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=1cdba13f-489e-491e-89dc-8fc2dd98d2ed >> $HCResult
cat >>/tmp/CES_HC_ITEMa1cdba13f489e491e89dc8fc2dd98d2ed.sh <<CES_EVO_HC_EOF
df -hTP| grep -v /dev/sr| grep -v tmpfs
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa1cdba13f489e491e89dc8fc2dd98d2ed.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa1cdba13f489e491e89dc8fc2dd98d2ed.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=54583cd3-c351-4845-a965-1d8d5c58da2a >> $HCResult
cat >>/tmp/CES_HC_ITEMa54583cd3c3514845a9651d8d5c58da2a.sh <<CES_EVO_HC_EOF
df -hiP| grep -v tmpfs |grep -v /dev/sr|grep -v efi
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa54583cd3c3514845a9651d8d5c58da2a.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa54583cd3c3514845a9651d8d5c58da2a.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=7cac3924-fe50-4475-80bc-5c3be535ebaf >> $HCResult
cat >>/tmp/CES_HC_ITEMa7cac3924fe50447580bc5c3be535ebaf.sh <<CES_EVO_HC_EOF
for netif in \$(ls /sys/class/net)
 do
   rx_before=\$(cat /sys/class/net/\$netif/statistics/rx_bytes)
   tx_before=\$(cat /sys/class/net/\$netif/statistics/tx_bytes)
   sleep 5
   rx_after=\$(cat /sys/class/net/\$netif/statistics/rx_bytes)
   tx_after=\$(cat /sys/class/net/\$netif/statistics/tx_bytes)
   rx_result=\$(awk 'BEGIN{printf "%0.2f",("'\$rx_after'"-"'\$rx_before'")/1024/5*8}')
   tx_result=\$(awk 'BEGIN{printf "%0.2f",("'\$tx_after'"-"'\$tx_before'")/1024/5*8}')
   cat /sys/class/net/\$netif/speed > /dev/null 2>&1
   if [ \$? -eq 0 ];then
       Speed=\$(cat /sys/class/net/\$netif/speed)
       banduse=\$(awk 'BEGIN{printf "%4.1f",("'\$rx_result'" + "'\$tx_result'")/1024/"'\$Speed'"*100;print "%"}')
       echo "\$netif:\${rx_result}Kbps:\${tx_result}Kbps:\${Speed}Mbps:\$banduse"
     else
       Speed=-1
       banduse=-1%
       echo "\$netif:\${rx_result}Kbps:\${tx_result}Kbps:\${Speed}:\$banduse"
   fi
done
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa7cac3924fe50447580bc5c3be535ebaf.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa7cac3924fe50447580bc5c3be535ebaf.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=e44eb811-5591-45af-8841-3952602ee752 >> $HCResult
cat >>/tmp/CES_HC_ITEMae44eb811559145af88413952602ee752.sh <<CES_EVO_HC_EOF
ps aux |grep -v USER|sort -nr -k4|head -10|awk '{print \$11","\$1","\$2","\$3","\$4}'
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMae44eb811559145af88413952602ee752.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMae44eb811559145af88413952602ee752.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=d7dfcfb6-713b-4de1-9814-2d25da97e464 >> $HCResult
cat >>/tmp/CES_HC_ITEMad7dfcfb6713b4de198142d25da97e464.sh <<CES_EVO_HC_EOF
ps aux|head -1;ps aux|grep -v PID|sort -rn -k +3|head -5|awk '{print \$11","\$1","\$2","\$3}'
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMad7dfcfb6713b4de198142d25da97e464.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMad7dfcfb6713b4de198142d25da97e464.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=24ae7f7c-3598-4a77-bcc2-13907e187a9b >> $HCResult
cat >>/tmp/CES_HC_ITEMa24ae7f7c35984a77bcc213907e187a9b.sh <<CES_EVO_HC_EOF
#kexec-tools rpm
echo "kexec-tools:rpm version:\$(rpm -qa | grep kexec-tools)"
#kdump.service
echo "kdump.service:is-active:\$(systemctl is-active kdump.service)"
echo "kdump.service:is-enabled:\$(systemctl is-enabled kdump.service)"
#Memory reservation config
cat /proc/cmdline | grep crashkernel >/dev/null 2>&1
if [ \$? = 0 ]; then
	echo "/proc/cmdline:Memory reservation config:crashkernel=auto"
else
	echo "/proc/cmdline:Memory reservation config:no config"
fi
grep crashkernel /etc/default/grub >/dev/null 2>&1
if [ \$? = 0 ]; then
	echo "grub.cfg:Memory reservation config:crashkernel=auto"
else
	echo "grub.cfg:Memory reservation config:no config"
fi
#kdump.conf
echo "kdump.conf:kdump :\$(grep ^path /etc/kdump.conf )"
#kdump.conf "path" available space
echo "system memTotal:\$(grep MemTotal /proc/meminfo)"
echo "/var/crash:Available free space:\$(df -h /var/crash |grep -v Filesystem| awk '{print \$4}')"
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa24ae7f7c35984a77bcc213907e187a9b.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa24ae7f7c35984a77bcc213907e187a9b.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=6cba0109-3bc9-43a6-b8d2-894e51f9a6b1 >> $HCResult
cat >>/tmp/CES_HC_ITEMa6cba01093bc943a6b8d2894e51f9a6b1.sh <<CES_EVO_HC_EOF
rpm -Va
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa6cba01093bc943a6b8d2894e51f9a6b1.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa6cba01093bc943a6b8d2894e51f9a6b1.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=1d883b9a-13fa-4824-ba1d-eccc5f9ff278 >> $HCResult
cat >>/tmp/CES_HC_ITEMa1d883b9a13fa4824ba1deccc5f9ff278.sh <<CES_EVO_HC_EOF
interface=\`ip addr | grep '^[0-9]' |awk -F':' '{print \$2}' | grep -v lo\`
for i in \$interface 
do
	echo \$i,\
	\`ethtool \$i 2>/dev/null | grep -i "Link detected"|awk -F  ":" '{print \$2}'\`,\
 	\`ethtool \$i 2>/dev/null| grep -i "Speed"|awk -F  ":" '{print \$2}'\`,\
 	\`ethtool \$i 2>/dev/null| grep -i "Duplex"|awk -F  ":" '{print \$2}'\`,\
 	\`ethtool \$i 2>/dev/null | grep -i "Supported ports"|awk -F  ":" '{print \$2}'\`,\
 	\`ethtool -i \$i 2>/dev/null| grep -i "driver"|awk -F  ":" '{print \$2}'\`,\
 	\`ethtool -i \$i 2>/dev/null| grep -i "version"|awk -F  ":" '{print \$2}'\`
done
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa1d883b9a13fa4824ba1deccc5f9ff278.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa1d883b9a13fa4824ba1deccc5f9ff278.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=17aca8ef-574e-47a7-a916-6391ded1dbb8 >> $HCResult
cat >>/tmp/CES_HC_ITEMa17aca8ef574e47a7a9166391ded1dbb8.sh <<CES_EVO_HC_EOF
interface=\`ifconfig | grep -E -o "^[a-z0-9]+" | grep -v "lo" | uniq\`
for i in \$interface 
do
        echo "\$i,\
\`ifconfig \$i | grep ether |awk '{print \$2 "," \$4}'\`,\
\`ifconfig \$i | grep inet | grep -v inet6 |awk '{print \$2"/"\$4}'\`,\
\`ifconfig \$i | grep mtu | awk '{print\$4}'\`"
done
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa17aca8ef574e47a7a9166391ded1dbb8.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa17aca8ef574e47a7a9166391ded1dbb8.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=02c20c34-7002-4164-af80-6a29249f2dea >> $HCResult
cat >>/tmp/CES_HC_ITEMa02c20c3470024164af806a29249f2dea.sh <<CES_EVO_HC_EOF
if [ -e /proc/net/bonding ];then
        bond=\`ls  /proc/net/bonding\`
        count=\`ls  /proc/net/bonding |wc -l\`
fi
if [[ ! -e /proc/net/bonding || \$count = 0 ]];then
        echo -e "network bonding No configuration\n"
elif [[  -e /proc/net/bonding && \$count != 0 ]];then
        for i in \$bond
        do
                echo "###\$i config:"
                echo "\`cat /proc/net/bonding/\$i | grep "Bonding Mode"\`"
                echo "\`cat /proc/net/bonding/\$i | grep "Currently Active Slave"\`"
                echo "\`cat /proc/net/bonding/\$i | grep -E "Slave Interface|Permanent HW add"\`"
        done
fi
Teamc=\$(nmcli connection show 2>/dev/null| awk '\$3 == "team"  {print \$1}'| wc -l)
if [ \$Teamc = 0 ];then
        echo "network team No configuration"
elif [ \$Teamc != 0 ];then
        echo "###network team config:"
        nmcli connection show | awk '\$3 == "team"  {print "team dev:"\$1;system("teamdctl "\$1" state")}'
fi
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa02c20c3470024164af806a29249f2dea.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa02c20c3470024164af806a29249f2dea.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=4babaaa2-44a6-4443-be50-7b72d3775d5b >> $HCResult
cat >>/tmp/CES_HC_ITEMa4babaaa244a64443be507b72d3775d5b.sh <<CES_EVO_HC_EOF
echo "#Total number of processes:"
ps -ef |wc -l
echo "#Total number of threads:"
ps -eLf |wc -l
echo "#Top users of CPU & MEM:"
ps axo user,pcpu,pmem,rss --no-heading | awk '{pCPU[\$1]+=\$2; pMEM[\$1]+=\$3; sRSS[\$1]+=\$4} END {for (user in pCPU) if (pCPU[user]>0 || sRSS[user]>10240) printf "%s:@%.1f%% of total CPU,@%.1f%% of total MEM@(%.2f GiB used)\n", user, pCPU[user], pMEM[user], sRSS[user]/1024/1024}' | column -ts@ | sort -rnk2
echo "#Defunct processes"
ps axo user,pid,%cpu,%mem,rss,stat,time,command | grep -e '^[Zz]\$'
echo "#Uninteruptible sleep"
ps axo user,pid,%cpu,%mem,rss,stat,time,command | grep -e '^[Dd]\$'
echo "#Top CPU-using processes"
ps aux|grep USER| head -n 1
ps aux|grep -v  USER|sort -rn -k +3|head -10
echo "#Top MEM-using processes"
ps aux|grep USER| head -n 1
ps aux|grep -v  USER|sort -rn -k +4|head -10
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa4babaaa244a64443be507b72d3775d5b.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa4babaaa244a64443be507b72d3775d5b.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=055c7952-9b2f-4209-9c15-0fb03cb29d7e >> $HCResult
cat >>/tmp/CES_HC_ITEMa055c79529b2f42099c150fb03cb29d7e.sh <<CES_EVO_HC_EOF
#Time zone
echo "#Time zone config"
echo "Time zone:\$(timedatectl  | grep "Time zone" | awk  -F":"  '{print \$2}') "
systemctl is-active chronyd.service >/dev/null 2>&1
N=\$?
systemctl is-active ntpd.service  >/dev/null 2>&1
M=\$?
crontab  -l| grep ntpdate  >/dev/null 2>&1
K=\$?
if [ \$N = 0 ];then
	echo "#Synchronization time use chronyd"
	echo "NTP service: \`grep ^server /etc/chrony.conf\`"
	echo "NTP status:\` chronyc sources\`"
	echo "NTP service: \` systemctl is-enabled chronyd.service\`"
elif [ \$M = 0 ];then
	echo "#Synchronization time use ntpd"
        echo "NTP service: \`grep ^server /etc/ntp.conf\`"
        echo "NTP status:\` ntpq  -p\`"
	echo "NTP service: \` systemctl is-enabled ntpd.service\`"
elif [ \$K = 0 ];then
	echo "#Synchronization time use crontab"
	echo "crontab conig: \`crontab  -l| grep ntpdate \`"
else
	echo "#Synchronization time no config"
fi
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa055c79529b2f42099c150fb03cb29d7e.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa055c79529b2f42099c150fb03cb29d7e.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=b3b5911c-0336-4891-8037-67661768c70d >> $HCResult
cat >>/tmp/CES_HC_ITEMab3b5911c03364891803767661768c70d.sh <<CES_EVO_HC_EOF
#ulimit.conf
echo "#ulimit.conf"
cat /etc/security/limits.conf | grep -Ev "^#|^\$"
#root user ulimit -a
echo "#root user ulimit -a"
ulimit -a
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMab3b5911c03364891803767661768c70d.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMab3b5911c03364891803767661768c70d.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=c63de9a8-846b-4241-b671-4a94384d85c7 >> $HCResult
cat >>/tmp/CES_HC_ITEMac63de9a8846b4241b6714a94384d85c7.sh <<CES_EVO_HC_EOF
lsblk |grep ^s| grep -v ^sr |awk '{print \$1","\$2"," \$4"," \$6}'
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMac63de9a8846b4241b6714a94384d85c7.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMac63de9a8846b4241b6714a94384d85c7.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=0aaf80cc-6d57-4bee-9e09-f7d0cd6c44bf >> $HCResult
cat >>/tmp/CES_HC_ITEMa0aaf80cc6d574bee9e09f7d0cd6c44bf.sh <<CES_EVO_HC_EOF
##lsblk
echo "#lsblk"
lsblk
##/dev/disk/by-path/
echo "#/dev/disk/by-path"
ls -al /dev/disk/by-path/
## lsscsi
echo "#lsscsi"
lsscsi -l      
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa0aaf80cc6d574bee9e09f7d0cd6c44bf.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa0aaf80cc6d574bee9e09f7d0cd6c44bf.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=d568269b-abb5-41fc-87eb-5c3e0af48e6c >> $HCResult
cat >>/tmp/CES_HC_ITEMad568269babb541fc87eb5c3e0af48e6c.sh <<CES_EVO_HC_EOF
#pvs
pvs
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMad568269babb541fc87eb5c3e0af48e6c.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMad568269babb541fc87eb5c3e0af48e6c.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=527690db-201f-4cd9-9ad6-f99b78285de7 >> $HCResult
cat >>/tmp/CES_HC_ITEMa527690db201f4cd99ad6f99b78285de7.sh <<CES_EVO_HC_EOF
#vgs
vgs
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa527690db201f4cd99ad6f99b78285de7.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa527690db201f4cd99ad6f99b78285de7.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=e4a89a29-d31e-4b8e-bfe1-ff0f0ac54f49 >> $HCResult
cat >>/tmp/CES_HC_ITEMae4a89a29d31e4b8ebfe1ff0f0ac54f49.sh <<CES_EVO_HC_EOF
lvs
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMae4a89a29d31e4b8ebfe1ff0f0ac54f49.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMae4a89a29d31e4b8ebfe1ff0f0ac54f49.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=3298a13c-13db-40ae-97b9-c1d0d827757c >> $HCResult
cat >>/tmp/CES_HC_ITEMa3298a13c13db40ae97b9c1d0d827757c.sh <<CES_EVO_HC_EOF
powermt display dev=all >/dev/null 2>&1
if  [ \$? != 0 ];then
	echo "#System no Use EMC Powerpath"
else
	echo "#System  Use EMC Powerpath"
	echo "powermt dispaly dev=all"
	powermt display dev=all
fi
upadmin show vlun  >/dev/null 2>&1
if  [ \$? != 0 ];then
	echo "#System no Use Huawei Ultrapath"
else
	echo "#System  Use Huawei Ultrapath"
	echo "upadmin show vlun"
	upadmin show vlun
	
fi

multipath -ll  >/dev/null 2>&1
if  [ \$? != 0 ];then
	echo "#System no Use  Multipath"
else
	echo "#System  Use Multipath"
	echo "multipath -ll"
	multipath -ll
	echo "cat /etc/multipath.conf"
	cat /etc/multipath.conf
fi
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa3298a13c13db40ae97b9c1d0d827757c.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa3298a13c13db40ae97b9c1d0d827757c.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=7f629b89-2b5b-4da2-874c-9099738a147a >> $HCResult
cat >>/tmp/CES_HC_ITEMa7f629b892b5b4da2874c9099738a147a.sh <<CES_EVO_HC_EOF
#kernel
echo "kernel,sem,arry,\`cat /proc/sys/kernel/sem\`,for oracle:250 32000 100 128"
echo "kernel,threads-max,num,\`cat /proc/sys/kernel/threads-max\`,"
echo "kernel,shmall,4-KiB pages,\`cat /proc/sys/kernel/shmall\`,"
echo "kernel,shmmax,bytes,\` cat /proc/sys/kernel/shmmax\`,"
echo "kernel,shmmni,segments,\`cat /proc/sys/kernel/shmmni\`,"
#fs
echo "fs,file-max,num,\`cat /proc/sys/fs/file-max\`,"
echo "fs,nr_open,num,\`cat /proc/sys/fs/nr_open\`,"
#net
echo "net,core.rmem_default,bytes,\`cat /proc/sys/net/core/rmem_default\`,"
echo "net,core.wmem_default,bytes,\`cat /proc/sys/net/core/wmem_default\`,"
echo "net,core.rmem_max,bytes,\`cat /proc/sys/net/core/rmem_max\`,4M vaule:4194304"
echo "net,core.wmem_max,bytes,\`cat /proc/sys/net/core/wmem_max\`, 4M vaule:4194304"
echo "net,ipv4.ip_forward,bool,\`cat /proc/sys/net/ipv4/ip_forward\`,0"
echo "net,ipv4.ip_local_port_range,ports,\`cat /proc/sys/net/ipv4/ip_local_port_range\`,for oracle:9000 65500"
echo "net,ipv4.tcp_timestamps,bool,\`cat /proc/sys/net/ipv4/tcp_timestamps\`,1"
#vm
echo "vm,vm.swappiness,%,\`cat /proc/sys/vm/swappiness\`,10"
echo "vm,min_free_kbytes,kbytes,\`cat /proc/sys/vm/min_free_kbytes\`,"
echo "vm,dirty_ratio,%,\`cat /proc/sys/vm/dirty_ratio\`,15"
echo "vm,dirty_expire_centisecs,1/100s,\`cat /proc/sys/vm/dirty_expire_centisecs\`,500"
echo "vm,dirty_writeback_centisecs,1/100s,\`cat /proc/sys/vm/dirty_writeback_centisecs\`,100"
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa7f629b892b5b4da2874c9099738a147a.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa7f629b892b5b4da2874c9099738a147a.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=dc9c7e2d-91ea-4170-a12a-f6a83186ba4b >> $HCResult
cat >>/tmp/CES_HC_ITEMadc9c7e2d91ea4170a12af6a83186ba4b.sh <<CES_EVO_HC_EOF
tail -10000 /var/log/messages | grep -iE "error|fail|Machine Check Exception|Out of memory|soft lockup|EXT4-fs error|qla2xxx|Failing path|Kernel panic" |grep -Ev "failed to assign|sftp-server" 
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMadc9c7e2d91ea4170a12af6a83186ba4b.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMadc9c7e2d91ea4170a12af6a83186ba4b.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=e4925a5d-fdc5-4f8a-9d25-cec9f81db1f0 >> $HCResult
cat >>/tmp/CES_HC_ITEMae4925a5dfdc54f8a9d25cec9f81db1f0.sh <<CES_EVO_HC_EOF
tail -1000 /var/log/dmesg | grep -iE "error|fail|Machine Check Exception|Out of memory|soft lockup| I\/O error|EXT4-fs error|qla2xxx|Failing path|Kernel panic|NIC Link is Down" | grep -Ev "failed to assign|sftp-server" 
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMae4925a5dfdc54f8a9d25cec9f81db1f0.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMae4925a5dfdc54f8a9d25cec9f81db1f0.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=422a5c94-1e87-48ba-bec9-117c19f15ad7 >> $HCResult
cat >>/tmp/CES_HC_ITEMa422a5c941e8748babec9117c19f15ad7.sh <<CES_EVO_HC_EOF
journalctl  -p crit
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMa422a5c941e8748babec9117c19f15ad7.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMa422a5c941e8748babec9117c19f15ad7.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
echo CES_HC_ITEM_KEY=fdcb6e66-3efe-489b-a301-600b0584d0a7 >> $HCResult
cat >>/tmp/CES_HC_ITEMafdcb6e663efe489ba301600b0584d0a7.sh <<CES_EVO_HC_EOF
file=/var/log/mcelog
if [ ! -e \$file ];then
	echo "-- No entries --"
else
	tail -10 \$file
fi
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMafdcb6e663efe489ba301600b0584d0a7.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMafdcb6e663efe489ba301600b0584d0a7.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
cat >>/tmp/CES_HC_ITEMad1ed5e97a924aa0b9389ef6350c1b2c.sh <<CES_EVO_HC_EOF
echo "ad1ed5e9-7a92-4aa0-b938-9ef6350c1b2cCESEVO`hostname`"
CES_EVO_HC_EOF
sh /tmp/CES_HC_ITEMad1ed5e97a924aa0b9389ef6350c1b2c.sh >> $HCResult
rm -f /tmp/CES_HC_ITEMad1ed5e97a924aa0b9389ef6350c1b2c.sh
echo "########CES_HC_ITEM_SEPARATOR########" >> $HCResult
