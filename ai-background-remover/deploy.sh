#!/bin/bash

# AI Background Remover 自动化部署脚本
# 用于快速设置和部署到 Cloudflare Pages

set -e

echo "🚀 开始 Cloudflare Pages 自动化部署..."

# 检查必要工具
echo "📋 检查必要工具..."
command -v git >/dev/null 2>&1 || { echo "❌ Git 未安装"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm 未安装"; exit 1; }

# 检查当前目录
if [ ! -f "package.json" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

# 检查 Git 状态
echo "📁 检查 Git 状态..."
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  有未提交的更改，正在添加..."
    git add .
    git commit -m "feat: 自动化部署更新"
    echo "✅ 更新已提交"
fi

# 推送代码到 GitHub
echo "📤 推送代码到 GitHub..."
git push origin main
echo "✅ 代码已推送"

# 检查 GitHub Actions
echo "🔄 检查 GitHub Actions 状态..."
sleep 5  # 等待 Actions 启动

# 获取最新的 commit hash
COMMIT_HASH=$(git rev-parse HEAD)
echo "🔍 最新提交: $COMMIT_HASH"

echo ""
echo "🎉 部署流程已启动！"
echo ""
echo "📊 监控部署状态:"
echo "   GitHub Actions: https://github.com/lekaihuai2017/ai-background-remover/actions"
echo "   Cloudflare Pages: https://dash.cloudflare.com/pages"
echo ""
echo "⏱️  预计部署时间: 2-5 分钟"
echo ""
echo "🔑 如果遇到部署错误，请检查:"
echo "   1. GitHub Secrets 是否正确设置"
echo "   2. Cloudflare API Token 权限"
echo "   3. 构建日志中的错误信息"
echo ""
echo "📖 详细部署指南请查看: DEPLOYMENT_GUIDE.md"

# 可选：等待部署完成
read -p "是否等待部署完成？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⏳ 等待部署完成..."
    sleep 120  # 等待2分钟
    
    # 检查部署状态
    if curl -s "https://api.github.com/repos/lekaihuai2017/ai-background-remover/actions/runs?branch=main" | grep -q '"conclusion":"success"'; then
        echo "✅ 部署成功！"
    else
        echo "❌ 部署可能失败，请检查 GitHub Actions"
    fi
fi

echo "🎯 部署完成！访问你的应用: https://ai-background-remover.你的域名.pages.dev"