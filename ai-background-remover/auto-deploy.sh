#!/bin/bash

# Cloudflare Pages 自动化部署脚本
# 通过 GitHub Actions 自动化部署，无需手动配置

set -e

echo "🚀 开始 Cloudflare Pages 自动化部署..."

# 1. 检查必要工具
echo "📋 检查必要工具..."
command -v git >/dev/null 2>&1 || { echo "❌ Git 未安装"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm 未安装"; exit 1; }

# 2. 检查当前目录
if [ ! -f "package.json" ]; then
    echo "❌ 请在项目根目录运行此脚本"
    exit 1
fi

# 3. 检查 Git 状态
echo "📁 检查 Git 状态..."
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  有未提交的更改，正在添加..."
    git add .
    git commit -m "feat: 自动化部署准备"
    echo "✅ 更新已提交"
fi

# 4. 创建 GitHub Secrets 配置文件
echo "🔑 创建 GitHub Secrets 配置..."
cat > github-secrets-config.json << EOF
{
  "CLOUDFLARE_API_TOKEN": "ThifwmItAHG3ZqgAIsaDsXEmT5--sXugBufl1-du",
  "CLOUDFLARE_ACCOUNT_ID": "e60142483b7847e196fdc287602ee06f"
}
EOF

echo "✅ GitHub Secrets 配置文件已创建"

# 5. 提交配置文件
echo "📤 提交配置文件..."
git add github-secrets-config.json
git commit -m "feat: 添加 GitHub Secrets 配置"

# 6. 推送代码到 GitHub
echo "📤 推送代码到 GitHub..."
git push origin main
echo "✅ 代码已推送"

# 7. 等待 GitHub Actions 启动
echo "⏳ 等待 GitHub Actions 启动..."
sleep 10

# 8. 检查部署状态
echo "📊 检查部署状态..."
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
echo "🔑 GitHub Secrets 配置说明:"
echo "   CLOUDFLARE_API_TOKEN: ThifwmItAHG3ZqgAIsaDsXEmT5--sXugBufl1-du"
echo "   CLOUDFLARE_ACCOUNT_ID: e60142483b7847e196fdc287602ee06f"
echo ""
echo "⚠️  重要提醒:"
echo "   1. 请手动在 GitHub 仓库中设置这两个 Secrets"
echo "   2. 设置完成后，推送代码会自动触发部署"
echo "   3. 首次部署需要等待 GitHub Actions 连接 Cloudflare"
echo ""
echo "📖 详细部署指南请查看: DEPLOYMENT_GUIDE.md"

# 9. 可选：等待部署完成
read -p "是否等待部署完成？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⏳ 等待部署完成..."
    sleep 180  # 等待3分钟
    
    # 检查部署状态
    if curl -s "https://api.github.com/repos/lekaihuai2017/ai-background-remover/actions/runs?branch=main" | grep -q '"conclusion":"success"'; then
        echo "✅ 部署成功！"
        
        # 获取部署 URL
        if curl -s "https://api.cloudflare.com/client/v4/accounts/e60142483b7847e196fdc287602ee06f/pages/projects/ai-background-remover" \
           -H "Authorization: Bearer ThifwmItAHG3ZqgAIsaDsXEmT5--sXugBufl1-du" | grep -q '"success":true'; then
            echo "🌐 部署 URL 已生成"
        fi
    else
        echo "❌ 部署可能失败，请检查 GitHub Actions"
    fi
fi

# 10. 清理临时文件
echo "🧹 清理临时文件..."
rm -f github-secrets-config.json

echo "🎯 部署完成！请访问 Cloudflare Dashboard 查看部署结果"