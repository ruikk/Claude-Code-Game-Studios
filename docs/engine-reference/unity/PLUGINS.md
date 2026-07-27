# Unity 6.3 LTS — 可选包与系统

**最后验证时间：** 2026-02-13

本文档汇总了 Unity 6.3 LTS 中可用的**可选包与系统**。
这些内容**不属于核心引擎**，但在特定类型的游戏开发中非常常用。

---

## 如何使用本指南

**✅ 提供详细文档** - 参见 `plugins/` 目录中的完整指南
**🟡 仅简要概览** - 提供官方文档链接，详情请使用 WebSearch
**⚠️ Preview** - 未来版本中可能存在破坏性变更
**📦 需要安装包** - 通过 Package Manager 安装

---

## 可用于生产环境的包（提供详细文档）

### ✅ Cinemachine
- **用途：** 虚拟相机系统（动态相机、过场动画、相机混合）
- **适用场景：** 第三人称游戏、电影化演出、复杂相机行为
- **知识缺口：** Cinemachine 3.0+（Unity 6）相较 2.x 有重大 API 变化
- **状态：** 可用于生产环境
- **Package：** `com.unity.cinemachine` (Package Manager)
- **详细文档：** [plugins/cinemachine.md](plugins/cinemachine.md)
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.cinemachine@3.0/manual/index.html

---

### ✅ Addressables
- **用途：** 高级资源管理（异步加载、远程内容、内存控制）
- **适用场景：** 大型项目、DLC、远程内容分发
- **知识缺口：** Unity 6 带来了一些改进，性能更好
- **状态：** 可用于生产环境
- **Package：** `com.unity.addressables` (Package Manager)
- **详细文档：** [plugins/addressables.md](plugins/addressables.md)
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.addressables@2.0/manual/index.html

---

### ✅ DOTS / Entities (ECS)
- **用途：** 数据导向技术栈（Data-Oriented Technology Stack，高性能 ECS，适合超大规模场景）
- **适用场景：** 拥有数千实体的游戏、RTS、模拟类游戏
- **知识缺口：** Entities 1.3+（Unity 6）已可用于生产环境，与 0.x 相比几乎是重写
- **状态：** 可用于生产环境（截至 Unity 6.3 LTS）
- **Package：** `com.unity.entities` (Package Manager)
- **详细文档：** [plugins/dots-entities.md](plugins/dots-entities.md)
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.entities@1.3/manual/index.html

---

## 其他可用于生产环境的包（简要概览）

### 🟡 Input System（已覆盖）
- **用途：** 现代输入处理（可重绑定、跨平台）
- **状态：** 可用于生产环境（Unity 6 默认方案）
- **Package：** `com.unity.inputsystem`
- **文档：** 参见 [modules/input.md](modules/input.md)
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.inputsystem@1.11/manual/index.html

---

### 🟡 UI Toolkit（已覆盖）
- **用途：** 现代运行时 UI（类似 HTML/CSS，性能优秀）
- **状态：** 可用于生产环境（Unity 6）
- **Package：** 内置
- **文档：** 参见 [modules/ui.md](modules/ui.md)
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.ui@2.0/manual/index.html

---

### 🟡 Visual Effect Graph (VFX Graph)
- **用途：** GPU 加速粒子系统（可支持数百万粒子）
- **适用场景：** 大规模特效、火焰、烟雾、魔法、爆炸
- **状态：** 可用于生产环境
- **Package：** `com.unity.visualeffectgraph` (仅限 URP/HDRP)
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.visualeffectgraph@17.0/manual/index.html

---

### 🟡 Shader Graph
- **用途：** 可视化 Shader 编辑器（基于节点创建 Shader）
- **适用场景：** 无需编写 HLSL 也能制作自定义 Shader
- **状态：** 可用于生产环境
- **Package：** `com.unity.shadergraph` (URP/HDRP)
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.shadergraph@17.0/manual/index.html

---

### 🟡 Timeline
- **用途：** 电影化序列编辑（过场动画、脚本事件）
- **适用场景：** 剧情驱动游戏、电影化演出、脚本化流程
- **状态：** 可用于生产环境
- **Package：** `com.unity.timeline` (内置)
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.timeline@1.8/manual/index.html

---

### 🟡 Animation Rigging
- **用途：** 运行时 IK、程序化动画
- **适用场景：** 脚部 IK、瞄准偏移、程序化肢体摆放
- **状态：** 可用于生产环境（Unity 6）
- **Package：** `com.unity.animation.rigging`
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.animation.rigging@1.3/manual/index.html

---

### 🟡 ProBuilder
- **用途：** 编辑器内 3D 建模（关卡原型、灰盒搭建）
- **适用场景：** 快速原型制作、关卡白盒/灰盒搭建
- **状态：** 可用于生产环境
- **Package：** `com.unity.probuilder`
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.probuilder@6.0/manual/index.html

---

### 🟡 Netcode for GameObjects
- **用途：** Unity 官方多人联机网络方案
- **适用场景：** 多人游戏（客户端-服务器架构）
- **状态：** 可用于生产环境
- **Package：** `com.unity.netcode.gameobjects`
- **官方文档：** https://docs-multiplayer.unity3d.com/netcode/current/about/

---

### 🟡 Burst Compiler
- **用途：** 面向 C# Jobs 的 LLVM 编译器（大幅提升性能）
- **适用场景：** 性能关键代码、DOTS、Jobs System
- **状态：** 可用于生产环境
- **Package：** `com.unity.burst`（随 DOTS 自动安装）
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.burst@1.8/manual/index.html

---

### 🟡 Jobs System
- **用途：** 多线程作业调度系统（CPU 并行化）
- **适用场景：** 性能优化、并行处理
- **状态：** 可用于生产环境
- **Package：** 内置
- **官方文档：** https://docs.unity3d.com/Manual/JobSystem.html

---

### 🟡 Mathematics
- **用途：** SIMD 数学库（针对 Burst 优化）
- **适用场景：** DOTS、高性能数学计算
- **状态：** 可用于生产环境
- **Package：** `com.unity.mathematics`
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.mathematics@1.3/manual/index.html

---

### 🟡 ML-Agents（机器学习）
- **用途：** 使用强化学习训练 AI
- **适用场景：** 高级 AI 训练、程序化行为
- **状态：** 可用于生产环境
- **Package：** `com.unity.ml-agents`
- **官方文档：** https://github.com/Unity-Technologies/ml-agents

---

### 🟡 Recorder
- **用途：** 录制游戏画面、截图、动画片段
- **适用场景：** 预告片、回放、调试录制
- **状态：** 可用于生产环境
- **Package：** `com.unity.recorder`
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.recorder@5.0/manual/index.html

---

## Preview/实验性包（谨慎使用）

### ⚠️ Splines
- **用途：** 运行时样条创建与编辑
- **适用场景：** 道路、路径、程序化内容
- **状态：** 可用于生产环境（Unity 6）
- **Package：** `com.unity.splines`
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.splines@2.6/manual/index.html

---

### ⚠️ Muse（AI Assistant）
- **用途：** AI 驱动的资源创作（纹理、精灵、动画）
- **状态：** Preview（Unity 6）
- **Package：** `com.unity.muse.*`
- **官方文档：** https://unity.com/products/muse

---

### ⚠️ Sentis（神经网络推理）
- **用途：** 在 Unity 中运行神经网络（AI 推理）
- **状态：** Preview
- **Package：** `com.unity.sentis`
- **官方文档：** https://docs.unity3d.com/Packages/com.unity.sentis@2.0/manual/index.html

---

## 已弃用的包（新项目应避免使用）

### ❌ UGUI（Canvas UI）
- **已弃用：** 仍受支持，但推荐使用 UI Toolkit
- **替代方案：** UI Toolkit

---

### ❌ Legacy Particle System
- **已弃用：** 请使用 Visual Effect Graph (VFX Graph)
- **替代方案：** VFX Graph

---

### ❌ Legacy Animation
- **已弃用：** 请使用 Animator (Mecanim)
- **替代方案：** Animator Controller

---

## 按需使用 WebSearch 的策略

对于上方**未列出**的包，当用户提问时，建议采用以下流程：

1. 使用 **WebSearch** 查询最新文档：`"Unity 6.3 [package name]"`
2. 验证该包是否：
   - 属于知识截止日期之后的内容（超出 2025 年 5 月训练数据）
   - 是 Preview 还是可用于生产环境
   - 在 Unity 6.3 LTS 中是否仍受支持
3. 如有需要，可将结果缓存到 `plugins/[package-name].md` 供后续参考

---

## 快速决策指南

**我需要虚拟相机** → **Cinemachine**
**我需要异步资源加载 / DLC** → **Addressables**
**我需要数千个实体（RTS、模拟）** → **DOTS/Entities**
**我需要现代输入系统** → **Input System**（见 modules/input.md）
**我需要 GPU 粒子** → **Visual Effect Graph**
**我需要可视化 Shader** → **Shader Graph**
**我需要电影化演出** → **Timeline**
**我需要运行时 IK** → **Animation Rigging**
**我需要关卡原型工具** → **ProBuilder**
**我需要多人联机** → **Netcode for GameObjects**

---

**最后更新时间：** 2026-02-13
**引擎版本：** Unity 6.3 LTS
**LLM 知识截止：** 2025 年 5 月
