# JavaScript/TypeScript 文件头模板

## 使用 JSDoc 块注释（推荐）

```javascript
/**
 * Input: {依赖模块列表，如: lodash, ./utils, ../models/User}
 * Output: {导出内容，如: createUser(), updateUser(), User 类型}
 * Pos: {定位，如: 业务层-用户管理服务, UI层-按钮组件, 工具层-日期格式化}
 *
 * 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
 */

import { something } from './module';
// 文件内容...
```

## 使用单行注释（简化版）

```javascript
// Input: {依赖模块}
// Output: {导出内容}
// Pos: {定位}
// 本注释在文件修改时自动更新

const myFunction = () => {
  // 实现...
};
```

## TypeScript 特定

```typescript
/**
 * Input: React, ./types/User, ./hooks/useAuth
 * Output: UserProfile 组件, UserProfileProps 类型
 * Pos: UI层-用户资料展示组件
 *
 * 本注释在文件修改时自动更新
 */

import React from 'react';
import { User } from './types/User';

export interface UserProfileProps {
  user: User;
}

export const UserProfile: React.FC<UserProfileProps> = ({ user }) => {
  // 组件实现...
};
```

## 示例：完整文件

```typescript
/**
 * Input: express, ./models/User, ./middleware/auth, bcrypt
 * Output: router (Express Router), POST /login, POST /register
 * Pos: API层-认证路由，处理用户登录注册请求
 *
 * 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
 */

import express from 'express';
import bcrypt from 'bcrypt';
import { User } from './models/User';
import { authMiddleware } from './middleware/auth';

const router = express.Router();

router.post('/login', async (req, res) => {
  // 登录逻辑...
});

router.post('/register', async (req, res) => {
  // 注册逻辑...
});

export default router;
```
