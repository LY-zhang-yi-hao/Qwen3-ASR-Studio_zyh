## 任务名称
将前后端打包为 `.deb` 安装包（方案 A：前后端两个端口，分服务运行）

## 背景说明
- 当前本地运行方式：
  - 前端：`qwen3-asr-studio/`，通过 `npm run dev` 启动 Vite 开发服务器，端口约为 `5173`。
  - 后端：`aliyun-api/`，通过 `PORT=3002 npm run dev` 启动 Next.js 自定义服务器，提供阿里云百炼转写接口。
- 用户需求：
  - 希望将当前前后端整体打包为一个 `.deb` 包，方便在本机或其他 Ubuntu 机器上安装和部署。
  - 选择的打包方案为「A」：保持前后端分离、分别监听不同端口（前端 5173，后端 3002），改动最小。

## 目标设计
- 安装 `.deb` 后，系统中具备：
  - 安装目录：`/opt/qwen3-asr-studio/`
    - `/opt/qwen3-asr-studio/aliyun-api`：后端项目（包含构建产物、依赖）。
    - `/opt/qwen3-asr-studio/qwen3-asr-studio`：前端项目（包含构建产物、依赖）。
  - systemd 服务单元：
    - `qwen-asr-backend.service`：启动阿里云后端，监听端口 `3002`。
    - `qwen-asr-frontend.service`：启动前端（使用 `vite preview`），监听端口 `5173`。
- 安装 `.deb` 时：
  - 不强制自动启动服务，仅安装文件和 systemd 单元。
  - 由用户自行执行：
    - `sudo systemctl enable --now qwen-asr-backend.service`
    - `sudo systemctl enable --now qwen-asr-frontend.service`
  - 访问方式不变：浏览器访问 `http://localhost:5173`。

## 技术方案

### 打包策略
- 在源码仓库中新增一个脚本：`scripts/build-deb.sh`，用于在本地构建 `.deb` 包：
  - 执行前提：
    - `aliyun-api` 已经完成 `npm install`。
    - `qwen3-asr-studio` 已经完成 `npm install`。
  - 构建流程：
    1. 在 `aliyun-api` 目录执行：
       - 如无 `node_modules`：自动执行 `npm install`。
       - 执行 `npm run build`，生成 `.next` 构建产物。
    2. 在 `qwen3-asr-studio` 目录执行：
       - 检查 `node_modules` 是否存在，如不存在直接报错提示用户先手动 `npm install`。
       - 执行 `npm run build`，生成前端 `dist` 产物。
    3. 创建打包目录结构：
       - `dist/deb/qwen3-asr-studio_<版本>_amd64/DEBIAN/control`：包元信息。
       - `dist/deb/qwen3-asr-studio_<版本>_amd64/DEBIAN/postinst`：安装后脚本（刷新 systemd）。
       - `dist/deb/qwen3-asr-studio_<版本>_amd64/opt/qwen3-asr-studio/...`：拷贝前后端代码与构建产物。
       - `dist/deb/qwen3-asr-studio_<版本>_amd64/lib/systemd/system/*.service`：前后端 systemd 单元。
    4. 使用 `dpkg-deb --build` 生成 `.deb` 包。
- control 文件关键字段：
  - `Package: qwen3-asr-studio`
  - `Version: <脚本参数传入的版本号，如 1.0.0>`
  - `Architecture: amd64`
  - `Depends: nodejs (>= 18), systemd`

### systemd 服务设计
- 后端服务 `qwen-asr-backend.service`：
  - WorkingDirectory: `/opt/qwen3-asr-studio/aliyun-api`
  - 环境变量：
    - `PORT=3002`
    - `NODE_ENV=production`
  - 启动命令：
    - `ExecStart=/usr/bin/npm start`
  - Restart 策略：
    - `Restart=on-failure`
- 前端服务 `qwen-asr-frontend.service`：
  - WorkingDirectory: `/opt/qwen3-asr-studio/qwen3-asr-studio`
  - 启动命令：
    - `ExecStart=/usr/bin/npm run preview -- --host 0.0.0.0 --port 5173`
  - Restart 策略：
    - `Restart=on-failure`

## 实施步骤

1. 在仓库中新增脚本 `scripts/build-deb.sh`：
   - 使用 Bash 编写。
   - 负责：
     - 构建前后端。
     - 组织打包目录结构。
     - 生成 control/postinst。
     - 生成 systemd unit 文件。
     - 调用 `dpkg-deb --build` 生成 `.deb`。

2. 用户使用流程（脚本设计目标）：
   1. 准备依赖（仅首次）：
      - 在 `aliyun-api` 下执行：`npm install`
      - 在 `qwen3-asr-studio` 下执行：`npm install`
   2. 回到仓库根目录执行：
      - `bash scripts/build-deb.sh 1.0.0`
   3. 脚本完成后输出 `.deb` 路径，例如：
      - `dist/deb/qwen3-asr-studio_1.0.0_amd64.deb`
   4. 安装：
      - `sudo dpkg -i dist/deb/qwen3-asr-studio_1.0.0_amd64.deb`
   5. 启动服务：
      - `sudo systemctl enable --now qwen-asr-backend.service`
      - `sudo systemctl enable --now qwen-asr-frontend.service`

## 实际进展
- 已确认端口规划：
  - 前端：`5173`
  - 后端：`3002`
- 已完成工作：
  - 新增打包脚本：`scripts/build-deb.sh`。
  - 在脚本中生成 DEBIAN 元信息和 systemd 单元模板。
  - 为支持离线构建，调整了 `aliyun-api/src/app/layout.tsx`：
    - 移除对 `next/font/google` 的 `Geist` / `Geist_Mono` 引入。
    - 改为使用基础样式类：`className="antialiased bg-background text-foreground"`。
    - 仅影响页面字体样式，不影响后端 API 功能。
- 后续步骤：
  - 在有网络的本机或当前环境中执行：
    - `bash scripts/build-deb.sh <版本号>`
  - 生成 `.deb` 后，通过 `dpkg -i` 安装，并使用 `systemctl` 管理服务。
