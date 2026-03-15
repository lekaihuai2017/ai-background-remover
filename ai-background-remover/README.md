# AI Background Remover - Cloudflare Pages 版本

一个基于 Cloudflare Pages Functions 的 AI 背景移除工具，提供全球 CDN 加速和 Serverless 架构。

## 🚀 功能特性

- **AI 背景移除**: 使用人工智能技术自动移除图片背景
- **全球 CDN**: 基于 Cloudflare Pages 的全球网络加速
- **Serverless 架构**: 无需管理服务器，自动扩缩容
- **响应式设计**: 适配桌面和移动设备
- **实时处理**: 支持图片上传和实时预览

## 📦 项目结构

```
ai-background-remover/
├── public/                 # 静态资源
├── functions/              # Cloudflare Pages Functions
│   └── api/
│       ├── health.js      # 健康检查接口
│       └── remove-background.js  # 背景移除接口
├── src/
│   ├── app/
│   │   └── page.tsx       # 主页面
│   └── components/
│       └── BackgroundRemover.tsx  # 主要组件
├── package.json           # 项目依赖
├── wrangler.toml          # Cloudflare 配置
└── next.config.ts         # Next.js 配置
```

## 🛠️ 安装和部署

### 1. 安装依赖

```bash
npm install
```

### 2. 配置环境变量

创建 `.env.local` 文件：

```bash
# AI 服务配置
AI_API_KEY=your_ai_api_key
AI_ENDPOINT=https://api.ai-service.com/v1
```

### 3. 本地开发

```bash
# 安装 wrangler
npm install -g wrangler

# 登录 Cloudflare
wrangler login

# 本地开发
npm run dev
```

### 4. 部署到 Cloudflare Pages

```bash
# 构建项目
npm run build

# 部署
npm run deploy
```

## 🔧 配置说明

### wrangler.toml

```toml
name = "ai-background-remover"
compatibility_date = "2024-01-01"

[env.production]
vars = { ENVIRONMENT = "production" }

[env.staging]
vars = { ENVIRONMENT = "staging" }

[build]
command = "npm run build"
watch_dir = "src"

[assets]
directory = "public"
```

### API 端点

- `GET /api/health` - 健康检查
- `POST /api/remove-background` - 背景移除

## 🎯 使用说明

1. **上传图片**: 点击"选择图片"按钮上传要处理的图片
2. **处理图片**: 点击"移除背景"按钮开始处理
3. **查看结果**: 处理完成后查看结果和详细信息

## 🌐 环境支持

- **开发环境**: 本地开发服务器
- **生产环境**: Cloudflare Pages Functions
- **预览环境**: Cloudflare Pages 预览部署

## 📊 性能优化

- **CDN 加速**: 全球节点缓存静态资源
- **图片压缩**: 自动优化上传和处理后的图片
- **缓存策略**: 智能缓存减少重复计算

## 🔒 安全考虑

- **文件验证**: 严格验证上传文件类型和大小
- **API 限流**: 防止滥用和恶意请求
- **数据加密**: 敏感数据加密存储

## 🚨 故障排除

### 常见问题

1. **部署失败**: 检查 Cloudflare 账户权限
2. **AI 服务错误**: 验证 API 密钥和网络连接
3. **图片处理超时**: 检查图片大小和复杂度

### 调试模式

```bash
# 启用详细日志
wrangler dev --verbose
```

## 📈 监控和分析

- **性能监控**: Cloudflare Analytics
- **错误追踪**: Sentry 集成
- **使用统计**: Cloudflare Metrics

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 创建 Pull Request

## 📄 许可证

MIT License

## 📞 支持

- [Cloudflare 文档](https://developers.cloudflare.com/pages/)
- [Next.js 文档](https://nextjs.org/docs)
- [项目 Issues](https://github.com/your-repo/issues)