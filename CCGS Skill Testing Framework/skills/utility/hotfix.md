# 技能测试规范：/hotfix

## 技能摘要

`/hotfix` 管理紧急修复工作流：从 `main` 创建 hotfix 分支，对已识别的文件应用针对性修复，运行 `/smoke-check` 验证修复没有引入回归，并提示用户确认合并回 `main`。每次代码变更都必须先询问“May I write to [filepath]?”。Git 操作（创建分支、合并）以 Bash 命令呈现，须经用户确认后执行。

该技能具有时效性，导演审查可事后进行，但不是阻塞性门禁。Verdict：HOTFIX COMPLETE（已应用修复、冒烟检查通过并完成合并）或 HOTFIX BLOCKED（修复引入回归或用户拒绝）。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含 verdict 关键字：HOTFIX COMPLETE、HOTFIX BLOCKED
- [ ] 代码变更包含“May I write”协议措辞
- [ ] 包含下一步交接（例如用 `/bug-report` 记录问题，或提升版本号）

---

## 导演门禁检查

无。hotfix 具有时效性。导演审查可作为事后步骤单独进行。本技能不会调用门禁。

---

## 测试用例

### 用例 1：正常路径——关键崩溃缺陷修复且冒烟检查通过

**测试夹具：**
- `main` 分支干净
- 已在 `src/gameplay/arena.gd` 中识别缺陷（进入首领竞技场时崩溃）
- 用户提供了复现步骤

**输入：** `/hotfix`（用户描述崩溃和受影响的文件）

**预期行为：**
1. 技能建议创建 hotfix 分支：`hotfix/boss-arena-crash`
2. 用户确认后，展示并确认创建分支的 Bash 命令
3. 技能识别 `arena.gd` 中的修复位置并起草变更
4. 技能询问“May I write to `src/gameplay/arena.gd`?”，获批后应用修复
5. 技能运行 `/smoke-check`，结果为 PASS
6. 技能展示合并命令，并请求用户确认合并到 `main`
7. 用户确认后执行合并，verdict 为 HOTFIX COMPLETE

**断言：**
- [ ] 在任何代码变更前创建 hotfix 分支
- [ ] 修改源文件前询问“May I write”
- [ ] 应用修复后运行 `/smoke-check`
- [ ] 合并需要用户明确确认（不是自动合并）
- [ ] 合并成功后 verdict 为 HOTFIX COMPLETE

---

### 用例 2：冒烟检查失败——HOTFIX BLOCKED

**测试夹具：**
- 已将修复应用到 `src/gameplay/arena.gd`
- `/smoke-check` 返回 FAIL：“检测到玩家生命值限制回归”

**输入：** `/hotfix`

**预期行为：**
1. 技能应用修复并运行 `/smoke-check`
2. 冒烟检查返回 FAIL，并指出具体回归
3. 技能报告：“HOTFIX BLOCKED — 冒烟检查失败：[回归详情]”
4. 技能提供选项：尝试修改后的修复、还原变更，或在用户确认风险后合并已知回归
5. 冒烟检查失败时不自动合并

**断言：**
- [ ] Verdict 为 HOTFIX BLOCKED
- [ ] 向用户原样显示冒烟检查失败信息
- [ ] 冒烟检查失败时不自动执行合并
- [ ] 向用户提供明确的后续选项

---

### 用例 3：修复已发布构建——记录版本标签并提示提升补丁版本

**测试夹具：**
- 最新 git tag 为 `v1.2.0`
- hotfix 针对 v1.2.0 发布版本中的缺陷

**输入：** `/hotfix`

**预期行为：**
1. 技能检测到当前 HEAD 是带标签的发布版本（v1.2.0）
2. 技能记录：“hotfix 目标为带标签的发布版本 v1.2.0”
3. 冒烟检查通过后，技能提示：“是否应将版本提升至 v1.2.1？”
4. 如果用户确认提升版本，技能询问“May I write to VERSION or equivalent?”
5. 版本更新并合并后，verdict 为 HOTFIX COMPLETE，并注明版本

**断言：**
- [ ] 检测并向用户展示版本标签上下文
- [ ] 合并后建议提升补丁版本（非强制）
- [ ] 提升版本需要单独的“May I write”确认
- [ ] Verdict 为 HOTFIX COMPLETE

---

### 用例 4：没有复现步骤——技能在应用修复前询问

**测试夹具：**
- 用户用模糊描述调用 `/hotfix`：“第 3 关有东西坏了”
- 未提供复现步骤

**输入：** `/hotfix`（模糊描述）

**预期行为：**
1. 技能检测到信息不足，无法识别修复位置
2. 技能询问：“请提供复现步骤以及受影响的文件或系统”
3. 提供复现步骤前，技能不会创建分支或修改文件
4. 用户提供复现步骤后开始正常 hotfix 流程

**断言：**
- [ ] 没有复现步骤时不创建分支
- [ ] 没有明确修复位置时不进行代码变更
- [ ] 复现步骤请求具体明确（不是泛泛的“请提供更多信息”）
- [ ] 用户提供复现步骤后恢复正常 hotfix 流程

---

### 用例 5：导演门禁检查——无门禁；hotfix 具有时效性

**测试夹具：**
- 已识别出带复现步骤的关键缺陷

**输入：** `/hotfix`

**预期行为：**
1. 技能完成 hotfix 工作流
2. 执行期间不启动导演代理
3. 输出中不出现门禁 ID
4. 事后导演审查（如需要）是手动后续步骤，不在此处调用

**断言：**
- [ ] 不调用导演门禁
- [ ] 不出现跳过门禁的消息
- [ ] Verdict 为 HOTFIX COMPLETE 或 HOTFIX BLOCKED，不是门禁 verdict

---

## 协议合规性

- [ ] 在任何代码变更前创建 hotfix 分支
- [ ] 修改源文件前询问“May I write”
- [ ] 应用修复后运行 `/smoke-check`
- [ ] 合并前需要用户明确确认
- [ ] 冒烟检查失败时为 HOTFIX BLOCKED，不自动合并
- [ ] Verdict 为 HOTFIX COMPLETE 或 HOTFIX BLOCKED

---

## 覆盖说明

- 一个修复需要修改多个文件时，遵循按文件询问“May I write”的相同模式，本文件未单独测试。
- hotfix 后续步骤（创建缺陷报告、更新 changelog）会在交接中建议，但不属于本技能执行测试范围。
- 合并期间的冲突解决（如果 `main` 已发生分叉）未测试；技能会显示冲突并要求用户手动解决。
