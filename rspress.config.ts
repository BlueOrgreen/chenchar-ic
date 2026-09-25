import * as path from 'node:path';
import { defineConfig, type Plugin } from '@rspress/core';
import { CopyRspackPlugin } from '@rspack/core';

// 把 docs/tcl/*.tcl 拷到产物 /tcl/ 下，页面里的 .tcl 链接（/tcl/xxx.tcl）即可下载。
const copyTclPlugin: Plugin = {
  name: 'copy-tcl-scripts',
  builderConfig: {
    tools: {
      rspack: (config) => {
        config.plugins = config.plugins || [];
        config.plugins.push(
          new CopyRspackPlugin({
            patterns: [
              {
                from: path.join(__dirname, 'docs/tcl/*.tcl'),
                to: 'tcl/[name][ext]',
              },
            ],
          }),
        );
      },
    },
  },
};

export default defineConfig({
  root: path.join(__dirname, 'docs'),
  lang: 'zh',
  title: 'chenchar-ic',
  description: '芯片领域个人知识站：博客与体系化笔记',
  icon: '/rspress-icon.png',
  logo: {
    light: '/rspress-icon.png',
    dark: '/rspress-icon.png',
  },
  logoText: 'chenchar-ic',
  siteOrigin: 'https://www.ic.chenchar.com',
  route: {
    exclude: ['superpowers/**/*'],
  },
  // 页面里的 .tcl 链接是下载文件（由 copyTclPlugin 提供在 /tcl/ 下），
  // 不是页面路由，因此从死链检查中排除。
  markdown: {
    link: {
      checkDeadLinks: {
        excludes: (url: string) => url.endsWith('.tcl'),
      },
    },
  },
  plugins: [copyTclPlugin],
  themeConfig: {
    socialLinks: [],
    outlineTitle: '本页目录',
    prevPageText: '上一页',
    nextPageText: '下一页',
    searchPlaceholderText: '搜索文档',
    searchNoResultsText: '未找到相关结果',
    searchSuggestedQueryText: '可尝试其他关键词',
  },
});
