const { createServer } = require('http');
const { parse } = require('url');
const next = require('next');

const dev = process.env.NODE_ENV !== 'production';
const hostname = '0.0.0.0';  // 监听所有接口
const port = process.env.PORT || 3000;

// 开发环境或生产环境
const app = next({ dev, hostname, port });
const handle = app.getRequestHandler();

app.prepare().then(() => {
  createServer(async (req, res) => {
    const parsedUrl = parse(req.url, true);
    await handle(req, res, parsedUrl);
  }).listen(port, '0.0.0.0', (err) => {  // 添加 '0.0.0.0' 监听所有接口
    if (err) throw err;
    console.log(`> Ready on http://0.0.0.0:${port}`);
    console.log(`> External access: http://43.128.96.249:${port}`);
    console.log(`> Local development: http://localhost:${port}`);
  });
});