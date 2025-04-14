#!/bin/bash

# 获取服务器 IP
SERVER_IP=$(curl -s https://api.ipify.org)

# 随机生成密码（12位）
PASSWORD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)

# 设置端口与加密方式
PORT=8388
METHOD=aes-256-gcm

# 安装 shadowsocks-libev
apt update && apt install shadowsocks-libev -y

# 写入配置文件
cat > /etc/shadowsocks-libev/config.json <<EOF
{
    "server":"0.0.0.0",
    "server_port":$PORT,
    "local_port":1080,
    "password":"$PASSWORD",
    "timeout":60,
    "method":"$METHOD"
}
EOF

# 启动并设置开机自启
systemctl restart shadowsocks-libev
systemctl enable shadowsocks-libev

# 放行防火墙端口
ufw allow $PORT/tcp
ufw allow $PORT/udp

# 输出 Clash 节点配置
echo -e "\n✅ 安装完成！以下是 Clash 节点配置：\n"
echo "proxies:"
echo "  - name: my-ss"
echo "    type: ss"
echo "    server: $SERVER_IP"
echo "    port: $PORT"
echo "    cipher: $METHOD"
echo "    password: $PASSWORD"
