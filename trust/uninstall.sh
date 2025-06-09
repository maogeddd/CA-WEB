#!/bin/bash

CRT_NAME="Maogeddd_Root_CA.crt"
CRT_DIR="/usr/share/ca-certificates/maogeddd"
CRT_PATH="$CRT_DIR/$CRT_NAME"
CONF_LINE="maogeddd/$CRT_NAME"

# 🛡️ 自动使用 sudo 提升权限
if [ "$EUID" -ne 0 ]; then
  echo "🔐 本操作需要 root 权限，请输入密码以继续..."
  exec sudo bash "$0" "$@"
fi

echo "🧹 正在卸载 Maogeddd Root CA 证书..."

# 删除证书文件
if [ -f "$CRT_PATH" ]; then
  rm -f "$CRT_PATH"
  echo "✅ 已删除证书文件：$CRT_PATH"
else
  echo "⚠️ 证书文件不存在：$CRT_PATH"
fi

# 删除证书目录（如果为空）
if [ -d "$CRT_DIR" ]; then
  if [ "$(ls -A $CRT_DIR)" ]; then
    echo "⚠️ 目录 $CRT_DIR 不为空，未删除。"
  else
    rmdir "$CRT_DIR"
    echo "✅ 已删除空目录：$CRT_DIR"
  fi
fi

# 从 /etc/ca-certificates.conf 中删除对应行
if grep -Fxq "$CONF_LINE" /etc/ca-certificates.conf; then
  grep -Fxv "$CONF_LINE" /etc/ca-certificates.conf > /tmp/ca-certificates.conf.tmp && mv /tmp/ca-certificates.conf.tmp /etc/ca-certificates.conf
  echo "✅ 已从 /etc/ca-certificates.conf 移除：$CONF_LINE"
else
  echo "ℹ️ /etc/ca-certificates.conf 中无该条目：$CONF_LINE"
fi

# 更新系统证书信任列表
echo "🔄 正在更新系统证书信任列表..."
sudo pdate-ca-certificates --fresh

echo "🎉 卸载完成，Maogeddd Root CA 根证书已从系统内移除！"
