# 技能测试规范：/team-audio

## 技能摘要

通过四步流水线编排音频团队：音频方向（audio-director）→ 音效设计与无障碍审查并行（sound-designer + accessibility-specialist）→ 技术实现与引擎验证并行（technical-artist + 主引擎专家）→ 代码集成（gameplay-programmer）。生成代理前先读取相关 GDD、声音圣经（如存在）和现有音频资产清单。将所有输出汇编为 `design/gdd/audio-[feature].md`。每次步骤转换都使用 `AskUserQuestion`。产出音频设计文档后结论为 COMPLETE；未配置引擎时优雅跳过引擎专家。

---

## 静态断言（结构）

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少有 2 个步骤/阶段标题
- [ ] 包含结论关键词：COMPLETE、BLOCKED
- [ ] 包含“File Write Protocol”章节
- [ ] 文件写入委托给子代理，编排器不直接写文件
- [ ] 子代理每次写入前执行 “May I write to [path]?”
- [ ] 末尾有下一步交接（引用 `/dev-story`、`/asset-audit`）
- [ ] 存在 Error Recovery Protocol 章节
- [ ] 步骤转换前使用 `AskUserQuestion`
- [ ] 步骤 2 明确并行启动 sound-designer 和 accessibility-specialist
- [ ] 配置引擎时，步骤 3 明确并行启动 technical-artist 和引擎专家
- [ ] 若存在，收集上下文时读取 `design/gdd/sound-bible.md`
- [ ] 输出文档保存到 `design/gdd/audio-[feature].md`

---

## 测试用例

### 用例 1：成功路径——全部步骤完成并保存音频设计文档

**夹具：**
- 目标功能的 GDD 位于 `design/gdd/combat.md` 且存在
- 声音圣经位于 `design/gdd/sound-bible.md` 且存在
- 现有音频资产已列在 `assets/audio/`
- `.claude/docs/technical-preferences.md` 已配置引擎
- 计划音频事件列表不存在无障碍缺口

**输入：** `/team-audio combat`

**预期行为：**
1. 上下文收集：编排器在启动任何代理前读取 `design/gdd/combat.md`、`design/gdd/sound-bible.md` 和 `assets/audio/` 资产列表
2. 步骤 1：启动 audio-director；为 combat 定义声音身份、情绪基调、自适应音乐方向、混音目标和自适应音频规则
3. `AskUserQuestion` 展示音频方向；用户批准后才开始步骤 2
4. 步骤 2：并行启动 sound-designer 和 accessibility-specialist；sound-designer 生成 SFX 规范、带触发条件的音频事件列表和混音组；accessibility-specialist 识别关键游戏音频事件并规定视觉替代和字幕要求
5. `AskUserQuestion` 展示 SFX 规范和无障碍要求；用户批准后才开始步骤 3
6. 步骤 3：并行启动 technical-artist 和主引擎专家；technical-artist 设计总线结构、中间件集成、内存预算和流式策略；引擎专家验证集成方式符合已配置引擎的惯用做法
7. `AskUserQuestion` 展示技术计划；用户批准后才开始步骤 4
8. 步骤 4：启动 gameplay-programmer；将音频事件连接到 gameplay 触发器，实现自适应音乐，设置遮挡区域，并为音频事件触发器编写单元测试
9. 编排器将全部输出汇编为单个音频设计文档
10. 写入前子代理询问“May I write 音频设计文档到 `design/gdd/audio-combat.md`?”
11. 汇总输出列出音频事件数量、预计资产数量、实现任务和未决问题
12. 结论：COMPLETE

**断言：**
- [ ] 声音圣经存在时，在上下文收集期间（步骤 1 前）读取
- [ ] 在 sound-designer 或 accessibility-specialist 之前启动 audio-director
- [ ] `AskUserQuestion` 出现在步骤 1 输出之后、步骤 2 启动之前
- [ ] 步骤 2 中同时发出 sound-designer 和 accessibility-specialist 的 Task 调用
- [ ] 步骤 3 中同时发出 technical-artist 和引擎专家的 Task 调用
- [ ] 直到步骤 3 的 `AskUserQuestion` 获得批准后才启动 gameplay-programmer
- [ ] 音频设计文档写入 `design/gdd/audio-combat.md`（而不是其他路径）
- [ ] 汇总包含音频事件数量和预计资产数量
- [ ] 编排器不直接写入任何文件
- [ ] 文档交付后结论为 COMPLETE

---

### 用例 2：无障碍缺口——关键游戏音频事件没有视觉替代

**夹具：**
- 目标功能的 GDD 存在
- 步骤 1 和步骤 2 正在进行
- sound-designer 的音频事件列表包含“EnemyNearbyAlert”——用于警告玩家敌人正从屏幕外接近的空间音频提示
- accessibility-specialist 审查事件列表，发现“EnemyNearbyAlert”没有视觉替代（未指定屏幕指示器、字幕或控制器震动）

**输入：** `/team-audio stealth`（步骤 2 场景）

**预期行为：**
1. 步骤 1–2 继续执行；并行启动 accessibility-specialist 和 sound-designer
2. accessibility-specialist 返回审查结果，并指出 BLOCKING 问题：“`EnemyNearbyAlert` 是关键游戏音频事件（警告玩家注意屏幕外威胁），但没有视觉替代；听力障碍玩家无法察觉该威胁。这是一个 BLOCKING 无障碍缺口。”
3. 编排器在展示 `AskUserQuestion` 前立即在对话中指出该问题
4. `AskUserQuestion` 将该无障碍问题作为 BLOCKING 问题展示，并提供以下选项：
    - 为 EnemyNearbyAlert 添加视觉指示器（例如 HUD 上的方向箭头）并继续
    - 添加控制器触觉反馈作为替代方案并继续
    - 暂停并解决所有无障碍缺口后再进入步骤 3
5. 在用户解决或明确接受该缺口之前，不启动步骤 3（technical-artist + 引擎专家）
6. 如果未解决，该无障碍缺口将记录在最终音频设计文档的“开放无障碍问题”下

**断言：**
- [ ] 报告将无障碍缺口标记为 BLOCKING（而非建议性问题）
- [ ] 报告写明具体事件名称（“EnemyNearbyAlert”）及缺口性质
- [ ] 在启动步骤 3 前通过 `AskUserQuestion` 展示该缺口
- [ ] 至少提供一个解决选项（添加视觉替代或触觉替代）
- [ ] 缺口未解决且未获得用户明确授权时，不启动步骤 3
- [ ] 如果未解决的缺口被带入后续流程，则在音频设计文档中记录为开放问题

---

### 用例 3：无参数——显示用法指导，不推断设计文档

**夹具：**
- 任意项目状态

**输入：** `/team-audio`（无参数）

**预期行为：**
1. 技能检测到未提供参数
2. 输出用法指导，例如：“用法：`/team-audio [feature or area]`——指定要设计音频的功能或区域（例如 `combat`、`main menu`、`forest biome`、`boss encounter`）”
3. 技能退出，不启动任何代理

**断言：**
- [ ] 未提供参数时，技能不会启动任何代理
- [ ] 用法消息包含正确的调用格式和参数示例
- [ ] 没有用户指示时，技能不会尝试从现有设计文档推断功能
- [ ] 不使用 `AskUserQuestion`——直接输出指导

---

### 用例 4：缺少声音圣经——记录缺口后继续

**夹具：**
- 目标功能的 GDD 位于 `design/gdd/main-menu.md` 且存在
- `design/gdd/sound-bible.md` 不存在
- 已配置引擎；其他上下文文件存在

**输入：** `/team-audio main menu`

**预期行为：**
1. 上下文收集：编排器读取 `design/gdd/main-menu.md` 并检查 `design/gdd/sound-bible.md`
2. 未找到声音圣经；编排器在对话中记录缺口：“注意：未找到 `design/gdd/sound-bible.md`——音频方向将不使用项目级声音身份参考继续进行。如果这是一个持续开发的项目，建议创建声音圣经。”
3. 流水线不以声音圣经为输入，正常完成全部四个步骤
4. 告知步骤 1 的 audio-director 不存在声音圣经，必须仅根据功能 GDD 建立声音身份
5. 在最终汇总中将缺失的声音圣经列为建议的下一步

**断言：**
- [ ] 编排器在上下文收集期间（步骤 1 前）检查声音圣经
- [ ] 在对话中明确记录缺失的声音圣经，而不是静默忽略
- [ ] 流水线不会因声音圣经缺失而停止
- [ ] 在提示上下文中告知 audio-director 不存在声音圣经
- [ ] 汇总或“下一步”章节建议创建声音圣经
- [ ] 如果其他步骤均成功，结论仍为 COMPLETE

---

### 用例 5：未配置引擎——优雅跳过引擎专家步骤

**夹具：**
- `.claude/docs/technical-preferences.md` 中未配置引擎（显示 `[TO BE CONFIGURED]`）
- 目标功能的 GDD 存在
- 声音圣经可能存在，也可能不存在

**输入：** `/team-audio boss encounter`

**预期行为：**
1. 上下文收集：编排器读取 `.claude/docs/technical-preferences.md`，检测到未配置引擎
2. 步骤 1–2 正常执行（audio-director、sound-designer、accessibility-specialist）
3. 步骤 3：正常启动 technical-artist；跳过启动引擎专家
4. 编排器在对话中记录：“未启动引擎专家——technical-preferences.md 中未配置引擎。引擎集成验证将推迟到选择引擎之后。”
5. 步骤 4：gameplay-programmer 继续执行，并注明无法验证特定引擎的音频集成模式
6. 在音频设计文档的“延后验证”下记录引擎专家缺口
7. 结论：COMPLETE（这是优雅跳过，而非阻塞项）

**断言：**
- [ ] 未配置引擎时不启动引擎专家
- [ ] 技能不会因缺少引擎配置而报错退出
- [ ] 在对话中明确记录跳过，而不是静默省略
- [ ] 步骤 3 仍启动 technical-artist（只跳过引擎专家）
- [ ] 步骤 4 的 gameplay-programmer 在注明延后验证的情况下继续执行
- [ ] 在音频设计文档中记录延后的引擎验证
- [ ] 结论为 COMPLETE（未配置引擎是已知的优雅处理场景）

---

## 协议合规性

- [ ] 上下文收集（GDD、声音圣经、资产列表）在启动任何代理前完成
- [ ] 每次步骤输出后、下一步骤启动前使用 `AskUserQuestion`
- [ ] 并行启动：步骤 2（sound-designer + accessibility-specialist）和步骤 3（technical-artist + 引擎专家）在等待结果前发出全部 Task 调用
- [ ] 编排器不直接写入文件——所有写入均委托给子代理
- [ ] 每个子代理在写入前执行“May I write to [path]?”协议
- [ ] 任何代理返回的 BLOCKED 状态都立即展示，而不是静默跳过
- [ ] 部分代理完成、其他代理阻塞时，始终生成部分报告
- [ ] 音频设计文档路径遵循 `design/gdd/audio-[feature].md` 模式
- [ ] 结论必须恰为 COMPLETE 或 BLOCKED，不使用其他结论值
- [ ] 下一步交接引用 `/dev-story` 和 `/asset-audit`

---

## 覆盖说明

- Error Recovery Protocol 中“缩小范围后重试”和“跳过此代理”的解决路径未单独测试——它们遵循用例 2 和用例 5 验证的相同 `AskUserQuestion` + 部分报告模式。
- 用例 1 隐式验证步骤 4（gameplay-programmer）的成功路径行为；该步骤的失败模式遵循标准 Error Recovery Protocol。
- 用例 1 隐式验证 accessibility-specialist 的字幕和说明文字要求（视觉替代之外）；用例 2 聚焦于关键游戏事件完全没有替代方案这一更严重的情况。
- 引擎专家验证逻辑（惯用集成方式、特定版本变更）仅测试已配置和未配置两种状态；引擎专家输出的具体内容不在本行为规范范围内。
