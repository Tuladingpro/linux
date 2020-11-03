

> centos7系小技巧
>
> cobbler profile edit --name="Centos-7.4-x86_64" --kopts='net.ifnames=0 biosdevname=0'
>
> 修改安装系统的内核参数，在CentOS7系统有一个地方变了，就是网卡名变成eno16777736这种形式，但是为了运维标准化，我们需要将它变成我们常用的eth0，因此使用上面的参数。但要注意是CentOS7才需要上面的步骤

==注意:若遇到新建虚拟机安装系统提示未找到网络启动设备的,依次排查重启httpd、xinetd、tftp、cobblerd服务，最终使用`cobbler sync`同步配置==