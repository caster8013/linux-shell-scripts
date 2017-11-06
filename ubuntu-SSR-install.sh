#!/bin/bash
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

#Check Root
[ $(id -u) != "0" ] && { echo "Error: You must be root to run this script"; exit 1; }

apt-get update
apt-get install -y python3 git python-m2crypto libsodium18 || true

workdir=/home/Downloads
[ -d $workdir ] || mkdir -p $workdir
cd $workdir
git clone -b manyuser https://github.com/shadowsocksrr/shadowsocksr.git

cat <<EOF >/etc/ssr.json
{
"server":"proxy.undervineyard.com",
"server_ipv6":"::",
"server_port":$1,
"local_address":"127.0.0.1",
"local_port":1080,
"password":"$2",
"timeout":300,
"udp_timeout":60,
"method":"aes-128-ctr",
"protocol":"auth_aes128_md5",
"protocol_param":"",
"obfs":"tls1.2_ticket_auth",
"obfs_param":"",
"fast_open":false,
"workers":1
}
EOF

sed -i '/^exit/d' /etc/rc.local
cat <<EOF >>/etc/rc.local
/usr/bin/python3 $workdir/shadowsocksr/shadowsocks/local.py -c /etc/ssr.json -d start
exit 0
EOF

reboot
