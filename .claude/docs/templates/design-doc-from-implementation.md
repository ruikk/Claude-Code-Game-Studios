# [System Name] — 设计文档（Design Document）

---
**Status**: Reverse-Documented
**Source**: `[path to implementation code]`
**Date**: [YYYY-MM-DD]
**Verified By**: [User name or "pending review"]
**Implementation Status**: [Fully implemented | Partially implemented | Needs extension]
---

> **⚠️ Reverse-Documentation Notice（逆向文档说明）**
>
> 本设计文档是在实现代码已存在之后创建的。
> 它基于代码分析与用户沟通，记录当前行为并澄清设计意图。
> 当实现尚不完整，或在逆向梳理过程中设计意图不明确时，部分章节可能不完整。

---

## 1. Overview（概述）

**Purpose（目的）**: [What problem does this system solve?]

**Scope（范围）**: [What is included/excluded from this system?]

**Current Implementation（当前实现）**: [Brief description of what exists in code]

**Design Intent（设计意图）** (clarified):
- [Intent 1 — why this feature exists]
- [Intent 2 — what player experience it creates]
- [Intent 3 — how it fits into overall game pillars]

---

## 2. Detailed Design（详细设计）

### 2.1 Core Mechanics（核心机制）

[Describe the mechanics as implemented, organized clearly]

**[Mechanic 1 Name]**:
- **Description（说明）**: [What it does]
- **Implementation（实现）**: [How it works in code]
- **Design Rationale（设计依据）**: [Why it exists — from user clarification]
- **Player-Facing（玩家体验）**: [How players experience this]

**[Mechanic 2 Name]**:
- **Description（说明）**: [What it does]
- **Implementation（实现）**: [How it works]
- **Design Rationale（设计依据）**: [Why it exists]
- **Player-Facing（玩家体验）**: [Player experience]

### 2.2 Rules and Formulas（规则与公式）

**Formulas Discovered in Code（代码中发现的公式）**:

| Formula | Expression | Purpose | Verified? |
|---------|-----------|---------|-----------|
| [Formula 1] | `[mathematical expression]` | [What it calculates] | ✅ / ⚠️ needs tuning |
| [Formula 2] | `[expression]` | [Purpose] | ✅ / ⚠️ needs tuning |

**Clarifications（澄清）**:
- [Formula X]: Originally [value/approach], user clarified intent is [corrected intent]
- [Formula Y]: Implemented as [X], but should be [Y] — flagged for update

### 2.3 State and Data（状态与数据）

**Data Structures（数据结构）** (from code):
- [Data structure 1]: `[fields/properties]`
- [Data structure 2]: `[fields/properties]`

**State Machines（状态机）** (if applicable):
```
[State diagram or list of states and transitions]
```

**Persistence（持久化）**:
- Saved: [What is saved to player save file]
- Not saved: [What is session-only or recalculated]

### 2.4 Integration Points（集成点）

**Dependencies（依赖项）** (systems this depends on):
- [System 1]: [What it provides]
- [System 2]: [What it provides]

**Dependents（被依赖方）** (systems that depend on this):
- [System 3]: [How it uses this system]
- [System 4]: [How it uses this system]

**API Surface（API 表面）** (public interface):
- [Method/Function 1]: [Purpose]
- [Method/Function 2]: [Purpose]

---

## 3. Edge Cases（边界情况）

**Handled in Code（代码中已处理）**:
- ✅ [Edge case 1]: [How it's handled]
- ✅ [Edge case 2]: [How it's handled]

**Not Yet Handled（尚未处理）** (discovered during analysis):
- ⚠️ [Edge case 3]: [What happens? Needs implementation]
- ⚠️ [Edge case 4]: [What happens? Needs implementation]

**Unclear（不明确）** (need user clarification):
- ❓ [Edge case 5]: [What should happen? Pending decision]

---

## 4. Dependencies（依赖关系）

**Technical Dependencies（技术依赖）**:
- [Dependency 1]: [Why needed]
- [Dependency 2]: [Why needed]

**Design Dependencies（设计依赖）** (other design docs):
- [System X Design]: [How they interact]
- [System Y Design]: [How they interact]

**Content Dependencies（内容依赖）**:
- [Asset type]: [What's needed]
- [Data files]: [Required config/balance data]

---

## 5. Balance and Tuning（平衡与调优）

**Current Values（当前数值）** (as implemented):

| Parameter | Current Value | Rationale | Needs Tuning? |
|-----------|--------------|-----------|---------------|
| [Param 1] | [value] | [Why this value] | ✅ / ⚠️ / ❌ |
| [Param 2] | [value] | [Why this value] | ✅ / ⚠️ / ❌ |

**Balance Concerns Identified（已识别的平衡问题）**:
- ⚠️ [Concern 1]: [What's wrong, suggested fix]
- ⚠️ [Concern 2]: [What's wrong, suggested fix]

**Recommended Balance Pass（建议的平衡检查）**:
- Run `/balance-check` on [specific aspect]
- Playtest with focus on [specific scenario]

---

## 6. Acceptance Criteria（验收标准）

**What Exists（已实现）**:
- ✅ [Criterion 1]
- ✅ [Criterion 2]
- ⚠️ [Criterion 3] — partially implemented

**What's Missing（缺失项）** (not yet implemented):
- ❌ [Criterion 4] — flagged for future work
- ❌ [Criterion 5] — flagged for future work

**Definition of Done（完成定义）** (when is this system "complete"?):
- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]

---

## 7. Open Questions and Follow-Up Work（开放问题与后续工作）

### Questions Needing User Decision（需要用户决策的问题）
1. **[Question 1]**: [What needs to be decided?]
   - Option A: [Approach A]
   - Option B: [Approach B]

2. **[Question 2]**: [What needs to be decided?]

### Flagged Follow-Up Work（已标记的后续工作）
- [ ] **Update [Formula X]**: Change from exponential to linear (per user clarification)
- [ ] **Implement [Edge Case Y]**: Handle scenario not in current code
- [ ] **Create ADR**: Document why [architectural decision] was chosen
- [ ] **Balance pass**: Run `/balance-check` on progression curve
- [ ] **Extend design doc**: When [related feature] is implemented, update this doc

---

## 8. Version History（版本历史）

| Date | Author | Changes |
|------|--------|---------|
| [Date] | Claude (reverse-doc) | Initial reverse-documentation from `[source path]` |
| [Date] | [User] | Clarified design intent, corrected [X] |

---

**Next Steps（下一步）**:
1. [Priority 1 task based on gaps identified]
2. [Priority 2 task]
3. [Priority 3 task]

**Related Skills（相关技能）**:
- `/balance-check` — Validate formulas and progression
- `/architecture-decision` — Document technical decisions
- `/code-review` — Ensure code matches clarified design

---

*This document was generated by `/reverse-document design [path]`*
