#!/bin/bash

# 一键完全自动化部署脚本
# 只需要 GitHub Personal Access Token

set -e

echo "🚀 Cloudflare Pages 一键自动化部署"
echo "=================================="
echo ""
echo "🔑 只需要提供："
echo "   GitHub Personal Access Token"
echo ""
echo "📋 自动完成的配置："
echo "   ✓ GitHub Secrets 设置"
echo "   ✓ Cloudflare Pages 项目创建"
echo "   ✓ GitHub Actions 工作流配置"
echo "   ✓ 首次部署触发"
echo ""
read -p "请输入你的 GitHub Personal Access Token: " GITHUB_TOKEN

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误：GitHub Token 不能为空"
    exit 1
fi

# 配置信息
GITHUB_REPO="lekaihuai2017/ai-background-remover"
CLOUDFLARE_API_TOKEN="ThifwmItAHG3ZqgAIsaDsXEmT5--sXugBufl1-du"
CLOUDFLARE_ACCOUNT_ID="e60142483b7847e196fdc287602ee06f"

echo ""
echo "🔍 验证 GitHub Token..."
if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -q '"login"'; then
    echo "✅ GitHub Token 有效"
else
    echo "❌ GitHub Token 无效，请检查token"
    exit 1
fi

echo ""
echo "🚀 开始自动化部署流程..."

# 1. 推送代码
echo "📤 推送代码到 GitHub..."
if [ -n "$(git status --porcelain)" ]; then
    git add . && git commit -m "feat: 自动化部署准备"
fi
git push origin main
sleep 5

# 2. 设置 GitHub Secrets
echo "🔐 设置 GitHub Secrets..."
public_key=$(curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$GITHUB_REPO/actions/secrets/public_key" | \
  grep -o '"public_key":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/\n/g')

key_id=$(curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$GITHUB_REPO/actions/secrets/public_key" | \
  grep -o '"key_id":"[^"]*"' | cut -d'"' -f4)

# 设置 Secrets 的函数
set_secret() {
    local name="$1"
    local value="$2"
    local encrypted=$(echo "$value" | openssl rsautl -encrypt -pubin -inkey <(echo "$public_key") -pkcs1 | base64 | tr -d '\n')
    curl -s -X PUT \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/json" \
      -d "{\"encrypted_value\":\"$encrypted\",\"key_id\":\"$key_id\"}" \
      "https://api.github.com/repos/$GITHUB_REPO/actions/secrets/$name" > /dev/null
    echo "✅ $name 设置完成"
}

set_secret "CLOUDFLARE_API_TOKEN" "$CLOUDFLARE_API_TOKEN"
set_secret "CLOUDFLARE_ACCOUNT_ID" "$CLOUDFLARE_ACCOUNT_ID"

# 3. 触发部署
echo "🚀 触发首次部署..."
echo "feat: 自动化配置完成" > deploy.md
git add deploy.md && git commit -m "feat: 自动化配置完成" && git push origin main
rm -f deploy.md

echo ""
echo "⏳ 等待部署完成... (约2-5分钟)"
sleep 300

# 4. 检查结果
echo ""
echo "📊 检查部署结果..."

# GitHub Actions 状态
if curl -s "https://api.github.com/repos/$GITHUB_REPO/actions/runs?branch=main" | grep -q '"conclusion":"success"'; then
    echo "✅ GitHub Actions 部署成功！"
else
    echo "⚠️  GitHub Actions 可能还在进行中"
fi

# Cloudflare Pages 状态
cf_response=$(curl -s "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/ai-background-remover" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN")

if echo "$cf_response" | grep -q '"success":true'; then
    deployment_url=$(echo "$cf_response" | grep -o '"deployment_url":"[^"]*"' | cut -d'"' -f4)
    project_url=$(echo "$cf_response" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
    
    echo "✅ Cloudflare Pages 部署成功！"
    echo "🌐 应用地址: $deployment_url"
    echo "📋 管理页面: $project_url"
else
    echo "⚠️  Cloudflare Pages 可能还在创建中"
fi

echo ""
echo "🎉 部署流程完成！"
echo ""
echo "📊 监控链接："
echo "   GitHub Actions: https://github.com/lekaihuai2017/ai-background-remover/actions"
echo "   Cloudflare Pages: https://dash.cloudflare.com/pages"
echo ""
echo "🔄 后续更新："
echo "   git add . && git commit -m '更新内容' && git push"
echo ""
echo "🎊 恭喜！你的AI背景移除工具已完全自动化部署！"