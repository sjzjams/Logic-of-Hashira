#!/usr/bin/env bash
# fetch_ncnn.sh
# 用途:从 Tencent ncnn 官方 release 下载 android-vulkan 预编译包,只解出 arm64-v8a。
# 用法:./fetch_ncnn.sh [version] [abi]  默认 version=20260526 abi=arm64-v8a

set -euo pipefail

VERSION="${1:-20260526}"
ABI="${2:-arm64-v8a}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${SCRIPT_DIR}/ncnn/ncnn-${VERSION}-android-vulkan"
TARGET_ABI="${TARGET_DIR}/${ABI}"

# 已存在则直接退出(幂等)
if [[ -d "${TARGET_ABI}" ]]; then
    echo "[fetch_ncnn] 已存在 ${TARGET_ABI},跳过下载。"
    exit 0
fi

URL="https://github.com/Tencent/ncnn/releases/download/${VERSION}/ncnn-${VERSION}-android-vulkan.zip"
TMP_DIR="$(mktemp -d)"
ZIP_PATH="${TMP_DIR}/ncnn.zip"

echo "[fetch_ncnn] 下载 ${URL}"
curl -fL --retry 3 -o "${ZIP_PATH}" "${URL}"

echo "[fetch_ncnn] 解压并裁剪到 ${ABI}"
unzip -q "${ZIP_PATH}" -d "${TMP_DIR}/extract"

# 顶层通常是 ncnn-<ver>-android-vulkan
EXTRACTED_ROOT="$(find "${TMP_DIR}/extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
SRC_ABI="${EXTRACTED_ROOT}/${ABI}"
if [[ ! -d "${SRC_ABI}" ]]; then
    echo "[fetch_ncnn] 解压结果中未找到 ${ABI} 目录" >&2
    exit 1
fi

mkdir -p "${TARGET_DIR}"
mv "${SRC_ABI}" "${TARGET_ABI}"

# 清理其他 ABI
find "${EXTRACTED_ROOT}" -mindepth 1 -maxdepth 1 -type d ! -name "${ABI}" -exec rm -rf {} +
# 把共享内容(include / lib / share 等)挪进 TARGET_DIR
find "${EXTRACTED_ROOT}" -mindepth 1 -maxdepth 1 ! -name "${ABI}" -exec mv {} "${TARGET_DIR}/" \;

rm -rf "${TMP_DIR}"

echo "[fetch_ncnn] 完成:${TARGET_ABI}"
