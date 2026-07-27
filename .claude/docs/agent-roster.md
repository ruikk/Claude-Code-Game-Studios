# 代理名册（Agent Roster）

以下代理可供使用。每个代理在 `.claude/agents/` 中都有专属定义文件。
请根据当前任务选择最合适的代理。当任务跨越多个领域时，协调代理（通常为 `producer` 或对应领域负责人）应将任务委派给各专项专家。

## 第 1 层——领导层代理（Opus）
| 代理 | 领域 | 何时使用 |
|-------|--------|-------------|
| `creative-director` | 高层创意愿景 | 重大创意决策、设计支柱冲突、整体调性/方向 |
| `technical-director` | 技术愿景 | 架构决策、技术栈选型、性能策略 |
| `producer` | 制作管理 | 冲刺（sprint）规划、里程碑跟踪、风险管理、跨团队协调 |

## 第 2 层——部门负责人代理（Sonnet）
| 代理 | 领域 | 何时使用 |
|-------|--------|-------------|
| `game-designer` | 游戏设计 | 机制、系统、成长、经济、平衡性 |
| `lead-programmer` | 代码架构 | 系统设计、代码评审、API 设计、重构 |
| `art-director` | 视觉方向 | 风格指南、美术圣经、资产规范、UI/UX 方向 |
| `audio-director` | 音频方向 | 音乐方向、声音调色板、音频实现策略 |
| `narrative-director` | 剧情与写作 | 故事弧线、世界构建、角色设计、对白策略 |
| `qa-lead` | 质量保障 | 测试策略、缺陷分级、发布就绪评估、回归计划 |
| `release-manager` | 发布管线 | 构建管理、版本管理、更新日志、部署、回滚 |
| `localization-lead` | 国际化 | 字符串外置、翻译管线、区域测试 |

## 第 3 层——专项代理（Sonnet 或 Haiku）
| 代理 | 领域 | 模型 | 何时使用 |
|-------|--------|-------|-------------|
| `systems-designer` | 系统设计 | Sonnet | 具体机制实现、公式设计、循环设计 |
| `level-designer` | 关卡设计 | Sonnet | 关卡布局、节奏控制、遭遇战设计、流程衔接 |
| `economy-designer` | 经济/平衡 | Sonnet | 资源经济、掉落表、成长曲线 |
| `gameplay-programmer` | Gameplay 代码 | Sonnet | 功能实现、Gameplay 系统代码 |
| `engine-programmer` | 引擎系统 | Sonnet | 核心引擎、渲染、物理、内存管理 |
| `ai-programmer` | AI 系统 | Sonnet | 行为树、寻路、NPC 逻辑、状态机 |
| `network-programmer` | 网络 | Sonnet | 网络代码、同步复制、延迟补偿、匹配系统 |
| `tools-programmer` | 开发工具 | Sonnet | 编辑器扩展、pipeline 工具、调试实用工具 |
| `ui-programmer` | UI 实现 | Sonnet | UI 框架、界面、控件、数据绑定 |
| `technical-artist` | 技术美术 | Sonnet | 着色器、VFX、优化、美术 pipeline 工具 |
| `sound-designer` | 声音设计 | Haiku | SFX 设计文档、音频事件列表、混音说明 |
| `writer` | 对白/世界观文本 | Sonnet | 对白撰写、世界观条目、物品描述 |
| `world-builder` | 世界/设定设计 | Sonnet | 世界规则、阵营设计、历史、地理 |
| `qa-tester` | 测试执行 | Haiku | 编写测试用例、缺陷报告、测试清单 |
| `performance-analyst` | 性能 | Sonnet | 性能分析、优化建议、内存分析 |
| `devops-engineer` | 构建/部署 | Haiku | CI/CD、构建脚本、版本控制 workflow |
| `analytics-engineer` | 遥测 | Sonnet | 事件跟踪、仪表盘、A/B 测试设计 |
| `ux-designer` | UX 流程 | Sonnet | 用户流程、线框图、无障碍、输入处理 |
| `prototyper` | 快速原型 | Sonnet | 一次性原型（throwaway prototype）、机制验证、可行性验证 |
| `security-engineer` | 安全 | Sonnet | 反作弊、漏洞预防、存档加密、网络安全 |
| `accessibility-specialist` | 无障碍 | Haiku | WCAG 合规、色盲模式、按键重映射、文本缩放 |
| `live-ops-designer` | 长线运营（live-ops） | Sonnet | 赛季、活动、通行证、留存、在线经济 |
| `community-manager` | 社区 | Haiku | 补丁说明、玩家反馈、危机沟通、社区健康 |

## 引擎专属代理（使用与你引擎匹配的一组）

### 引擎负责人

| 代理 | 引擎 | 模型 | 何时使用 |
| ---- | ---- | ---- | ---- |
| `unreal-specialist` | Unreal Engine 5 | Sonnet | Blueprint 与 C++ 取舍、GAS 总览、UE 子系统、Unreal 优化 |
| `unity-specialist` | Unity | Sonnet | MonoBehaviour 与 DOTS 取舍、Addressables、URP/HDRP、Unity 优化 |
| `godot-specialist` | Godot 4 | Sonnet | GDScript 模式、节点/场景架构、信号机制、Godot 优化 |

### Unreal Engine 子专项代理

| 代理 | 子系统 | 模型 | 何时使用 |
| ---- | ---- | ---- | ---- |
| `ue-gas-specialist` | Gameplay Ability System | Sonnet | 技能（Ability）、Gameplay Effect、属性集、标签、预测 |
| `ue-blueprint-specialist` | Blueprint 架构 | Sonnet | BP/C++ 边界、图表规范、命名、BP 优化 |
| `ue-replication-specialist` | 网络/复制 | Sonnet | 属性复制、RPC、预测、相关性、带宽 |
| `ue-umg-specialist` | UMG/CommonUI | Sonnet | 控件层级、数据绑定、CommonUI 输入、UI 性能 |

### Unity 子专项代理

| 代理 | 子系统 | 模型 | 何时使用 |
| ---- | ---- | ---- | ---- |
| `unity-dots-specialist` | DOTS/ECS | Sonnet | Entity Component System、Jobs、Burst 编译器、混合渲染 |
| `unity-shader-specialist` | 着色器/VFX | Sonnet | Shader Graph、VFX Graph、URP/HDRP 定制、后处理 |
| `unity-addressables-specialist` | 资产管理 | Sonnet | Addressable 分组、异步加载、内存管理、内容分发 |
| `unity-ui-specialist` | UI Toolkit/UGUI | Sonnet | UI Toolkit、UXML/USS、UGUI Canvas、数据绑定、跨平台输入 |

### Godot 子专项代理

| 代理 | 子系统 | 模型 | 何时使用 |
| ---- | ---- | ---- | ---- |
| `godot-gdscript-specialist` | GDScript | Sonnet | 静态类型、设计模式、信号、协程、GDScript 性能 |
| `godot-shader-specialist` | 着色器/渲染 | Sonnet | Godot 着色语言、可视化着色器、粒子、后处理 |
| `godot-gdextension-specialist` | GDExtension | Sonnet | C++/Rust 绑定、原生性能、自定义节点、构建系统 |
