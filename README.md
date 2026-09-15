# chenchar-ic

芯片领域个人知识站（Rspress）：博客 + 体系化笔记。

线上域名约定：`https://www.ic.chenchar.com`

## 本地开发

```bash
pnpm install
pnpm dev
```

常用命令：

```bash
pnpm build    # 产出到 doc_build/
pnpm preview  # 预览生产构建
```

## Docker 部署

本机构建并启动（默认映射 `8080 -> 80`）：

```bash
docker compose build
docker compose up -d
```

访问：`http://localhost:8080`

停止：

```bash
docker compose down
```

### 推到服务器

在服务器上拉取代码后同样执行 `docker compose up -d --build`，或先在本机构建镜像后推送到你的镜像仓库，再在服务器 `docker compose pull && docker compose up -d`。

### 与域名对接

容器内 Nginx 监听 **80**。在主机 Nginx / Caddy / 宝塔中，将 `www.ic.chenchar.com` 反向代理到宿主机映射端口（默认 `8080`），并在主机侧配置 HTTPS 证书。

## 内容结构

| 路径 | 说明 |
|------|------|
| `/` | 首页 |
| `/blog/` | 博客 |
| `/guide/` | 芯片知识库 |

在 `docs/blog/` 与 `docs/guide/` 下新增 Markdown / MDX 即可扩展内容。
