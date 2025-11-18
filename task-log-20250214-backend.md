# 任务日志 - 2025-02-14（本地后端部署）

## 背景
- 先前前端一直调用作者部署在 `space.z.ai` 的 ModelScope / 百炼代理接口，导致识别功能受远端服务稳定性约束。
- 目标是在本机启动仓库自带的 `modelscope-api` 与 `aliyun-api` 服务，通过前端指向本地地址来自主管道，确保可用性与可控性。

## 计划
1. 阅读两个后端子项目的 README / 配置需求，安装依赖并启动，可通过 curl 验证健康状态。
2. 把前端设置改为指向本地 URL，必要时增强配置项，完成音频转写回路的端到端验证。

## 预期效果
- `modelscope-api` 和 `aliyun-api` 均能在本地端口提供可用的 `/api/asr-inference` 与 `/api/proxy/transcribe` 接口。
- `qwen3-asr-studio` 前端上传音频时不再访问任何公共实例，所有请求命中本机服务。

## 实施情况
- 2025-02-14：在 `modelscope-api/` 中执行 `pnpm install` 成功拉取依赖，但无论是通过 `pnpm dev`（`tsx server.ts`）还是 `pnpm exec next dev/start`，都会在监听端口阶段触发 `Error: listen EPERM: operation not permitted ...`；手动用 `node` 创建最小 HTTP 服务器同样因为当前沙箱禁止绑定本地端口而失败，确认无法在此环境中真正启动该服务。
- 2025-02-14：在 `aliyun-api/` 中同样安装依赖、尝试 `pnpm dev`，`tsx` 在创建 `/tmp/tsx-*/.pipe` 监听文件时即报 `listen EPERM`；因此百炼代理服务也无法在当前受限环境运行，尚需具备端口监听权限的机器才能完成部署与联调。
- 2025-02-14：在获得 `sudo` 权限后为两个 `server.ts` 增加 `PORT/HOST` 环境变量支持并多次尝试以提权方式启动，虽然能让 Node 监听 `0.0.0.0:3000`，但仅 root 用户可以访问（普通用户 `curl` 仍被拒绝），且 nodemon 很快因为沙箱对 `/tmp/tsx-*/.pipe` 的限制再次崩溃，暂无法维持长期运行。
