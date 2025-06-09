#!/bin/bash

CERT_URL="http://pki.mgddd.top:88/cert/Maogeddd_Root_CA.crt"
TEMP_PATH="/tmp/Maogeddd_Root_CA.crt"
CRT_NAME="Maogeddd_Root_CA.crt"
CRT_DIR="/usr/share/ca-certificates/maogeddd"
DEST_PATH="$CRT_DIR/$CRT_NAME"
CONF_LINE="maogeddd/$CRT_NAME"

# 🛡️ 自动使用 sudo 提升权限
if [ "$EUID" -ne 0 ]; then
  echo "🔐 本操作需要 root 权限，请输入密码以继续..."
  exec sudo bash "$0" "$@"
fi

# 🧲 尝试下载证书
echo "📥 正在尝试下载 Maogeddd Root CA 根证书..."
wget -q "$CERT_URL" -O "$TEMP_PATH"

# 🧐 如果下载失败，提示用户手动输入路径
if [ $? -ne 0 ]; then
  echo "⚠️ 无法下载证书，可能是链接失效或网络问题。"
  echo "📂 请手动输入你本地的 .crt 文件路径："
  read -p "请输入证书所在路径： " USER_PATH

  # 🚨 校验用户路径是否存在
  if [ ! -f "$USER_PATH" ]; then
    echo "❌ 文件路径不存在：$USER_PATH"
    exit 1
  fi

  cp "$USER_PATH" "$TEMP_PATH"
fi

# 📁 创建目标目录（无提示）
mkdir -p "$CRT_DIR"

# 🚚 复制证书文件
cp "$TEMP_PATH" "$DEST_PATH"

# 📜 添加到 ca-certificates.conf（避免重复，静默）
if ! grep -Fxq "$CONF_LINE" /etc/ca-certificates.conf; then
  echo "$CONF_LINE" >> /etc/ca-certificates.conf
fi

# 🔄 更新系统证书
echo "🔄 正在更新系统证书信任列表..."
update-ca-certificates

echo "🎉 ✅ 成功安装 Maogeddd Root CA 证书！系统已信任该证书！"
