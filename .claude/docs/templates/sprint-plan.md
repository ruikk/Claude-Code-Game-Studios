# 迭代 [N] -- [Start Date] to [End Date]

## 迭代目标 / Sprint Goal

[一句话：这个迭代将如何推动当前里程碑？]

## 里程碑背景 / Milestone Context

- **当前里程碑**: [Name]
- **里程碑截止日期**: [Date]
- **剩余迭代数**: [N]

## 产能 / Capacity

- **Total days**: [X]
- **Buffer (20%)**: [Y days reserved for unplanned work]
- **Available**: [Z days]

## 任务 / Tasks

### 必须完成（关键路径）/ Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria | Status |
|----|------|-------------|-----------|-------------|-------------------|--------|
| S[N]-001 | | | | None | | Not Started |
| S[N]-002 | | | | S[N]-001 | | Not Started |

### 应该完成 / Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria | Status |
|----|------|-------------|-----------|-------------|-------------------|--------|
| S[N]-010 | | | | | | Not Started |

### 可选完成（优先砍掉）/ Nice to Have (Cut First)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria | Status |
|----|------|-------------|-----------|-------------|-------------------|--------|
| S[N]-020 | | | | | | Not Started |

## 来自迭代 [N-1] 的结转项 / Carryover from Sprint [N-1]

| Original ID | Task | Reason for Carryover | New Estimate | Priority Change |
|------------|------|---------------------|-------------|----------------|

## 本迭代风险 / Risks to This Sprint

| Risk | Probability | Impact | Mitigation | Owner |
|------|------------|--------|-----------|-------|

## 外部依赖 / External Dependencies

| Dependency | Status | Impact if Delayed | Contingency |
|-----------|--------|------------------|-------------|

## 完成定义 / Definition of Done

- [ ] 所有必须完成的任务都已完成
- [ ] 所有任务通过验收标准
- [ ] 已有 QA 计划 (`production/qa/qa-plan-sprint-[N].md`)
- [ ] 所有逻辑/集成故事的单元/集成测试均已通过
- [ ] 烟雾测试通过 (`/smoke-check sprint`)
- [ ] QA 签核报告：批准或有条件批准 (`/team-qa sprint`)
- [ ] 已交付功能中无 S1 或 S2 级别的 bug
- [ ] 对任何偏差的设计文档已更新
- [ ] 代码已审查并合并
