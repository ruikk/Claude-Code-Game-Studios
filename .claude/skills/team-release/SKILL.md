---
name: team-release
description: "编排发布团队：协调 release-manager、qa-lead、devops-engineer 和 producer，完成从候选版本到部署的发布流程。"
argument-hint: "[version number or 'next'] [--review full|lean|solo]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, Task, AskUserQuestion, TodoWrite
model: sonnet
---
**参数检查：** 如果未提供版本号：
1. 读取 `production/session-state/active.md` 和 `production/milestones/` 中最新的文件（如果存在），以推断目标版本。
2. 如果找到版本：报告“未提供版本参数，已从里程碑数据推断出 [version]。准备继续。”然后使用 `AskUserQuestion` 确认：“即将发布 [version]，是否正确？”
3. 如果无法确定版本：使用 `AskUserQuestion` 询问“要发布哪个版本号？（例如 v1.0.0）”，并等待用户输入后再继续。不得使用硬编码的默认版本字符串。

调用此技能时，通过结构化流水线编排发布团队。

**决策点：** 每次阶段转换时，使用 `AskUserQuestion` 将子代理的建议作为可选项
呈现给用户。先在对话中写出代理的完整分析，再用简洁标签记录决策。
必须获得用户批准后才能进入下一阶段。

## 阶段 0：确定审查模式

1. 如果参数中传入了 `--review [mode]`，使用该模式。
2. 否则读取 `production/review-mode.txt`，使用其中指定的模式。
3. 如果仍未指定，默认为 `lean`。

模式：
- `full`：按说明启动所有总监和主管门禁
- `lean`：跳过总监门禁，但 PHASE-GATE 类型除外（CD-PHASE-GATE、TD-PHASE-GATE、PR-PHASE-GATE、AD-PHASE-GATE）
- `solo`：完全不启动任何总监门禁；在没有代理门禁的情况下运行此技能

保存最终确定的模式，供后续所有阶段使用。

## 团队构成
- **release-manager**：发布分支、版本管理、变更日志、部署
- **qa-lead**：测试签核、回归测试套件、发布质量门禁
- **devops-engineer**：构建流水线、构建产物、部署自动化
- **security-engineer**：发布前安全审计（游戏具有在线/多人功能或玩家数据时调用）
- **analytics-engineer**：验证遥测事件是否正确触发，以及仪表盘是否已上线
- **community-manager**：补丁说明、发布公告、面向玩家的信息
- **producer**：Go/No-Go 决策、利益相关者沟通、排期

## 如何委派

使用 Task 工具将每位团队成员启动为子代理：
- `subagent_type: release-manager`：发布分支、版本管理、变更日志、部署
- `subagent_type: qa-lead`：测试签核、回归测试套件、发布质量门禁
- `subagent_type: devops-engineer`：构建流水线、构建产物、部署自动化
- `subagent_type: security-engineer`：在线/多人/数据功能的安全审计
- `subagent_type: analytics-engineer`：遥测事件验证和仪表盘就绪检查
- `subagent_type: community-manager`：补丁说明和发布沟通
- `subagent_type: producer`：Go/No-Go 决策、利益相关者沟通
- `subagent_type: network-programmer`：网络代码稳定性签核（游戏具有多人功能时调用）

始终在每个代理的提示词中提供完整上下文（版本号、里程碑状态、已知问题）。在流水线允许时并行启动相互独立的代理（例如，阶段 3 的代理可以同时运行）。

## 流水线

### 阶段 1：发布规划
委派给 **producer**：
- 确认所有里程碑验收标准均已满足
- 识别本次发布中延期的范围项
- 确定目标发布日期并通知团队
- 输出：包含范围确认的发布授权

### 阶段 2：候选发布版本
委派给 **release-manager**：
- 从商定的提交创建发布分支
- 更新所有相关文件中的版本号
- 使用 `/release-checklist` 生成发布检查清单
- 冻结分支：禁止功能变更，仅允许缺陷修复
- 输出：发布分支名称和检查清单

### 阶段 3：质量门禁（并行）
并行委派：
- **qa-lead**：执行完整的回归测试套件。测试所有关键路径。确认不存在 S1/S2 缺陷。完成质量签核。
- **devops-engineer**：为所有目标平台构建发布产物。验证构建干净且可复现。在 CI 中运行自动化测试。
- **security-engineer** *（游戏具有在线功能、多人功能或玩家数据时）*：执行发布前安全审计。审查身份验证、反作弊和数据隐私合规性。完成安全状况签核。
- **network-programmer** *（游戏具有多人功能时）*：签核网络代码稳定性。验证负载下的延迟补偿、重连处理和带宽使用情况。

### 阶段 4：本地化、性能和分析
进行委派（资源允许时可与阶段 3 并行）：
- 验证所有字符串均已翻译（如果有 **localization-lead**，则委派给该代理）
- 根据目标运行性能基准测试（如果有 **performance-analyst**，则委派给该代理）
- **analytics-engineer**：验证发布构建中的所有遥测事件均能正确触发。确认仪表盘正在接收数据。检查关键漏斗（新手引导、成长进程，以及适用时的商业化）是否已埋点。
- 输出：本地化、性能和分析签核

### 阶段 5：Go/No-Go
委派给 **producer**：
- 收集以下人员的签核：qa-lead、release-manager、devops-engineer、security-engineer（如果已在阶段 3 启动）、network-programmer（如果已在阶段 3 启动）和 technical-director
- 评估所有未解决问题：它们会阻止发布，还是可以随版本发布？
- 作出 Go/No-Go 决策
- 输出：发布决策及其理由

**如果 producer 宣布 NO-GO：**
- 立即呈现决策：“PRODUCER: NO-GO：[rationale, e.g., S1 bug found in Phase 3].”
- 使用 `AskUserQuestion` 提供以下选项：
  - 修复阻塞项并重新运行受影响的阶段
  - 将发布延期
  - 提供书面理由以推翻 NO-GO（用户必须提供书面说明）
- **完全跳过阶段 6**：不得创建标签、部署到预发布环境、部署到生产环境，也不得启动 community-manager。
- 生成一份部分报告，总结阶段 1–5，并说明跳过了什么（阶段 6）以及原因。
- 结论：**BLOCKED**：发布未部署。

用户选择“提供书面理由以推翻 NO-GO”后：
- 以纯文本而非控件询问：“请说明推翻 NO-GO 结论的理由。该说明将写入发布记录。”
- 等待用户提供书面理由。
- 在阶段 6 之前将理由文本嵌入部分批准记录：追加“⚠️ 推翻理由：[user's text]”字段。
- 完成后才能进入阶段 6。

### 阶段 6：部署（如果为 GO）
委派给 **release-manager** + **devops-engineer**：
- 在版本控制中为发布创建标签
- 使用 `/changelog` 生成变更日志
- 部署到预发布环境，进行最终冒烟测试
- 部署到生产环境
- 人工团队操作：发布后监控仪表盘和错误率 48 小时。在第 48 小时使用 `/retrospective` 安排后续复盘。

委派给 **community-manager**（与部署并行）：
- 使用 `/patch-notes [version]` 完成补丁说明
- 准备发布公告（商店页面更新、社交媒体、社区帖子）
- 如果随版本发布了任何 S3+ 问题，起草已知问题公告
- 输出：所有面向玩家的发布沟通内容，在确认部署后即可发布

### 阶段 7：发布后
- **release-manager**：生成发布报告（已发布内容、延期内容、指标）
- **producer**：更新里程碑跟踪信息，与利益相关者沟通
- **qa-lead**：监控新收到的缺陷报告，排查回归问题
- **community-manager**：发布所有面向玩家的沟通内容，监控社区舆情
- **analytics-engineer**：确认线上仪表盘运行正常；如缺失任何关键事件，发出警报
- 如果发生问题，安排发布后复盘

## 错误恢复协议

如果通过 Task 启动的任何代理返回 BLOCKED、报错或无法完成任务：

1. **立即呈现**：在继续执行依赖阶段之前，向用户报告“[AgentName]: BLOCKED：[reason]”
2. **评估依赖项**：检查后续阶段是否需要被阻塞代理的输出。如果需要，在获得用户输入前不得越过该依赖点。
3. **提供选项**：通过 AskUserQuestion 提供以下选择：
   - 跳过此代理，并在最终报告中注明缺口
   - 缩小范围后重试
   - 在此停止，先解决阻塞项
4. **始终生成部分报告**：输出所有已完成的内容。不得因一个代理被阻塞而丢弃工作成果。

常见阻塞项：
- 缺少输入文件（找不到故事、缺少 GDD）→ 转到创建该文件的技能
- ADR 状态为 Proposed → 不得实施；先运行 `/architecture-decision`
- 范围过大 → 通过 `/create-stories` 拆分为两个故事
- ADR 与故事中的指令冲突 → 明确呈现冲突，不要猜测

## 文件写入协议

所有文件写入（发布检查清单、变更日志、补丁说明、部署脚本）均委派给子代理和子技能。
每个子代理和子技能都执行“可以写入 [path] 吗？”协议。
此编排器不直接写入文件。

## 输出

生成一份摘要报告，涵盖：发布版本、范围、质量门禁结果、Go/No-Go 决策、部署状态和监控计划。

结论：**COMPLETE**：发布已执行并部署。
结论：**BLOCKED**：发布已停止；Go/No-Go 决策为 NO，或仍有硬性阻塞项未解决。

## 后续步骤

- 发布后监控仪表盘 48 小时。
- 如果发布期间发生重大问题，运行 `/retrospective`。
- 成功部署后，将 `production/stage.txt` 更新为 `Live`。
