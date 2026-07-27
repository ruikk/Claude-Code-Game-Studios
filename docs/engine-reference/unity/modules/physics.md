# Unity 6.3 — Physics 模块参考

**最后校验时间：** 2026-02-13
**知识缺口：** Unity 6 物理改进、求解器变更

---

## 概览

Unity 6.3 使用 **PhysX 5.1**（相较于 2022 LTS 中的 PhysX 4.x 有所提升）：
- 更好的求解器稳定性
- 更优的性能
- 增强的碰撞检测

---

## 相比 2022 LTS 的关键变化

### 默认求解器迭代次数提升
Unity 6 提高了默认求解器迭代次数，以获得更好的稳定性：

```csharp
// 默认值从 6 次迭代改为 8 次
Physics.defaultSolverIterations = 8; // 如果依赖旧行为，请检查
```

### 增强的碰撞检测

```csharp
// ✅ Unity 6：改进了 Continuous Collision Detection (CCD，连续碰撞检测)
rigidbody.collisionDetectionMode = CollisionDetectionMode.ContinuousDynamic;
// 对高速移动物体的处理更好
```

---

## 核心物理组件

### Rigidbody

```csharp
// ✅ 最佳实践：使用 AddForce，而不是直接写 velocity
Rigidbody rb = GetComponent<Rigidbody>();
rb.AddForce(Vector3.forward * 10f, ForceMode.Impulse);

// ❌ 避免：直接赋值 velocity（可能导致不稳定）
rb.velocity = new Vector3(0, 10, 0); // 仅在必要时使用
```

### Colliders

```csharp
// 基础碰撞体：Box、Sphere、Capsule（开销最低）
// Mesh 碰撞体：开销高，仅用于静态几何体

// ✅ 复合碰撞体（多个基础碰撞体）优于单个 mesh collider
```

---

## 射线检测

### 高效 Raycasting（避免分配内存）

```csharp
// ✅ 不分配内存的 raycast
if (Physics.Raycast(origin, direction, out RaycastHit hit, maxDistance)) {
    Debug.Log($"Hit: {hit.collider.name}");
}

// ✅ 多命中（不分配内存）
RaycastHit[] results = new RaycastHit[10];
int hitCount = Physics.RaycastNonAlloc(origin, direction, results, maxDistance);
for (int i = 0; i < hitCount; i++) {
    Debug.Log($"Hit {i}: {results[i].collider.name}");
}

// ❌ 避免：RaycastAll（每次调用都会分配数组）
RaycastHit[] hits = Physics.RaycastAll(origin, direction); // GC allocation!
```

### 使用 LayerMask 进行选择性射线检测

```csharp
// ✅ 使用 LayerMask 过滤碰撞
int layerMask = 1 << LayerMask.NameToLayer("Enemy");
Physics.Raycast(origin, direction, out RaycastHit hit, maxDistance, layerMask);
```

---

## 物理查询

### OverlapSphere（检查附近物体）

```csharp
// ✅ 不分配内存的版本
Collider[] results = new Collider[10];
int count = Physics.OverlapSphereNonAlloc(center, radius, results);
for (int i = 0; i < count; i++) {
    // 处理 results[i]
}
```

### SphereCast（粗射线检测）

```csharp
// 适用于角色控制器
if (Physics.SphereCast(origin, radius, direction, out RaycastHit hit, maxDistance)) {
    // 用球形射线命中了某个物体
}
```

---

## 碰撞事件

### OnCollisionEnter / Stay / Exit

```csharp
void OnCollisionEnter(Collision collision) {
    // 在碰撞开始时触发
    Debug.Log($"Collided with {collision.gameObject.name}");

    // 访问接触点
    foreach (ContactPoint contact in collision.contacts) {
        Debug.DrawRay(contact.point, contact.normal, Color.red, 2f);
    }
}
```

### OnTriggerEnter / Stay / Exit

```csharp
void OnTriggerEnter(Collider other) {
    // Trigger 碰撞体（Is Trigger = true）
    if (other.CompareTag("Pickup")) {
        Destroy(other.gameObject);
    }
}
```

---

## 角色控制器

### CharacterController 组件

```csharp
CharacterController controller = GetComponent<CharacterController>();

// ✅ 带碰撞检测的移动
Vector3 move = transform.forward * speed * Time.deltaTime;
controller.Move(move);

// 手动施加重力
if (!controller.isGrounded) {
    velocity.y += Physics.gravity.y * Time.deltaTime;
}
controller.Move(velocity * Time.deltaTime);
```

---

## Physics Materials

### 摩擦与弹性

```csharp
// 创建：Assets > Create > Physic Material
// 赋给碰撞体：Collider > Material

// PhysicMaterial 设置：
// - Dynamic Friction: 0.6（滑动摩擦）
// - Static Friction: 0.6（起始摩擦）
// - Bounciness: 0.0 - 1.0
// - Friction Combine: Average, Minimum, Maximum, Multiply
// - Bounce Combine: Average, Minimum, Maximum, Multiply
```

---

## Joints

### Fixed Joint（连接两个刚体）

```csharp
FixedJoint joint = gameObject.AddComponent<FixedJoint>();
joint.connectedBody = otherRigidbody;
```

### Hinge Joint（门、轮子）

```csharp
HingeJoint hinge = gameObject.AddComponent<HingeJoint>();
hinge.axis = Vector3.up; // 旋转轴
hinge.useLimits = true;
hinge.limits = new JointLimits { min = -90, max = 90 };
```

---

## 性能优化

### Physics Layer Collision Matrix
`Edit > Project Settings > Physics > Layer Collision Matrix`
- 禁用层与层之间不必要的碰撞检测
- 能带来显著的性能收益

### Fixed Timestep
`Edit > Project Settings > Time > Fixed Timestep`
- 默认值：0.02（50 FPS 物理更新）
- 值越低越精确，但 CPU 开销越高
- 如有可能，尽量与游戏目标帧率匹配

### 简化碰撞几何体
- 优先使用基础碰撞体（box、sphere、capsule），而不是 mesh colliders
- 在构建时烘焙 mesh colliders，而不是运行时生成

---

## 常见模式

### Ground Check（角色控制器）

```csharp
bool IsGrounded() {
    float rayLength = 0.1f;
    return Physics.Raycast(transform.position, Vector3.down, rayLength);
}
```

### 施加爆炸力

```csharp
void ApplyExplosion(Vector3 explosionPos, float radius, float force) {
    Collider[] colliders = Physics.OverlapSphere(explosionPos, radius);
    foreach (Collider hit in colliders) {
        Rigidbody rb = hit.GetComponent<Rigidbody>();
        if (rb != null) {
            rb.AddExplosionForce(force, explosionPos, radius);
        }
    }
}
```

---

## 调试

### Physics Debugger（Unity 6+）
- `Window > Analysis > Physics Debugger`
- 可视化碰撞体、接触点、查询

### Gizmos

```csharp
void OnDrawGizmos() {
    Gizmos.color = Color.red;
    Gizmos.DrawWireSphere(transform.position, detectionRadius);
}
```

---

## Sources
- https://docs.unity3d.com/6000.0/Documentation/Manual/PhysicsOverview.html
- https://docs.unity3d.com/ScriptReference/Physics.html
