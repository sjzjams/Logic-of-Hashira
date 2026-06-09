// V1 升级 - Visual Effects: 边缘发光 + 像素消融 Fragment Shader (V1.3-Skia)。
//
// 合成规则：
// 1. Sobel 算子检测原图的亮度边缘，叠 warm-orange 发光（uGlowIntensity 越大越亮）；
// 2. 若 uHasMask > 0.5，边缘 glow 仅作用在 uMask 通道命中的像素
//    （真实 NCNN 主体），避免在背景上产生"假"的发光圈；
// 3. 用 hash 噪声做像素级透明度阈值，uDisintegrate 越大被消融的像素越多；
// 4. 消融出去的像素颜色偏向 glowColor，让观感像"被能量吞噬"。
//
// V1.3-Skia 重要变更：
//   移除 sobelEdge(sampler2D, ...) 辅助函数，改为内联。
//   原因：Skia SkSL 后端不允许 shader/sampler2D 作为函数参数传递
//        ("parameters of type 'shader' not allowed")。
//   Impeller 后端无此限制；本版本兼容两种渲染引擎。
//
// Flutter 端通过 FragmentProgram.fromAsset 加载本文件，uniform 索引：
//   0: uSize.x         (像素宽度)
//   1: uSize.y         (像素高度)
//   2: uTime           (0..1 动画时间，由 Dart 端驱动)
//   3: uGlowIntensity  (0..1 边缘发光强度)
//   4: uDisintegrate   (0..1 像素消融阈值)
//   5: uHasMask        (0 = Sobel 全图,1 = Sobel ∩ uMask 主体)
//
// 图像采样：
//   setImageSampler(0, image) → uImage
//   setImageSampler(1, mask)  → uMask
#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;
uniform float uTime;
uniform float uGlowIntensity;
uniform float uDisintegrate;
uniform float uHasMask;

uniform sampler2D uImage;
uniform sampler2D uMask;

out vec4 fragColor;

// 经典 2D hash 函数，把 fragCoord 映射到 [0,1) 伪随机数。
float hash21(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

void main() {
  // FlutterFragCoord() 返回的坐标已对齐 setFloat 传入的 uSize，无需翻转 Y。
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec4 color = texture(uImage, uv);

  // 1) 边缘发光：Sobel 内联（不使用函数参数传 sampler2D，兼容 SkSL）。
  vec2 texel = 1.0 / uSize;

  // Sobel 3x3 邻域采样 —— 直接使用 uImage uniform，避免 shader 类型传参。
  float c00 = length(texture(uImage, uv + vec2(-texel.x, -texel.y)).rgb);
  float c01 = length(texture(uImage, uv + vec2(0.0, -texel.y)).rgb);
  float c02 = length(texture(uImage, uv + vec2(texel.x, -texel.y)).rgb);
  float c10 = length(texture(uImage, uv + vec2(-texel.x, 0.0)).rgb);
  float c12 = length(texture(uImage, uv + vec2(texel.x, 0.0)).rgb);
  float c20 = length(texture(uImage, uv + vec2(-texel.x, texel.y)).rgb);
  float c21 = length(texture(uImage, uv + vec2(0.0, texel.y)).rgb);
  float c22 = length(texture(uImage, uv + vec2(texel.x, texel.y)).rgb);

  float gx = -c00 - 2.0 * c10 - c20 + c02 + 2.0 * c12 + c22;
  float gy = -c00 - 2.0 * c01 - c02 + c20 + 2.0 * c21 + c22;
  float edge = sqrt(gx * gx + gy * gy);

  // 经验值：原始 Sobel 值通常在 [0,1.5] 之间，乘 3.0 把锐边拉满。
  float glow = clamp(edge * 3.0 * uGlowIntensity, 0.0, 1.0);

  // 有真实 mask 时，glow 只作用在主体像素上。
  if (uHasMask > 0.5) {
    float m = texture(uMask, uv).r;
    // smoothstep 让 mask 边缘也有软过渡,避免 glow 出现锯齿边。
    glow *= smoothstep(0.15, 0.85, m);
  }
  vec3 glowColor = vec3(1.0, 0.78, 0.42);

  // 2) 像素消融：hash 阈值；uDisintegrate 越大被 step 过滤掉的像素越多。
  float n = hash21(floor(gl_FragCoord.xy * 1.5));
  float alpha = step(uDisintegrate, n);

  // 3) 合成：先在颜色上叠加 glow，再让 alpha 受 disintegrate 控制。
  vec3 finalColor = mix(color.rgb, glowColor, glow);
  // 已消融出去的像素稍微偏亮，方便观感上的"被能量冲散"。
  finalColor = mix(finalColor, glowColor, (1.0 - alpha) * 0.3);

  fragColor = vec4(finalColor, color.a * alpha);
}
