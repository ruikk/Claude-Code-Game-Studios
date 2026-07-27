# Unreal Engine — 版本参考

| 字段 | 值 |
|-------|-------|
| **Engine Version** | Unreal Engine 5.7 |
| **Release Date** | 2025 年 11 月 |
| **Project Pinned** | 2026-02-13 |
| **Last Docs Verified** | 2026-02-13 |
| **LLM Knowledge Cutoff** | 2025 年 5 月 |

## 知识缺口警告

该 LLM 的训练数据很可能最多只覆盖到约 Unreal Engine 5.3。5.4、5.5、
5.6 和 5.7 版本引入了大量模型**不了解**的重要变更。
在建议 Unreal API 调用之前，务必先交叉核对本目录中的文档。

## 知识截止后的版本时间线

| 版本 | 发布时间 | 风险等级 | 关键主题 |
|---------|---------|------------|-----------|
| 5.4 | ~2025 年中 | HIGH | Motion Design 工具、动画改进、PCG 增强 |
| 5.5 | ~2025 年 9 月 | HIGH | Megalights（数百万灯光）、动画制作、MegaCity 演示 |
| 5.6 | ~2025 年 10 月 | MEDIUM | 性能优化、Bug 修复 |
| 5.7 | 2025 年 11 月 | HIGH | PCG 达到生产可用、Substrate 达到生产可用、AI assistant |

## 从 UE 5.3 到 UE 5.7 的主要变化

### 破坏性变更
- **Substrate Material System**：全新的材质框架（替代旧版材质系统）
- **PCG (Procedural Content Generation)**：达到生产可用，API 发生重大变化
- **Megalights**：全新的光照系统（支持数百万动态灯光）
- **Animation Authoring**：新的绑定与动画制作工具
- **AI Assistant**：编辑器内 AI 引导（实验性）

### 新特性（知识截止后）
- **Megalights**：支持超大规模动态光照（数百万灯光）
- **Substrate Materials**：达到生产可用的模块化材质系统
- **PCG Framework**：程序化世界生成框架（在 5.7 中达到生产可用）
- **Enhanced Virtual Production**：MetaHuman 集成、更深入的 VP 工作流
- **Animation Improvements**：更好的绑定、混合与程序化动画
- **AI Assistant**：编辑器内 AI 帮助（实验性）

### 已弃用系统
- **Legacy Material System**：新项目请迁移到 Substrate
- **Old PCG API**：请使用新的、达到生产可用的 PCG API（5.7+）

## 已验证来源

- Official docs: https://docs.unrealengine.com/5.7/
- UE 5.7 release notes: https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-5-7-release-notes
- What's new in 5.7: https://dev.epicgames.com/documentation/en-us/unreal-engine/whats-new
- UE 5.7 announcement: https://www.unrealengine.com/en-US/news/unreal-engine-5-7-is-now-available
- UE 5.5 blog: https://www.unrealengine.com/en-US/blog/unreal-engine-5-5-is-now-available
- Migration guides: https://docs.unrealengine.com/5.7/en-US/upgrading-projects/
