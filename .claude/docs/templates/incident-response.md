# Incident Response: [事件标题]

**Severity**: [S1-Critical / S2-Major / S3-Moderate / S4-Minor]
**Status**: [Active / Mitigated / Resolved / Post-Mortem Complete]
**Detected**: [Date Time UTC]
**Resolved**: [Date Time UTC or ONGOING]
**Duration**: [从检测到解决的总时长]
**Incident Commander**: [姓名/角色]

---

## 影响摘要（Impact Summary）

[用 2-3 句话描述玩家实际体验到的问题。请从玩家视角撰写，而非技术视角。]

- **Players affected**: [估算人数或百分比]
- **Platforms affected**: [PC / Console / Mobile / All]
- **Regions affected**: [All / 特定地区]
- **Revenue impact**: [如适用，填写估算值]

---

## 时间线（Timeline）

| Time (UTC) | Event | Action Taken |
| ---- | ---- | ---- |
| [HH:MM] | 通过 [monitoring/player report/etc.] 检测到事件 | 已指定 incident commander |
| [HH:MM] | 已识别根因 | [原因简述] |
| [HH:MM] | 已部署缓解措施 | [执行了什么] |
| [HH:MM] | 服务恢复 / 修复确认 | 持续监控是否复发 |
| [HH:MM] | 宣布全部解除警报 | 已安排 post-mortem |

---

## 根因（Root Cause）

### 发生了什么（What Happened）
[根因的技术描述。请明确说明导致该事件的事件链。]

### 为什么会发生（Why It Happened）
[系统性原因——为什么现有流程、测试或防护机制未能阻止该问题？这比技术层面的原因更重要。]

### 促成因素（Contributing Factors）
- [因素 1 —— 例如："新 matchmaking system 的负载测试不足"]
- [因素 2 —— 例如："监控告警阈值设置过高"]
- [因素 3]

---

## 缓解与解决（Mitigation and Resolution）

### 即时行动（事件期间）
1. [为止血采取的行动]
2. [为恢复服务采取的行动]
3. [为验证问题已解决采取的行动]

### 后续行动（解决之后）
1. [若即时行动是临时绕行方案，则填写永久修复]
2. [补充的测试或监控项]
3. [用于防止复发的流程变更]

---

## 玩家沟通（Player Communication）

### 初次确认公告（Initial Acknowledgment）
*Sent: [Time] via [channel]*
> [首次公开确认问题的原文]

### 状态更新（Status Updates）
*Sent: [Time] via [channel]*
> [每次后续更新的文本]

### 解决通知（Resolution Notice）
*Sent: [Time] via [channel]*
> [宣布修复完成及补偿信息的文本]

### 补偿（如适用）
- **What**: [补偿内容描述 —— 例如："500 premium currency + 24-hour XP boost"]
- **Who**: [all players / 仅受影响玩家 / 事件期间登录过的玩家]
- **When**: [发放日期与方式]
- **Rationale**: [该补偿与影响程度匹配的理由]

---

## 预防（Prevention）

### 我们将进行的改进（What We Are Changing）

| Action Item | Owner | Deadline | Status |
| ---- | ---- | ---- | ---- |
| [具体预防措施] | [Role] | [Date] | [TODO/Done] |
| [为 X 增加监控] | [Role] | [Date] | [TODO/Done] |
| [为 Y 增加测试覆盖] | [Role] | [Date] | [TODO/Done] |
| [更新 Z 的 runbook] | [Role] | [Date] | [TODO/Done] |

### 流程改进（Process Improvements）
- [防止类似事件的流程改进]
- [监控/告警改进]
- [测试改进]

---

## 经验复盘（Lessons Learned）

### 做得好的方面（What Went Well）
- [事件响应中的积极点 —— 例如："由于监控告警，检测速度很快"]
- [积极点]

### 做得不好的方面（What Went Poorly）
- [响应过程中的问题 —— 例如："花了 20 分钟才找到正确的值班人员"]
- [问题]

### 运气成分（Where We Got Lucky）
- [靠偶然而非设计减少影响的因素 —— 这是需要处理的隐性风险]

---

## 签核（Sign-Offs）

- [ ] Technical Director — 根因准确，预防方案充分
- [ ] QA Lead — 测试覆盖缺口已补齐
- [ ] Producer — 时间线与沟通内容已审阅
- [ ] Community Manager — 玩家沟通内容已审阅

---

*本文档归档于 `production/hotfixes/`，并从修复版本的 release notes 进行链接。*
