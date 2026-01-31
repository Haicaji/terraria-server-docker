# Terraria 双模服务器 Docker 镜像
# 支持原版 (Vanilla) 和 tModLoader 切换
# 容器仅提供运行环境，服务器由玩家手动启动

FROM ubuntu:22.04

# 避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要依赖
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    libicu70 \
    tmux \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /server

# 复制服务器压缩包 (使用通配符匹配任意版本)
COPY zip/terraria-server-*.zip /tmp/vanilla.zip
COPY zip/tModLoader.zip /tmp/tmod.zip

# 解压原版服务器
RUN mkdir -p /server/vanilla && \
    unzip /tmp/vanilla.zip -d /tmp/vanilla_temp && \
    mv /tmp/vanilla_temp/*/* /server/vanilla/ && \
    rm -rf /tmp/vanilla_temp /tmp/vanilla.zip && \
    chmod +x /server/vanilla/Linux/TerrariaServer.bin.x86_64

# 解压 tModLoader
RUN mkdir -p /server/tmod && \
    unzip /tmp/tmod.zip -d /server/tmod && \
    rm /tmp/tmod.zip && \
    chmod +x /server/tmod/start-tModLoaderServer.sh

# 创建数据目录并建立符号链接
RUN mkdir -p /data/Worlds /data/Mods /data/Config /data/server && \
    mkdir -p /root/.local/share && \
    ln -sf /data /root/.local/share/Terraria

# 复制升级脚本
COPY scripts/upgrade-vanilla.sh /server/upgrade-vanilla.sh
RUN chmod +x /server/upgrade-vanilla.sh

# 暴露端口
EXPOSE 7777

# 保持容器运行，等待用户手动操作
CMD ["tail", "-f", "/dev/null"]
