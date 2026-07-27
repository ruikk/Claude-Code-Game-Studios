# 技能测试规范：/onboard

## 技能摘要

`/onboard` 为新团队成员生成上下文相关的项目入职摘要。它读取 CLAUDE.md、`technical-preferences.md`、当前迭代文件、最近的 Git 提交和 `production/stage.txt`，生成结构化的入职说明。技能运行在 Haiku 模型上（只读、格式化任务），不写入文件，所有输出均为对话内容。

技能可选接受角色参数（例如 `/onboard artist`），以针对特定专业领域定制摘要。当项目处于早期阶段或尚未配置时，输出会根据已知的有限信息调整。Verdict 始终为 ONBOARDING COMPLETE，该技能纯粹提供信息。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含 verdict 关键字：ONBOARDING COMPLETE
- [ ] 不包含“May I write”措辞（该技能为只读）
- [ ] 包含建议相关后续技能的下一步交接

---

## 导演门禁检查

无。`/onboard` 是只读入职说明技能，不适用导演门禁。

---

## 测试用例

### 用例 1：正常路径——已配置项目处于 Production 阶段且存在当前迭代

**测试夹具：**
- `production/stage.txt` 包含 `Production`
- `technical-preferences.md` 已填写引擎、语言和 specialists
- `production/sprints/sprint-005.md` 存在，且包含进行中的故事
- Git log 包含最近 5 次提交

**输入：** `/onboard`

**预期行为：**
1. 技能读取 `stage.txt`、`technical-preferences.md`、当前迭代和 `git log`
2. 技能生成包含以下部分的入职摘要：项目概览、技术栈、当前阶段、活跃迭代摘要、最近活动
3. 摘要采用便于阅读的格式（标题、项目符号）
4. 下一步建议适用于 Production 阶段（例如 `/sprint-status`、`/dev-story`）
5. 声明 Verdict ONBOARDING COMPLETE

**断言：**
- [ ] 输出包含来自 stage.txt 的当前阶段名称
- [ ] 输出包含来自 technical-preferences.md 的引擎和语言
- [ ] 摘要包含当前迭代故事，而不只是迭代文件名
- [ ] 包含最近提交的上下文
- [ ] Verdict 为 ONBOARDING COMPLETE
- [ ] 不写入文件

---

### 用例 2：全新项目——没有引擎和迭代，建议 /start

**测试夹具：**
- `technical-preferences.md` 只包含占位符（`[TO BE CONFIGURED]`）
- 没有 `production/stage.txt`
- 没有迭代文件
- 除默认值外没有 CLAUDE.md 覆盖配置

**输入：** `/onboard`

**预期行为：**
1. 技能读取所有配置文件并检测到尚未配置状态
2. 技能生成最小摘要：“此项目尚未配置”
3. 输出说明入职工作流：`/start` → `/setup-engine` → `/brainstorm`
4. 技能建议立即运行 `/start`
5. Verdict 为 ONBOARDING COMPLETE（仅供参考，不是失败）

**断言：**
- [ ] 输出明确说明项目尚未配置
- [ ] 建议 `/start` 作为下一步
- [ ] 技能不会报错，而是优雅处理空项目状态
- [ ] Verdict 仍为 ONBOARDING COMPLETE

---

### 用例 3：找不到 CLAUDE.md——错误及补救措施

**测试夹具：**
- `CLAUDE.md` 文件不存在（已删除或从未创建）
- 其他文件可能存在，也可能不存在

**输入：** `/onboard`

**预期行为：**
1. 技能尝试读取 CLAUDE.md，但失败
2. 技能输出错误：“未找到 CLAUDE.md——无法生成入职摘要”
3. 技能提供补救措施：“运行 `/start` 初始化项目配置”
4. 不生成部分摘要

**断言：**
- [ ] 错误消息明确指出缺失文件是 CLAUDE.md
- [ ] 明确写出补救步骤（`/start`）
- [ ] 根配置缺失时技能不生成部分输出
- [ ] Verdict 为 ONBOARDING COMPLETE（包含错误上下文，不发生崩溃）

---

### 用例 4：角色专属入职——用户指定“artist”角色

**测试夹具：**
- 已完整配置且处于 Production 阶段的项目
- `design/` 中存在 `art-bible.md`
- 当前迭代包含视觉故事类型（animation、VFX）

**输入：** `/onboard artist`

**预期行为：**
1. 技能读取所有标准文件，以及相关美术文档（美术圣经、资产规格）
2. 摘要针对 `artist` 角色定制：美术圣经概览、资产管线、当前迭代中的视觉故事
3. 弱化技术架构细节（代码结构、ADR）
4. 在摘要中突出美术/音频领域的专业代理
5. Verdict 为 ONBOARDING COMPLETE

**断言：**
- [ ] 输出确认角色参数（“入职角色：Artist”）
- [ ] 文件存在时包含美术圣经摘要
- [ ] 展示当前迭代中的视觉故事
- [ ] 技术实现细节不是主要重点
- [ ] Verdict 为 ONBOARDING COMPLETE

---

### 用例 5：导演门禁检查——无门禁；`onboard` 是只读入职说明

**测试夹具：**
- 任意已配置的项目状态

**输入：** `/onboard`

**预期行为：**
1. 技能完成完整入职摘要
2. 任意时刻都不启动导演代理
3. 输出中不出现门禁 ID
4. 不出现“May I write”提示

**断言：**
- [ ] 不调用导演门禁
- [ ] 不调用写入工具
- [ ] 不出现跳过门禁的消息
- [ ] 不执行任何门禁检查，verdict 为 ONBOARDING COMPLETE

---

## 协议合规性

- [ ] 生成输出前读取所有源文件（不臆测项目状态）
- [ ] 根据项目阶段调整输出（Production ≠ Concept）
- [ ] 提供角色参数时遵循该参数
- [ ] 不写入任何文件
- [ ] 所有路径最后均以 ONBOARDING COMPLETE verdict 结束

---

## 覆盖说明

- `technical-preferences.md` 完全缺失（而不是包含占位符）的情况未单独测试；行为遵循用例 3 的优雅错误模式。
- 假定可以读取 Git 历史；离线或没有 git 的场景未在此测试。
- 除“artist”之外的专业角色（例如 programmer、designer、producer）遵循用例 4 的相同定制模式，未单独测试。
