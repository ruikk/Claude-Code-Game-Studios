---
name: security-audit
description: "审计游戏中的安全漏洞：存档篡改、作弊途径、网络攻击、数据暴露和输入验证缺口。生成包含修复指导的优先级安全报告。在任何公开发布或多人游戏上线前运行。"
argument-hint: "[full | network | save | input | quick]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash, Write, Task
model: sonnet
agent: security-engineer
---

# 安全审计

对于任何已发布的游戏，安全性都不是可选项。即使是单人游戏也存在
存档篡改途径。多人游戏还面临作弊面、数据暴露风险和拒绝服务的可能性。
此技能会系统地审计代码库中最常见的游戏安全问题，并生成按优先级排列的
修复计划。

**运行此技能：**
- 任何公开发布前（Polish → Release 门禁要求）
- 启用任何在线/多人功能前
- 实现任何读取磁盘或网络的系统后
- 报告安全相关缺陷时

**输出：** `production/security/security-audit-[date].md`

---

## 阶段 1：解析参数和范围

**模式：**
- `full` — 所有类别（发布前推荐）
- `network` — 仅网络/多人
- `save` — 仅存档文件和序列化
- `input` — 仅输入验证和注入
- `quick` — 仅高严重性检查（最快，适合迭代使用）
- 无参数 — 运行 `full`

读取 `.claude/docs/technical-preferences.md` 以确定：
- 引擎和语言（影响要搜索的模式）
- 目标平台（影响适用的攻击面）
- 多人/网络是否在范围内

---

## 阶段 2：启动安全工程师

通过 Task 启动 `security-engineer`。传入：
- 审计范围/模式
- 技术偏好中的引擎和语言
- 所有源代码目录的清单：`src/`、`assets/data/` 以及所有配置文件

security-engineer 会针对 6 个类别运行审计（见阶段 3）。在继续前收集其完整发现。

---

## 阶段 3：审计类别

security-engineer 会评估以下每个类别。跳过不适用于项目范围的类别。

### 类别 1：存档文件和序列化安全
- 存档文件是否在加载前经过验证？（不得盲目反序列化）
- 存档文件路径是否由用户输入构造？（路径遍历风险）
- 存档文件是否经过校验和或签名？（篡改检测）
- 游戏是否在未进行范围检查的情况下信任存档文件中的数值？
- 存档加载附近是否存在任何 eval() 或动态代码执行调用？

Grep 模式：`File.open`、`load`、`deserialize`、`JSON.parse`、`from_json`、`read_file` — 检查每处是否有验证。

### 类别 2：网络和多人游戏安全（仅单人游戏时跳过）
- 游戏状态是否由服务器负责权威判定，还是由客户端决定结果？
- 传入的网络数据包是否针对大小、类型和值范围进行验证？
- 玩家位置和状态变化是否在服务器端验证？
- 网络调用是否有速率限制？
- 身份验证令牌是否得到正确处理（绝不以明文发送）？
- 发布构建是否暴露任何调试端点？

搜索：`recv`、`receive`、`PacketPeer`、`socket`、`NetworkedMultiplayerPeer`、`rpc`、`rpc_id` — 检查每个调用点是否有验证。

### 类别 3：输入验证
- 是否有玩家提供的字符串被用于文件路径？（路径遍历）
- 是否有玩家提供的字符串未经清理就写入日志？（日志注入）
- 数值输入（例如物品数量、角色属性）是否在使用前进行范围检查？
- 成就/统计数据的值是否在写入任何后端前经过检查？

搜索：`get_input`、`Input.get_`、`input_map`、面向用户的文本字段 — 检查验证。

### 类别 4：数据暴露
- `src/` 或 `assets/` 中是否硬编码了任何 API 密钥、凭据或机密？
- 发布构建中是否包含调试符号或详细错误消息？
- 游戏是否将敏感玩家数据记录到磁盘或控制台？
- 是否向玩家暴露任何内部文件路径或系统信息？

在面向发布的代码中搜索：`api_key`、`secret`、`password`、`token`、`private_key`、`DEBUG`、`print(`。

### 类别 5：作弊和反篡改途径
- 游戏玩法关键数值是否仅存储在内存中，而不是易于编辑的文件中？
- 关键游戏进度标志（例如“已购买 DLC”）是否在服务器端验证？
- 多人游戏是否有防范内存编辑工具（Cheat Engine 等）的措施？
- 排行榜/分数提交是否在接受前经过验证？

注意：客户端反作弊基本无法强制执行。对于任何具有竞争性或涉及货币化的内容，应重点关注服务器端验证。

### 类别 6：依赖和供应链
- 是否使用了任何第三方插件或库？列出它们。
- 所使用版本的插件是否存在已知 CVE？
- 插件来源是否经过验证（官方市场、已审核的仓库）？

Glob：`addons/`、`plugins/`、`third_party/`、`vendor/` — 列出所有外部依赖。

---

## 阶段 4：分类发现

为每项发现指定：

**严重性：**
| 等级 | 定义 |
|-------|-----------|
| **CRITICAL** | 远程代码执行、数据泄露，或可轻易利用且破坏多人游戏完整性的作弊 |
| **HIGH** | 绕过游戏进度的存档篡改、凭据暴露，或绕过服务器权威判定 |
| **MEDIUM** | 启用客户端作弊、信息披露，或影响有限的输入验证缺口 |
| **LOW** | 深度防御改进——降低攻击面的加固措施，但不存在直接漏洞利用 |

**状态：** Open / Accepted Risk / Out of Scope

---

## 阶段 5：生成报告

```markdown
# 安全审计报告

**日期**：[date]
**范围**：[full | network | save | input | quick]
**引擎**：[engine + version]
**审计者**：security-engineer via /security-audit
**扫描文件**：[N source files, N config files]

---

## 执行摘要

| 严重性 | 数量 | 发布前必须修复 |
|----------|-------|------------------------|
| CRITICAL | [N] | 是——全部 |
| HIGH | [N] | 是——全部 |
| MEDIUM | [N] | 建议 |
| LOW | [N] | 可选 |

**发布建议**：[CLEAR TO SHIP / FIX CRITICALS FIRST / DO NOT SHIP]

---

## CRITICAL 发现

### SEC-001: [Title]
**类别**：[Save / Network / Input / Data / Cheat / Dependency]
**文件**：`[path]` 行 [N]
**描述**：[What the vulnerability is]
**攻击场景**：[How a malicious user would exploit it]
**修复**：[Specific code change or pattern to apply]
**工作量**：[Low / Medium / High]

[repeat per finding]

---

## HIGH 发现

[same format]

---

## MEDIUM 发现

[same format]

---

## LOW 发现

[same format]

---

## 已接受风险

[Any findings explicitly accepted by the team with rationale]

---

## 依赖清单

| 插件 / 库 | 版本 | 来源 | 已知 CVE |
|-----------------|---------|--------|------------|
| [name] | [version] | [source] | [none / CVE-XXXX-NNNN] |

---

## 修复优先级顺序

1. [SEC-NNN] — [1-line description] — 预计工作量：[Low/Medium/High]
2. ...

---

## 重新审计触发条件

修复任何 CRITICAL 或 HIGH 发现后，再次运行 `/security-audit`。
Polish → Release 门禁要求此报告中没有处于开放状态的 CRITICAL 或 HIGH 项。
```

---

## 阶段 6：写入报告

在对话中呈现报告摘要（仅执行摘要和 CRITICAL/HIGH 发现）。

询问：“可以将完整的安全审计报告写入 `production/security/security-audit-[date].md` 吗？”

仅在获得批准后写入。

---

## 阶段 7：门禁集成

此报告是 **Polish → Release 门禁** 的必需产物。

修复发现后，重新运行：`/security-audit quick`，确认 CRITICAL/HIGH 项已解决，再运行 `/gate-check release`。

如果存在 CRITICAL 发现：
> “⛔ CRITICAL 安全发现必须在任何公开发布前解决。在处理这些问题前，不要继续执行 `/launch-checklist`。”

如果没有 CRITICAL/HIGH 发现：
> “✅ 没有阻塞性安全发现。报告已写入 `production/security/`。运行 `/gate-check release` 时包含此路径。”

---

## 协作协议

- **绝不假定某个模式是安全的**——标记它并让用户决定
- **接受风险是有效结果**——对于单人团队而言，一些 LOW 发现是可接受的权衡；记录该决定
- **多人游戏的标准更高**——多人场景中的任何 HIGH 发现都应按 CRITICAL 处理
- **这不是渗透测试**——此审计覆盖常见模式；在任何具有竞争性或货币化的多人游戏上线前，建议由人类安全专业人员进行真正的渗透测试
