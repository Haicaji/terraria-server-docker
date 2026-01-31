# Terraria Docker 混合云部署

> 🎮 支持原版 (Vanilla) 和 tModLoader 双模服务器  
> 🐳 容器化部署，一键迁移  
> 🌐 内网穿透，无公网 IP 也能联机

## 📁 项目结构

```
terraria-server-docker/
├── Dockerfile              # Docker 镜像构建文件
├── docker-compose.yml      # 容器编排配置
├── scripts/
│   └── upgrade-vanilla.sh  # 原版服务器升级脚本
├── frp/
│   ├── frpc.toml           # FRP 客户端配置 (本地)
│   └── frps.toml           # FRP 服务端配置 (云服务器)
├── zip/
│   ├── terraria-server-*.zip   # 原版服务器 (任意版本)
│   └── tModLoader.zip          # tModLoader
└── server_data/            # 数据卷 (存档/Mod/配置)
    ├── Worlds/             # 世界存档
    ├── Mods/               # Mod 文件 (tModLoader)
    ├── Config/             # 配置文件
    └── server/             # 服务器升级文件存放目录
```

---

## 🚀 快速开始

### 1. 准备工作

1. 下载服务器文件到 `zip/` 目录：
   - [原版服务器](https://terraria.org/) → `terraria-server-xxxx.zip`
   - [tModLoader](https://github.com/tModLoader/tModLoader/releases) → `tModLoader.zip`

2. 配置 FRP（如需内网穿透）：
   - 编辑 `frp/frpc.toml`，填入您的 VPS IP 和 Token
   - 并且记得在 VPS 上配置好 FRP

### 2. 构建并启动容器

```powershell
# 构建镜像并启动容器
docker-compose up -d --build

# 查看容器状态
docker ps
```

### 3. 进入容器并启动服务器

```powershell
# 进入容器命令行
docker exec -it terraria_server bash
```

---

## 📖 服务器启动命令(参考对应的服务器启动指南)

进入容器后，使用原生命令启动服务器：

### 原版服务器 (Vanilla)

```bash
# 进入原版服务器目录
cd /server/vanilla/Linux

# 启动服务器 (交互式创建世界)
./TerrariaServer.bin.x86_64

# 或指定参数直接启动
./TerrariaServer.bin.x86_64 -world /data/Worlds/MyWorld.wld -autocreate 2 -port 7777
```

### tModLoader 服务器

```bash
# 进入 tModLoader 目录
cd /server/tmod

# 启动服务器 (交互式)
./start-tModLoaderServer.sh

# 或指定参数直接启动
./start-tModLoaderServer.sh -world /data/Worlds/MyModWorld.wld -autocreate 2 -port 7777
```

---

## 🌐 内网穿透配置 (FRP)

### 本地配置 (frp/frpc.toml)

已预配置，只需修改 VPS IP 和 Token。

### 云服务器配置

1. 将 `frp/frps.toml` 上传到云服务器
2. 下载 FRP: https://github.com/fatedier/frp/releases
3. 运行服务端：
   ```bash
   ./frps -c frps.toml
   ```
4. 开放安全组端口：**7000, 7777** (TCP/UDP)

### 连接方式

玩家使用您的 **VPS 公网 IP:7777** 连接游戏。
---

## 升级原版服务器

容器内置了简单的升级脚本：

### 升级步骤

1. 从 [terraria.org](https://terraria.org/) 下载最新的 `PC Dedicated Server`
2. 将 `terraria-server-xxxx.zip` 放入 `server_data/server/` 目录
3. 进入容器执行升级：

```bash
docker exec -it terraria_server bash
/server/upgrade-vanilla.sh
```

脚本会自动查找 `server_data/server/` 目录下的最新版本 zip 文件并完成升级。

---

## 迁移服务器

### 导出

1. 停止容器: `docker-compose down`
2. 复制整个 `terraria-server-docker` 文件夹

### 导入

1. 在新电脑安装 Docker
2. 粘贴文件夹
3. 运行: `docker-compose up -d --build`
4. 进入容器启动服务器

**所有存档、Mods、配置都在 `server_data/` 目录中，完整保留！**
