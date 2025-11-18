#!/usr/bin/env bash

# ============================================================
# Qwen3-ASR-Studio 本地打包脚本：生成 .deb 安装包（方案 A）
# ------------------------------------------------------------
# 用途：
#   在当前源码目录下构建前后端，然后打包为 Debian .deb 文件。
#
# 使用前提：
#   1. 已在当前仓库根目录下执行本脚本：
#        bash scripts/build-deb.sh 1.0.0
#      （其中 1.0.0 为版本号，可自行替换）
#   2. 已在以下目录完成依赖安装：
#        - aliyun-api/ : npm install
#        - qwen3-asr-studio/ : npm install
#     （如果未安装，脚本会对 aliyun-api 自动尝试 npm install，
#        但前端由于 npm install 有兼容性问题，需手动安装）
#
# 生成结果：
#   - 在 dist/deb/ 下生成类似：
#       qwen3-asr-studio_1.0.0_amd64.deb
#
# 安装方式：
#   sudo dpkg -i dist/deb/qwen3-asr-studio_1.0.0_amd64.deb
#   sudo systemctl enable --now qwen-asr-backend.service
#   sudo systemctl enable --now qwen-asr-frontend.service
#
# 注意：
#   - 本脚本假设系统中已安装 nodejs (>=18) 和 npm、dpkg-deb。
#   - 服务默认监听端口：
#       前端：5173
#       后端：3002
# ============================================================

set -euo pipefail

VERSION="${1:-1.0.0}"
ARCH="amd64"
PKG_NAME="qwen3-asr-studio"

# 仓库根目录
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="$ROOT_DIR/dist/deb"
PKG_DIR="$BUILD_ROOT/${PKG_NAME}_${VERSION}_${ARCH}"

echo "===> 打包版本: ${VERSION}"
echo "===> 仓库根目录: ${ROOT_DIR}"

# 清理旧构建
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/opt/$PKG_NAME"
mkdir -p "$PKG_DIR/lib/systemd/system"

echo "===> 步骤 1：构建阿里云后端 aliyun-api"
cd "$ROOT_DIR/aliyun-api"
if [ ! -d node_modules ]; then
  echo "     检测到 aliyun-api 缺少 node_modules，正在执行 npm install..."
  npm install
fi
echo "     执行 npm run build..."
npm run build
echo "     确保 .next/BUILD_ID 存在（适配 Next.js 生产启动要求）..."
if [ ! -f ".next/BUILD_ID" ]; then
  echo "${VERSION}" > ".next/BUILD_ID"
fi

echo "===> 步骤 2：构建前端 qwen3-asr-studio"
cd "$ROOT_DIR/qwen3-asr-studio"
if [ ! -d node_modules ]; then
  echo "错误：检测到 qwen3-asr-studio 缺少 node_modules。"
  echo "请先在该目录下手动执行："
  echo "  cd \"$ROOT_DIR/qwen3-asr-studio\""
  echo "  npm install"
  echo "然后重新运行本脚本。"
  exit 1
fi
echo "     执行 npm run build..."
npm run build

echo "===> 步骤 3：拷贝项目到 /opt/${PKG_NAME}"
cd "$ROOT_DIR"
cp -a aliyun-api "$PKG_DIR/opt/$PKG_NAME/aliyun-api"
cp -a qwen3-asr-studio "$PKG_DIR/opt/$PKG_NAME/qwen3-asr-studio"

echo "===> 步骤 4：生成 DEBIAN/control"
cat > "$PKG_DIR/DEBIAN/control" <<EOF
Package: ${PKG_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Depends: nodejs (>= 18), systemd
Maintainer: local-user
Description: Qwen3 ASR Studio (frontend + Aliyun backend) local deployment
EOF

echo "===> 步骤 5：生成 DEBIAN/postinst（刷新 systemd）"
cat > "$PKG_DIR/DEBIAN/postinst" <<'EOF'
#!/bin/bash
set -e
if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload || true
fi
exit 0
EOF
chmod 755 "$PKG_DIR/DEBIAN/postinst"

echo "===> 步骤 6：生成 systemd 服务单元"

cat > "$PKG_DIR/lib/systemd/system/qwen-asr-backend.service" <<'EOF'
[Unit]
Description=Qwen3 ASR Backend (Aliyun API)
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/qwen3-asr-studio/aliyun-api
Environment=PORT=3002
Environment=NODE_ENV=production
ExecStart=/usr/bin/npm start
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cat > "$PKG_DIR/lib/systemd/system/qwen-asr-frontend.service" <<'EOF'
[Unit]
Description=Qwen3 ASR Frontend (Vite preview)
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/qwen3-asr-studio/qwen3-asr-studio
ExecStart=/usr/bin/npm run preview -- --host 0.0.0.0 --port 5173
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "===> 步骤 7：构建 .deb 包"
mkdir -p "$BUILD_ROOT"
DEB_FILE="$BUILD_ROOT/${PKG_NAME}_${VERSION}_${ARCH}.deb"
dpkg-deb --build "$PKG_DIR" "$DEB_FILE"

echo "=============================================="
echo "打包完成：${DEB_FILE}"
echo
echo "安装命令示例："
echo "  sudo dpkg -i \"${DEB_FILE}\""
echo
echo "安装后启动服务："
echo "  sudo systemctl enable --now qwen-asr-backend.service"
echo "  sudo systemctl enable --now qwen-asr-frontend.service"
echo
echo "前端访问地址："
echo "  http://localhost:5173"
echo "=============================================="
