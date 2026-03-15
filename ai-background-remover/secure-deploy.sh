#!/bin/bash

# AI Background Remover - Cloudflare Pages 安全部署脚本
# 使用环境变量传递敏感信息，不硬编码在脚本中

set -e

echo "🚀 AI Background Remover - Cloudflare Pages 安全部署"
echo "=================================================="
echo ""

# 从环境变量获取配置
GITHUB_TOKEN="${GITHUB_TOKEN}"
GITHUB_REPO="lekaihuai2017/ai-background-remover"
CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN}"
CLOUDFLARE_ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID}"

# 检查必要的环境变量
if [ -z "$GITHUB_TOKEN" ] || [ -z "$CLOUDFLARE_API_TOKEN" ] || [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
    echo "❌ 错误：请设置必要的环境变量"
    echo "   export GITHUB_TOKEN='your_github_token'"
    echo "   export CLOUDFLARE_API_TOKEN='your_cloudflare_token'"
    echo "   export CLOUDFLARE_ACCOUNT_ID='your_cloudflare_account_id'"
    exit 1
fi

echo "🔧 配置信息："
echo "   GitHub Token: ${GITHUB_TOKEN:0:10}..."
echo "   GitHub Repo: $GITHUB_REPO"
echo "   Cloudflare API Token: ${CLOUDFLARE_API_TOKEN:0:10}..."
echo "   Cloudflare Account ID: $CLOUDFLARE_ACCOUNT_ID"
echo ""

# 1. 验证 GitHub Token
echo "🔍 验证 GitHub Token..."
token_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
if echo "$token_response" | grep -q '"login"'; then
    username=$(echo "$token_response" | grep -o '"login":"[^"]*"' | cut -d'"' -f4)
    echo "✅ GitHub Token 有效 (用户: $username)"
else
    echo "❌ GitHub Token 无效，请检查token"
    exit 1
fi

# 2. 检查当前状态
echo ""
echo "📁 检查项目状态..."
if [ ! -f "package.json" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 3. 检查Git状态
echo "🔍 检查Git状态..."
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  有未提交的更改，正在添加..."
    git add .
    git commit -m "feat: 自动化部署准备"
    echo "✅ 更新已提交"
fi

# 4. 推送代码到GitHub
echo ""
echo "📤 推送代码到GitHub..."
git push origin main
echo "✅ 代码已推送"

# 5. 等待GitHub Actions启动
echo ""
echo "⏳ 等待GitHub Actions启动..."
sleep 10

# 6. 获取GitHub Public Key
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

# 7. 加密并设置GitHub Secrets
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

# 8. 创建提交触发部署
echo ""
echo "🔄 创建提交触发部署..."
echo "feat: 自动化配置完成" > deploy-trigger.md
git add deploy-trigger.md
git commit -m "feat: 自动化配置完成"
git push origin main

# 9. 等待部署完成
echo ""
echo "⏳ 等待部署完成..."
echo "预计需要2-5分钟..."

# 10. 监控部署状态
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    echo "检查部署状态... ($attempt/$max_attempts)"
    
    # 检查GitHub Actions状态
    actions_response=$(curl -s \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$GITHUB_REPO/actions/runs?branch=main")
    
    if echo "$actions_response" | grep -q '"conclusion":"success"'; then
        echo "✅ 部署成功！"
        break
    elif echo "$actions_response" | grep -q '"conclusion":"failure"'; then
        echo "❌ 部署失败，请检查 GitHub Actions"
        break
    fi
    
    sleep 30
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "⏰ 部署检查超时，请手动检查 GitHub Actions 状态"
fi

echo ""
echo "🎉 部署流程完成！"
echo ""
echo "📊 监控链接："
echo "   GitHub Actions: https://github.com/lekaihuai2017/ai-background-remover/actions"
echo "   Cloudflare Pages: https://dash.cloudflare.com/pages"
echo ""
echo "🚀 预计访问地址："
echo "   生产环境: https://ai-background-remover.你的域名.pages.dev"
echo "   预览环境: https://ai-background-remover-xxx.pages.dev"
echo ""
echo "🔄 后续更新："
echo "   每次只需 git push 即可自动部署"