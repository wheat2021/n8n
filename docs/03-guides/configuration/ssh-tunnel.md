---
title: n8n SSH 隧道访问指南
description: 通过 SSH 隧道安全访问远程 n8n 服务的配置和使用指南
category: guides/configuration
tags: [ssh, tunnel, security, remote-access]
author: Terry Chen
created: 2024-12-24
updated: 2024-12-29
version: 1.0.0
status: active
---

# n8n SSH 隧道访问指南

## 快速开始

### 方法 1：命令行 SSH 隧道

在你的**本地电脑**（不是服务器）上运行：

```bash
# 基本命令
ssh -L 5678:localhost:5678 你的用户名@160.13.4.23

# 如果需要指定 SSH 密钥
ssh -i ~/.ssh/your_key -L 5678:localhost:5678 你的用户名@160.13.4.23

# 后台运行（推荐）
ssh -f -N -L 5678:localhost:5678 你的用户名@160.13.4.23
```

**参数说明**：
- `-L 5678:localhost:5678`：将本地 5678 端口映射到远程的 localhost:5678
- `-f`：后台运行
- `-N`：不执行远程命令，仅转发端口
- `-i`：指定 SSH 私钥文件

### 方法 2：SSH 配置文件（推荐）

创建或编辑 `~/.ssh/config`：

```ssh-config
Host n8n-tunnel
    HostName 160.13.4.23
    User 你的用户名
    LocalForward 5678 localhost:5678
    # 可选：指定密钥
    # IdentityFile ~/.ssh/your_key
    # 保持连接活跃
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

然后只需运行：

```bash
# 前台运行
ssh n8n-tunnel

# 后台运行
ssh -f -N n8n-tunnel
```

## 访问 n8n

SSH 隧道建立后，在浏览器中访问：

```
http://localhost:5678
```

✅ **验证成功标志**：
- n8n 界面正常加载
- 没有 `crypto.randomUUID()` 错误
- 可以正常登录和使用

## 管理 SSH 隧道

### 查看活跃的隧道

```bash
# macOS/Linux
ps aux | grep "ssh.*5678"

# 或使用 lsof
lsof -i :5678
```

### 关闭隧道

```bash
# 找到 SSH 进程 PID
ps aux | grep "ssh.*5678"

# 关闭进程
kill <PID>

# 或者强制关闭所有相关 SSH 隧道
pkill -f "ssh.*5678"
```

### 自动重连

创建脚本 `~/bin/n8n-tunnel.sh`：

```bash
#!/bin/bash

# n8n SSH 隧道自动重连脚本

HOST="160.13.4.23"
USER="你的用户名"
LOCAL_PORT="5678"
REMOTE_PORT="5678"

while true; do
    echo "$(date): 启动 n8n SSH 隧道..."
    ssh -N -L ${LOCAL_PORT}:localhost:${REMOTE_PORT} ${USER}@${HOST}
    
    echo "$(date): SSH 隧道断开，5 秒后重连..."
    sleep 5
done
```

赋予执行权限并运行：

```bash
chmod +x ~/bin/n8n-tunnel.sh
~/bin/n8n-tunnel.sh
```

## 常见问题

### Q1: 提示 "Address already in use"

**原因**：本地 5678 端口已被占用

**解决**：

```bash
# 查看占用端口的进程
lsof -i :5678

# 关闭占用的进程
kill <PID>

# 或使用其他本地端口
ssh -L 5679:localhost:5678 你的用户名@160.13.4.23
# 然后访问 http://localhost:5679
```

### Q2: SSH 连接超时

**原因**：网络问题或防火墙阻止

**解决**：

```bash
# 测试 SSH 连接
ssh -v 你的用户名@160.13.4.23

# 检查防火墙设置
# 确保 22 端口开放
```

### Q3: 隧道经常断开

**原因**：网络不稳定或 SSH 超时

**解决**：在 `~/.ssh/config` 添加：

```ssh-config
Host n8n-tunnel
    # ... 其他配置 ...
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

### Q4: 需要从多台电脑访问

**解决方案 1**：每台电脑都建立 SSH 隧道

**解决方案 2**：使用方案 2（域名 + HTTPS），参考实施方案文档

## 性能优化

### 启用 SSH 压缩

```bash
ssh -C -L 5678:localhost:5678 你的用户名@160.13.4.23
```

### 使用 SSH 多路复用

在 `~/.ssh/config` 添加：

```ssh-config
Host n8n-tunnel
    # ... 其他配置 ...
    ControlMaster auto
    ControlPath ~/.ssh/sockets/%r@%h-%p
    ControlPersist 600
```

创建 socket 目录：

```bash
mkdir -p ~/.ssh/sockets
```

## 安全建议

1. **使用 SSH 密钥认证**
   ```bash
   # 生成 SSH 密钥（如果还没有）
   ssh-keygen -t ed25519 -C "your_email@example.com"
   
   # 复制公钥到服务器
   ssh-copy-id 你的用户名@160.13.4.23
   ```

2. **限制端口转发**
   
   在服务器的 `/etc/ssh/sshd_config` 中：
   ```
   AllowTcpForwarding yes
   PermitOpen localhost:5678
   ```

3. **使用防火墙规则**
   
   确保服务器上的 n8n 只监听 localhost：
   ```bash
   # 检查 n8n 监听地址
   docker-compose exec n8n netstat -tlnp | grep 5678
   ```

## macOS 快捷方式

### 使用 Automator 创建一键启动

1. 打开 Automator
2. 创建新的"应用程序"
3. 添加"运行 Shell 脚本"动作
4. 输入：
   ```bash
   /usr/bin/ssh -f -N n8n-tunnel
   open http://localhost:5678
   ```
5. 保存为"启动 n8n 隧道.app"

双击应用即可启动隧道并打开浏览器。

## 下一步

使用 SSH 隧道验证 n8n 功能正常后，如果需要：

1. **团队协作**：考虑实施方案 2（域名 + HTTPS）
2. **长期使用**：配置自动重连脚本
3. **多设备访问**：升级到 HTTPS 方案

参考主实施方案文档了解更多选项。
