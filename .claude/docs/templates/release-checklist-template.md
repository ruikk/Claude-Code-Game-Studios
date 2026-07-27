# 发布检查清单（Release Checklist）: [Version] -- [Platform]

**发布日期**: [Target Date]
**发布经理**: [Name]
**状态**: [ ] GO / [ ] NO-GO

---

## 构建验证（Build Verification）

- [ ] 在所有目标平台上，干净构建成功
- [ ] 无编译器警告（零警告策略）
- [ ] 构建版本号设置正确：`[version]`
- [ ] 可从已打标签的提交复现构建：`[commit hash]`
- [ ] 构建体积在预算内：[actual] / [budget]
- [ ] 所有资源均已包含且加载正常
- [ ] 发布构建中未启用调试/开发功能

---

## 质量门禁（Quality Gates）

### 严重缺陷（Critical Bugs）
- [ ] 未关闭的 S1（Critical）缺陷为零
- [ ] 未关闭的 S2（Major）缺陷为零——或在下方记录例外：

| Bug ID | Description | Exception Rationale | Approved By |
| ---- | ---- | ---- | ---- |
| | | | |

### 测试覆盖（Test Coverage）
- [ ] 所有关键路径功能均已测试并签字确认
- [ ] 完整回归测试套件通过：[pass rate]%
- [ ] 浸泡测试通过（连续游玩 4 小时以上）
- [ ] 边界/异常场景测试完成

### 性能（Performance）
- [ ] 最低配置达到目标 FPS：[actual] / [target] FPS
- [ ] 内存使用在预算内：[actual] / [budget] MB
- [ ] 加载时长在预算内：[actual] / [target] seconds
- [ ] 长时游玩（浸泡测试）无内存泄漏
- [ ] 正常游戏过程中无低于 [threshold] 的掉帧

---

## 内容完备（Content Complete）

- [ ] 所有占位资源已替换为最终版本
- [ ] 所有面向玩家的文本已完成校对
- [ ] 所有文本已具备本地化准备状态（无硬编码字符串）
- [ ] 以下语言/地区的本地化已完成：[list locales]
- [ ] 音频混音已定版并获批准
- [ ] 制作人员名单完整且准确
- [ ] 法律声明与第三方署名完整

---

## 平台：PC（Platform: PC）

- [ ] 最低与推荐配置已文档化
- [ ] 键盘+鼠标控制功能完整可用
- [ ] 控制器支持已测试（Xbox、PlayStation、通用手柄）
- [ ] 分辨率缩放已测试：1080p、1440p、4K、超宽屏
- [ ] 窗口化、无边框、全屏模式工作正常
- [ ] 图形设置可正确保存并加载
- [ ] 商店 SDK 已集成并测试：[Steam/Epic/GOG]
- [ ] 成就功能正常
- [ ] 云存档功能正常

## 平台：主机（如适用）（Platform: Console）

- [ ] 满足 TRC/TCR/Lotcheck 要求
- [ ] 平台控制器提示正确
- [ ] 挂起/恢复功能正常
- [ ] 用户切换处理正确
- [ ] 网络断开可平滑处理
- [ ] 存储已满场景处理正确
- [ ] 遵循家长控制限制
- [ ] 认证提交流程已准备完成

---

## 商店与分发（Store and Distribution）

- [ ] 商店页面元数据完整且已校对
- [ ] 截图为最新版本并满足平台要求
- [ ] 预告片为最新版本
- [ ] 关键视觉与胶囊图已定稿
- [ ] 已取得分级：[ ] ESRB [ ] PEGI [ ] Other
- [ ] 法务材料：EULA、Privacy Policy、Terms of Service
- [ ] 所有地区定价已配置完成

---

## 上线就绪（Launch Readiness）

- [ ] 分析/遥测已验证并正在接收数据
- [ ] 崩溃上报已配置：[service name]
- [ ] 首日补丁已准备（如需要）
- [ ] 首发 72 小时值班团队排班已确定
- [ ] 社区公告文案已起草
- [ ] 媒体/创作者密钥已准备
- [ ] 支持团队已知会已知问题
- [ ] 回滚方案已文档化并测试

---

## 签字确认（Sign-offs）

| Role | Name | Status | Date |
| ---- | ---- | ---- | ---- |
| QA Lead | | [ ] Approved | |
| Technical Director | | [ ] Approved | |
| Producer | | [ ] Approved | |
| Creative Director | | [ ] Approved | |

---

## 最终决策（Final Decision）

**GO / NO-GO**: ____________

**Rationale**: [就绪情况摘要。若为 NO-GO，请列出具体阻塞项及预计解决时间。]

**Notes**: [任何补充背景、已接受的已知风险，或发布附带条件。]
