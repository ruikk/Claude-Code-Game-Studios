# 技术偏好 / Technical Preferences

<!-- 由 /setup-engine 填充。随着用户在开发过程中做出决策而更新。 -->
<!-- 所有 agent 都会引用此文件作为项目特定标准与约定。 -->

## 引擎与语言 / Engine & Language

- **Engine**: [TO BE CONFIGURED — 运行 /setup-engine]
- **Language**: [TO BE CONFIGURED]
- **Rendering**: [TO BE CONFIGURED]
- **Physics**: [TO BE CONFIGURED]

## 输入与平台 / Input & Platform

<!-- 由 /setup-engine 写入。被 /ux-design、/ux-review、/test-setup、/team-ui 和 /dev-story 读取 -->
<!-- 以便将交互规范、测试辅助与实现范围限定到正确的输入方式。 -->

- **Target Platforms**: [TO BE CONFIGURED — 例如 PC、主机、移动端、Web]
- **Input Methods**: [TO BE CONFIGURED — 例如 键盘/鼠标、手柄、触摸、混合]
- **Primary Input**: [TO BE CONFIGURED — 本游戏的主要输入方式]
- **Gamepad Support**: [TO BE CONFIGURED — Full / Partial / None]
- **Touch Support**: [TO BE CONFIGURED — Full / Partial / None]
- **Platform Notes**: [TO BE CONFIGURED — 任意平台特定的 UX 约束]

## 命名约定 / Naming Conventions

- **Classes**: [TO BE CONFIGURED]
- **Variables**: [TO BE CONFIGURED]
- **Signals/Events**: [TO BE CONFIGURED]
- **Files**: [TO BE CONFIGURED]
- **Scenes/Prefabs**: [TO BE CONFIGURED]
- **Constants**: [TO BE CONFIGURED]

## 性能预算 / Performance Budgets

- **Target Framerate**: [TO BE CONFIGURED]
- **Frame Budget**: [TO BE CONFIGURED]
- **Draw Calls**: [TO BE CONFIGURED]
- **Memory Ceiling**: [TO BE CONFIGURED]

## 测试 / Testing

- **Framework**: [TO BE CONFIGURED]
- **Minimum Coverage**: [TO BE CONFIGURED]
- **Required Tests**: 平衡性公式、gameplay 系统、网络（如适用）

## 禁止模式 / Forbidden Patterns

<!-- 添加不应在本项目代码库中出现的模式 -->
- [None configured yet — 随着架构决策（architecture decision record）形成后补充]

## 允许的库 / 插件 / Allowed Libraries / Addons

<!-- 在此添加已批准的第三方依赖 -->
- [None configured yet — 依赖获批后补充]

## 架构决策日志 / Architecture Decisions Log

<!-- 指向 docs/architecture/ 中完整 ADR 的快速引用 -->
- [No ADRs yet — 使用 /architecture-decision 创建]

## 引擎专项专家 / Engine Specialists

<!-- 当引擎完成配置后由 /setup-engine 写入。 -->
<!-- 被 /code-review、/architecture-decision、/architecture-review 以及 team 技能读取 -->
<!-- 以确定应为引擎特定校验拉起哪个 specialist。 -->

- **Primary**: [TO BE CONFIGURED — 运行 /setup-engine]
- **Language/Code Specialist**: [TO BE CONFIGURED]
- **Shader Specialist**: [TO BE CONFIGURED]
- **UI Specialist**: [TO BE CONFIGURED]
- **Additional Specialists**: [TO BE CONFIGURED]
- **Routing Notes**: [TO BE CONFIGURED]

### 文件扩展名路由 / File Extension Routing

<!-- Skills 使用此表按文件类型选择正确的 specialist。 -->
<!-- 若某行显示 [TO BE CONFIGURED]，则该文件类型回退到 Primary。 -->

| File Extension / Type | Specialist to Spawn |
|-----------------------|---------------------|
| Game code (primary language) | [TO BE CONFIGURED] |
| Shader / material files | [TO BE CONFIGURED] |
| UI / screen files | [TO BE CONFIGURED] |
| Scene / prefab / level files | [TO BE CONFIGURED] |
| Native extension / plugin files | [TO BE CONFIGURED] |
| General architecture review | Primary |
