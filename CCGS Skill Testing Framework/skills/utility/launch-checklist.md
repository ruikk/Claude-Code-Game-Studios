# 技能测试规范：/launch-checklist

## 技能摘要

`/launch-checklist` 生成并评估完整的发布就绪清单，涵盖：法律合规（EULA、隐私政策、ESRB/PEGI 评级）、平台认证状态、商店页面完整性（截图、描述、元数据）、构建验证（版本标签、可复现构建）、分析和崩溃报告配置，以及首次运行体验验证。

技能在询问“May I write”后，将清单报告写入 `production/launch/launch-checklist-[date].md`。如果已有上一份发布清单，则将新结果与旧结果比较，突出显示新解决和新阻塞的项目。不适用导演门禁，完整发布管线由 `/team-release` 编排。Verdict：LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 frontmatter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含 verdict 关键字：LAUNCH READY、LAUNCH BLOCKED、CONCERNS
- [ ] 写入清单前包含“May I write”协作协议措辞
- [ ] 包含下一步交接（例如 `/team-release` 或 `/day-one-patch`）

---

## 导演门禁检查

无。`/launch-checklist` 是就绪性审计工具，完整发布管线由 `/team-release` 管理。

---

## 测试用例

### 用例 1：正常路径——所有清单项目通过验证，LAUNCH READY

**测试夹具：**
- 法律文档存在：`production/legal/` 中有 EULA、隐私政策
- 平台认证：制作记录标记为已提交且已批准
- 商店页面资产：`production/store/` 中存在截图、描述和元数据
- 构建：版本标签 `v1.0.0` 存在，已确认可复现构建
- 崩溃报告：已在 `technical-preferences.md` 中配置

**输入：** `/launch-checklist`

**预期行为：**
1. 技能检查所有清单类别
2. 所有项目通过验证
3. 技能生成所有项目标记为 PASS 的清单报告
4. 技能询问“May I write to `production/launch/launch-checklist-2026-04-06.md`?”
5. 获批后写入报告，verdict 为 LAUNCH READY

**断言：**
- [ ] 检查所有清单类别（legal、platform、store、build、analytics、UX）
- [ ] 报告中包含所有项目，并带有 PASS 标记
- [ ] Verdict 为 LAUNCH READY
- [ ] 使用正确的日期文件名询问“May I write”

---

### 用例 2：平台认证未提交——LAUNCH BLOCKED

**测试夹具：**
- 其他所有清单项目通过
- 平台认证部分为“not submitted”（未找到提交记录）

**输入：** `/launch-checklist`

**预期行为：**
1. 技能检查所有项目
2. 平台认证检查失败：没有提交记录
3. 技能报告：“LAUNCH BLOCKED — 平台认证未提交”
4. 指明缺少认证的具体平台
5. Verdict 为 LAUNCH BLOCKED

**断言：**
- [ ] Verdict 为 LAUNCH BLOCKED（不是 CONCERNS）
- [ ] 将平台认证识别为阻塞项目
- [ ] 指定缺少认证的平台名称
- [ ] 报告仍显示其他通过的项目

---

### 用例 3：需要手动检查——CONCERNS Verdict

**测试夹具：**
- 所有关键清单项目通过
- 首次运行体验项目：“MANUAL CHECK NEEDED — 必须由人工游玩前 5 分钟并验证教程完成流程”
- 商店截图项目：“MANUAL CHECK NEEDED — 必须由美术团队验证截图质量与当前构建一致”

**输入：** `/launch-checklist`

**预期行为：**
1. 技能检查所有项目
2. 标记 2 个需要人工验证的项目
3. 技能报告：“CONCERNS — 2 个项目在发布前需要人工验证”
4. 列出两个项目，并说明需要手动验证的内容
5. Verdict 为 CONCERNS（这些是建议项，不是 LAUNCH BLOCKED）

**断言：**
- [ ] Verdict 为 CONCERNS（不是 LAUNCH READY 或 LAUNCH BLOCKED）
- [ ] 列出两个手动检查项目及验证说明
- [ ] 技能不会因 MANUAL CHECK 项目自动阻塞

---

### 用例 4：存在上一份清单——差异比较

**测试夹具：**
- `production/launch/launch-checklist-2026-03-25.md` 存在，并包含上一轮结果：
   - 2 个项目为 BLOCKED（平台认证、崩溃报告）
  - 1 个项目为 MANUAL CHECK
- 新清单：平台认证现在为 PASS，崩溃报告现在为 PASS，手动检查仍未完成；新增 1 个标记项目（EULA 最近更新日期）

**输入：** `/launch-checklist`

**预期行为：**
1. 技能找到上一份清单并加载以供比较
2. 技能生成新清单并进行比较：
    - 新解决：“平台认证：之前为 BLOCKED，现为 PASS”
     - 新解决：“崩溃报告：之前为 BLOCKED，现为 PASS”
   - 仍未完成：手动检查（无变化）
   - 新问题：EULA 最近更新日期（上一份清单中没有）
3. 在报告中突出显示差异
4. Verdict 为 CONCERNS（手动检查 + 新的 EULA 问题）

**断言：**
- [ ] 差异部分显示新解决的项目
- [ ] 差异部分显示上一份清单中没有的新问题
- [ ] 标注上一份清单中仍未完成的项目仍在持续
- [ ] Verdict 反映当前状态，而不是上一轮状态

---

### 用例 5：导演门禁检查——无门禁；`launch-checklist` 是审计工具

**测试夹具：**
- 所有清单依赖均存在

**输入：** `/launch-checklist`

**预期行为：**
1. 技能运行完整清单并写入报告
2. 不启动导演代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用导演门禁
- [ ] 不出现跳过门禁的消息
- [ ] Verdict 为 LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS，不是门禁 verdict

---

## 协议合规性

- [ ] 检查所有必需类别（legal、platform、store、build、analytics、UX）
- [ ] 出现硬性失败（认证未完成、缺少法律文档）时为 LAUNCH BLOCKED
- [ ] 对需要手动验证的建议项使用 CONCERNS
- [ ] 存在上一份清单时与其比较
- [ ] 创建清单报告前询问“May I write”
- [ ] Verdict 为 LAUNCH READY、LAUNCH BLOCKED 或 CONCERNS

---

## 覆盖说明

- 区域特定合规（GDPR 数据处理、面向 13 岁以下受众的 COPPA）会被检查，但测试断言未列出具体要求。
- 商店页面完整性检查（截图、描述）依赖 `production/store/` 中存在文件，无法验证视觉质量。
- 可复现构建检查验证版本标签和构建配置是否存在，但不会执行构建过程。
