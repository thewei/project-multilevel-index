# src/services 文件夹索引

## 架构说明
业务逻辑层，封装核心业务规则和数据访问逻辑。
采用服务模式，每个服务对应一个业务领域，通过依赖注入与数据层解耦。
所有事务管理和权限控制在此层完成。

## 文件清单

### userService.ts
- **地位**: 用户管理核心服务
- **功能**: 提供用户 CRUD 操作、认证逻辑、密码管理
- **依赖**: database.ts, logger.ts, User 模型, bcrypt, EmailService
- **被依赖**: userController.ts, authController.ts, adminController.ts
- **关键方法**: `createUser()`, `getUserById()`, `updateUser()`, `deleteUser()`, `validateCredentials()`

### authService.ts
- **地位**: 认证授权服务
- **功能**: JWT 生成验证、Token 刷新、权限检查、会话管理
- **依赖**: userService.ts, config.ts, jsonwebtoken, redis
- **被依赖**: authController.ts, authMiddleware.ts, socketService.ts
- **关键方法**: `generateToken()`, `verifyToken()`, `refreshToken()`, `checkPermission()`

### emailService.ts
- **地位**: 邮件发送服务
- **功能**: 发送验证邮件、密码重置邮件、通知邮件
- **依赖**: nodemailer, config.ts, emailTemplates
- **被依赖**: userService.ts, authService.ts, notificationService.ts
- **关键方法**: `sendVerificationEmail()`, `sendPasswordResetEmail()`, `sendNotification()`

### productService.ts
- **地位**: 产品管理服务
- **功能**: 产品 CRUD、库存管理、价格计算
- **依赖**: database.ts, Product 模型, Category 模型, logger.ts
- **被依赖**: productController.ts, orderService.ts, cartService.ts
- **关键方法**: `createProduct()`, `updateInventory()`, `calculatePrice()`, `searchProducts()`

### orderService.ts
- **地位**: 订单管理服务
- **功能**: 订单创建、状态更新、支付处理、发货管理
- **依赖**: database.ts, Order 模型, productService.ts, paymentService.ts, emailService.ts
- **被依赖**: orderController.ts, adminController.ts
- **关键方法**: `createOrder()`, `processPayment()`, `updateOrderStatus()`, `cancelOrder()`

### paymentService.ts
- **地位**: 支付处理服务
- **功能**: 集成第三方支付、支付验证、退款处理
- **依赖**: stripe, config.ts, logger.ts, Transaction 模型
- **被依赖**: orderService.ts, subscriptionService.ts
- **关键方法**: `createPaymentIntent()`, `confirmPayment()`, `processRefund()`

### notificationService.ts
- **地位**: 通知服务
- **功能**: 推送通知、邮件通知、短信通知的统一接口
- **依赖**: emailService.ts, smsService.ts, pushService.ts, NotificationQueue
- **被依赖**: orderService.ts, userService.ts, systemMonitor.ts
- **关键方法**: `send()`, `scheduleNotification()`, `batchSend()`

## 服务间依赖关系

```
userService ←─ authService
    ↓              ↓
emailService   orderService
    ↓              ↓
notificationService
                   ↓
            productService ← paymentService
```

## 设计模式

- **依赖注入**: 所有服务通过构造函数注入依赖
- **单例模式**: 服务实例在应用启动时创建，全局共享
- **策略模式**: `paymentService` 支持多种支付方式
- **观察者模式**: `notificationService` 订阅各类事件

## 最佳实践

1. **事务管理**: 涉及多表操作的方法使用数据库事务
2. **错误处理**: 统一的错误类型和错误码
3. **日志记录**: 关键操作记录详细日志
4. **缓存策略**: 频繁查询的数据使用 Redis 缓存
5. **异步处理**: 耗时操作（如邮件发送）使用消息队列

## 测试覆盖率

- userService: 95%
- authService: 92%
- orderService: 88%
- paymentService: 90%
- 其他服务: 85%+

## 性能指标

- 平均响应时间: < 100ms
- P95 响应时间: < 200ms
- 缓存命中率: > 80%
- 事务成功率: > 99.9%

---
⚠️ **自指声明**: 当本文件夹内容变化时（新增/删除/重命名文件），请更新此索引
