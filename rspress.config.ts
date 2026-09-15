import * as path from 'node:path';
import { defineConfig } from '@rspress/core';

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
