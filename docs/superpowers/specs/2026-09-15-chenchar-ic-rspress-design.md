# chenchar-ic 个人博客站点设计

**日期：** 2026-09-15  
**状态：** 已确认（域名更新为 www.ic.chenchar.com）  
**目标域名：** `https://www.ic.chenchar.com`（主域 `chenchar.com`）

## 1. 目标

搭建个人品牌站点 **chenchar-ic**，聚焦芯片领域知识分享。首发版本要求：

- 本地可开发、可构建
- 可通过 Docker 镜像在服务器部署
- 内容可为占位，结构可扩展

## 2. 产品形态

采用 **混合结构**：

| 区域 | 路径 | 作用 |
|------|------|------|
| 首页 | `/` | 品牌介绍、最新文章入口、知识库入口 |
| 博客 | `/blog/` | 短文 / 随笔列表与详情 |
| 芯片知识库 | `/guide/` | 体系化文档（左侧目录） |

语言：中文。首发放 1～2 篇博客占位 + 若干知识库占位章节。

## 3. 技术方案

### 3.1 站点框架

- **Rspress v2**（`@rspress/core`）
- 脚手架：`create-rspress`，模板 `basic-theme`（便于后续轻量主题定制）
- 包管理：`pnpm`（若环境无 pnpm 则用 npm）
- 配置要点：
  - `title` / `description`：chenchar-ic、芯片知识个人站
  - `siteOrigin`：`https://www.ic.chenchar.com`
  - 导航：首页、博客、芯片知识
  - 博客页使用 frontmatter（`title`、`date`、`description`）
  - 可选：`@rspress/plugin-rss`（首发可做可不做；推荐首发就加，成本低）

### 3.2 目录约定

```
/
├── docs/                    # Rspress 内容根目录
│   ├── index.mdx            # 首页
│   ├── blog/                # 博客文章
│   ├── guide/               # 芯片知识库
│   └── superpowers/         # 工程过程文档（不对导航暴露）
├── theme/                   # 轻量主题定制（basic-theme）
├── rspress.config.ts
├── Dockerfile               # 多阶段构建
├── docker-compose.yml
├── nginx.conf               # 容器内静态托管
└── README.md                # 本地开发与部署说明
```

说明：`docs/superpowers/` 仅作工程规格存放，不进入站点主导航与首页入口。

### 3.3 Docker 部署

多阶段构建：

1. **builder**：Node 20+，安装依赖，`rspress build`，产物目录 `doc_build`
2. **runtime**：`nginx:alpine`，拷贝 `doc_build` 与 `nginx.conf`

`docker-compose.yml`：

- 服务名：`chenchar-ic`
- 容器内 Nginx 监听 `80`
- 宿主机映射：默认 `8080:80`（可按服务器现有端口调整）
- 域名 `www.ic.chenchar.com` 由服务器侧反向代理（Nginx / Caddy / 宝塔等）指到该端口；本仓库不负责主机级 HTTPS 证书申请

### 3.4 首发占位内容

- 首页：品牌一句话 + 博客 / 知识库 CTA
- 博客：例如《写在前面：为什么做 chenchar-ic》
- 知识库占位树（可调整命名）：
  - 入门：数字 IC 学习地图
  - 基础：时序分析概念扫盲
  - 基础：工艺节点与命名速览

正文保持短小，标明后续会充实。

## 4. 非目标（首发不做）

- 真实深度长文写作
- 评论系统、用户登录
- 搜索引擎提交 / 复杂 SEO 运营
- 主机上的 DNS / HTTPS / 反向代理实操（仅在 README 写对接约定）
- CI/CD（可后续再加 GitHub Actions 自动构建推送镜像）

## 5. 验收标准

1. `pnpm install && pnpm dev` 可本地预览
2. `pnpm build` 生成 `doc_build`
3. `docker compose build && docker compose up -d` 后，本机 `http://localhost:8080` 可访问站点
4. 导航可到达首页、博客、知识库；占位内容可读
5. README 写清：本地开发、构建、Docker 部署、与 `www.ic.chenchar.com` 反代对接方式

## 6. 风险与约定

- Rspress 默认把 `docs/` 下 Markdown 都变成页面；`superpowers` 路径若可访问，保持无外链即可，后续可用路由策略收紧
- 服务器推镜像 / `docker compose pull` 流程由运维习惯决定；首发以本仓库可构建镜像为准
