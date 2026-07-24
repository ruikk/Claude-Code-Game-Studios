---
paths:
  - "src/networking/**"
---

# 网络代码规则

- 服务器对所有游戏关键状态拥有权威性（Authoritative）——绝不信任客户端
- 所有网络消息必须版本化（versioned），以支持前向/后向兼容性
- 客户端在本地进行预测（predict），与服务器协调（reconcile）——为预测错误实现回滚（rollback）
- 优雅地处理断开连接、重新连接和主机迁移（host migration）
- 对所有网络日志进行速率限制（rate-limit），防止日志泛滥
- 所有网络同步的值必须指定复制策略（replication strategy）：可靠/不可靠（reliable/unreliable）、频率、插值（interpolation）
- 带宽预算（bandwidth budget）：定义并跟踪每种消息类型的带宽使用
- 安全：验证所有传入数据包的大小和字段范围
