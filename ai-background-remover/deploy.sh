#!/bin/bash

# AI Background Remover - Cloudflare Pages 部署脚本

set -e

echo "🚀 开始部署 AI Background Remover 到 Cloudflare Pages..."

# 检查依赖
echo "📦 检查依赖..."
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler 未安装，正在安装..."
    npm install -g wrangler
fi

# 安装项目依赖
echo "📦 安装项目依赖..."
npm install

# 构建项目
echo "🔨 构建项目..."
npm run build

# 检查环境变量
echo "🔍 检查环境变量..."
if [ ! -f ".env.local" ]; then
    echo "⚠️  .env.local 文件不存在，创建模板..."
    cat > .env.local << EOF
# AI 服务配置
AI_API_KEY=your_ai_api_key_here
AI_ENDPOINT=https://api.ai-service.com/v1

# Cloudflare 配置
CLOUDFLARE_ACCOUNT_ID=your_account_id
CLOUDFLARE_API_TOKEN=your_api_token
EOF
    echo "✅ 已创建 .env.local 模板文件，请填入您的 API 密钥"
    echo "📝 编辑 .env.local 文件后重新运行此脚本"
    exit 1
fi

# 登录 Cloudflare（如果需要）
echo "🔐 检查 Cloudflare 登录状态..."
if ! wrangler whoami &> /dev/null; then
    echo "🔐 请先登录 Cloudflare..."
    wrangler login
fi

# 创建 Pages 项目
echo "📄 创建 Cloudflare Pages 项目..."
wrangler pages project create ai-background-remover --production

# 部署
echo "🚀 部署到 Cloudflare Pages..."
wrangler pages deploy public --project-name ai-background-remover

echo "✅ 部署完成！"
echo "🌐 您的应用已部署到: https://ai-background-remover.pages.dev"
echo "📊 查看部署状态: https://dash.cloudflare.com/pages"