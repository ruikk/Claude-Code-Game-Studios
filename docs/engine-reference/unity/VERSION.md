# Unity Engine — 版本参考

| 字段 | 值 |
|-------|-------|
| **Engine Version** | Unity 6.3 LTS |
| **Release Date** | 2025 年 12 月 |
| **Project Pinned** | 2026-02-13 |
| **Last Docs Verified** | 2026-02-13 |
| **LLM Knowledge Cutoff** | 2025 年 5 月 |

## 知识缺口警告

该 LLM 的训练数据很可能只覆盖到 Unity ~2022 LTS（2022.3）。整个
Unity 6 发布序列（此前称为 Unity 2023 Tech Stream）引入了大量重要变更，
这些内容模型**并不了解**。因此，在建议使用 Unity API 之前，务必先交叉查阅本目录中的参考资料。

## 截止日期之后的版本时间线

| 版本 | 发布 | 风险等级 | 关键主题 |
|---------|---------|------------|-----------|
| 6.0 | 2024 年 10 月 | HIGH | Unity 6 品牌重塑、全新渲染特性、Entities 1.3、DOTS 改进 |
| 6.1 | 2024 年 11 月 | MEDIUM | Bug 修复、稳定性提升 |
| 6.2 | 2024 年 12 月 | MEDIUM | 性能优化、新 Input System 改进 |
| 6.3 LTS | 2025 年 12 月 | HIGH | 自 6.0 以来首个 LTS、可用于生产的 DOTS、增强的图形特性 |

## 从 2022 LTS 到 Unity 6.3 LTS 的主要变化

### 破坏性变更
- **Entities/DOTS**：Entities 1.0+ 对 API 进行了大幅重构，ECS 模式被彻底重新设计
- **Input System**：旧版 Input Manager 已弃用，默认使用新的 Input System
- **Rendering**：URP/HDRP 获得显著升级，SRP Batcher 也有改进
- **Addressables**：资源管理工作流发生变化
- **Scripting**：支持 C# 9，并引入新的 API 模式

### 新特性（知识截止之后）
- **DOTS**：可用于生产环境的 Entity Component System（Entities 1.3+）
- **Graphics**：增强版 URP/HDRP 流水线、GPU Resident Drawer
- **Multiplayer**：Netcode for GameObjects 改进
- **UI Toolkit**：已可用于生产环境的运行时 UI（在新项目中替代 UGUI）
- **Async Asset Loading**：Addressables 性能提升
- **Web**：支持 WebGPU

### 已弃用系统
- **Legacy Input Manager**：改用新的 Input System package
- **Legacy Particle System**：改用 Visual Effect Graph
- **UGUI**：仍受支持，但新项目建议使用 UI Toolkit
- **Old ECS (GameObjectEntity)**：已被现代 DOTS/Entities 替代

## 已验证来源

- 官方文档：https://docs.unity3d.com/6000.0/Documentation/Manual/index.html
- Unity 6 发布：https://unity.com/releases/unity-6
- Unity 6.3 LTS 公告：https://unity.com/blog/unity-6-3-lts-is-now-available
- 迁移指南：https://docs.unity3d.com/6000.0/Documentation/Manual/upgrade-guides.html
- Unity 6 支持政策：https://unity.com/releases/unity-6/support
- C# API 参考：https://docs.unity3d.com/6000.0/Documentation/ScriptReference/index.html
