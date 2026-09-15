# chenchar-ic Rspress 站点 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 初始化可 Docker 部署的「chenchar-ic」Rspress 混合站（博客 + 芯片知识库），域名约定 `https://www.ic.chenchar.com`。

**Architecture:** 用 `create-rspress`（`basic-theme`）脚手架到当前仓库；在 `docs/` 下组织首页、博客、知识库占位内容；多阶段 Docker（Node 构建 → nginx:alpine 托管 `doc_build`）；`docker-compose` 映射 `8080:80`，主机反代到 `www.ic.chenchar.com`。

**Tech Stack:** Rspress v2 (`@rspress/core`)、pnpm、Docker、nginx:alpine

**Spec:** `docs/superpowers/specs/2026-09-15-chenchar-ic-rspress-design.md`

## Global Constraints

- 站点名：chenchar-ic
- `siteOrigin`：`https://www.ic.chenchar.com`
- 内容语言：中文
- 路径：`/` 首页、`/blog/` 博客、`/guide/` 知识库
- 保留已有 `docs/superpowers/` 工程文档，不进入主导航
- 首发不做评论、登录、CI、主机 HTTPS

---

### Task 1: Scaffold Rspress

**Files:**
- Create via scaffold: `package.json`, `rspress.config.ts`, `tsconfig.json`, `theme/`, `docs/` baseline
- Preserve: `docs/superpowers/**`

- [x] **Step 1: Scaffold into current directory**

```bash
pnpm create rspress@latest . --template basic-theme --packageName chenchar-ic --no-git --override
pnpm install
```

Expected: project files present; `docs/superpowers` still exists.

- [x] **Step 2: Verify scripts exist**

`package.json` scripts: `dev`, `build`, `preview`.

---

### Task 2: Configure site + content IA

**Files:**
- Modify: `rspress.config.ts`
- Create/Modify: `docs/index.mdx`, `docs/blog/**`, `docs/guide/**`, nav/sidebar meta as needed
- Modify: `theme/` only if logo/title CSS needed

- [x] **Step 1: Set `rspress.config.ts`**

```ts
import { defineConfig } from '@rspress/core';

export default defineConfig({
  root: 'docs',
  title: 'chenchar-ic',
  description: '芯片领域个人知识站：博客与体系化笔记',
  icon: '/rspress-icon.png',
  logo: {
    light: '/rspress-light-logo.png',
    dark: '/rspress-dark-logo.png',
  },
  siteOrigin: 'https://www.ic.chenchar.com',
  themeConfig: {
    nav: [
      { text: '首页', link: '/' },
      { text: '博客', link: '/blog/' },
      { text: '芯片知识', link: '/guide/' },
    ],
    socialLinks: [],
  },
});
```

Adjust logo paths to whatever scaffold generated.

- [x] **Step 2: Home + blog + guide placeholder MDX**

Create short Chinese placeholder pages per spec (1 blog intro + 3 guide stubs). Wire sidebar for `/guide/`.

- [x] **Step 3: Local verify**

```bash
pnpm build
```

Expected: success, `doc_build/` generated.

---

### Task 3: Docker + README

**Files:**
- Create: `Dockerfile`, `nginx.conf`, `docker-compose.yml`, `.dockerignore`
- Create/Modify: `README.md`
- Modify: `.gitignore` if needed for `doc_build`, `node_modules`

- [x] **Step 1: Dockerfile multi-stage**

Builder: `node:22-alpine`, pnpm, `pnpm build`.  
Runtime: `nginx:alpine`, copy `doc_build` → `/usr/share/nginx/html`, use custom `nginx.conf` with SPA-ish try_files for static SSG.

- [x] **Step 2: compose + docs**

`docker-compose.yml` service `chenchar-ic`, ports `8080:80`.  
README: dev / build / docker / reverse-proxy notes for `www.ic.chenchar.com`.

- [x] **Step 3: Verify Docker**

```bash
docker compose build && docker compose up -d
curl -sI http://localhost:8080 | head
```

Expected: HTTP 200 from nginx serving the site.

---

## Self-review

- Spec coverage: scaffold, hybrid IA, Docker, domain, placeholders, README — covered.
- No CI/HTTPS host setup — intentionally out of scope.
