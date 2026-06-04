from ultralytics import YOLO

# 1. 加载模型
model = YOLO('yolov8n-seg.pt')

# 2. 导出为 ncnn 格式
model.export(format='ncnn')
