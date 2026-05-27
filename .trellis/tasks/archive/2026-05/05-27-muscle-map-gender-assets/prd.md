# PRD: 补齐男女两套人体资源切换 (Gender-Specific Muscle Map Assets)

## 1. 目标 (Goals)
实现 Muscle Map 组件在切换“男/女”性别时，能够真正加载并显示对应性别的 SVG 人体模型，提升视觉的专业性和准确性。

## 2. 需求描述 (Requirements)
- **资源注册**：在 `pubspec.yaml` 中正式注册 `muscle_map_female_front.svg` 和 `muscle_map_female_back.svg`。
- **状态联动**：重构 [muscle_map.dart](file:///d:/Logic-of-Hashira/lib/core/widgets/muscle_map.dart) 中的 `_BodySvgView` 调用逻辑。
- **动态路径**：根据 `_MuscleMapState` 中的 `_selectedGender` 变量，动态计算传给 `_BodySvgView` 的 `assetPath`。
- **视觉一致性**：确保女性版 SVG 的缩放和对齐方式与男性版保持一致。

## 3. 验收标准 (Acceptance Criteria)
- 点击“Male”按钮，显示男性人体模型。
- 点击“Female”按钮，立即切换为女性人体模型。
- 切换过程平滑，无布局跳动或资源加载闪烁。
- `flutter analyze` 检查通过。

## 4. 相关文件
- [muscle_map.dart](file:///d:/Logic-of-Hashira/lib/core/widgets/muscle_map.dart)
- [pubspec.yaml](file:///d:/Logic-of-Hashira/pubspec.yaml)
- `assets/muscle_map_female_front.svg`
- `assets/muscle_map_female_back.svg`
