# n8n 中使用 SSH 访问 GitHub

## 配置说明

Docker Compose 配置已被修改，使 n8n 容器能够访问本机的 SSH 密钥来操作 GitHub。

### 挂载的文件和目录

在 `docker-compose.yml` 中，以下文件被挂载到容器：

```yaml
volumes:
  - n8n_storage:/home/node/.n8n
  - /opt/code:/opt/code
  - /Users/terrychen/.gitconfig:/home/node/.gitconfig:ro
  - /Users/terrychen/.ssh/id_ed25519:/home/node/.ssh/id_ed25519:ro
  - /Users/terrychen/.ssh/id_ed25519.pub:/home/node/.ssh/id_ed25519.pub:ro
  - /Users/terrychen/.ssh/id_rsa:/home/node/.ssh/id_rsa:ro
  - /Users/terrychen/.ssh/id_rsa.pub:/home/node/.ssh/id_rsa.pub:ro
  - /Users/terrychen/.ssh/known_hosts:/home/node/.ssh/known_hosts:ro
```

- **`~/.gitconfig`**: Git 全局配置文件（只读）
- **`~/.ssh/id_ed25519`** 和 **`~/.ssh/id_rsa`**: SSH 私钥（只读）
- **`~/.ssh/id_ed25519.pub`** 和 **`~/.ssh/id_rsa.pub`**: SSH 公钥（只读）
- **`~/.ssh/known_hosts`**: 已知主机列表（只读）

> [!IMPORTANT]
> 我们**不挂载** `~/.ssh/config` 文件，因为 macOS 的 SSH config 包含 `UseKeychain` 等 Linux 容器不支持的选项。
> 
> 所有挂载都使用了 `:ro` (只读) 标志，确保容器内的进程不会意外修改本机的 Git 配置或 SSH 密钥。

## 使用前提

### 1. 确保 SSH 密钥已配置

确认你的本机已经有 GitHub SSH 密钥：

```bash
ls -la ~/.ssh/
```

应该能看到类似这些文件：
- `id_rsa` 或 `id_ed25519` (私钥)
- `id_rsa.pub` 或 `id_ed25519.pub` (公钥)
- `known_hosts`
- `config` (可选)

### 2. 测试本机 SSH 连接

在重启容器前，先确认本机能够正常连接 GitHub：

```bash
ssh -T git@github.com
```

应该看到类似输出：
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

## 重启服务

修改配置后需要重新创建容器以应用挂载：

```bash
cd /opt/code/n8n
docker-compose down
docker-compose up -d
```

## 验证配置

### 1. 进入容器验证

```bash
docker-compose exec n8n sh
```

在容器内检查：

```bash
# 查看 SSH 密钥
ls -la ~/.ssh/

# 测试 GitHub 连接
ssh -T git@github.com

# 查看 Git 配置
git config --list
```

### 2. 在 n8n 工作流中使用

现在你可以在 n8n 的 Execute Command 节点或其他需要 Git 操作的节点中使用 SSH 方式克隆或操作 GitHub 仓库：

```bash
# 使用 SSH URL 克隆仓库
git clone git@github.com:username/repository.git

# 或执行其他 Git 操作
cd /path/to/repo
git pull
git push
```

## 常见问题

### macOS SSH Config 兼容性问题

**问题现象：**
```
/home/node/.ssh/config: line XX: Bad configuration option: usekeychain
/home/node/.ssh/config: terminating, 1 bad configuration options
```

**原因：**
macOS 的 SSH config 文件中包含 `UseKeychain` 等 macOS 特有的配置选项，这些选项在 Linux 容器中不被支持。

**解决方案：**
我们采用的方案是**只挂载必要的 SSH 文件**（私钥、公钥、known_hosts），而不挂载 `config` 文件。这样可以避免 macOS 特有配置导致的兼容性问题。

如果你需要在容器内使用特定的 SSH 配置，可以：

1. **创建 Linux 兼容的 SSH config**：
   ```bash
   # 在本机创建一个不包含 macOS 特有选项的 config
   cat > ~/.ssh/config.linux <<EOF
   Host github.com
       HostName github.com
       User git
       IdentityFile ~/.ssh/id_ed25519
       IdentitiesOnly yes
   EOF
   ```

2. **在 docker-compose.yml 中挂载这个文件**：
   ```yaml
   - /Users/terrychen/.ssh/config.linux:/home/node/.ssh/config:ro
   ```

### SSH 权限问题

如果遇到权限问题，可能需要检查：

1. **本机 SSH 密钥权限**：
   ```bash
   chmod 600 ~/.ssh/id_rsa
   chmod 644 ~/.ssh/id_rsa.pub
   chmod 700 ~/.ssh
   ```

2. **known_hosts 文件**：
   如果第一次在容器内连接 GitHub，可能需要接受主机密钥。可以在本机先执行一次 `ssh -T git@github.com` 来添加 GitHub 到 known_hosts。

### Git 配置问题

确保你的 `~/.gitconfig` 包含正确的用户信息：

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

## 安全注意事项

> [!CAUTION]
> - SSH 密钥以**只读模式**挂载，容器无法修改你的密钥
> - 不要在不信任的 n8n 工作流中使用这些密钥
> - 定期检查和轮换你的 SSH 密钥
> - 如果担心安全问题，可以为 n8n 创建专用的 SSH 密钥（部署密钥）

## 高级配置：使用专用密钥（可选）

如果你希望为 n8n 使用单独的 SSH 密钥而不是主密钥：

### 1. 生成专用密钥

```bash
ssh-keygen -t ed25519 -C "n8n@yourdomain.com" -f ~/.ssh/n8n_github
```

### 2. 添加公钥到 GitHub

将 `~/.ssh/n8n_github.pub` 的内容添加到 GitHub:
- 作为个人 SSH 密钥：Settings → SSH and GPG keys
- 或作为仓库的 Deploy Key（推荐）

### 3. 创建 SSH 配置

创建或编辑 `~/.ssh/config`：

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/n8n_github
    IdentitiesOnly yes
```

### 4. 修改挂载配置

可选：如果只想挂载特定文件，可以这样修改 `docker-compose.yml`：

```yaml
volumes:
  - /Users/terrychen/.ssh/n8n_github:/home/node/.ssh/id_ed25519:ro
  - /Users/terrychen/.ssh/n8n_github.pub:/home/node/.ssh/id_ed25519.pub:ro
  - /Users/terrychen/.ssh/config:/home/node/.ssh/config:ro
  - /Users/terrychen/.ssh/known_hosts:/home/node/.ssh/known_hosts:ro
```

这样可以更精确地控制哪些密钥对容器可见。
