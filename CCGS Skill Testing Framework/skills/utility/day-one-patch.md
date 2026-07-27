# 技能测试规范：/day-one-patch

## 技能摘要

`/day-one-patch` 为发布时已知但从 v1.0 版本延期处理的问题准备首日补丁计划。它读取
`production/bugs/` 中未关闭的缺陷报告、故事文件中延期的验收标准（标记为 `Status: Done`
但注明存在延期 AC 的故事），并为每个问题估算修复时间，生成有优先级的补丁计划。

补丁计划会在询问 "May I write" 后写入 `production/releases/day-one-patch.md`。如果发现
P0（发布后的严重问题），技能会先引导运行 `/hotfix`，再处理补丁计划。不适用总监门禁。
结论始终为 COMPLETE。

---

## 静态断言（结构）

由 `/skill-test static` 自动验证，不需要测试夹具。

- [ ] 包含必需的 front matter 字段：`name`、`description`、`argument-hint`、`user-invocable`、`allowed-tools`
- [ ] 至少包含 2 个阶段标题
- [ ] 包含结论关键词：COMPLETE
- [ ] 在写入计划前包含 "May I write" 协作协议语言
- [ ] 包含下一步交接（例如对 P0 问题使用 `/hotfix`，后续使用 `/release-checklist`）

---

## 总监门禁检查

无。`/day-one-patch` 是发布规划工具，不适用总监门禁。

---

## 测试用例

### 用例 1：正常路径——3 个已知问题，补丁计划包含修复估算

**测试夹具：**
- `production/bugs/` 包含 3 个未关闭缺陷，严重程度为：1 个 MEDIUM、2 个 LOW
- 迭代故事中没有延期 AC
- 所有缺陷都有复现步骤和系统标识

**输入：** `/day-one-patch`

**预期行为：**
1. 技能读取全部 3 个未关闭缺陷
2. 技能分配修复工作量估算：MEDIUM 缺陷 = 1-2 天，LOW 缺陷各 = 4 小时
3. 技能生成优先处理 MEDIUM 缺陷的补丁计划
4. 计划包含：优先级顺序、预计时间线、负责系统和修复说明
5. 技能询问 "May I write to `production/releases/day-one-patch.md`?"
6. 写入文件；结论为 COMPLETE

**断言：**
- [ ] 计划中包含全部 3 个缺陷
- [ ] 缺陷按严重程度排序（MEDIUM 在 LOW 前）
- [ ] 每个问题都有修复估算
- [ ] 写入前询问 "May I write"
- [ ] 结论为 COMPLETE

---

### 用例 2：发布后发现严重问题——P0，触发 /hotfix 引导

**测试夹具：**
- v1.0 发布后，在 `production/bugs/` 中发现一个 CRITICAL 严重程度的缺陷
- 该缺陷导致所有存档文件丢失数据

**输入：** `/day-one-patch`

**预期行为：**
1. 技能读取缺陷并识别 CRITICAL 严重程度的问题
2. 技能升级处理："P0 ISSUE DETECTED — data loss bug requires immediate hotfix
   before patch planning can proceed"
3. 技能不会将 P0 问题纳入补丁计划时间线
4. 技能明确指示："Run `/hotfix` to resolve this issue first"
5. 发出 P0 引导后，仍生成并写入其余较低严重程度缺陷的计划；结论为 COMPLETE

**断言：**
- [ ] P0 升级消息在补丁计划前显著显示
- [ ] 针对 P0 问题明确指示 `/hotfix`
- [ ] P0 问题不会排入补丁计划时间线（需要立即处理）
- [ ] 非 P0 问题仍会纳入计划；结论为 COMPLETE

---

### 用例 3：来自 Story-Done 的延期 AC——自动纳入补丁计划

**测试夹具：**
- `production/sprints/sprint-008.md` 包含一个 `Status: Done` 的故事，并有备注：
  "DEFERRED AC: Gamepad vibration on damage — deferred to post-launch patch"
- 同一系统没有未关闭缺陷

**输入：** `/day-one-patch`

**预期行为：**
1. 技能读取迭代故事并检测延期 AC 备注
2. 延期 AC 自动作为工作项加入补丁计划
3. 计划条目："Deferred from sprint-008: Gamepad vibration on damage"
4. 分配修复估算；在批准 "May I write" 后写入补丁计划
5. 结论为 COMPLETE

**断言：**
- [ ] 故事文件中的延期 AC 自动纳入计划
- [ ] 延期项目按来源故事（sprint-008）标记
- [ ] 延期 AC 像缺陷条目一样获得修复估算
- [ ] 结论为 COMPLETE

---

### 用例 4：没有已知问题——带模板说明的空计划

**测试夹具：**
- `production/bugs/` 为空
- 没有故事包含延期 AC

**输入：** `/day-one-patch`

**预期行为：**
1. 技能读取缺陷，没有找到
2. 技能读取故事延期 AC，没有找到
3. 技能生成带有说明 "No known issues at launch" 的空补丁计划
4. 为便于未来使用，保留模板结构（标题完整）
5. 技能询问 "May I write to `production/releases/day-one-patch.md`?"
6. 写入文件；结论为 COMPLETE

**断言：**
- [ ] 写入文件中出现 "No known issues at launch" 说明
- [ ] 空计划中包含模板标题
- [ ] 没有待规划问题时技能不会报错
- [ ] 结论为 COMPLETE

---

### 用例 5：总监门禁检查——无门禁；day-one-patch 是规划工具

**测试夹具：**
- `production/bugs/` 中存在已知问题

**输入：** `/day-one-patch`

**预期行为：**
1. 技能生成并写入补丁计划
2. 不启动总监代理
3. 输出中不出现门禁 ID

**断言：**
- [ ] 不调用总监门禁
- [ ] 不出现门禁跳过消息
- [ ] 无需门禁检查即可得出 COMPLETE 结论

---

## 协议合规性

- [ ] 生成计划前读取 `production/bugs/` 中的未关闭缺陷
- [ ] 扫描故事文件中的延期 AC 备注
- [ ] 对 CRITICAL（P0）缺陷给出明确的 `/hotfix` 引导
- [ ] 没有问题时生成带说明的空计划（而不是报错）
- [ ] 写入前询问 "May I write to `production/releases/day-one-patch.md`?"
- [ ] 所有路径的结论均为 COMPLETE

---

## 覆盖说明

- 存在多个 CRITICAL 缺陷时，处理方式与用例 2 相同；所有 P0 问题会一并升级处理。
- 补丁时间线估算（例如 "patch available in 3 days"）需要手动 QA 和构建时间估算；此技能
  根据严重程度进行粗略估算，而不是依据团队实际速度。
- 面向玩家的补丁说明文档（`/patch-notes`）是另一个技能，会在补丁计划执行后调用。
