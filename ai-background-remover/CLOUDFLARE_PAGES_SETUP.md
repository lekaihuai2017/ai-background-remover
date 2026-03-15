# Cloudflare Pages 原生 GitHub 集成配置指南

## 🎯 配置完成状态

✅ **GitHub仓库**: `https://github.com/lekaihuai2017/ai-background-remover`  
✅ **代码已推送**: 所有文件已推送到main分支  
✅ **GitHub Actions**: 已优化工作流配置  
⏳ **GitHub Secrets**: 需要手动设置  
⏳ **Cloudflare Pages**: 需要创建项目  

## 🔑 GitHub Secrets 设置指南

### 方法1: GitHub Web界面（推荐）

1. 打开仓库: `https://github.com/lekaihuai2017/ai-background-remover`
2. 进入 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **"New repository secret"**

#### 创建以下两个secrets:

**Secret 1: CLOUDFLARE_API_TOKEN**
- **Name**: `CLOUDFLARE_API_TOKEN`
- **Secret**: `ThifwmItAHG3ZqgAIsaDsXEmT5--sXugBufl1-du`

**Secret 2: CLOUDFLARE_ACCOUNT_ID**
- **Name**: `CLOUDFLARE_ACCOUNT_ID`
- **Secret**: `e60142483b7847e196fdc287602ee06f`

### 方法2: GitHub CLI（可选）

```bash
# 设置CLOUDFLARE_API_TOKEN
gh secret set CLOUDFLARE_API_TOKEN --body "ThifwmItAHG3ZqgAIsaDsXEmT5--sXugBufl1-du"

# 设置CLOUDFLARE_ACCOUNT_ID
gh secret set CLOUDFLARE_ACCOUNT_ID --body "e60142483b7847e196fdc287602ee06f"
```

## 🌐 Cloudflare Pages 配置步骤

### 1. 登录 Cloudflare Dashboard
访问: [https://dash.cloudflare.com/](https://dash.cloudflare.com/)

### 2. 创建 Pages 项目
1. 进入 **Pages** → **Create project**
2. 选择 **"Connect to Git"**
3. 选择你的GitHub仓库: `ai-background-remover`

### 3. 配置项目设置
- **Project name**: `ai-background-remover`
- **Framework preset**: **Next.js**
- **Build command**: `npm run build`
- **Build output directory**: `out`
- **Root directory**: `/`

### 4. 配置环境变量（可选）
如果需要环境变量，在项目设置中添加：
- 例如: `API_KEY`, `DATABASE_URL` 等

### 5. 部署设置
- **Environment**: Production
- **Branch**: `main`
- **Preview deployments**: 启用（推荐）

## 🔄 自动化流程说明

### GitHub Actions 工作流
`.github/workflows/deploy.yml` 已配置：

1. **触发条件**:
   - 推送到 `main` 或 `develop` 分支
   - 创建针对 `main` 分支的 PR

2. **执行步骤**:
   - 检出代码
   - 设置 Node.js 环境
   - 安装依赖
   - 运行测试
   - 构建项目
   - 部署到 Cloudflare Pages
   - 上传部署状态

### 部署流程
```
git commit → git push → GitHub Actions → Cloudflare Pages → 部署完成
```

## 📊 监控和调试

### 1. GitHub Actions 检查
- 访问仓库: `https://github.com/lekaihuai2017/ai-background-remover/actions`
- 查看部署日志和状态

### 2. Cloudflare Pages 检查
- 访问 Cloudflare Dashboard → Pages
- 查看部署历史和状态

### 3. 常见问题排查

#### 问题1: 部署失败
- 检查 GitHub Secrets 是否正确设置
- 确认 Cloudflare API Token 权限
- 查看 GitHub Actions 日志

#### 问题2: 构建失败
- 检查 `package.json` 中的构建命令
- 确认依赖项正确安装
- 检查 `next.config.ts` 配置

#### 问题3: 静态资源路径问题
- 检查 `next.config.ts` 中的 `output` 配置
- 确认 `public` 目录结构正确

## 🚀 首次部署

完成上述配置后，首次部署将自动触发：

1. 等待 GitHub Actions 完成构建
2. 部署到 Cloudflare Pages
3. 生成预览链接（PR时）
4. 生成生产环境链接

## 📝 部署链接

配置完成后，你的应用将部署到：
- **生产环境**: `https://ai-background-remover.你的域名.pages.dev`
- **预览环境**: `https://ai-background-remover-xxx.pages.dev` (每次PR时)

## 🔧 后续维护

### 更新代码
```bash
cd ai-background-remover
git add .
git commit -m "你的提交信息"
git push
```

### 查看部署状态
- GitHub Actions: `https://github.com/lekaihuai2017/ai-background-remover/actions`
- Cloudflare Pages: `https://dash.cloudflare.com/pages`

### 环境变量管理
- 在 Cloudflare Pages 项目设置中添加/更新环境变量
- 重新部署以应用更改

---

## 🎉 完成检查清单

- [x] GitHub 仓库创建
- [x] 代码推送完成
- [x] GitHub Actions 工作流配置
- [ ] GitHub Secrets 设置
- [ ] Cloudflare Pages 项目创建
- [ ] 首次部署测试
- [ ] 预览环境验证

完成所有步骤后，你的 AI 背景移除工具将实现完全自动化的 CI/CD 流程！