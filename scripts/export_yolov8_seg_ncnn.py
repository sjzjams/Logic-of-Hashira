#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Sprint 2.2-C Phase C 辅助脚本。

把 yolov8n-seg.pt 导出为 ncnn 格式,并把产物统一拷贝到
`android/app/src/main/assets/yolov8-seg/`,JSI / JNI 侧按固定文件名加载。

使用方式:
    pip install ultralytics
    python scripts/export_yolov8_seg_ncnn.py \
        --weights ./models/yolov8n-seg.pt

若未提供 --weights 且 ./models/yolov8n-seg.pt 也不存在,会尝试让
ultralytics 自动从 GitHub release 下载(需联网)。
"""

from __future__ import annotations

import argparse
import shutil
import sys
from pathlib import Path

# 仓库根 = scripts/ 的上一级
REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_OUTPUT_DIR = REPO_ROOT / "android" / "app" / "src" / "main" / "assets" / "yolov8-seg"
DEFAULT_WEIGHTS = REPO_ROOT / "models" / "yolov8n-seg.pt"

# 强制产物的文件名,方便 JNI 端按固定路径读取
TARGET_PARAM_NAME = "model.ncnn.param"
TARGET_BIN_NAME = "model.ncnn.bin"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="导出 yolov8n-seg 到 ncnn 格式,并复制到 Android assets。",
    )
    parser.add_argument(
        "--weights",
        type=Path,
        default=DEFAULT_WEIGHTS,
        help=f"输入 .pt 权重路径(默认 {DEFAULT_WEIGHTS})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT_DIR,
        help=f"输出目录(默认 {DEFAULT_OUTPUT_DIR})",
    )
    parser.add_argument(
        "--imgsz",
        type=int,
        default=640,
        help="导出时使用的输入尺寸,默认 640(与 JNI 端 letterbox 目标保持一致)",
    )
    return parser.parse_args()


def find_exported_ncnn(export_root: Path) -> tuple[Path, Path]:
    """在 ultralytics 导出的目录里找出 *.ncnn.param / *.ncnn.bin。

    ultralytics 不同版本命名会变化(<stem>_ncnn_model/*.ncnn.param),
    这里做一次宽松匹配,避免被具体版本绑死。
    """
    candidates = list(export_root.rglob("*.ncnn.param"))
    if not candidates:
        raise FileNotFoundError(
            f"在 {export_root} 下未找到 *.ncnn.param,导出可能失败"
        )
    param_path = candidates[0]
    bin_path = param_path.with_suffix(".bin")
    if not bin_path.exists():
        raise FileNotFoundError(
            f"找到 {param_path},但对应的 {bin_path.name} 不存在"
        )
    return param_path, bin_path


def main() -> int:
    args = parse_args()

    # 延迟导入,避免在没装 ultralytics 时直接抛 ImportError 难定位
    try:
        from ultralytics import YOLO  # type: ignore
    except ImportError as exc:  # pragma: no cover - 依赖缺失由用户环境决定
        print(
            "缺少依赖 ultralytics,请先执行 `pip install ultralytics`",
            file=sys.stderr,
        )
        raise exc

    weights = args.weights
    if not weights.exists():
        print(
            f"[warn] 权重文件 {weights} 不存在,交给 ultralytics 自动下载",
            file=sys.stderr,
        )

    # 让 ultralytics 在 weights 同目录输出,导出目录形如
    # `<weights父目录>/<stem>_ncnn_model/`
    print(f"[info] 加载权重: {weights}")
    model = YOLO(str(weights))

    print(f"[info] 导出 ncnn,imgsz={args.imgsz}")
    exported_dir = Path(
        model.export(format="ncnn", imgsz=args.imgsz)
    )

    param_src, bin_src = find_exported_ncnn(exported_dir)
    print(f"[info] 找到导出产物: {param_src} + {bin_src.name}")

    # 拷贝到 Android assets,统一命名为 model.ncnn.{param,bin}
    args.output.mkdir(parents=True, exist_ok=True)
    target_param = args.output / TARGET_PARAM_NAME
    target_bin = args.output / TARGET_BIN_NAME
    shutil.copy2(param_src, target_param)
    shutil.copy2(bin_src, target_bin)

    print("[ok] 已写入:")
    print(f"     {target_param}")
    print(f"     {target_bin}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
