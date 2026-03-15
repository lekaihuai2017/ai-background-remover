/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'export',
  images: {
    unoptimized: true,
  },
  trailingSlash: true,
  // 增加内存限制
  webpack: (config, { isServer }) => {
    config.optimization.minimize = isServer;
    return config;
  },
};

export default nextConfig;