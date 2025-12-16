#!/bin/bash

# n8n Docker 重启脚本
# 用于安全地重启 n8n 服务

set -e

echo "=========================================="
echo "n8n Docker 服务重启脚本"
echo "=========================================="
echo ""

# 检查 .env 文件
if [ ! -f .env ]; then
    echo "❌ 错误: .env 文件不存在"
    echo "请从 .env.example 复制并配置 .env 文件:"
    echo "  cp .env.example .env"
    echo "  然后编辑 .env 文件,设置必要的环境变量"
    exit 1
fi

echo "✅ .env 文件存在"
echo ""

# 停止所有服务
echo "🛑 停止所有服务..."
docker-compose down

echo ""
echo "⏳ 等待 5 秒确保服务完全停止..."
sleep 5

# 启动服务
echo ""
echo "🚀 启动服务..."
docker-compose up -d

echo ""
echo "⏳ 等待服务启动 (30秒)..."
sleep 30

# 检查服务状态
echo ""
echo "📊 检查服务状态..."
docker-compose ps

echo ""
echo "🔍 检查 PostgreSQL 健康状态..."
docker-compose exec postgres pg_isready -U n8n_admin -d n8n

echo ""
echo "🔍 检查 n8n 日志 (最近 20 行)..."
docker-compose logs n8n --tail 20

echo ""
echo "=========================================="
echo "✅ 重启完成!"
echo "访问 http://localhost:5678 使用 n8n"
echo "=========================================="
