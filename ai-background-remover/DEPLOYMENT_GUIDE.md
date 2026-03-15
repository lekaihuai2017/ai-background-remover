# Cloudflare Pages 完整部署指南

## 🎯 部署状态

✅ **GitHub仓库**: `https://github.com/lekaihuai2017/ai-background-remover`  
✅ **项目配置**: 已更新为静态导出模式  
✅ **GitHub Actions**: 已配置自动化部署  
✅ **构建测试**: 已验证成功  
⏳ **GitHub Secrets**: 需要设置  
⏳ **Cloudflare Pages**: 需要创建项目  

## 🔧 完整配置步骤

### 1. 设置 GitHub Secrets

#### 方法1: GitHub Web界面（推荐）

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

### 2. 创建 Cloudflare Pages 项目

#### 步骤1: 登录 Cloudflare Dashboard
访问: [https://dash.cloudflare.com/](https://dash.cloudflare.com/)

#### 步骤2: 进入 Pages
1. 左侧菜单选择 **Pages**
2. 点击 **"Create project"**

#### 步骤3: 连接 GitHub
1. 选择 **"Connect to Git"**
2. 选择你的GitHub仓库: `ai-background-remover`

#### 步骤4: 配置项目设置
- **Project name**: `ai-background-remover`
- **Framework preset**: **Next.js**
- **Build command**: `npm run build`
- **Build output directory**: `out`
- **Root directory**: `/`

#### 步骤5: 配置环境变量（可选）
如果需要环境变量，在 **Environment variables** 部分添加：
- 例如: `API_KEY`, `DATABASE_URL` 等

#### 步骤6: 部署设置
- **Environment**: Production
- **Branch**: `main`
- **Preview deployments**: 启用（推荐）

### 3. 验证部署

#### 检查 GitHub Actions
1. 访问仓库: `https://github.com/lekaihuai2017/ai-background-remover/actions`
2. 等待自动部署触发
3. 查看部署日志

#### 检查 Cloudflare Pages
1. 访问 Cloudflare Dashboard → Pages
2. 查看项目状态
3. 获取部署链接

## 🚀 自动化部署流程

### 触发条件
- **主分支推送**: 推送到 `main` 分支时自动部署到生产环境
- **PR创建**: 创建针对 `main` 分支的 PR 时自动创建预览环境
- **PR更新**: 更新 PR 时自动更新预览环境

### 部署步骤
```
git commit → git push → GitHub Actions → Cloudflare Pages → 部署完成
```

## 📋 预期部署链接

配置完成后，你的应用将部署到：
- **生产环境**: `https://ai-background-remover.你的域名.pages.dev`
- **预览环境**: `https://ai-background-remover-xxx.pages.dev` (每次PR时)

## 🔍 监控和调试

### 1. GitHub Actions 监控
- 访问: `https://github.com/lekaihuai2017/ai-background-remover/actions`
- 查看构建和部署日志
- 检查错误信息

### 2. Cloudflare Pages 监控
- 访问: `https://dash.cloudflare.com/pages`
- 查看部署历史
- 检查构建日志
- 查看性能指标

### 3. 常见问题排查

#### 问题1: 构建失败
- 检查 `package.json` 中的构建命令
- 确认依赖项正确安装
- 查看 GitHub Actions 日志

#### 问题2: 部署失败
- 检查 GitHub Secrets 是否正确设置
- 确认 Cloudflare API Token 权限
- 查看 Cloudflare Pages 日志

#### 问题3: 静态资源路径问题
- 检查 `next.config.ts` 中的 `output` 配置
- 确认 `out` 目录结构正确
- 验证静态资源路径

## 📝 项目配置文件

### next.config.ts
```typescript
const nextConfig = {
  output: 'export', // 静态导出
  trailingSlash: true,
  skipTrailingSlashRedirect: true,
  // ...其他配置
};
```

### cloudflare-pages.json
```json
{
  "buildCommand": "npm run build",
  "outputDirectory": "out",
  "framework": {
    "name": "next",
    "version": "16.1.6"
  }
}
```

### .github/workflows/deploy.yml
```yaml
- name: Deploy to Cloudflare Pages
  uses: cloudflare/pages-action@v4
  with:
    apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    projectName: ai-background-remover
    directory: out
    gitHubToken: ${{ secrets.GITHUB_TOKEN }}
    branch: main
```

## 🔄 后续维护

### 更新代码
```bash
cd ai-background-remover
git add .
git commit -m "你的提交信息"
git push  # 自动触发部署
```

### 环境变量管理
- 在 Cloudflare Pages 项目设置中添加/更新环境变量
- 重新部署以应用更改

### 性能优化
- 启用 Cloudflare CDN
- 配置缓存策略
- 压缩静态资源

---

## 🎉 完成检查清单

- [x] GitHub 仓库创建
- [x] 代码推送完成
- [x] Next.js 配置更新（静态导出）
- [x] GitHub Actions 工作流配置
- [x] GitHub Secrets 设置指南
- [x] Cloudflare Pages 配置文件
- [x] 部署文档创建
- [ ] GitHub Secrets 手动设置
- [ ] Cloudflare Pages 项目创建
- [ ] 首次部署测试
- [ ] 预览环境验证

完成所有步骤后，你的 AI 背景移除工具将实现完全自动化的 CI/CD 流程！