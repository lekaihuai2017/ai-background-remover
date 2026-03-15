#!/bin/bash

# Cloudflare API 自动化部署脚本
# 通过 API 直接创建项目和部署，无需手动配置

set -e

# Cloudflare API 配置
CLOUDFLARE_API_TOKEN="ThifwmItAHG3ZqgAIsaDsXEmT5--sXugBufl1-du"
CLOUDFLARE_ACCOUNT_ID="e60142483b7847e196fdc287602ee06f"
GITHUB_REPO="lekaihuai2017/ai-background-remover"
PROJECT_NAME="ai-background-remover"

# API 端点
BASE_URL="https://api.cloudflare.com/client/v4"

echo "🚀 开始 Cloudflare API 自动化部署..."

# 1. 检查 API Token 有效性
echo "🔍 检查 API Token 有效性..."
response=$(curl -s -X GET "$BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

if echo "$response" | grep -q '"success":true'; then
    echo "✅ API Token 有效"
else
    echo "❌ API Token 无效，请检查 Token"
    exit 1
fi

# 2. 检查是否已存在 Pages 项目
echo "📁 检查 Pages 项目是否存在..."
project_response=$(curl -s -X GET "$BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_NAME" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

if echo "$project_response" | grep -q '"success":true'; then
    echo "✅ Pages 项目已存在"
    PROJECT_ID=$(echo "$project_response" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    echo "📋 项目 ID: $PROJECT_ID"
else
    echo "🆕 创建新的 Pages 项目..."
    
    # 创建 Pages 项目
    create_response=$(curl -s -X POST "$BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "'"$PROJECT_NAME"'",
        "production_branch": "main",
        "source": {
          "type": "github",
          "config": {
            "owner": "'"$GITHUB_REPO"'",
            "repo_name": "'"$PROJECT_NAME"'",
            "production_branch": "main"
          }
        },
        "build_config": {
          "build_command": "npm run build",
          "destination_dir": "out",
          "root_dir": "/",
          "framework": {
            "name": "next",
            "version": "16.1.6"
          }
        }
      }')
    
    if echo "$create_response" | grep -q '"success":true'; then
        echo "✅ Pages 项目创建成功"
        PROJECT_ID=$(echo "$create_response" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
        echo "📋 项目 ID: $PROJECT_ID"
        
        # 获取项目 URL
        project_url=$(echo "$create_response" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
        echo "🌐 项目 URL: $project_url"
    else
        echo "❌ 创建项目失败"
        echo "错误信息: $create_response"
        exit 1
    fi
fi

# 3. 设置环境变量（如果需要）
echo "🔧 设置环境变量..."
env_vars='[
  {"key": "NODE_ENV", "value": "production"},
  {"key": "NEXT_TELEMETRY_DISABLED", "value": "1"}
]'

env_response=$(curl -s -X PUT "$BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_ID/environment_variables" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"variables\": $env_vars}")

if echo "$env_response" | grep -q '"success":true'; then
    echo "✅ 环境变量设置成功"
else
    echo "⚠️  环境变量设置可能失败，但不影响部署"
fi

# 4. 手动触发部署
echo "🚀 触发部署..."
deploy_response=$(curl -s -X POST "$BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_ID/deployments" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

if echo "$deploy_response" | grep -q '"success":true'; then
    echo "✅ 部署已启动"
    DEPLOY_ID=$(echo "$deploy_response" | grep -o '"id":"[^"]*"' | cut -d'"' -f4)
    echo "📋 部署 ID: $DEPLOY_ID"
else
    echo "❌ 触发部署失败"
    echo "错误信息: $deploy_response"
    exit 1
fi

# 5. 监控部署状态
echo "📊 监控部署状态..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    status_response=$(curl -s -X GET "$BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_ID/deployments/$DEPLOY_ID" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      -H "Content-Type: application/json")
    
    status=$(echo "$status_response" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    
    case $status in
        "success")
            echo "✅ 部署成功！"
            break
            ;;
        "failed")
            echo "❌ 部署失败！"
            echo "错误详情: $status_response"
            exit 1
            ;;
        "queued"|"running")
            echo "⏳ 部署进行中... ($((attempt + 1))/$max_attempts)"
            sleep 10
            ;;
        *)
            echo "⚠️  未知状态: $status"
            sleep 10
            ;;
    esac
    
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ 部署超时，请手动检查状态"
    exit 1
fi

# 6. 获取最终部署信息
echo "📋 获取部署信息..."
final_response=$(curl -s -X GET "$BASE_URL/accounts/$CLOUDFLARE_ACCOUNT_ID/pages/projects/$PROJECT_ID" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json")

# 提取部署 URL
deployment_url=$(echo "$final_response" | grep -o '"deployment_url":"[^"]*"' | cut -d'"' -f4)
if [ -n "$deployment_url" ]; then
    echo "🎉 部署完成！"
    echo "🌐 访问地址: $deployment_url"
else
    echo "⚠️  无法获取部署 URL，请检查 Cloudflare Dashboard"
fi

echo ""
echo "📊 监控链接:"
echo "   Cloudflare Pages: https://dash.cloudflare.com/pages"
echo "   GitHub Actions: https://github.com/lekaihuai2017/ai-background-remover/actions"
echo ""
echo "🔄 后续更新:"
echo "   推送代码到 GitHub 即可自动部署"
echo "   git add . && git commit -m '更新内容' && git push"