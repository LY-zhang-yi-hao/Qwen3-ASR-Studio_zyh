## 任务名称
前端接入本地阿里云百炼后端（BAILIAN_API_URL 本地化）

## 背景说明
- 前端项目：`qwen3-asr-studio/`。
- 阿里云百炼后端项目：`aliyun-api/`，已在本地通过命令启动：
  - `PORT=3002 npm run dev`
  - 日志中显示：`> Ready on http://0.0.0.0:3002`。
- 前端当前阿里云百炼模式使用的接口地址为：
  - `https://r0vrc7kjd4q0-deploy.space.z.ai/api/proxy/transcribe`（作者远端服务）。
- 用户目标：
  - 将前端的百炼接口地址改为本机 `aliyun-api` 服务地址。
  - 用户已具备阿里云百炼 DashScope 的 API Key（SK）。

## 变更方案

### 需要修改的文件
- 文件：`qwen3-asr-studio/services/gradioService.ts`
- 常量定义：
  - 原值：  
    `const BAILIAN_API_URL = 'https://r0vrc7kjd4q0-deploy.space.z.ai/api/proxy/transcribe';`
  - 修改为：  
    `const BAILIAN_API_URL = 'http://localhost:3002/api/proxy/transcribe';`

### 预期行为
- 当前端在设置中选择「阿里云百炼」作为 Provider，并在设置中填入有效的阿里云 API Key 时：
  - 前端代码 `transcribeWithBailian` 将向 `http://localhost:3002/api/proxy/transcribe` 发送请求。
  - 该请求被本地 `aliyun-api` 的 `/api/proxy/transcribe` 接口接收。
  - 接口内部再转发到阿里云 DashScope HTTP API（`qwen3-asr-flash` 模型），并返回转写结果。
- 浏览器地址栏仍为前端开发地址（如 `http://localhost:5173`），跨域由 `aliyun-api` 已配置的 CORS 头处理。

## 实施步骤

1. 修改前端常量
   - 打开 `qwen3-asr-studio/services/gradioService.ts`。
   - 将 `BAILIAN_API_URL` 从远端地址改为本地地址：
     - `http://localhost:3002/api/proxy/transcribe`。

2. 保持阿里云后端运行
   - 终端 1：
     ```bash
     cd /home/zyh/Desktop/Qwen3-ASR-Studio/aliyun-api
     PORT=3002 npm run dev
     ```
   - 确保日志中持续显示服务运行中。

3. 启动前端
   - 终端 2：
     ```bash
     cd /home/zyh/Desktop/Qwen3-ASR-Studio/qwen3-asr-studio
     npm run dev
     ```

4. 在前端中配置阿里云百炼
   - 打开浏览器访问前端（如 `http://localhost:5173`）。
   - 打开设置面板（Settings）：
     - Provider：选择「阿里云百炼」。
     - API Key：填入用户的阿里云百炼 / DashScope SK。
   - 关闭设置面板。

5. 验证转写
   - 在前端上传音频或录音。
   - 点击转写，观察：
     - 前端是否显示转写进度和结果。
     - `aliyun-api` 终端是否打印收到请求和调用 DashScope 的日志。
   - 如遇错误（如 401/403/429），根据响应信息检查：
     - SK 是否正确。
     - 阿里云控制台是否已开通对应模型与额度。

## 实际执行情况
- 代码修改：
  - 已计划修改 `BAILIAN_API_URL` 为本地地址 `http://localhost:3002/api/proxy/transcribe`。
- 运行状态：
  - 用户已成功在本地启动 `aliyun-api`（端口 3002），日志显示服务正常。
  - 前端已成功通过 `npm run dev` 启动并可访问。
- 后续由用户验证：
  - 填入阿里云 SK 后的实际识别效果。
  - 如有错误，将错误信息反馈以便进一步分析。

