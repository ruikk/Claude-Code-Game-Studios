---
name: localize
description: "完整的本地化管道:扫描硬编码字符串,提取和管理字符串表,验证翻译,生成译者简报,运行文化/敏感性评审,管理 VO 本地化,测试 RTL/平台要求,执行字符串冻结,并报告覆盖率。"
argument-hint: "[scan|extract|validate|status|brief|cultural-review|vo-pipeline|rtl-check|freeze|qa]"
user-invocable: true
agent: localization-lead
allowed-tools: Read, Glob, Grep, Write, Bash, Task, AskUserQuestion
model: sonnet
---

# 本地化管道

本地化不仅仅是翻译 —— 它是让游戏在每种语言和地区都感觉原生的完整过程。糟糕的本地化会破坏沉浸感、困惑玩家,并阻碍平台认证。此技能覆盖从字符串提取到文化评审、VO 录制、RTL 布局测试和本地化 QA 签核的完整管道。

**模式:**
- `scan` —— 查找硬编码字符串和本地化反模式(只读)
- `extract` —— 提取字符串并生成可翻译的表
- `validate` —— 检查翻译的完整性、占位符和长度
- `status` —— 跨所有语言区域的覆盖率矩阵
- `brief` —— 为外部团队生成译者上下文简报文档
- `cultural-review` —— 标记文化敏感内容、符号、颜色、习语
- `vo-pipeline` —— 管理旁白本地化:剧本、录制规格、集成
- `rtl-check` —— 验证 RTL 语言布局、镜像和字体支持
- `freeze` —— 执行字符串冻结;在翻译开始前锁定源字符串
- `qa` —— 在发布前运行完整的本地化 QA 周期

如果未提供子命令,输出用法并停止。结论:**FAIL** —— 缺少必需的子命令。

---

## Phase 2A: Scan 模式

在 `src/` 中搜索硬编码的面向用户字符串:

- UI 代码中未包裹在本地化函数(`tr()`、`Tr()`、`NSLocalizedString`、`GetText` 等)中的字符串字面量
- 应该参数化的拼接字符串
- 使用位置占位符(`%s`、`%d`)而非命名占位符(`{playerName}`)的字符串
- 混合语言敏感数据(数字、日期、货币)而未使用语言感知格式化的格式字符串

搜索本地化反模式:

- 日期/时间格式化未使用语言感知函数
- 数字格式化无语言感知(`1,000` vs `1.000`)
- 嵌入在图像或纹理中的文本(标记 `assets/` 中的资产文件)
- 假设从左到右文本方向的字符串(位置布局、字符串组装顺序)
- 内置于字符串逻辑的性别/复数假设(必须使用复数形式或性别标记)
- 硬编码标点(如 `"You won!"` —— 感叹号风格因语言区域而异)

报告所有发现及其文件路径和行号。此模式是只读的 —— 不写入文件。

---

## Phase 2B: Extract 模式

- 扫描所有源文件中的本地化字符串引用
- 与 `assets/data/strings/` 中的现有字符串表比较
- 为尚未有键的字符串生成新条目
- 按照约定建议键名:`[category].[subcategory].[description]`
  - 示例:`ui.hud.health_label`、`dialogue.npc.merchant.greeting`、`menu.main.play_button`
- 每个新条目必须包含一个 `context` 字段 —— 译者注释,解释:
  - 出现位置(哪个屏幕、哪个场景)
  - 最大字符长度
  - 任何占位符含义(`{playerName}` = 玩家选择的显示名)
  - 性别/复数上下文(如适用)

输出要添加到字符串表的新字符串 diff。

向用户呈现 diff。询问:"我可以将这些新条目写入 `assets/data/strings/strings-en.json` 吗?"

如果是,仅写入 diff(新条目),而不是完整替换。结论:**COMPLETE** —— 字符串已提取并写入。

---

## Phase 2C: Validate 模式

读取 `assets/data/strings/` 中的所有字符串表文件。对每个语言区域检查:

- **完整性** —— 键存在于源(en)中但此语言区域无翻译
- **占位符不匹配** —— 源有 `{name}` 但翻译遗漏或添加了额外的
- **字符串长度违规** —— 翻译超过源 `context` 字段中记录的字符限制
- **复数形式数量** —— 语言区域需要 N 种复数形式;翻译提供的更少
- **孤立键** —— 翻译存在但 `src/` 中无引用该键的内容
- **过时翻译** —— 源字符串在翻译编写后发生了变更(标记重新翻译)
- **编码** —— 存在非 ASCII 字符且字体图集支持它们(如不确定则标记)

按语言区域和严重性分组报告验证结果。此模式是只读的 —— 不写入文件。

---

## Phase 2D: Status 模式

- 统计源表中的可本地化字符串总数
- 每个语言区域:统计已翻译、未翻译、过时(翻译后源字符串已变更)
- 生成覆盖率矩阵:

```markdown
## Localization Status
Generated: [日期]
String freeze: [Active / Not yet called / Lifted]

| Locale | Total | Translated | Missing | Stale | Coverage |
|--------|-------|-----------|---------|-------|----------|
| en (source) | [N] | [N] | 0 | 0 | 100% |
| [locale] | [N] | [N] | [N] | [N] | [X]% |

### Issues
- 源代码中发现 [N] 个硬编码字符串(运行 /localize scan)
- [N] 个字符串超出字符限制
- [N] 个占位符不匹配
- [N] 个孤立键
- [N] 个在冻结后添加的字符串(冻结违规)
```

此模式是只读的 —— 不写入文件。

---

## Phase 2E: Brief 模式

生成译者上下文简报文档。此文档与字符串表导出一起发送给外部翻译团队或本地化供应商。

读取:
- `design/gdd/` —— 提取游戏类型、基调、设定、角色名称
- `assets/data/strings/strings-en.json` —— 源字符串表
- `design/narrative/` 中任何现有的传说或叙事文档

生成 `production/localization/translator-brief-[locale]-[date].md`:

```markdown
# Translator Brief — [游戏名称] — [Locale]

## Game Overview
[游戏的 2-3 段摘要,包括类型、基调和受众]

## Tone and Voice
- **Overall tone**: [如"暗黑喜剧,不是闹剧 —— 想想 Terry Pratchett,不是 Looney Tunes"]
- **Player address**: [如"第二人称,非正式。绝不用正式的'vous' —— 法语始终用'tu'"]
- **Profanity policy**: [如"轻度 —— 相当于 PG-13。匹配源的强度,不要弱化或升级"]
- **Humour**: [如"存在文字游戏 —— 如果双关语无法翻译,发明一个等效的本地笑话;不要直译"]

## Character Glossary
| Name | Role | Personality | Notes |
|------|------|-------------|-------|
| [名称] | [角色] | [性格] | [不要翻译 / 音译为 X] |

## World Glossary
| Term | Meaning | Notes |
|------|---------|-------|
| [术语] | [含义] | [保持英文 / 翻译为 X] |

## Do Not Translate List
以下必须在所有语言区域中逐字出现:
- [游戏名称]
- [与引擎内标签匹配的 UI 术语]
- [品牌或商标名称]

## Placeholder Reference
| Placeholder | What it represents | Example |
|-------------|-------------------|---------|
| `{playerName}` | 玩家选择的显示名 | "Shadowblade" |
| `{count}` | 整数量 | "3" |

## Character Limits
有硬限制的紧凑 UI 字段在字符串表 `context` 字段中标记。
未说明限制的地方,以英文长度的 ±30% 作为指导。

## Contact
问题请发送至:[用户/团队联系方式的占位符]
交付格式:JSON,与 strings-en.json 相同的 schema
```

询问:"我可以将此译者简报写入 `production/localization/translator-brief-[locale]-[date].md` 吗?"

---

## Phase 2F: Cultural Review 模式

通过 Task 生成 `localization-lead`。要求他们针对目标语言区域(从 `assets/data/strings/` 和 `assets/` 读取)审计以下文化敏感性:

### 要评审的内容领域

**符号和手势**
- 竖大拇指、OK 手势、和平手势 —— 含义因地区而异
- 美术、UI 或音频中的宗教或精神符号
- 国旗、地图表示、争议领土

**颜色**
- 白色(某些亚洲文化中表示哀悼)、绿色(某些地区有政治联想)、红色(幸运 vs 危险)
- 与文化联想冲突的告警/警告颜色

**数字**
- 4(日语/中文中代表死亡)、13、666 —— 标记在 UI 中的使用(房间号、物品计数、价格)

**幽默和习语**
- 在其他语言区域中翻译为冒犯性的习语
- 在某些市场(特别是日本、德国、中东)不适当的厕所/身体幽默
- 围绕在特定地区具有文化敏感性主题的黑色幽默

**暴力和内容评级**
- 在 DE(德国)、AU(澳大利亚)、CN(中国)或 AE(阿联酋)需要变更评级的内容
- 血液颜色、血腥程度、药物引用 —— 如需要,全部标记为地区特定资产变体

**名称和表现**
- 在目标语言区域中具有冒犯性、亵渎性或负面含义的角色名称
- 对国籍、宗教或种族群体的刻板表现

以表格形式呈现发现:

| Finding | Locale(s) Affected | Severity | Recommended Action |
|---------|--------------------|----------|--------------------|
| [描述] | [语言区域] | [BLOCKING / ADVISORY / NOTE] | [更改 / 标记评审 / 接受] |

BLOCKING = 必须在发布该语言区域前修复。ADVISORY = 建议更改。NOTE = 仅供参考。

询问:"我可以将此文化评审报告写入 `production/localization/cultural-review-[date].md` 吗?"

---

## Phase 2G: VO Pipeline 模式

管理旁白本地化过程。从参数确定子任务:

- `vo-pipeline scan` —— 识别所有需要 VO 录制的对话行
- `vo-pipeline script` —— 生成带导演备注的录制剧本
- `vo-pipeline validate` —— 检查所有录制的 VO 文件存在且命名正确
- `vo-pipeline integrate` —— 验证 VO 文件在代码/资产中被正确引用

### VO Pipeline: Scan

读取 `assets/data/strings/` 和 `design/narrative/`。识别:
- 所有对话行(匹配 `dialogue.*` 的键)及其源文本
- 已录制的行(音频文件存在于 `assets/audio/vo/`)
- 尚未录制的行

输出录制清单:

```
## VO Recording Manifest — [日期]

| Key | Character | Source Line | Status |
|-----|-----------|-------------|--------|
| dialogue.npc.merchant.greeting | Merchant | "Welcome, traveller." | Recorded |
| dialogue.npc.merchant.haggle | Merchant | "That's my final offer." | Needs recording |
```

### VO Pipeline: Script

为每个角色生成录制剧本文档,按场景分组。包括:

- 角色名称和简短性格注释
- 完整对话行,附有不常见专有名词的发音指南
- 每行的情感/指导注释(`[Warm, welcoming]`、`[Annoyed, clipped]`)
- 任何作为对话回应的行(提供上下文:"玩家刚说了 X")

询问:"我可以将 VO 录制剧本写入 `production/localization/vo-scripts-[locale]-[date].md` 吗?"

### VO Pipeline: Validate

Glob `assets/audio/vo/[locale]/` 查找所有 `.wav`/`.ogg` 文件。与 VO 清单交叉引用。报告:
- 缺失文件(剧本中有行,无音频文件)
- 多余文件(音频文件存在,无匹配的字符串键)
- 命名约定违规

### VO Pipeline: Integrate

Grep `src/` 查找 VO 音频引用。验证每个引用的路径存在于 `assets/audio/vo/[locale]/`。报告损坏的引用。

---

## Phase 2H: RTL Check 模式

从右到左的语言(阿拉伯语、希伯来语、波斯语、乌尔都语)需要超越文本翻译的布局镜像。此模式验证实现。

读取 `.claude/docs/technical-preferences.md` 以确定引擎。然后检查:

**布局镜像**
- 引擎中是否启用了 RTL 布局?(Godot:`Control.layout_direction`,Unity:`RTL Support` 包,Unreal:文本方向标志)
- 所有 UI 容器是否设置为自动镜像,还是位置被硬编码?
- 进度条、血条和方向指示器是否正确镜像?

**文本渲染**
- 是否加载了支持阿拉伯语/希伯来语字符集的字体?
- 阿拉伯语文本是否以正确的连字(连接脚本)渲染?
- 需要时数字是否显示为东阿拉伯数字?

**字符串组装**
- 是否有任何假设从左到右阅读顺序的字符串拼接?
- 当句子结构反转时,句子中的 `{placeholder}` 位置是否正确工作?

**资产评审**
- 是否有带方向箭头或不对称设计的 UI 图标需要镜像变体?
- 是否存在需要 RTL 版本的图中文本资产?

检查的 Grep 模式:
- 场景/预制体文件中引擎特定的 RTL 标志
- 任何 `HBoxContainer`、`LinearLayout`、`HorizontalBox` 节点 —— 验证 layout_direction 设置
- 对话或 UI 代码附近使用 `+` 的字符串拼接

报告发现。标记 BLOCKING 问题(不修复内容不可读)vs ADVISORY(外观改进)。

询问:"我可以将此 RTL 检查报告写入 `production/localization/rtl-check-[date].md` 吗?"

---

## Phase 2I: Freeze 模式

字符串冻结锁定源(英文)字符串表,以便翻译可以在源不发生变化的情况下进行。

### freeze call

检查 `production/localization/freeze-status.md`(如果存在)中的当前冻结状态。

如果已冻结:
> "字符串冻结当前为 ACTIVE(于 [date] 调用)。冻结后有 [N] 个字符串被添加或修改。这些是冻结违规 —— 它们需要重新翻译或批准解除冻结。"

如果未冻结,呈现冻结前检查清单:

```
Pre-Freeze Checklist
[ ] 所有计划的 UI 屏幕已实现
[ ] 所有对话行已定稿(无更多叙事修订计划)
[ ] 所有系统字符串(错误消息、教程文本)已完成
[ ] /localize scan 显示零硬编码字符串
[ ] /localize validate 显示源(en)中无占位符不匹配
[ ] 营销字符串(商店描述、成就)已定稿
```

使用 `AskUserQuestion`:
- 提示:"以上所有项是否已确认?调用字符串冻结将锁定源表。"
- 选项:`[A] 是 —— 立即调用字符串冻结` / `[B] 否 —— 我还有字符串要添加`

如果选 [A]:写入 `production/localization/freeze-status.md`:

```markdown
# String Freeze Status

**Status**: ACTIVE
**Called**: [日期]
**Called by**: [用户]
**Total strings at freeze**: [N]

## Post-Freeze Changes
[冻结后添加或修改的任何字符串由 /localize extract 自动列在此处]
```

### freeze lift

如果参数包含 `lift`:更新 `freeze-status.md` 的 Status 为 `LIFTED`,记录原因和日期。警告:"解除冻结需要重新翻译所有修改的字符串。通知翻译团队。"

### freeze check(自动集成到 extract 中)

当 `extract` 模式发现新或修改的字符串,且 `freeze-status.md` 显示 Status: ACTIVE —— 将新键追加到 `## Post-Freeze Changes` 并警告:
> "⚠️ 字符串冻结处于活动状态。已添加 [N] 个新/修改的字符串。这些是冻结违规。在继续之前通知你的本地化供应商。"

---

## Phase 2J: QA 模式

本地化 QA 是一个专门的检查,在翻译交付后但在任何语言区域发布前运行。这与 `/validate`(检查完整性)不同 —— 这是基于实际游玩的结构化质量检查。

通过 Task 生成 `localization-lead`,提供:
- 要 QA 的目标语言区域
- 游戏中所有屏幕/流程的列表(来自 `design/gdd/` 或 `/content-audit` 输出)
- 当前的 `/localize validate` 报告
- 文化评审报告(如果存在)

要求 localization-lead 生成 QA 计划,覆盖:

1. **功能性字符串检查** —— 每个字符串在游戏内显示无截断、占位符错误或编码损坏
2. **UI 溢出检查** —— 翻译字符串超出 UI 边界(即使字符限制内,某些语言会扩展)
3. **上下文准确性** —— 抽样 10% 的字符串在游戏内评审翻译准确性和自然措辞
4. **文化评审项** —— 验证文化评审中所有 BLOCKING 项已解决
5. **VO 同步检查** —— 如果存在 VO,验证翻译后唇形同步或字幕时间可接受
6. **平台认证要求** —— 检查平台特定的本地化要求(年龄评级文本、法律声明、ESRB/PEGI/CERO 文本)

每个语言区域输出 QA 结论:

```
## Localization QA Verdict — [Locale]

**Status**: PASS / PASS WITH CONDITIONS / FAIL
**Reviewed by**: localization-lead
**Date**: [日期]

### Findings
| ID | Area | Description | Severity | Status |
|----|------|-------------|----------|--------|
| LOC-001 | UI Overflow | "Settings" 按钮文本在 [Screen] 上溢出 | BLOCKING | Open |
| LOC-002 | Translation | [Key] 翻译过于直译 —— 听起来不自然 | ADVISORY | Open |

### Conditions (if PASS WITH CONDITIONS)
- [条件 1 —— 发布前必须解决]

### Sign-Off
[ ] 所有 BLOCKING 发现已解决
[ ] Producer 批准发布 [Locale]
```

询问:"我可以将此本地化 QA 报告写入 `production/localization/loc-qa-[locale]-[date].md` 吗?"

**门禁集成**:Polish → Release 门禁要求每个要发布的语言区域获得 PASS 或 PASS WITH CONDITIONS 结论。FAIL 仅阻止该语言区域的发布 —— 其他语言区域如果 QA 通过仍可继续。

---

## Phase 3: 规则和下一步

### 规则
- 英语(en)始终是源语言区域
- 每个字符串表条目必须包含 `context` 字段,含译者注释、字符限制和占位符含义
- 绝不直接修改翻译文件 —— 生成 diff 供评审
- 字符限制必须按 UI 元素定义并在 validate 模式中执行
- 字符串冻结必须在发送给译者前调用 —— 绝不翻译移动的目标
- RTL 支持必须从一开始就设计 —— 改造 RTL 布局代价高昂
- 文化评审对于游戏将进行商业销售的任何语言区域都是必需的
- VO 剧本必须包含导演备注 —— 原始对话行会产生平淡的录制

### 推荐工作流

```
/localize scan            → 查找硬编码字符串
/localize extract         → 构建字符串表
/localize freeze          → 发送给译者前锁定源
/localize brief           → 生成译者简报文档
[发送给译者]
/localize validate        → 检查返回的翻译
/localize cultural-review → 标记文化敏感内容
/localize rtl-check       → 如果发布阿拉伯语 / 希伯来语 / 波斯语
/localize vo-pipeline     → 如果发布配音 VO
/localize qa              → 完整本地化 QA 通过
```

在 `qa` 对所有发布语言区域返回 PASS 后,运行 `/gate-check release` 时包含 QA 报告路径。
