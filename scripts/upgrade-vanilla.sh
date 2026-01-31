#!/bin/bash

# ============================================
# Terraria 原版服务器升级脚本
# ============================================
# 用法: ./upgrade-vanilla.sh
#
# 从 /data/server/ 目录读取 terraria-server-*.zip 并升级
# ============================================

set -e

# 路径定义
VANILLA_DIR="/server/vanilla"
SERVER_ZIP_DIR="/data/server"
TEMP_DIR="/tmp/vanilla_upgrade"

echo ""
echo "=========================================="
echo "  Terraria 原版服务器升级工具"
echo "=========================================="
echo ""

# 查找最新的服务器zip文件
latest_zip=""
latest_version=0

for zip_file in "$SERVER_ZIP_DIR"/terraria-server-*.zip; do
    if [ -f "$zip_file" ]; then
        version=$(basename "$zip_file" | grep -oP '\d+' | head -1)
        if [ -n "$version" ] && [ "$version" -gt "$latest_version" ]; then
            latest_version=$version
            latest_zip=$zip_file
        fi
    fi
done

if [ -z "$latest_zip" ]; then
    echo "[错误] 在 $SERVER_ZIP_DIR 目录中没有找到服务器文件"
    echo ""
    echo "请将 terraria-server-xxxx.zip 放入:"
    echo "  宿主机: ./server_data/server/"
    echo "  容器内: /data/server/"
    exit 1
fi

echo "[信息] 找到: $(basename $latest_zip)"
echo "[信息] 正在升级..."

# 清理并解压
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
unzip -q "$latest_zip" -d "$TEMP_DIR"

# 查找解压后的服务器目录
server_dir=""
for dir in "$TEMP_DIR"/*/; do
    if [ -d "${dir}Linux" ]; then
        server_dir="$dir"
        break
    fi
done

if [ -z "$server_dir" ]; then
    echo "[错误] 无法识别服务器文件结构"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 替换服务器文件
rm -rf "$VANILLA_DIR"
mkdir -p "$VANILLA_DIR"
mv "$server_dir"/* "$VANILLA_DIR/"
chmod +x "$VANILLA_DIR/Linux/TerrariaServer.bin.x86_64"

# 清理
rm -rf "$TEMP_DIR"

echo ""
echo "[完成] 服务器已升级!"
echo ""
echo "启动命令:"
echo "  cd /server/vanilla/Linux"
echo "  ./TerrariaServer.bin.x86_64"
