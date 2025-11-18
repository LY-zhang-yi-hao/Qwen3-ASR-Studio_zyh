#!/usr/bin/env bash

# 一键启动本地 ASR 前后端（开发模式）
# 使用方式：
#   1) 确保已在两个目录安装依赖：
#        cd aliyun-api && npm install
#        cd qwen3-asr-studio && npm install
#   2) 在仓库根目录授权并运行：
#        chmod +x start-asr-local.sh
#        ./start-asr-local.sh
#   3) 在运行脚本的终端按 Ctrl+C 可同时停止前后端。

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$ROOT_DIR/aliyun-api"
FRONTEND_DIR="$ROOT_DIR/qwen3-asr-studio"
BACKEND_URL="http://localhost:3002"
FRONTEND_URL="http://localhost:5173"

if [ ! -d "$BACKEND_DIR" ]; then
  echo "错误：未找到后端目录 $BACKEND_DIR"
  exit 1
fi

if [ ! -d "$FRONTEND_DIR" ]; then
  echo "错误：未找到前端目录 $FRONTEND_DIR"
  exit 1
fi

echo "===> 启动阿里云后端 (aliyun-api) 在端口 3002..."
cd "$BACKEND_DIR"
PORT=3002 npm run dev &
BACKEND_PID=$!

echo "===> 启动前端 (qwen3-asr-studio) 在端口 5173..."
cd "$FRONTEND_DIR"
npm run dev &
FRONTEND_PID=$!

echo "----------------------------------------"
echo "阿里云后端 PID:   $BACKEND_PID ($BACKEND_URL)"
echo "前端页面 PID:     $FRONTEND_PID ($FRONTEND_URL)"
echo "在本终端按 Ctrl+C 可以一次性停止前后端。"
echo "----------------------------------------"

open_browser() {
  local url="$1"

  if command -v xdg-open >/dev/null 2>&1; then
    nohup xdg-open "$url" >/dev/null 2>&1 &
    echo "已在默认浏览器中打开：$url"
    return 0
  fi

  if command -v open >/dev/null 2>&1; then
    nohup open "$url" >/dev/null 2>&1 &
    echo "已在默认浏览器中打开：$url"
    return 0
  fi

  if command -v start >/dev/null 2>&1; then
    start "" "$url" >/dev/null 2>&1 &
    echo "已尝试在默认浏览器中打开：$url"
    return 0
  fi

  echo "提示：未找到可用的打开命令，请手动访问：$url"
  return 1
}

sleep 1
open_browser "$FRONTEND_URL" || true

cleanup() {
  echo
  echo "正在停止前后端服务..."
  kill "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
  wait "$BACKEND_PID" "$FRONTEND_PID" 2>/dev/null || true
  echo "已停止。"
}

trap cleanup INT TERM

wait
