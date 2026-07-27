# [Prototype Name] — 概念文档（Concept Document）

---
**Status**: 从原型反向文档化（Reverse-Documented from Prototype）
**Prototype Path**: `prototypes/[name]/`
**Date**: [YYYY-MM-DD]
**Creator**: [User name]
**Outcome**: [Success | Partial Success | Failed | Needs More Testing]
---

> **⚠️ 反向文档化说明（Reverse-Documentation Notice）**
>
> 本概念文档是在原型构建**之后**创建的。它记录了通过原型验证过程中发现的核心机制、经验教训与设计洞察。
> 这是对实验性工作的正式化整理，而非预先规划的设计。

---

## 1. 原型概览（Prototype Overview）

**Original Hypothesis**:
[这个原型在验证什么问题或想法？]

**Approach**:
[原型是如何构建的？快速粗糙实现？聚焦单一机制？]

**Duration**:
- Time spent: [X hours/days]
- Complexity: [Throwaway | Could be production-ready | Needs full rewrite]

**Outcome**（细化）:
- ✅ **Validated**: [哪些内容有效并应继续推进]
- ⚠️ **Needs Work**: [哪些内容有潜力但需要打磨]
- ❌ **Invalidated**: [哪些内容无效并应放弃]

---

## 2. 核心机制（Core Mechanic）

**What the Prototype Does**:
[描述被原型化的机制或系统]

**How It Feels**（用户反馈）:
- [感受 1 — 例如：“令人满足（Satisfying）”、“手感生硬（Clunky）”、“过于复杂（Too complex）”]
- [感受 2 — 例如：“直观（Intuitive）”、“困惑（Confusing）”、“需要教程（Needs tutorial）”]
- [感受 3 — 例如：“有趣（Fun）”、“无聊（Boring）”、“有潜力（Has potential）”]

**玩家幻想（Player Fantasy）**:
[该机制创造了什么幻想或体验？]

**核心循环（Core Loop）**（如适用）:
```
[Action 1] → [Result 1] → [Action 2] → [Result 2] → [Repeat or Conclude]
```

**涌现行为（Emergent Behaviors）**（非预期但有趣）:
- [行为 1]: [玩家做了哪些原本未计划的行为]
- [行为 2]: [意外策略或交互]

---

## 3. 有效之处（What Worked）

### 机制成功点（Mechanic Successes）

✅ **[Success 1]**: [哪里做得好]
- **Why**: [成功原因]
- **Keep for Production**: [是否应在正式版本中保留？]

✅ **[Success 2]**: [哪里做得好]
- **Why**: [成功原因]
- **Keep for Production**: [是否应在正式版本中保留？]

### 技术成功点（Technical Successes）

✅ **[Technical win 1]**: [哪种技术方案有效]
- **Lesson**: [学到了什么]
- **Reusable**: [该代码/方案能否用于正式版本？]

✅ **[Technical win 2]**: [哪里有效]
- **Lesson**: [学到了什么]

---

## 4. 无效之处（What Didn't Work）

### 机制失败点（Mechanic Failures）

❌ **[Failure 1]**: [哪里无效]
- **Why**: [根因]
- **Could It Be Fixed**: [可挽救还是根本性缺陷？]

❌ **[Failure 2]**: [哪里无效]
- **Why**: [根因]
- **Could It Be Fixed**: [Yes/No + how]

### 技术失败点（Technical Failures）

❌ **[Technical issue 1]**: [引发问题的点]
- **Lesson**: [在正式版本中应避免什么]

❌ **[Technical issue 2]**: [引发问题的点]
- **Lesson**: [应避免什么]

---

## 5. 需要优化之处（What Needs Refinement）

⚠️ **[Element 1]**: [有潜力但需要改进的点]
- **Issue**: [当前问题]
- **Path Forward**: [改进路径]
- **Effort**: [Small | Medium | Large refactor]

⚠️ **[Element 2]**: [需要优化的点]
- **Issue**: [当前问题]
- **Path Forward**: [改进方案]
- **Effort**: [Estimate]

---

## 6. 关键洞察（Key Learnings）

### 设计洞察（Design Insights）

💡 **[Insight 1]**: [关于游戏设计学到的内容]
- **Implication**: [这将如何影响后续工作]

💡 **[Insight 2]**: [设计层面的学习]
- **Implication**: [对游戏设计文档（GDD）或其他系统的影响]

### 技术洞察（Technical Insights）

💡 **[Insight 3]**: [技术层面的学习]
- **Implication**: [架构或实现指导]

💡 **[Insight 4]**: [技术层面的学习]
- **Implication**: [未来技术决策]

### 玩家心理洞察（Player Psychology Insights）

💡 **[Insight 5]**: [关于玩家行为学到的内容]
- **Implication**: [这将如何影响设计哲学]

---

## 7. 量产就绪评估（Production Readiness Assessment）

**Should This Become a Full Feature?**: [Yes | No | Needs More Testing | Pivot to Different Approach]

**If Yes — Production Requirements**:
- [ ] [Requirement 1 — e.g., "Rewrite for performance"]
- [ ] [Requirement 2 — e.g., "Add proper UI"]
- [ ] [Requirement 3 — e.g., "Design 10 more variations"]
- [ ] [Requirement 4 — e.g., "Integrate with progression system"]

**Estimated Production Effort**: [Small | Medium | Large]
- Prototype reusability: [X%] of code can be kept
- From-scratch effort: [X hours/days to production-ready]

**If No — Why Not?**:
- [Reason 1 — e.g., "Fun but doesn't fit game pillars"]
- [Reason 2 — e.g., "Too complex for target audience"]
- [Reason 3 — e.g., "Technically infeasible at scale"]

**If Pivot — Suggested Direction**:
- [Alternative approach 1]
- [Alternative approach 2]

---

## 8. 与设计支柱的一致性（Design Pillars Alignment）

**How This Relates to Game Pillars**（若已定义游戏支柱）:

| Pillar | Alignment | Notes |
|--------|-----------|-------|
| [Pillar 1] | ✅ Strong / ⚠️ Weak / ❌ Conflicts | [Explanation] |
| [Pillar 2] | ✅ Strong / ⚠️ Weak / ❌ Conflicts | [Explanation] |
| [Pillar 3] | ✅ Strong / ⚠️ Weak / ❌ Conflicts | [Explanation] |

**Overall Pillar Fit**: [这个机制是否属于当前游戏？]

---

## 9. 下一步（Next Steps）

### 立即执行（若继续推进）

1. **[Task 1]**: [e.g., "Create full design doc for this system"]
2. **[Task 2]**: [e.g., "Write ADR for technical approach"]
3. **[Task 3]**: [e.g., "Add to backlog for Sprint X"]

### 进入量产前（若仍需完善）

1. **[Task 1]**: [e.g., "Build second prototype testing X variation"]
2. **[Task 2]**: [e.g., "Playtest with 5+ people"]
3. **[Task 3]**: [e.g., "Investigate technical feasibility of Y"]

### 若决定放弃

1. **[Task 1]**: [e.g., "Archive prototype with this document"]
2. **[Task 2]**: [e.g., "Extract reusable code/learnings"]
3. **[Task 3]**: [e.g., "Update game pillars if this changed thinking"]

---

## 10. 技术备注（Technical Notes）

**Prototype Implementation**:
- Language/Engine: [使用了什么]
- Architecture: [结构如何组织]
- Shortcuts taken: [哪些部分是临时/一次性实现]

**Reusable Code**（如有）:
- `[file/path 1]`: [其作用、可复用性]
- `[file/path 2]`: [其作用、可复用性]

**Technical Debt**（若进入量产）:
- [Debt 1]: [哪些内容需要重写]
- [Debt 2]: [哪些内容需要正规实现]

---

## 11. 可玩性测试反馈（Playtest Feedback）

*(若原型已进行可玩性测试)*

**Testers**: [N people, [internal/external]]

**Positive Feedback**:
- "[Quote 1]" — [Tester name/role]
- "[Quote 2]" — [Tester name/role]

**Negative Feedback**:
- "[Quote 1]" — [Tester name/role]
- "[Quote 2]" — [Tester name/role]

**Suggestions**:
- "[Suggestion 1]" — [Tester name]
- "[Suggestion 2]" — [Tester name]

**Themes**:
- [Theme 1]: [多个测试者一致认同的点]
- [Theme 2]: [共性反馈]

---

## 12. 相关工作（Related Work）

**Inspired By**（受哪些游戏/机制启发）:
- [Game 1]: [对应机制或体验]
- [Game 2]: [借鉴或改编了什么]

**Differs From**（独特性或差异点）:
- [Difference 1]
- [Difference 2]

**Integrates With**（与现有系统的集成）:
- [System 1]: [如何连接]
- [System 2]: [如何连接]

---

## 13. 待解问题（Open Questions）

**Design Questions**:
1. **[Question 1]**: [设计上还有哪些未决问题？]
2. **[Question 2]**: [哪些内容需要可玩性测试或迭代？]

**Technical Questions**:
3. **[Question 3]**: [还存在哪些技术未知项？]
4. **[Question 4]**: [哪些内容需要可行性验证？]

---

## 14. 附录：原型资产（Appendix: Prototype Assets）

**Code**:
- Location: `prototypes/[name]/src/`
- Status: [Archival | Partial reuse | Full reuse]

**Art/Audio**（如有）:
- Location: `prototypes/[name]/assets/`
- Status: [Placeholder | Production-ready | Needs replacement]

**Documentation**:
- README: [Exists | Missing]
- Build instructions: [Exists | Missing]

---

## 版本历史（Version History）

| Date | Author | Changes |
|------|--------|---------|
| [Date] | Claude (reverse-doc) | Initial concept doc from prototype analysis |
| [Date] | [User] | Clarified outcomes, added playtest feedback |

---

**Final Recommendation**: [GO | NO-GO | PIVOT]

**Rationale**: [1-2 sentence summary of why]

---

*This concept document was generated by `/reverse-document concept prototypes/[name]`*
