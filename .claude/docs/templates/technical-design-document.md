# 技术设计（Technical Design）: [System Name]

## 文档状态（Document Status）
- **Version**: 1.0
- **Last Updated**: [Date]
- **Author**: [Agent/Person]
- **Reviewer**: lead-programmer
- **Related ADR**: [ADR-XXXX if applicable]
- **Related Design Doc**: [Link to game design doc this implements]

## 引擎 API 面（Engine API Surface）

| Field | Value |
|-------|-------|
| **Engine** | [e.g. Godot 4.6 / Unity 6 / Unreal Engine 5.4] |
| **APIs Depended On** | [所使用的具体类/方法/节点，需版本锁定 —— e.g. `CharacterBody3D.move_and_slide() (Godot 4.x)`] |
| **References Consulted** | [撰写前查阅过的 engine-reference 文档 —— e.g. `docs/engine-reference/godot/modules/physics.md`] |
| **Post-Cutoff Features Used** | [使用了超出 LLM 训练截止版本的引擎特性，或 "None"] |
| **Unverified Assumptions** | [已假设但尚未在目标版本中验证的 API 行为，或 "None"] |
| **Engine Upgrade Risk** | [LOW / MEDIUM / HIGH —— 若引擎版本变化，此设计的脆弱程度如何？] |

> **Rule**: 如果列出了任何 **Unverified Assumptions**，则在这些假设于真实引擎环境中完成验证前，本文档不得标记为 Accepted。

## 概述（Overview）
[用 2-3 句话概述该系统做什么，以及它为何存在]

## 需求（Requirements）
### 功能需求（Functional Requirements）
- [FR-1]: [Description]
- [FR-2]: [Description]

### 非功能需求（Non-Functional Requirements）
- **Performance**: [预算 —— e.g., "< 1ms per frame"]
- **Memory**: [预算 —— e.g., "< 50MB at peak"]
- **Scalability**: [上限 —— e.g., "Support up to 1000 entities"]
- **Thread Safety**: [Requirements]

## 架构（Architecture）

### 系统图（System Diagram）
```
[使用 ASCII 图展示组件与数据流]
```

### 组件拆解（Component Breakdown）
| Component | Responsibility | Owns |
| --------- | -------------- | ---- |
| [Name] | [它的职责] | [它拥有的数据] |

### 对外 API（Public API）
```
[用伪代码或目标语言给出接口/API 定义]
```

### 数据结构（Data Structures）
```
[关键数据结构及字段说明]
```

### 数据流（Data Flow）
[逐步说明：在典型一帧期间，数据如何在系统中流动]

## 实施计划（Implementation Plan）

### 阶段 1（Phase 1）: [Core Functionality]
- [ ] [Task 1]
- [ ] [Task 2]

### 阶段 2（Phase 2）: [Extended Features]
- [ ] [Task 3]
- [ ] [Task 4]

### 阶段 3（Phase 3）: [Optimization/Polish]
- [ ] [Task 5]

## 依赖关系（Dependencies）
| Depends On | For What |
| ---------- | -------- |
| [System] | [Reason] |

| Depended On By | For What |
| -------------- | -------- |
| [System] | [Reason] |

## 测试策略（Testing Strategy）
- **Unit Tests**: [单元层级需要验证的内容]
- **Integration Tests**: [所需的跨系统测试]
- **Performance Tests**: [需要建立的基准测试]
- **Edge Cases**: [需要测试的特定场景]

## 已知限制（Known Limitations）
[说明此设计有意不支持什么，以及原因]

## 未来考虑（Future Considerations）
[若需求演进，未来可能需要变更什么 —— 但现在不要为此提前实现]
