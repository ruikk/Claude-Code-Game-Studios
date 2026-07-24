---
paths:
  - "assets/shaders/**"
---

# 着色器(Shader)代码规范

`assets/shaders/` 目录下的所有着色器文件必须遵循以下规范，以确保视觉质量、性能和跨平台兼容性。

## 命名规范
- 文件命名：`[类型]_[类别]_[名称].[扩展名]`
  - `spatial_env_water.gdshader` (Godot)
  - `SG_Env_Water` (Unity Shader Graph)
  - `M_Env_Water` (Unreal Material)
- 使用能表明材质用途的描述性名称
- 以着色器类型为前缀：`spatial_`、`canvas_`、`particles_`、`post_`

## 代码质量
- 所有 uniform/参数必须具有描述性名称和适当的提示(hints)
- 对相关参数进行分组（Godot：`group_uniforms`，Unity：`[Header]`，Unreal：Category）
- 对非显而易见的计算添加注释（尤其是数学密集的部分）
- 禁止魔法数字(Magic Numbers) — 使用命名常量或有文档记录的 uniform 值
- 在每个着色器文件顶部包含作者和用途注释

## 性能要求
- 为每个着色器记录目标平台和复杂度预算
- 使用适当的精度：移动端不需要全精度的地方使用 `half`/`mediump`
- 尽量减少片元着色器(Fragment Shader)中的纹理采样
- 避免在片元着色器中使用动态分支(Dynamic Branching) — 使用 `step()`、`mix()`、`smoothstep()`
- 循环内禁止纹理读取
- 模糊效果使用两遍处理方式（先水平后垂直）

## 跨平台
- 在最低规格目标硬件上测试着色器
- 为较低质量级别提供回退(Fallback)/简化版本
- 记录着色器面向的渲染管线（Forward/Deferred、URP/HDRP、Forward+/Mobile/Compatibility）
- 不要在同一目录中混用来自不同渲染管线的着色器

## 变体(Variant)管理
- 尽量减少着色器变体 — 每个变体都是单独编译的着色器
- 记录所有关键字(Keyword)/变体及其用途
- 尽可能使用特性剥离(Feature Stripping)来减小构建体积
- 记录并监控每个着色器的变体总数
