# 技能测试规范：/review-all-gdds

## 技能摘要

`/review-all-gdds` 是 Opus 级技能，用于对 `design/gdd/` 中的所有文件执行整体跨 GDD
评审。它并行运行两个互补的评审阶段：阶段 1 检查一致性（矛盾、公式不匹配、过时引用、
竞争性所有权），阶段 2 检查设计理论（支配策略、支柱偏移、认知过载、经济失衡）。
由于两个阶段相互独立，因此同时生成以节省时间。技能给出 CONSISTENT / MINOR ISSUES /
MAJOR ISSUES 结论，并且是只读的：未经用户明确批准不会写入文件。

该技能本身就是流程中的整体评审门禁。它在各个 GDD 完成后、架构工作开始前调用。
它不会生成任何主管门禁代理（它本身就是主管级评审）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，无需测试夹具。

- [ ] 包含必需的前置元数据字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 5 个阶段标题（复杂的多阶段技能）
- [ ] 包含结论关键字：CONSISTENT、MINOR ISSUES、MAJOR ISSUES
- [ ] 不要求使用 "May I write" 措辞（只读技能）
- [ ] 末尾包含下一步交接
- [ ] 说明并行生成评审阶段（阶段 1 与阶段 2 相互独立）

---

## 主管门禁检查

没有主管门禁：该技能不生成任何主管门禁代理。它本身就是整体评审；委派给主管门禁会造成循环依赖。

---

## 测试用例

### 用例 1：正常路径 - 没有冲突的干净 GDD 集合

**测试夹具：**
- `design/gdd/` 至少包含 3 个系统 GDD
- 所有 GDD 内部一致：没有公式矛盾、竞争性所有权或过时引用
- 所有 GDD 均与 `design/gdd/game-pillars.md` 中定义的支柱一致

**输入：** `/review-all-gdds`

**预期行为：**
1. 技能读取 `design/gdd/` 中的全部 GDD 文件
2. 阶段 1（一致性扫描）和阶段 2（设计理论检查）并行生成
3. 阶段 1 未发现矛盾、公式不匹配或所有权冲突
4. 阶段 2 未发现支柱偏移、支配策略或认知过载
5. 技能输出包含 0 个阻塞问题的结构化发现表
6. 结论：CONSISTENT

**断言：**
- [ ] 两个评审阶段并行生成（而非依次运行）
- [ ] 输出包含发现表（即使为空，也显示 "No issues found"）
- [ ] 未发现冲突时，结论为 CONSISTENT
- [ ] 未经用户批准，技能不写入任何文件
- [ ] 包含交接到 `/architecture-review` 或 `/create-architecture` 的下一步

---

### 用例 2：失败路径 - 两个 GDD 之间存在规则冲突

**测试夹具：**
- GDD-A 定义一个下限值（例如“[output] 的最小值为 [N]”）
- GDD-B 描述一个绕过该下限的机制（例如“[mechanic] 可以将 [output] 降至 0”）
- 两个 GDD 其他方面均完整有效

**输入：** `/review-all-gdds`

**预期行为：**
1. 阶段 1（一致性扫描）检测出 GDD-A 与 GDD-B 之间的矛盾
2. 报告冲突时包含：两个文件名、具体冲突规则，以及严重程度 HIGH
3. 结论：MAJOR ISSUES
4. 交接要求用户解决冲突并在继续前重新运行

**断言：**
- [ ] 结论为 MAJOR ISSUES（不是 CONSISTENT 或 MINOR ISSUES）
- [ ] 冲突条目中列出两个 GDD 文件名
- [ ] 引用或描述具体矛盾规则（不能只写“发现冲突”）
- [ ] 问题分类为严重程度 HIGH（阻塞）
- [ ] 技能不自动解决冲突

---

### 用例 3：部分路径 - 单个 GDD 引用了孤立的依赖项

**测试夹具：**
- GDD-A 在 Dependencies 章节中列出指向 `system-B` 的依赖
- `design/gdd/` 中不存在 system-B 的 GDD
- 其他所有 GDD 均一致

**输入：** `/review-all-gdds`

**预期行为：**
1. 阶段 1 检测出 GDD-A 中孤立的依赖引用
2. 问题报告为：DEPENDENCY GAP - GDD-A 引用了没有 GDD 的 system-B
3. 未发现其他冲突
4. 结论：MINOR ISSUES（依赖缺口本身属于建议项，不构成阻塞）

**断言：**
- [ ] 结论为 MINOR ISSUES（单个孤立引用不应导致 MAJOR ISSUES）
- [ ] 报告具体 GDD 文件名和缺失的依赖名称
- [ ] 技能建议运行 `/design-system system-B` 以解决缺口
- [ ] 技能不跳过或静默忽略缺失的依赖项

---

### 用例 4：边界情况 - 找不到 GDD 文件

**测试夹具：**
- `design/gdd/` 目录为空或不存在
- 不存在任何 GDD 文件

**输入：** `/review-all-gdds`

**预期行为：**
1. 技能尝试读取 `design/gdd/` 中的文件
2. 未找到文件，技能输出错误及指导
3. 技能建议在重新运行前执行 `/brainstorm` 和 `/design-system`
4. 技能不产生结论（CONSISTENT / MINOR ISSUES / MAJOR ISSUES）

**断言：**
- [ ] 未找到 GDD 时，技能输出清晰的错误消息
- [ ] 目录为空时不产生结论
- [ ] 技能建议正确的下一步（`/brainstorm` 或 `/design-system`）
- [ ] 技能不会崩溃或生成不完整报告

---

### 用例 5：主管门禁 - 无论评审模式为何均不生成门禁

**测试夹具：**
- `design/gdd/` 至少包含 2 个一致的系统 GDD
- `production/session-state/review-mode.txt` 存在，内容为 `full`

**输入：** `/review-all-gdds`

**预期行为：**
1. 技能读取所有 GDD 并运行两个评审阶段
2. 技能不读取 `review-mode.txt`
3. 技能不生成任何主管门禁代理（以 CD-、TD-、PR-、AD- 为前缀）
4. 技能正常完成并输出结论
5. 评审模式设置不影响该技能的行为

**断言：**
- [ ] 全程不生成任何主管门禁代理
- [ ] 技能不读取 `production/session-state/review-mode.txt`
- [ ] 输出不包含任何 "Gate: [GATE-ID]" 或被跳过的门禁条目
- [ ] 无论评审模式为何，技能均产生结论
- [ ] R4 指标：该技能在所有模式下的门禁数 = 0

---

## 协议合规性

- [ ] 阶段 1（一致性）和阶段 2（设计理论）并行生成，而非依次运行
- [ ] 未经“May I write”批准不写入任何文件
- [ ] 在请求任何写入前显示发现表
- [ ] 结论必须是以下三项之一：CONSISTENT、MINOR ISSUES、MAJOR ISSUES
- [ ] 以适当的交接结束：MAJOR ISSUES → 修复后重新运行；MINOR ISSUES → 了解风险后可继续；CONSISTENT → `/create-architecture`

---

## 覆盖说明

- 经济平衡分析（资源产出/消耗循环）需要跨 GDD 的资源数据；用例 2 从结构上覆盖了这一点，
  因为冲突检测模式相同。
- 设计理论阶段（阶段 2）包含支配策略检测和认知过载检查，但没有分别使用测试夹具；
  它们遵循与一致性检查相同的模式，并通过支柱偏移用例结构进行验证。
- `since-last-review` 范围模式未在此测试；它属于运行时问题。
