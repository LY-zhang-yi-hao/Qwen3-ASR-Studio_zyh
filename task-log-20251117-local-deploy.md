## 任务名称
本地部署 Qwen3-ASR-Studio（方案 A：仅使用本地 ModelScope 后端）

## 背景说明
- 当前前端项目：`qwen3-asr-studio/`，由 Vite + React 构建。
- 当前本地已有两个后端：
  - `modelscope-api/`：提供 `/api/asr-inference` 接口（ASR 推理，原本代理到作者的 Gradio 服务）。
  - `aliyun-api/`：提供百炼转写相关接口（本任务中先暂不使用）。
- 现状：前端默认把 ModelScope 请求转发到作者部署在 `space.z.ai` 的服务器（`https://c0rpr74ughd0-deploy.space.z.ai/api/asr-inference`），而不是使用本机的 `modelscope-api`。
- 用户目标：在本机同时运行前端和后端，使前端直接调用本机的 `modelscope-api`，不再依赖作者远端服务器。

## 方案选择
- 方案 A（当前实施）：**只启用本地 ModelScope 后端**，不修改前端代码，通过前端设置界面把接口地址改成本地。
  - 优点：无需改代码，风险小、见效快。
  - 缺点：每次重置设置或更换浏览器可能需要重新配置 API 地址。
- 方案 B（暂不实施）：修改前端默认配置，直接内置本地后端地址，并同时本地化阿里云百炼后端。

## 环境假设
- 操作系统：本地开发机（用户实际系统待确认，例如 Windows/macOS/Ubuntu）。
- 已安装：
  - Node.js（建议 >= 18）。
  - npm 或 pnpm（任务中以 npm 为例）。

## 实施计划（方案 A）

### 步骤 1：安装依赖
1. 前端依赖安装  
   - 进入前端目录：`cd qwen3-asr-studio`  
   - 执行：`npm install`
2. ModelScope 后端依赖安装  
   - 进入后端目录：`cd modelscope-api`  
   - 执行：`npm install`

### 步骤 2：启动本地 ModelScope 后端
1. 在一个终端窗口中执行：
   - `cd modelscope-api`
   - `PORT=3001 npm run dev`
2. 预期结果：
   - 控制台输出类似：`[server] starting modelscope-api on 0.0.0.0:3001` 和 `> Ready on http://0.0.0.0:3001`。
   - 此时后端可通过 `http://localhost:3001/api/asr-inference` 访问。

### 步骤 3：启动前端应用
1. 在另一个终端窗口中执行：
   - `cd qwen3-asr-studio`
   - `npm run dev`
2. 预期结果：
   - Vite 在本地启动开发服务器，一般为 `http://localhost:5173`（终端日志中会显示具体地址）。
   - 浏览器打开该地址可以看到 Qwen3 ASR Studio 界面。

### 步骤 4：在前端设置中配置本地 ModelScope 接口
1. 在浏览器中打开前端页面（例如 `http://localhost:5173`）。
2. 打开设置面板（Settings），找到：
   - **API 提供方 / Provider**，选择 `ModelScope`。
   - **ModelScope API 地址**（或类似描述的输入框）。
3. 将 ModelScope API 地址修改为：
   - `http://localhost:3001/api/asr-inference`
4. 保存或关闭设置面板。

### 步骤 5：验证本地端到端流程
1. 在前端上传一段音频或录制音频。
2. 点击转写按钮，观察页面提示：
   - 加载/识别进度信息。
   - 最终识别出的文本和检测到的语言。
3. 在 `modelscope-api` 的终端窗口中，观察是否有对应的请求日志输出（例如接收到 ASR 请求的日志）。

## 预期效果
- 前端所有选择 `ModelScope` 提供方的转写请求，将通过浏览器直接调用：
  - `http://localhost:3001/api/asr-inference`
- 不再依赖原先作者部署在 `space.z.ai` 上的 `https://c0rpr74ughd0-deploy.space.z.ai/api/asr-inference` 接口。
- 阿里云百炼（Bailian）模式暂时不做本地化配置，仍可在后续任务中单独处理。

## 实际执行情况（待用户确认）
- 代码改动：本方案 **不涉及任何代码改动**，仅通过启动命令和前端设置完成本地化。
- 当前状态：
  - 依赖安装：待用户执行。
  - 后端启动：待用户执行 `PORT=3001 npm run dev` 验证。
  - 前端启动：待用户执行 `npm run dev` 验证。
  - 转写功能：待用户在浏览器中实际上传音频测试。
- 建议用户在完成上述步骤后，在此日志中补充：
  - 成功/失败情况。
  - 遇到的错误信息（如有）。
  - 后续是否需要扩展到方案 B（本地化阿里云百炼并改默认配置）。

