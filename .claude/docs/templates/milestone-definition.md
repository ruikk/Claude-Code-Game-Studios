# 里程碑 Milestone：[名称]

## 概览 Overview

- **Target Date**: [日期]
- **Type**: [原型 Prototype | 垂直切片 Vertical Slice | Alpha | Beta | Gold | 上线后 Post-Launch]
- **Duration**: [N 周]
- **Number of Sprints**: [N]

## 里程碑目标 Milestone Goal

[用 2-3 句话说明该里程碑达成了什么，以及它为什么重要。
在该里程碑结束时，我们能够演示或评估什么？]

## 成功标准 Success Criteria

[具体且可衡量的标准。只有当以下所有条件都满足时，里程碑才算完成。]

- [ ] [标准 1 —— 具体且可测试]
- [ ] [标准 2]
- [ ] [标准 3]
- [ ] 所有 S1 和 S2 缺陷均已解决
- [ ] 在目标硬件上性能达到预算要求
- [ ] 构建在连续 [X] 天内保持稳定

## 功能清单 Feature List

### 必须交付 Must Ship（缺少即判定里程碑失败）

| Feature | Design Doc | Owner | Sprint Target | Status |
|---------|-----------|-------|--------------|--------|

### 应该交付 Should Ship（已规划但可裁剪）

| Feature | Design Doc | Owner | Sprint Target | Cut Impact | Status |
|---------|-----------|-------|--------------|-----------|--------|

### 延展目标 Stretch Goals（仅在进度领先时）

| Feature | Design Doc | Owner | Value Add |
|---------|-----------|-------|----------|

## 质量关卡检查 Quality Gates

| Gate | Threshold | Measurement Method |
|------|-----------|-------------------|
| 崩溃率 | < [X] per hour | 自动化崩溃上报 |
| 帧率 | > [X] FPS on min spec | 性能剖析 |
| 加载时间 | < [X] seconds | 自动化计时 |
| 严重缺陷 | 0 open S1 | 缺陷追踪系统 |
| 主要缺陷 | < [X] open S2 | 缺陷追踪系统 |
| 测试覆盖率 | > [X]% | 测试框架报告 |

## 风险登记 Risk Register

| Risk | Probability | Impact | Mitigation | Owner | Status |
|------|------------|--------|-----------|-------|--------|

## 依赖项 Dependencies

### 内部依赖 Internal Dependencies

| Feature | Depends On | Owner of Dependency | Status |
|---------|-----------|-------------------|--------|

### 外部依赖 External Dependencies

| Dependency | Provider | Status | Risk if Delayed |
|-----------|---------|--------|----------------|

## 评审排期 Review Schedule

| Date | Review Type | Attendees |
|------|-----------|-----------|
| [第 2 周] | 早期进度检查 | Producer, Directors |
| [中期] | 里程碑中期评审 | 全体团队 |
| [第 N-1 周] | 里程碑前评审 | 全体团队 |
| [目标日期] | 里程碑评审 | 全体团队 |
