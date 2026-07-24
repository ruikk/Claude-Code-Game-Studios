---
name: patch-notes
description: "从 git 历史、迭代数据和内部变更日志生成面向玩家的更新说明。将开发者语言转化为清晰、有吸引力的玩家沟通内容。"
argument-hint: "[version] [--style brief|detailed|full]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Write, Bash
model: haiku
agent: community-manager
---

## 阶段 1：解析参数

- `version`：要为其生成说明的发布版本（例如 `1.2.0`）
- `--style`：输出风格 —— `brief`（简短，要点式）、`detailed`（详细，带上下文）、`full`（完整，含开发者评论）。默认：`detailed`。

如果未提供版本，在继续前询问用户。

---

## 阶段 2：收集变更数据

- 如存在，阅读 `production/releases/[version]/changelog.md` 中的内部变更日志
- 同时检查 `docs/CHANGELOG.md` 中该版本的条目
- 作为后备，在上一个发布标签和当前标签/HEAD 之间运行 `git log`
- 阅读 `production/sprints/` 中的迭代回顾以获取上下文
- 阅读 `design/balance/` 中任何平衡性变更文档
- 阅读 QA 的 bug 修复记录（如有）

**如果没有可用的变更日志数据**（`production/releases/[version]/changelog.md` 和 `docs/CHANGELOG.md` 中该版本的条目都不存在，且 git log 为空或不可用）：

> "No changelog data found for [version]. Run `/changelog [version]` first to generate the
> internal changelog, then re-run `/patch-notes [version]`."
>（未找到 [version] 的变更日志数据。请先运行 `/changelog [version]` 生成内部变更日志，然后再运行 `/patch-notes [version]`。）

裁定：**BLOCKED**（阻塞）—— 在此停止，不生成说明。

---

## 阶段 2b：检测语调指南和模板

**语调指南检测** —— 在起草说明前，检查写作风格指引：

1. 检查 `.claude/docs/technical-preferences.md` 中是否有 "tone"（语调）、"voice"（语气）、"style"（风格）相关字段或章节。
2. 检查 `docs/PATCH-NOTES-STYLE.md`（如存在）。
3. 检查 `design/community/tone-guide.md`（如存在）。
4. 如果任一来源包含语调/语气/风格指令，提取并应用到生成说明的语言和框架中。
5. 如果所有地方都未找到语调指引，默认为：面向玩家、非技术性语言；热情但不夸张；聚焦于玩家的体验，而非开发者的改动。

**模板检测** —— 检查是否存在更新说明模板：

1. Glob 匹配 `docs/patch-notes-template.md` 和 `.claude/docs/templates/patch-notes-template.md`。
2. 如果在任一路径找到，阅读并作为阶段 4 的输出结构，取代内置风格模板（简短 / 详细 / 完整）。用分类后的数据填充模板章节。
3. 如果未找到，使用阶段 4 中定义的内置风格模板。

---

## 阶段 3：分类与翻译

将所有变更归入面向玩家的分类：

- **新内容**：新功能、地图、角色、物品、模式
- **玩法改动**：平衡性调整、机制改动、进度改动
- **体验优化**：UI 改进、便利功能、无障碍
- **Bug 修复**：按系统分组（战斗、UI、网络等）
- **性能**：玩家可能注意到的优化改进
- **已知问题**：对未解决问题保持透明

将开发者语言翻译为玩家语言：

- "重构伤害计算管线" → "提升了命中检测精度"
- "修复背包管理器中的空引用" → "修复了打开背包时的崩溃"
- "减少战斗循环中的 GC 分配" → "改善了战斗性能"
- 移除不影响玩家的纯内部改动
- 保留平衡性改动的具体数值（伤害：50 → 45）

---

## 阶段 4：生成更新说明

### 简短风格（Brief Style）
```markdown
# 更新 [版本] —— [标题]

**新增**
- [功能 1]
- [功能 2]

**改动**
- [平衡性/机制改动，含改动前 → 改动后数值]

**修复**
- [Bug 修复 1]
- [Bug 修复 2]

**已知问题**
- [问题 1]
```

### 详细风格（Detailed Style）
```markdown
# 更新 [版本] —— [标题]
*[日期]*

## 亮点
[1-2 句话概述最令人兴奋的改动]

## 新内容
### [功能名称]
[2-3 句话描述该功能以及玩家为何会兴奋]

## 玩法改动
### 平衡性
| 改动 | 改动前 | 改动后 | 原因 |
| ---- | ---- | ---- | ---- |
| [物品/能力] | [旧值] | [新值] | [简要理由] |

### 机制
- **[改动]**：[说明改了什么以及为什么]

## 体验优化
- [带上下文的改进]

## Bug 修复
### 战斗
- 修复了 [玩家遇到的现象描述]

### UI
- 修复了 [描述]

### 网络
- 修复了 [描述]

## 性能
- [玩家会注意到的改进]

## 已知问题
- [问题及（如有）临时解决方案]
```

### 完整风格（Full Style）
包含详细风格的全部内容，另加：
```markdown
## 开发者评论
### [主题]
> [对某项重大改动的开发者洞见 —— 为什么这么改、考虑过哪些方案、
> 团队学到了什么。以第一人称团队口吻撰写。]
```

---

## 阶段 5：审查输出

检查生成的说明是否满足：

- 无内部行话（用面向玩家的语言替换技术术语）
- 无对内部系统、工单或迭代编号的引用
- 平衡性改动包含改动前/后数值
- Bug 修复描述玩家体验，而非技术原因
- 语调与游戏的整体风格匹配（根据游戏类型调整正式程度）

---

## 阶段 6：保存更新说明

向用户呈现完成的更新说明，同时附上：按分类的变更数量统计，以及被排除的内部改动（供审查）。

询问："May I write these patch notes to `docs/patch-notes/[version].md`?"（我可以将这些更新说明写入 `docs/patch-notes/[version].md` 吗？）

如果同意，将文件写入 `docs/patch-notes/[version].md`（按需创建目录）。同时写入 `production/releases/[version]/patch-notes.md` 作为内部存档副本。

---

## 阶段 7：后续步骤

裁定：**COMPLETE**（已完成）—— 更新说明已生成并保存。

- 运行 `/release-checklist` 在公开发布前验证其他发布门禁是否满足。
- 在公开发布前，将更新说明草稿交由 community-manager（社区经理）进行语调审查。
