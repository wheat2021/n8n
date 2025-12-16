#!/bin/bash
set -e

echo "🚀 启动 n8n Docker Compose 部署..."
echo ""

# 检查 .env 文件是否存在
if [ ! -f .env ]; then
    echo "⚠️  未找到 .env 文件，正在从 .env.example 创建..."
    cp .env.example .env
    
    # 生成新的加密密钥
    ENCRYPTION_KEY=$(openssl rand -hex 32)
    
    # 更新 .env 文件中的加密密钥
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/ENCRYPTION_KEY=.*/ENCRYPTION_KEY=${ENCRYPTION_KEY}/" .env
    else
        # Linux
        sed -i "s/ENCRYPTION_KEY=.*/ENCRYPTION_KEY=${ENCRYPTION_KEY}/" .env
    fi
    
    echo "✅ 已创建 .env 文件并生成加密密钥"
    echo ""
    echo "⚠️  请编辑 .env 文件，修改数据库密码后再次运行此脚本"
    echo ""
    exit 0
fi

# 检查配置是否包含默认密码
if grep -q "change_this" .env; then
    echo "⚠️  检测到 .env 文件中包含默认密码"
    echo "   请修改以下配置："
    echo "   - POSTGRES_PASSWORD"
    echo "   - POSTGRES_NON_ROOT_PASSWORD"
    echo ""
    read -p "是否继续启动？(y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo "📦 拉取最新镜像..."
docker-compose pull

echo ""
echo "🏗️  启动服务..."
docker-compose up -d

echo ""
echo "⏳ 等待服务启动..."
sleep 5

echo ""
echo "📊 服务状态："
docker-compose ps

echo ""
echo "✅ n8n 已启动！"
echo ""
echo "🌐 访问地址: http://localhost:5678"
echo ""
echo "📝 查看日志: docker-compose logs -f"
echo "🛑 停止服务: docker-compose down"
echo ""
