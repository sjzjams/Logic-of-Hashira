// V1.2-B：处理页"背景消融提取" Fragment Shader (PRD 模块二第 2 段)。
//
// 合成规则：
// 1. 用 `uMaskStrength` 软阈值在画面中心保留一个椭圆区域（代表"食物主体"）；
//    V1.2-C 会把它替换为真实 NCNN mask。
// 2. 用 hash 噪声 + `uDisintegrate` 阈值，对“背景”像素做 step/discard 渐隐，
//    视觉上呈现“从四周向中心融化消失”。
// 3. 已被消融的像素偏白色，模拟“被能量冲散”后的纯白卡片效果。
//
// Flutter 端 FragmentProgram.fromAsset 加载，uniform 索引：
//   0: uSize.x          (像素宽度)
//   1: uSize.y          (像素高度)
//   2: uProgress       (0..1 动画进度，由 Dart 端驱动)
//   3: uDisintegrate   (0..1 像素消融阈值，由 Dart 端按阶段驱动)
//   4: uMaskStrength   (0..1 主体保留强度；0.0=全部消融，1.0=全部保留)
//
// 图像采样：setImageSampler(0, image) 绑定到 uImage。
#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;
uniform float uProgress;
uniform float uDisintegrate;
uniform float uMaskStrength;

uniform sampler2D uImage;

out vec4 fragColor;

// 经典 2D hash：把 fragCoord 映射到 [0,1) 伪随机数。
float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

// 软椭圆 mask：画面中心 1.0，边缘 0.0；uMaskStrength 越大主体范围越大。
// 返回 [0,1] 数值，> 0.5 视为“主体像素”，< 0.5 视为“背景像素”。
float softMask(vec2 uv) {
  vec2 d = uv - vec2(0.5);
  // 椭圆半径 0.36，uMaskStrength 把半径按 0.6..0.95 缩放。
  float radius = mix(0.36, 0.55, clamp(uMaskStrength, 0.0, 1.0));
  float dist = length(d) / radius;
  return 1.0 - clamp(dist, 0.0, 1.0);
}

void main() {
  // FlutterFragCoord() 与 setFloat 传入的 uSize 对齐，无需翻转 Y。
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec4 color = texture(uImage, uv);

  // 1) 主体 mask；用幂函数让边缘更陡，模拟“二值化抠图”。
  float mask = pow(softMask(uv), mix(1.4, 0.6, uProgress));
  // 主体：保留；背景：参与消融。

  // 2) 像素消融：hash 阈值 + uDisintegrate。
  //    - 主体像素把阈值降低（不易被消融）；
  //    - 背景像素把阈值抬高（容易被消融）。
  float n = hash21(floor(gl_FragCoord.xy * 1.5));
  float threshold = mix(uDisintegrate * 0.9, uDisintegrate * 0.05, mask);
  float alpha = step(threshold, n);

  // 3) 边缘发光：mask 在 0.35~0.65 之间的像素乘以 warm-white 高光，
  //    视觉上呈现“主体边缘柔光”。
  float edgeBand = 1.0 - smoothstep(0.35, 0.65, abs(mask - 0.5) * 2.0);
  // edgeBand 在 mask≈0.5 时最大；让 progress 控制其脉动 (0.0~0.6~0.4)。
  float pulse = 0.4 + 0.4 * sin(uProgress * 3.14159);
  vec3 glowColor = vec3(1.0, 0.98, 0.94);
  vec3 baseColor = mix(color.rgb, glowColor, edgeBand * pulse * 0.7);

  // 4) 已被消融的像素偏向纯白，模拟“背景被能量冲散后变为白色卡片”。
  vec3 finalColor = mix(vec3(1.0, 1.0, 1.0), baseColor, alpha);

  // 主体像素保持原透明度；背景被消融处 alpha 渐变至 0 让下一层白色卡片透出。
  fragColor = vec4(finalColor, color.a * mix(alpha, 1.0, mask));
}
