# This kickstart file should only be used with EL > 5 and/or Fedora > 7.
# For older versions please use the sample.ks kickstart file.

#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# System bootloader configuration
bootloader --location=mbr
#changed
# Partition clearing information
clearpart --all --initlabel
part pv.01 --size=1 --grow --ondisk=vdb
part pv.02 --size=1 --grow --ondisk=vdc
part /boot --fstype=xfs --ondisk=vda --size=500
part swap --fstype=swap --ondisk=vda --size=1024
volgroup vgtest pv.01 pv.02
logvol / --fstype=xfs --name=lv_root --vgname=vgtest --size=5000
logvol /home --fstype=xfs --name=lv_home --vgname=vgtest --size=4096
logvol /tmp --fstype=xfs --name=lv_tmp --vgname=vgtest --size=9192
# Use text mode install
text
#changed
# Firewall configuration
firewall --disabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot

#Root password
rootpw --iscrypted $default_password_crypted
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
#changed
# System timezone
timezone  Asia/Shanghai
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# Allow anaconda to partition the system as needed
autopart

%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')
%end

%packages
$SNIPPET('func_install_if_enabled')
#changed
@core
@base
tree
nmap
vim
telnet
%end

%post --nochroot
$SNIPPET('log_ks_post_nochroot')
%end

%post
$SNIPPET('log_ks_post')
# Start yum configuration
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('func_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps

#changed
sed -ri "/^#UseDNS/c\UseDNS no" /etc/ssh/sshd_config

%end
