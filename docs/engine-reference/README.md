# 引擎参考文档

此目录包含本项目所用游戏引擎的精选、版本锁定文档快照。之所以保留这些文件，
是因为**LLM 的知识有截止日期**，而游戏引擎会频繁更新。

## 存在原因

Claude 的训练数据有知识截止日期（当前为 2025 年 5 月）。Godot、Unity 和 Unreal
等游戏引擎会发布更新，引入破坏性 API 变更、新功能和弃用模式。没有这些参考文件，
代理可能会建议使用过时的代码。

## 结构

每个引擎都有自己的目录：

```
<engine>/
├── VERSION.md              # Pinned version, verification date, knowledge gap window
├── breaking-changes.md     # API changes between versions, organized by risk level
├── deprecated-apis.md      # "Don't use X → Use Y" lookup tables
├── current-best-practices.md  # New practices not in model training data
└── modules/                # Per-subsystem quick references (~150 lines max each)
    ├── rendering.md
    ├── physics.md
    └── ...
```

## 代理如何使用这些文件

引擎专家代理必须：

1. 阅读 `VERSION.md`，确认当前引擎版本
2. 在建议任何引擎 API 之前检查 `deprecated-apis.md`
3. 查阅 `breaking-changes.md`，了解特定版本的注意事项
4. 针对具体子系统的工作阅读相关的 `modules/*.md`

## 维护

### 更新时机

- 引擎版本升级后
- LLM 模型更新时（知识截止日期发生变化）
- 运行 `/refresh-docs` 后（如果可用）
- 发现模型对某个 API 的理解有误时

### 更新方法

1. 在 `VERSION.md` 中更新引擎版本和日期
2. 在 `breaking-changes.md` 中为版本迁移添加新条目
3. 将新近弃用的 API 移入 `deprecated-apis.md`
4. 在 `current-best-practices.md` 中更新新模式
5. 在相关的 `modules/*.md` 中更新 API 变更
6. 为所有修改过的文件设置“Last verified”日期

### 质量规则

- 每个文件都必须包含一个“Last verified: YYYY-MM-DD”日期
- 将模块文件控制在 150 行以内（上下文预算）
- 包含展示正确/错误模式的代码示例
- 链接官方文档 URL 以供验证
- 只记录与模型训练数据不同的内容
