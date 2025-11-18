# Qwen3-ASR-Studio_zyh

在线声音识别体验，基于 Qwen3-ASR-Studio 打造，提供一个强大、高效且用户友好的界面，用于驱动阿里云通义千问（Qwen）ASR 模型。无论是转录会议记录、整理语音笔记，还是任何语音转文本场景，都能获得流畅的体验。



---

## 📸 应用截图

<img width="1277" height="1252" alt="image" src="https://github.com/user-attachments/assets/cb26576a-2761-41a1-88dd-417213ac8964" />

<img width="1277" height="1252" alt="image" src="https://github.com/user-attachments/assets/4d7452cd-8631-4f07-81f4-e86b7ad5bf15" />

## ✨ 主要功能

- **多种音频输入方式**
  - 文件上传：支持拖拽或点击选择 WAV、MP3、FLAC、M4A 等格式。
  - 实时录音：直接从麦克风录制音频，并带实时音波可视化。
- **高效转录**
  - Qwen ASR 驱动，提供快速准确的语音识别。
  - 上下文提示：通过术语、人名等上下文提升识别准确率。
  - 多语言与自动检测。
  - 反向文本标准化（ITN）：将口语形式自动转换为书面形式。
- **优化的用户体验**
  - 按住空格一键录音；输入法模式（PiP）支持按住 `Ctrl+空格` 录音、松手停止。
  - 音频压缩：上传前在客户端压缩，节省时间。
  - 画中画模式：悬浮录音窗口，可对任意应用实现“语音输入法”。
- **工作流与效率工具**
  - 单次/笔记双模式。
  - 历史记录与笔记管理。
  - 智能缓存/自动复制。
- **个性化设置**
  - 明暗主题切换。
  - 设置持久化存储。

## 🛠️ 技术栈

- 前端：React + TypeScript
- UI：Tailwind CSS
- 后端：阿里云通义千问 ASR（通过 Gradio Space）
- 浏览器能力：Web Audio API、IndexedDB、Document Picture-in-Picture

## 🚀 本地开发

```bash
git clone https://github.com/yeahhe365/Qwen3-ASR-Studio.git
cd Qwen3-ASR-Studio
pnpm install    # 或 npm install
pnpm dev        # 启动前端 http://localhost:5173
```

后端位于 `aliyun-api/`，同样使用 `pnpm install && pnpm dev`。

## 📁 项目结构

```
.
├── aliyun-api/           # 阿里云后端（Next.js + Socket.IO）
├── modelscope-api/       # ModelScope API 示例
├── qwen3-asr-studio/     # 前端
├── scripts/              # 辅助脚本
├── start-asr-local.sh    # 一键启动脚本
└── README.md
```

## 🤝 如何贡献

1. Fork 本仓库并创建分支 `feature/xxx`
2. 提交修改 `git commit -m "feat: xxx"`
3. 推送并提交 PR

## 📜 开源许可

本项目基于 [MIT License](./LICENSE)。

## 🙏 致谢

- 阿里云通义千问团队
- Gradio / Hugging Face 社区
- React/Tailwind 以及所有开源贡献者
