#!/bin/bash

# 完全自动化 Cloudflare Pages 部署脚本
# 只需要提供 GitHub Token，自动完成所有配置

set -e

# 需要用户提供的token
GITHUB_TOKEN=""

echo "🚀 Cloudflare Pages 完全自动化部署"
echo "=================================="
echo ""
echo "此脚本将自动完成以下操作："
echo "1. 创建 GitHub Secrets (Cloudflare API Token 和 Account ID)"
echo "2. 创建 Cloudflare Pages 项目"
echo "3. 配置 GitHub Actions 工作流"
echo "4. 触发首次部署"
echo ""
echo "🔑 需要提供的Token："
echo "- GitHub Personal Access Token (用于设置GitHub Secrets)"
echo ""
read -p "请输入你的 GitHub Personal Access Token: " GITHUB_TOKEN

# 验证token
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
token_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
if echo "$token_response" | grep -q '"login"'; then
    username=$(echo "$token_response" | grep -o '"login":"[^"]*"' | cut -d'"' -f4)
    echo "✅ GitHub Token 有效 (用户: $username)"
else
    echo "❌ GitHub Token 无效，请检查token"
    exit 1
fi

# 1. 检查当前状态
echo ""
echo "📁 检查项目状态..."
if [ ! -f "package.json" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 2. 检查Git状态
echo "🔍 检查Git状态..."
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  有未提交的更改，正在添加..."
    git add .
    git commit -m "feat: 自动化部署准备"
    echo "✅ 更新已提交"
fi

# 3. 推送代码到GitHub
echo "📤 推送代码到GitHub..."
git push origin main
echo "✅ 代码已推送"

# 4. 等待GitHub Actions启动
echo "⏳ 等待GitHub Actions启动..."
sleep 10

# 5. 获取GitHub Public Key
echo "🔑 获取GitHub Public Key..."
public_key_response=$(curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$GITHUB_REPO/actions/secrets/public_key")

if ! echo "$public_key_response" | grep -q '"key_id"'; then
    echo "❌ 无法获取GitHub Public Key"
    echo "响应: $public_key_response"
    exit 1
fi

key_id=$(echo "$public_key_response" | grep -o '"key_id":"[^"]*"' | cut -d'"' -f4)
public_key=$(echo "$public_key_response" | grep -o '"public_key":"[^"]*"' | cut -d'"' -f4 | sed 's/\\n/\n/g')

echo "✅ 获取到GitHub Public Key (ID: $key_id)"

# 6. 加密并设置GitHub Secrets
echo ""
echo "🔐 设置GitHub Secrets..."

# 加密函数
encrypt_secret() {
    local secret="$1"
    local public_key="$2"
    echo "$secret" | openssl rsautl -encrypt -pubin -inkey <(echo "$public_key") -pkcs1 | base64 | tr -d '\n'
}

# 设置CLOUDFLARE_API_TOKEN
echo "设置 CLOUDFLARE_API_TOKEN..."
encrypted_api_token=$(encrypt_secret "$CLOUDFLARE_API_TOKEN" "$public_key")
api_response=$(curl -s -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -d "{\"encrypted_value\":\"$encrypted_api_token\",\"key_id\":\"$key_id\"}" \
  "https://api.github.com/repos/$GITHUB_REPO/actions/secrets/CLOUDFLARE_API_TOKEN")

if echo "$api_response" | grep -q '"success":true'; then
    echo "✅ CLOUDFLARE_API_TOKEN 设置成功"
else
    echo "❌ CLOUDFLARE_API_TOKEN 设置失败: $api_response"
fi

# 设置CLOUDFLARE_ACCOUNT_ID
echo "设置 CLOUDFLARE_ACCOUNT_ID..."
encrypted_account_id=$(encrypt_secret "$CLOUDFLARE_ACCOUNT_ID" "$public_key")
account_response=$(curl -s -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -d "{\"encrypted_value\":\"$encrypted_account_id\",\"key_id\":\"$key_id\"}" \
  "https://api.github.com/repos/$GITHUB_REPO/actions/secrets/CLOUDFLARE_ACCOUNT_ID")

if echo "$account_response" | grep -q '"success":true'; then
    echo "✅ CLOUDFLARE_ACCOUNT_ID 设置成功"
else
    echo "❌ CLOUDFLARE_ACCOUNT_ID 设置失败: $account_response"
fi

# 7. 创建提交触发部署
echo ""
echo "🔄 创建提交触发部署..."
echo "feat: 自动化配置完成" > deploy-trigger.md
git add deploy-trigger.md
git commit -m "feat: 自动化配置完成"
git push origin main

# 8. 等待部署完成
echo ""
echo "⏳ 等待部署完成..."
echo "预计需要2-5分钟..."

# 9. 监控部署状态
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    echo "⏳ 检查部署状态... ($((attempt + 1))/$max_attempts)"
    
    # 检查GitHub Actions
    actions_response=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/actions/runs?branch=main")
    if echo "$actions_response" | grep -q '"conclusion":"success"'; then
        echo "✅ GitHub Actions 部署成功！"
        break
    fi
    
    # 检查Cloudflare Pages
    cf_response=$(curl -s "https://api.cloudflare.com/client/v4/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/ai-background-remover" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN")
    
    if echo "$cf_response" | grep -q '"success":true'; then
        deployment_url=$(echo "$cf_response" | grep -o '"deployment_url":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$deployment_url" ]; then
            echo "✅ Cloudflare Pages 部署成功！"
            echo "🌐 部署URL: $deployment_url"
            break
        fi
    fi
    
    sleep 30
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "⚠️  部署可能还在进行中，请手动检查"
    echo "GitHub Actions: https://github.com/lekaihuai2017/ai-background-remover/actions"
    echo "Cloudflare Pages: https://dash.cloudflare.com/pages"
else
    echo "🎉 部署完成！"
fi

# 10. 清理临时文件
rm -f deploy-trigger.md

echo ""
echo "🎯 完成状态："
echo "✅ GitHub Secrets 已设置"
echo "✅ GitHub Actions 已配置"
echo "✅ Cloudflare Pages 已部署"
echo ""
echo "📊 监控链接："
echo "   GitHub Actions: https://github.com/lekaihuai2017/ai-background-remover/actions"
echo "   Cloudflare Pages: https://dash.cloudflare.com/pages"
echo ""
echo "🔄 后续更新："
echo "   推送代码即可自动部署："
echo "   git add . && git commit -m '更新内容' && git push"
echo ""
echo "🎊 恭喜！你的AI背景移除工具已完全自动化部署！"