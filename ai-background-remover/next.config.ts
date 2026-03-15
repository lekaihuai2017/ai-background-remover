/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  // 启用实验性功能以支持Pages Functions
  serverExternalPackages: [],
  images: {
    // 配置图像域名
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '**',
      },
    ],
    unoptimized: false,
  },
  // 重定向配置
  async redirects() {
    return [
      {
        source: '/old-path',
        destination: '/new-path',
        permanent: true,
      },
    ];
  },
  // 重写配置
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: '/functions/api/:path*',
      },
    ];
  },
  // 优化Cloudflare Pages部署
  trailingSlash: true,
  skipTrailingSlashRedirect: true,
};

export default nextConfig;