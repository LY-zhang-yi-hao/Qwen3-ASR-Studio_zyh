## 任务名称
本地一键启动脚本（前端 + 阿里云后端）

## 背景说明
- 用户已成功在本地以开发模式运行：
  - 前端：`qwen3-asr-studio/`，命令 `npm run dev`。
  - 阿里云后端：`aliyun-api/`，命令 `PORT=3002 npm run dev`。
- 为简化日常使用，希望通过一个脚本实现「一键启动前后端」，而不是手动在多个终端分别输入命令。
- `.deb + systemd` 方案已实现但使用较重，当前需求转为「简单脚本优先」。

## 方案设计

### 目标
- 在仓库根目录提供一个脚本（例如 `start-asr-local.sh`），用户执行后：
  - 自动在后台同时启动：
    - `aliyun-api`（端口 3002，开发模式）。
    - `qwen3-asr-studio`（端口 5173，开发模式）。
  - 在终端输出：
    - 前端访问地址：`http://localhost:5173`
    - 后端端口信息：`http://localhost:3002`
  - 支持通过 `Ctrl+C` 一次性停止两个进程。

### 行为细节
- 启动逻辑：
  1. 从脚本所在目录自动定位仓库根目录。
  2. 检查子目录是否存在：
     - `aliyun-api/`
     - `qwen3-asr-studio/`
  3. 并行启动：
     - 在 `aliyun-api/` 内执行：`PORT=3002 npm run dev &`，记录 PID。
     - 在 `qwen3-asr-studio/` 内执行：`npm run dev &`，记录 PID。
  4. 在终端打印 PID 与访问地址。
  5. 使用 `trap` 捕获 `INT`/`TERM` 信号，在用户 `Ctrl+C` 时：
     - `kill` 两个子进程，确保干净退出。
- 停止方式：
  - 在运行脚本的终端中按 `Ctrl+C`，脚本会自动结束前后端两个 dev 进程。

### 使用前提
- 在两个项目中已完成依赖安装：
  - `cd aliyun-api && npm install`
  - `cd qwen3-asr-studio && npm install`
- 端口：
  - 3002 未被其他服务占用（后端）。
  - 5173 未被其他服务占用（前端）。

## 实施步骤

1. 在仓库根目录新增脚本：
   - 文件名：`start-asr-local.sh`
   - 主要逻辑：
     - 自动定位根目录。
     - 后端和前端依次在后台启动。
     - 打印访问信息。
     - `trap` 信号统一退出。

2. 使用说明（写在脚本注释中并向用户说明）：
   - 授权执行：
     - `chmod +x start-asr-local.sh`
   - 启动：
     - `./start-asr-local.sh`
   - 停止：
     - 在脚本运行的终端中按 `Ctrl+C`。

## 实际执行情况
- 已在仓库根目录新增脚本：
  - `start-asr-local.sh`
- 脚本逻辑：
  - 并行启动 `aliyun-api`（端口 3002）和 `qwen3-asr-studio`（端口 5173）。
  - 在终端提示访问地址，并通过 `Ctrl+C` 统一停止。
- 后续使用由用户在本机终端执行脚本完成。

