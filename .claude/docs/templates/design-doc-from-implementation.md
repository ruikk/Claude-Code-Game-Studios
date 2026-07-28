# [System Name] — 设计文档（Design Document）

---
**Status**: Reverse-Documented
**Source**: `[path to implementation code]`
**Date**: [YYYY-MM-DD]
**Verified By**: [User name or "pending review"]
**Implementation Status**: [Fully implemented | Partially implemented | Needs extension]
---

> **⚠️ 逆向文档说明（Reverse-Documentation Notice）**
>
> 本设计文档是在实现代码已存在之后创建的。
> 它基于代码分析与用户沟通，记录当前行为并澄清设计意图。
> 当实现尚不完整，或在逆向梳理过程中设计意图不明确时，部分章节可能不完整。

---

## 1. 概述（Overview）

**目的（Purpose）**: [What problem does this system solve?]

**范围（Scope）**: [What is included/excluded from this system?]

**当前实现（Current Implementation）**: [Brief description of what exists in code]

**设计意图（Design Intent）** (clarified):
- [Intent 1 — why this feature exists]
- [Intent 2 — what player experience it creates]
- [Intent 3 — how it fits into overall game pillars]

---

## 2. 详细规则（Detailed Rules）

### 2.1 核心机制（Core Mechanics）

[Describe the mechanics as implemented, organized clearly]

**[Mechanic 1 Name]**:
- **说明（Description）**: [What it does]
- **实现（Implementation）**: [How it works in code]
- **设计依据（Design Rationale）**: [Why it exists — from user clarification]
- **玩家体验（Player-Facing）**: [How players experience this]

**[Mechanic 2 Name]**:
- **说明（Description）**: [What it does]
- **实现（Implementation）**: [How it works]
- **设计依据（Design Rationale）**: [Why it exists]
- **玩家体验（Player-Facing）**: [Player experience]

### 2.2 规则与公式（Rules and Formulas）

**代码中发现的公式（Formulas Discovered in Code）**:

| Formula | Expression | Purpose | Verified? |
|---------|-----------|---------|-----------|
| [Formula 1] | `[mathematical expression]` | [What it calculates] | ✅ / ⚠️ needs tuning |
| [Formula 2] | `[expression]` | [Purpose] | ✅ / ⚠️ needs tuning |

**澄清（Clarifications）**:
- [Formula X]: Originally [value/approach], user clarified intent is [corrected intent]
- [Formula Y]: Implemented as [X], but should be [Y] — flagged for update

### 2.3 状态与数据（State and Data）

**数据结构（Data Structures）** (from code):
- [Data structure 1]: `[fields/properties]`
- [Data structure 2]: `[fields/properties]`

**状态机（State Machines）** (if applicable):
```
[State diagram or list of states and transitions]
```

**持久化（Persistence）**:
- Saved: [What is saved to player save file]
- Not saved: [What is session-only or recalculated]

### 2.4 集成点（Integration Points）

**依赖项（Dependencies）** (systems this depends on):
- [System 1]: [What it provides]
- [System 2]: [What it provides]

**被依赖方（Dependents）** (systems that depend on this):
- [System 3]: [How it uses this system]
- [System 4]: [How it uses this system]

**API 表面（API Surface）** (public interface):
- [Method/Function 1]: [Purpose]
- [Method/Function 2]: [Purpose]

---

## 3. 边界情况（Edge Cases）

**代码中已处理（Handled in Code）**:
- ✅ [Edge case 1]: [How it's handled]
- ✅ [Edge case 2]: [How it's handled]

**尚未处理（Not Yet Handled）** (discovered during analysis):
- ⚠️ [Edge case 3]: [What happens? Needs implementation]
- ⚠️ [Edge case 4]: [What happens? Needs implementation]

**不明确（Unclear）** (need user clarification):
- ❓ [Edge case 5]: [What should happen? Pending decision]

---

## 4. 依赖关系（Dependencies）

**技术依赖（Technical Dependencies）**:
- [Dependency 1]: [Why needed]
- [Dependency 2]: [Why needed]

**设计依赖（Design Dependencies）** (other design docs):
- [System X Design]: [How they interact]
- [System Y Design]: [How they interact]

**内容依赖（Content Dependencies）**:
- [Asset type]: [What's needed]
- [Data files]: [Required config/balance data]

---

## 5. 平衡与调优（Balance and Tuning）

**当前数值（Current Values）** (as implemented):

| Parameter | Current Value | Rationale | Needs Tuning? |
|-----------|--------------|-----------|---------------|
| [Param 1] | [value] | [Why this value] | ✅ / ⚠️ / ❌ |
| [Param 2] | [value] | [Why this value] | ✅ / ⚠️ / ❌ |

**已识别的平衡问题（Balance Concerns Identified）**:
- ⚠️ [Concern 1]: [What's wrong, suggested fix]
- ⚠️ [Concern 2]: [What's wrong, suggested fix]

**建议的平衡检查（Recommended Balance Pass）**:
- Run `/balance-check` on [specific aspect]
- Playtest with focus on [specific scenario]

---

## 6. 验收标准（Acceptance Criteria）

**已实现（What Exists）**:
- ✅ [Criterion 1]
- ✅ [Criterion 2]
- ⚠️ [Criterion 3] — partially implemented

**缺失项（What's Missing）** (not yet implemented):
- ❌ [Criterion 4] — flagged for future work
- ❌ [Criterion 5] — flagged for future work

**完成定义（Definition of Done）** (when is this system "complete"?):
- [ ] [Requirement 1]
- [ ] [Requirement 2]
- [ ] [Requirement 3]

---

## 7. 开放问题与后续工作（Open Questions and Follow-Up Work）

### 需要用户决策的问题（Questions Needing User Decision）
1. **[Question 1]**: [What needs to be decided?]
   - Option A: [Approach A]
   - Option B: [Approach B]

2. **[Question 2]**: [What needs to be decided?]

### 已标记的后续工作（Flagged Follow-Up Work）
- [ ] **Update [Formula X]**: Change from exponential to linear (per user clarification)
- [ ] **Implement [Edge Case Y]**: Handle scenario not in current code
- [ ] **Create ADR**: Document why [architectural decision] was chosen
- [ ] **Balance pass**: Run `/balance-check` on progression curve
- [ ] **Extend design doc**: When [related feature] is implemented, update this doc

---

## 8. 版本历史（Version History）

| Date | Author | Changes |
|------|--------|---------|
| [Date] | Claude (reverse-doc) | Initial reverse-documentation from `[source path]` |
| [Date] | [User] | Clarified design intent, corrected [X] |

---

**下一步（Next Steps）**:
1. [Priority 1 task based on gaps identified]
2. [Priority 2 task]
3. [Priority 3 task]

**相关技能（Related Skills）**:
- `/balance-check` — Validate formulas and progression
- `/architecture-decision` — Document technical decisions
- `/code-review` — Ensure code matches clarified design

---

*This document was generated by `/reverse-document design [path]`*
