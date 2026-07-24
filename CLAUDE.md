# Claude Code Game Studios -- 游戏工作室代理架构

通过 49 个协同的 Claude Code 子代理管理独立游戏开发。
每个代理负责特定领域，强制关注点分离和质量控制。

## 技术栈

- **引擎**: [CHOOSE: Godot 4 / Unity / Unreal Engine 5]
- **语言**: [CHOOSE: GDScript / C# / C++ / Blueprint]
- **版本控制**: Git with trunk-based development
- **构建系统**: [SPECIFY after choosing engine]
- **资产管线**: [SPECIFY after choosing engine]

> **注意**：Godot、Unity 和 Unreal 都有专属的引擎专家代理，
> 配备专门的子专家。请使用与你引擎匹配的代理集。

## 项目结构

@.claude/docs/directory-structure.md

## 引擎版本参考

@docs/engine-reference/godot/VERSION.md

## 技术偏好

@.claude/docs/technical-preferences.md

## 协调规则

@.claude/docs/coordination-rules.md

## 协作协议

**用户驱动的协作，而非自主执行。**
每个任务遵循：**提问 -> 选项 -> 决定 -> 草稿 -> 审批**

- 代理在使用 Write/Edit 工具之前必须询问"可以将此内容写入 [文件路径] 吗？"
- 代理必须在请求审批之前展示草稿或摘要
- 多文件变更需要明确批准整个变更集
- 没有用户指示，不得进行任何提交

完整协议和示例请参见 `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md`。

> **第一次使用？** 如果项目没有配置引擎且没有游戏概念，
> 运行 `/start` 开始引导式入门流程。

## 编码标准

@.claude/docs/coding-standards.md

## 上下文管理

@.claude/docs/context-management.md
