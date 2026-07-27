# ADR-[NNNN]: [标题]

## 状态

[提议中 | 已采纳 | 已弃用 | 被 ADR-XXXX 取代]

## 日期

[YYYY-MM-DD — 本 ADR 的撰写日期]

## 最后验证

[YYYY-MM-DD — 上次根据当前引擎版本与设计确认其准确性的日期。即使内容未变，只要重新阅读并确认仍然正确，也要更新此日期。]

## 决策者

[参与该决策的人员]

## 摘要

[2 句话：该 ADR 解决了什么问题，以及最终做了什么决策。用于分层上下文加载——当某个技能扫描 20 份 ADR 时，会据此判断是否需要阅读全文。务必具体：写明系统、问题和所选方案。]

## 引擎兼容性（Engine Compatibility）

| Field | Value |
|-------|-------|
| **Engine** | [e.g. Godot 4.6 / Unity 6 / Unreal Engine 5.4] |
| **Domain** | [Physics / Rendering / UI / Audio / Navigation / Animation / Networking / Core / Input / Scripting] |
| **Knowledge Risk** | [LOW — in training data / MEDIUM — near cutoff, verify / HIGH — post-cutoff, must verify] |
| **References Consulted** | [e.g. `docs/engine-reference/godot/modules/physics.md`, `breaking-changes.md`] |
| **Post-Cutoff APIs Used** | [该决策依赖的截止日期后引擎版本中的具体 API，或 "None"] |
| **Verification Required** | [在目标引擎版本上线前需要验证的具体行为，或 "None"] |

> **Note**: 若 Knowledge Risk 为 MEDIUM 或 HIGH，当项目升级引擎版本时，必须重新验证此 ADR。将其标记为 "Superseded" 并撰写新的 ADR。

## ADR 依赖关系（ADR Dependencies）

| Field | Value |
|-------|-------|
| **Depends On** | [ADR-NNNN（在此 ADR 可实施前必须先处于 Accepted），或 "None"] |
| **Enables** | [ADR-NNNN（本 ADR 解锁该决策），或 "None"] |
| **Blocks** | [Epic/Story 名称——在本 ADR Accepted 前无法开始，或 "None"] |
| **Ordering Note** | [未被上述字段覆盖的任何顺序约束] |

## 背景（Context）

### 问题陈述（Problem Statement）

[我们要解决什么问题？为什么现在必须做出这个决策？如果不决策，代价是什么？]

### 当前状态（Current State）

[系统当前如何运作？现有方案的问题是什么？]

### 约束（Constraints）

- [技术约束 -- 引擎限制、平台要求]
- [时间线约束 -- 截止压力、依赖关系]
- [资源约束 -- 团队规模、可用专长]
- [兼容性要求 -- 必须与现有系统协同工作]

### 需求（Requirements）

- [功能需求 1]
- [功能需求 2]
- [性能需求 -- 具体且可度量]
- [可扩展性需求]

## 决策（Decision）

[具体技术决策，描述需足够详细，使他人无需额外澄清即可实施。]

### 架构（Architecture）

```
[展示该决策所形成系统架构的 ASCII 图。
标明组件、数据流方向和关键接口。]
```

### 关键接口（Key Interfaces）

```
[该决策定义出的伪代码或特定语言接口定义。
这些将成为实施者必须遵守的契约。]
```

### 实施指南（Implementation Guidelines）

[给实现该决策的程序员的具体指导。]

## 备选方案（Alternatives Considered）

### 方案 1: [名称]

- **Description**: [该方案将如何运作]
- **Pros**: [该方案的优点]
- **Cons**: [该方案的缺点]
- **Estimated Effort**: [相对所选方案的工作量]
- **Rejection Reason**: [未被采用的原因]

### 方案 2: [名称]

[与上方相同结构]

## 影响后果（Consequences）

### 正面

- [该决策带来的正向结果]

### 负面

- [我们接受的权衡与成本]

### 中性

- [既非好也非坏、只是不同的变化]

## 风险（Risks）

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|-----------|

## 性能影响（Performance Implications）

| Metric | Before | Expected After | Budget |
|--------|--------|---------------|--------|
| CPU (frame time) | [X]ms | [Y]ms | [Z]ms |
| Memory | [X]MB | [Y]MB | [Z]MB |
| Load Time | [X]s | [Y]s | [Z]s |
| Network (if applicable) | [X]KB/s | [Y]KB/s | [Z]KB/s |

## 迁移计划（Migration Plan）

[若该决策会变更现有系统，填写逐步迁移计划。]

1. [步骤 1 -- 变更内容、破坏点、验证方式]
2. [步骤 2]
3. [步骤 3]

**Rollback plan**: [若该决策被证明错误，如何回滚]

## 验证标准（Validation Criteria）

[实施后我们如何确认该决策是正确的。]

- [ ] [可度量标准 1]
- [ ] [可度量标准 2]
- [ ] [性能标准]

## 已覆盖的 GDD 需求（GDD Requirements Addressed）

<!-- This section is MANDATORY. Every ADR must trace back to at least one GDD
     requirement, or explicitly state it is a foundational decision with no GDD
     dependency. Traceability is audited by /architecture-review. -->

| GDD Document | System | Requirement | How This ADR Satisfies It |
|-------------|--------|-------------|--------------------------|
| [e.g. `design/gdd/combat.md`] | [e.g. Combat] | [e.g. "Hitbox detection must resolve within 1 frame"] | [e.g. "Jolt physics collision queries run synchronously in _physics_process"] |

> 若这是一个没有直接 GDD 依赖的基础性决策，请写：
> "Foundational — no GDD requirement. Enables: [列出该决策解锁或约束了哪些 GDD 系统]"

## 相关项（Related）

- [关联 ADR 链接——注明是 supersedes、contradicts 或 depends on]
- [实施后关联代码文件的链接]
