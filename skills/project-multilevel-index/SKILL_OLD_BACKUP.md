---
name: 项目多级索引系统
description: 当用户请求"初始化索引"、"更新文档"、"生成依赖图"或检测到文件结构性变更时，使用此技能维护分形自指文档系统
version: 1.0.0
---

## 🌍 语言配置加载 (Language Configuration Loading)

**在执行任何命令前，首先加载语言配置:**

1. **读取配置文件**:
   - 使用 Read 工具尝试读取 `.claude/locale-config.json`
   - 如果文件不存在或读取失败，使用默认语言 `zh-CN`

2. **解析语言设置**:
   - 从配置文件获取 `language` 字段（如 `"en-US"` 或 `"zh-CN"`）
   - 获取 `fallback` 字段作为备用语言

3. **加载语言文件**:
   - 使用 Read 工具读取以下文件（路径基于语言代码）:
     - `locales/{language}/messages.json` - 命令输出、通知、错误消息
     - `locales/{language}/skill.json` - 技能描述和核心文本
     - `locales/{language}/templates.json` - 文件头模板文本
     - `locales/{language}/hooks.json` - Hook 提示信息
   - 将这些 JSON 数据解析并存储在上下文中作为 `LANG` 变量

4. **翻译函数**:
   使用以下模式引用翻译文本：
   - `{{LANG.messages.commands.initIndex.confirmDirectory}}` → 从 messages.json 获取文本
   - 参数替换：将 `{directory}`, `{count}`, `{file}` 等占位符替换为实际值

   示例：
   ```
   询问用户：{{LANG.messages.commands.initIndex.confirmDirectory}}
   实际输出（zh-CN）："当前目录是 /home/user/project, 确认这是项目根目录吗？"
   实际输出（en-US）："Current directory is /home/user/project, confirm this is the project root?"
   ```

5. **语言文件缺失处理**:
   - 如果主语言文件不存在，尝试加载 fallback 语言
   - 如果 fallback 也失败，使用内置的中文文本（向后兼容）

**重要**: 每次执行 `/init-index`, `/update-index`, `/check-index` 或 Hook 触发时，都必须先执行上述语言加载步骤。

---

# 项目多级索引系统 (Project Multi-level Index)

## 核心理念

这是一个受《哥德尔、埃舍尔、巴赫》启发的分形文档系统：
- **自相似性**：每个层级（项目→文件夹→文件）都有相同的索引结构
- **自指性**：每个文档都声明"当我变化时，更新我"
- **复调性**：代码与文档相互呼应，局部影响整体，整体影响局部

## 三级索引结构

```
PROJECT_INDEX.md (根索引)
  ├─ 项目概览
  ├─ 架构说明
  ├─ 目录结构
  └─ 依赖关系图 (Mermaid)

FOLDER_INDEX.md (文件夹索引)
  ├─ 3行架构说明
  ├─ 文件清单
  └─ 自指声明

文件头注释
  ├─ Input: 依赖的外部内容
  ├─ Output: 对外提供的内容
  ├─ Pos: 在系统中的定位
  └─ 自指声明
```

---

## 命令 1: 初始化索引 (`/init-index`)

### 使用场景
用户首次在项目中运行，或想要重建整个索引系统。

### 执行步骤

#### 步骤 1: 确认项目根目录
询问用户："当前目录是 `{pwd}`, 确认这是项目根目录吗？"

#### 步骤 2: 扫描项目结构
使用 Glob 工具扫描所有文件：
```
排除目录: node_modules, .git, dist, build, .next, target, vendor, __pycache__
支持语言: .js, .jsx, .ts, .tsx, .py, .java, .kt, .rs, .go, .cpp, .c, .h
```

报告扫描结果：
```
发现:
- JavaScript/TypeScript: 45 文件
- Python: 12 文件
- 总计 57 个代码文件，分布在 8 个文件夹
```

#### 步骤 3: 生成文件头注释
对每个代码文件：
1. 读取文件内容
2. 分析 import/require 语句 → Input
3. 分析 export/public 声明 → Output
4. 根据文件路径推断定位 → Pos
5. 检查是否已有文件头注释：
   - 如有：智能更新（保留用户自定义内容）
   - 如无：在文件开头插入注释

**语言特定模板**：
- **JavaScript/TypeScript**: `/** Input/Output/Pos */`
- **Python**: `""" Input/Output/Pos """`
- **Java/Kotlin**: `/** Input/Output/Pos */`
- **Rust**: `//! Input/Output/Pos`
- **Go**: `// Input/Output/Pos`
- **C++**: `/** Input/Output/Pos */`

#### 步骤 4: 生成 FOLDER_INDEX.md
对每个包含代码文件的文件夹（从叶子到根）：
1. 分析该文件夹的职责（根据文件名和路径推断）
2. 生成 3 行架构说明
3. 列出所有文件及其功能摘要
4. 添加自指声明

示例：
```markdown
# src/services 文件夹索引

## 架构说明
业务逻辑层，封装核心业务规则和数据访问逻辑。
采用服务模式，每个服务对应一个业务领域。

## 文件清单

### userService.ts
- **地位**: 用户管理核心服务
- **功能**: 用户 CRUD、认证、权限验证
- **依赖**: database, logger, User 模型
- **被依赖**: userController, authMiddleware

### authService.ts
- **地位**: 认证授权服务
- **功能**: JWT 生成、Token 验证、登录登出
- **依赖**: userService, config, bcrypt
- **被依赖**: authController, authMiddleware

---
⚠️ **自指声明**: 当本文件夹内容变化时，请更新此索引
```

#### 步骤 5: 生成 PROJECT_INDEX.md
在项目根目录创建：
1. 项目概览（3-5 行描述）
2. 整体架构说明
3. 目录树（列出所有文件夹及其职责）
4. 依赖关系图（Mermaid）

**Mermaid 图生成规则**：
- 解析所有文件的 import 关系
- 按文件夹分组（使用 `subgraph`）
- 最多显示 50 个节点（优先显示核心模块）
- 标注循环依赖（如果存在）

示例：
```markdown
# 项目全局索引

## 项目概览
这是一个全栈 Web 应用，采用前后端分离架构。
后端使用 Node.js + Express，数据库为 PostgreSQL。
前端使用 React + TypeScript，状态管理使用 Redux。

## 架构说明
采用经典三层架构：
- **表现层** (src/controllers): 处理 HTTP 请求，参数验证
- **业务层** (src/services): 核心业务逻辑，事务管理
- **数据层** (src/models): 数据库模型，ORM 映射

## 目录结构

### src/controllers
- **地位**: HTTP 控制器层
- **功能**: 请求路由、参数验证、响应格式化
- [详见 FOLDER_INDEX.md](src/controllers/FOLDER_INDEX.md)

### src/services
- **地位**: 业务逻辑层
- **功能**: 核心业务规则、数据访问封装
- [详见 FOLDER_INDEX.md](src/services/FOLDER_INDEX.md)

### src/models
- **地位**: 数据模型层
- **功能**: Sequelize 模型定义、数据库映射
- [详见 FOLDER_INDEX.md](src/models/FOLDER_INDEX.md)

## 依赖关系图

\`\`\`mermaid
graph TB
  subgraph Controllers
    UserCtrl[userController.ts]
    AuthCtrl[authController.ts]
  end

  subgraph Services
    UserSvc[userService.ts]
    AuthSvc[authService.ts]
  end

  subgraph Models
    UserModel[User.ts]
  end

  UserCtrl -->|调用| UserSvc
  AuthCtrl -->|调用| AuthSvc
  UserSvc -->|使用| UserModel
  AuthSvc -->|使用| UserSvc
  AuthSvc -->|使用| UserModel
\`\`\`

---
⚠️ **自指声明**: 任何功能、架构、写法更新必须在工作结束后更新此文档
```

#### 步骤 6: 总结报告
```
✅ 索引系统初始化完成!

已生成:
- 57 个文件头注释
- 8 个 FOLDER_INDEX.md
- 1 个 PROJECT_INDEX.md
- 依赖关系图包含 25 个节点、38 条边

下一步:
- 查看 PROJECT_INDEX.md 了解整体架构
- 使用 /update-index 手动更新索引
- 使用 /check-index 检查一致性
```

---

## 命令 2: 更新索引 (`/update-index`)

### 使用场景
用户手动触发索引更新，或 PostToolUse Hook 自动调用。

### 执行步骤

#### 步骤 1: 检测变更范围
如果是 Hook 触发，分析被修改的文件：
```
- 是否为索引文件自身? → 跳过
- 是否为代码文件? → 继续
- 变更类型是什么? → 判断更新范围
```

**变更类型判断**：

| 变更内容 | 类型 | 更新范围 |
|---------|------|---------|
| 新增/删除 import | Structural | 文件头 + 文件夹索引 + 根索引 |
| 修改函数签名/类定义 | Structural | 文件头 + 文件夹索引 |
| 修改 Input/Output 注释 | Header | 仅文件头 |
| 修改函数内部实现 | Implementation | 不更新 |

#### 步骤 2: 执行增量更新
根据变更类型：

**Structural 变更**：
1. 重新分析文件的 Input/Output
2. 更新文件头注释
3. 更新所在文件夹的 FOLDER_INDEX.md（仅更新该文件的条目）
4. 重新生成 PROJECT_INDEX.md 的依赖图

**Header 变更**：
1. 仅更新文件头注释

#### 步骤 3: 智能合并
如果短时间内多个文件变更：
- 收集所有变更
- 批量更新文件夹索引（每个文件夹只更新一次）
- 根索引只在最后更新一次

#### 步骤 4: 报告更新
```
[索引已更新]
- 文件: src/services/authService.ts
- 变更: 新增 import bcrypt
- 已更新: 文件头注释、services/FOLDER_INDEX.md、PROJECT_INDEX.md
```

---

## 命令 3: 检查索引 (`/check-index`)

### 使用场景
用户想验证索引系统的完整性和一致性。

### 执行步骤

#### 步骤 1: 检查文件头完整性
扫描所有代码文件，检查是否包含 Input/Output/Pos 注释。

#### 步骤 2: 检查文件夹索引
- 每个包含代码的文件夹是否有 FOLDER_INDEX.md
- 索引中列出的文件是否都存在
- 是否有文件未被索引

#### 步骤 3: 检查依赖关系
- 解析所有 import 语句
- 检测循环依赖
- 验证依赖的文件是否存在

#### 步骤 4: 生成报告
```
索引一致性检查报告
===================

✅ 文件头完整性: 55/57 (2 个文件缺少注释)
  - src/utils/legacy.js
  - src/temp/test.ts

✅ 文件夹索引: 8/8 全部正常

⚠️ 依赖关系: 发现 1 个循环依赖
  - src/a.ts → src/b.ts → src/c.ts → src/a.ts

✅ 索引结构: 符合规范

建议操作:
1. 运行 /update-index 补充缺失的文件头注释
2. 重构循环依赖
```

---

## PostToolUse Hook 自动更新逻辑

### 触发条件
当用户使用 Write 或 Edit 工具修改文件时。

### 执行流程

#### 步骤 1: 过滤文件
跳过以下文件：
- `PROJECT_INDEX.md`
- `FOLDER_INDEX.md`
- 非代码文件（图片、PDF 等）
- 排除目录中的文件

#### 步骤 2: 快速判断
阅读修改内容，判断是否包含：
- `import`, `require`, `use`, `#include` 关键字
- `export`, `public`, `class`, `interface`, `function`, `def`, `fn` 关键字

**如果包含** → 可能是结构性变更，继续分析
**如果不包含** → 可能仅是实现细节，跳过

#### 步骤 3: 详细分析
读取完整文件，对比变更前后：
- Import 语句是否有增减
- 导出的符号是否变化
- 函数/类签名是否改变

#### 步骤 4: 执行更新
如果确认是结构性变更，调用 `/update-index` 逻辑。

#### 步骤 5: 静默处理
- 如果是小改动，静默更新，不打断用户
- 如果是大改动（如重构多个文件），简短提示：
  ```
  [索引系统] 检测到结构性变更，已自动更新索引
  ```

---

## 多语言文件头模板

### JavaScript/TypeScript
```javascript
/**
 * Input: {依赖列表}
 * Output: {导出列表}
 * Pos: {定位描述}
 *
 * 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
 */
```

### Python
```python
"""
Input: {依赖模块}
Output: {导出类/函数}
Pos: {定位描述}

本注释在文件修改时自动更新
"""
```

### Java/Kotlin
```java
/**
 * Input: {依赖包}
 * Output: {公共类/接口}
 * Pos: {定位描述}
 *
 * 本注释在文件修改时自动更新
 */
```

### Rust
```rust
//! Input: {依赖 crate}
//! Output: {pub 函数/结构}
//! Pos: {定位描述}
//!
//! 本注释在文件修改时自动更新
```

### Go
```go
// Input: {导入包}
// Output: {导出函数/类型}
// Pos: {定位描述}
//
// 本注释在文件修改时自动更新
```

### C++
```cpp
/**
 * @brief {简要描述}
 * Input: {头文件依赖}
 * Output: {导出符号}
 * Pos: {定位描述}
 *
 * 本注释在文件修改时自动更新
 */
```

---

## 依赖分析规则

### JavaScript/TypeScript

**Input 识别 (依赖)**:
```javascript
// ES6 静态导入
import { foo, bar } from './module'           → ./module
import * as utils from '../utils'             → ../utils
import React from 'react'                     → react (第三方)

// CommonJS 导入
const express = require('express')            → express
const { User } = require('./models/User')     → ./models/User

// 动态导入
const mod = await import('./dynamic')         → ./dynamic

// TypeScript 类型导入
import type { Config } from './types'         → ./types
```

**Output 识别 (导出)**:
```javascript
// 命名导出
export function createUser() {}               → createUser()
export class UserService {}                   → UserService 类
export const API_URL = "..."                  → API_URL 常量

// 默认导出
export default MyComponent                    → MyComponent (default)

// 重导出
export { User } from './models'               → User (from ./models)
export * from './utils'                       → * (from ./utils)
```

**区分本地 vs 第三方**:
- 本地模块: 以 `.` 或 `@/` 开头
- 第三方库: 包名 (react, lodash, express)
- 内置模块: Node.js 内置 (fs, path, http)

---

### Python

**Input 识别**:
```python
# 标准导入
import os                                     → os (内置)
import numpy as np                            → numpy (第三方)

# From 导入
from typing import List, Dict                 → typing
from .models import User                      → .models (相对导入)
from ..utils import validator                 → ..utils (父级模块)

# 第三方包
from django.db import models                  → django.db
```

**Output 识别**:
```python
# 顶层定义 (非下划线开头视为公开)
def get_user():                               → get_user() 函数
class UserService:                            → UserService 类
API_KEY = "..."                               → API_KEY 常量

# 私有定义 (下划线开头，不作为 Output)
def _internal_helper():                       → 私有，忽略
class _PrivateClass:                          → 私有，忽略

# __all__ 显式声明
__all__ = ['User', 'create_user']             → 仅这些为 Output
```

**智能判断**:
- 检查 `__all__` 优先使用其定义的导出
- 无 `__all__` 时，收集所有非下划线开头的顶层定义
- 忽略 `if __name__ == '__main__':` 内的代码

---

### Java

**Input 识别**:
```java
import java.util.List;                        → java.util.List
import com.example.User;                      → com.example.User
import static java.util.Collections.*;        → java.util.Collections (静态)
```

**Output 识别**:
```java
public class UserService {}                   → UserService 类 (public)
public interface IAuthService {}              → IAuthService 接口
protected class Helper {}                     → Helper 类 (protected)
private class Internal {}                     → 私有，忽略

public void processUser() {}                  → processUser() 方法
```

**访问修饰符规则**:
- `public`: 完全公开 → 收录为 Output
- `protected`: 包内/子类可见 → 收录为 Output
- 默认 (package-private): 包内可见 → 收录
- `private`: 私有 → 忽略

---

### Rust

**Input 识别**:
```rust
use std::collections::HashMap;                → std::collections::HashMap
use crate::models::User;                      → crate::models::User (本地)
use super::utils;                             → super::utils (父模块)
use serde::{Serialize, Deserialize};          → serde (第三方)
```

**Output 识别**:
```rust
pub fn process() {}                           → process() 函数
pub struct Config {}                          → Config 结构体
pub enum Status {}                            → Status 枚举
pub trait Validator {}                        → Validator trait

// 私有定义
fn internal() {}                              → 私有，忽略
struct PrivateData {}                         → 私有，忽略
```

---

### Go

**Input 识别**:
```go
import "fmt"                                  → fmt (标准库)
import "database/sql"                         → database/sql
import "github.com/user/repo/pkg"             → github.com/user/repo/pkg

// 别名导入
import db "gorm.io/gorm"                      → gorm.io/gorm (别名 db)
```

**Output 识别**:
```go
// 大写开头 = 导出
func GetUser() {}                             → GetUser() 函数 (exported)
type UserService struct {}                    → UserService 结构体
const MaxRetries = 3                          → MaxRetries 常量

// 小写开头 = 私有
func processInternal() {}                     → 私有，忽略
type config struct {}                         → 私有，忽略
```

**命名约定**:
- 大写字母开头: 导出 (公开)
- 小写字母开头: 包内私有

---

### C/C++

**Input 识别**:
```cpp
#include "user.h"                             → user.h (本地头文件)
#include <vector>                             → vector (标准库)
#include <boost/algorithm.hpp>                → boost/algorithm.hpp (第三方)
```

**Output 识别** (仅在头文件中分析):
```cpp
// 类声明
class UserService {                           → UserService 类
public:
    void processUser();                       → processUser() 方法
private:
    void internal();                          → 私有，忽略
};

// 函数声明
void initialize();                            → initialize() 函数
extern int globalCounter;                     → globalCounter 变量
```

**规则**:
- 仅分析 `.h` 或 `.hpp` 文件的 Output
- `.cpp` 文件仅分析 Input (依赖的头文件)
- `public` 成员作为 Output，`private` 忽略

---

### PHP

**Input 识别**:
```php
require 'vendor/autoload.php';                → vendor/autoload.php
include_once 'config.php';                    → config.php
use App\Models\User;                          → App\Models\User
use Illuminate\Support\Facades\DB;            → Illuminate\Support\Facades\DB
```

**Output 识别**:
```php
class UserController {                        → UserController 类
function getUserById($id) {                   → getUserById() 函数
const API_VERSION = '1.0';                    → API_VERSION 常量
```

---

### Ruby

**Input 识别**:
```ruby
require 'json'                                → json (内置)
require 'rails'                               → rails (gem)
require_relative 'user_model'                 → user_model (相对路径)
```

**Output 识别**:
```ruby
class UserService                             → UserService 类
  def self.create_user                        → create_user 类方法
  def update_user                             → update_user 实例方法
end

module Authentication                         → Authentication 模块
```

---

## 依赖分析最佳实践

### 1. 区分本地 vs 第三方依赖
```
本地依赖:
  - 显示完整相对路径: ./models/User, ../utils/validator
  - 在依赖图中用实线连接

第三方依赖:
  - 仅显示包名: react, express, django
  - 在依赖图中用虚线连接或省略 (如节点过多)
```

### 2. 处理循环依赖
```
检测到: A → B → C → A
标注: ⚠️ 循环依赖
建议: 在 /check-index 报告中列出并建议重构
```

### 3. 忽略噪音
```
跳过以下导入 (不显示在依赖图中):
  - 测试框架: jest, pytest, junit
  - 类型定义: @types/*
  - 开发工具: eslint, prettier
  - 构建工具: webpack, vite, rollup
```

### 4. 错误处理
```
无法解析的导入:
  - 记录警告但不中断流程
  - 在文件头注释中标注 "⚠️ 部分依赖无法解析"
  - 在 /check-index 报告中列出
```

---

## Mermaid 图生成策略

### 基本规则
```mermaid
graph TB
  subgraph 文件夹名
    文件A[文件名]
    文件B[文件名]
  end

  文件A -->|依赖关系| 文件B
```

### 复杂度控制
- 如果节点数 > 50：只显示核心模块（被依赖最多的）
- 如果边数 > 100：省略第三方库依赖
- 提供文件夹级别聚合视图选项

### 循环依赖标注
```mermaid
文件A -->|⚠️ 循环| 文件B
文件B -->|⚠️ 循环| 文件A

style 文件A fill:#faa
style 文件B fill:#faa
```

---

## 智能判断指南

### 何时更新索引
✅ **需要更新**：
- 文件新增/删除
- Import 语句变化
- 导出符号变化
- 函数/类签名改变
- 文件移动到其他文件夹

❌ **无需更新**：
- 函数内部实现改变（不影响签名）
- 注释修改（除了文件头注释）
- 格式化、空格调整
- 测试文件的细节修改

### 文件头注释冲突处理
如果文件已有注释：
1. 尝试定位现有的 Input/Output/Pos 标记
2. 对比当前分析结果
3. 如果不同，智能合并：
   - 保留用户添加的自定义说明
   - 更新依赖和导出列表
   - 更新自指声明

### 性能优化
- 使用 Grep 工具快速搜索 import 关键字，而非读取所有文件
- 缓存已分析的文件依赖（在会话期间）
- 批量更新而非逐个更新

---

## 示例场景

### 场景 1: 用户新建项目
```
User: /init-index
Assistant:
确认当前目录是 h:/Project/my-app 吗？

User: 是的
Assistant:
正在扫描项目...
发现:
- TypeScript: 23 文件
- Python: 8 文件

正在生成索引系统...
[进度条显示]

✅ 完成！已创建 PROJECT_INDEX.md，请查看项目架构。
```

### 场景 2: 自动更新（Hook 触发）
```
[用户修改 src/services/auth.ts，新增 import bcrypt]

Assistant (静默执行):
1. 检测到 auth.ts 新增 import
2. 更新文件头注释
3. 更新 services/FOLDER_INDEX.md
4. 更新 PROJECT_INDEX.md 依赖图

[显示简短提示]
[索引系统] 已自动更新 auth.ts 的索引
```

### 场景 3: 一致性检查
```
User: /check-index
Assistant:
正在检查索引系统...

索引一致性报告
===============
✅ 文件头: 30/30 完整
✅ 文件夹索引: 5/5 正常
✅ 依赖关系: 无循环依赖
✅ 结构完整性: 通过

索引系统运行良好！
```

---

## 错误处理与边界情况

### 1. 文件解析错误

**场景**: 文件包含语法错误，无法正常解析

**处理策略**:
```
try {
  分析文件的 import/export
} catch (ParseError) {
  - 记录警告: "⚠️ 无法解析 {文件名}，跳过"
  - 在文件头注释中标注: "⚠️ 自动分析失败，请手动编辑"
  - 不中断整体流程，继续处理其他文件
  - 在 /check-index 报告中列出所有解析失败的文件
}
```

### 2. 超大文件处理

**场景**: 单个文件 > 500KB 或 > 10000 行

**处理策略**:
```
if (文件大小 > 500KB) {
  - 仅分析文件前 5000 行的 import/export
  - 在文件头注释中标注: "⚠️ 大文件，仅部分分析"
  - 提示用户: "建议拆分此文件以提高可维护性"
  - 不在依赖图中显示（避免过度复杂）
}
```

### 3. 文件头注释冲突

**场景**: 文件已有非标准格式的头注释

**智能合并策略**:
```
现有注释:
  /**
   * 用户服务模块 - 这是我的自定义说明
   * @author John Doe
   */

新生成注释:
  /**
   * Input: ./models/User, bcrypt
   * Output: UserService 类
   * Pos: 业务层-用户管理

理想合并结果:
  /**
   * 用户服务模块 - 这是我的自定义说明
   * @author John Doe
   *
   * Input: ./models/User, bcrypt
   * Output: UserService 类
   * Pos: 业务层-用户管理
   *
   * 本注释在文件修改时自动更新
   */
```

**规则**:
- 保留用户自定义说明（第一段）
- 保留 @author, @license 等标签
- 更新 Input/Output/Pos 字段
- 添加自指声明

### 4. 循环依赖处理

**场景**: A → B → C → A

**处理策略**:
```
检测到循环依赖时:
  1. 不中断索引生成
  2. 在 PROJECT_INDEX.md 的依赖图中用红色标注
  3. 在 /check-index 报告中详细列出
  4. 提供重构建议:
     "建议: 提取 A、B、C 的共享逻辑到 Common 模块"
  5. 在相关文件的文件头注释中标注:
     "⚠️ 存在循环依赖，建议重构"
```

**Mermaid 图示**:
```mermaid
A -->|⚠️ 循环| B
B -->|⚠️ 循环| C
C -->|⚠️ 循环| A

style A fill:#faa
style B fill:#faa
style C fill:#faa
```

### 5. 依赖文件不存在

**场景**: import './missing-file'

**处理策略**:
```
if (依赖文件不存在) {
  - 仍然在 Input 中记录: "./missing-file ⚠️ (不存在)"
  - 在 /check-index 报告中列出
  - 不在依赖图中创建节点（避免图混乱）
  - 提示用户: "检查 import 路径是否正确"
}
```

### 6. Git 仓库过大

**场景**: 项目包含 .git 目录，大小 > 1GB

**处理策略**:
```
if (检测到 .git 目录) {
  - 自动排除 .git 目录
  - 不扫描 .git 内的任何文件
  - 提示: "已自动排除 .git 目录"
}

if (扫描超时 > 2 分钟) {
  - 提示用户: "扫描时间较长，建议使用 --exclude 排除大目录"
  - 提供 --max-depth 选项限制深度
}
```

### 7. 权限问题

**场景**: 无法读取某些文件（权限不足）

**处理策略**:
```
try {
  读取文件内容
} catch (PermissionError) {
  - 记录警告: "⚠️ 无权限读取 {文件名}"
  - 跳过此文件
  - 在 /check-index 报告中列出
  - 不阻塞整体流程
}
```

### 8. 文件夹索引已被手动修改

**场景**: 用户手动编辑了 FOLDER_INDEX.md

**处理策略**:
```
检测用户修改的方式:
  - 检查文件头是否有 "<!-- auto-generated -->" 标记
  - 如无标记，视为用户完全手动维护
  - 如有标记，仅更新标记内的内容

if (用户完全手动维护) {
  - 询问用户: "检测到手动编辑的 FOLDER_INDEX.md，是否覆盖？"
  - 提供选项:
    [1] 覆盖（使用自动生成内容）
    [2] 合并（保留用户内容，追加新内容）
    [3] 跳过（不更新此文件）
}
```

### 9. 动态导入处理

**场景**: const module = await import(`./dynamic/${name}`)

**处理策略**:
```
动态导入无法静态分析:
  - 在 Input 中标注: "⚠️ 动态导入 ./dynamic/*"
  - 提示用户手动补充依赖信息
  - 不在依赖图中创建边（避免误导）
```

### 10. 第三方依赖未安装

**场景**: import 'missing-package'

**处理策略**:
```
if (第三方依赖不在 package.json/requirements.txt) {
  - 在 Input 中标注: "missing-package ⚠️ (未安装)"
  - 在 /check-index 报告中列出
  - 建议: "运行 npm install 或 pip install"
}
```

### 11. 空文件或仅注释文件

**场景**: 文件只有注释，无任何代码

**处理策略**:
```
if (文件无实质内容) {
  - 不生成文件头注释
  - 不在 FOLDER_INDEX.md 中列出
  - 在 /check-index 报告中标注: "空文件，建议删除或补充代码"
}
```

### 12. Mermaid 图过于复杂

**场景**: 依赖图包含 200+ 节点

**处理策略**:
```
if (节点数 > 100) {
  - 仅显示核心模块（被依赖最多的前 50 个）
  - 分层显示:
    Layer 1: 仅显示文件夹级别依赖
    Layer 2: 点击文件夹展开详细文件依赖
  - 生成多个视图:
    * 整体视图（文件夹级别）
    * 详细视图（分模块）
}
```

**生成多个图**:
```markdown
## 依赖关系图（整体视图）
[简化的文件夹级别图]

## 详细依赖关系
### controllers/ 模块
[controllers 内部文件的详细依赖]

### services/ 模块
[services 内部文件的详细依赖]
```

---

## 性能优化策略

### 1. 缓存机制
```
会话级缓存:
  - 已分析的文件内容（避免重复读取）
  - 已解析的依赖关系
  - 清除策略: 会话结束时自动清除
```

### 2. 增量更新优化
```
仅在以下情况全量扫描:
  - 首次运行 /init-index
  - 使用 --full 参数
  - 检测到项目结构大幅变化（新增/删除 10+ 文件）

其他情况使用增量更新:
  - 仅处理变更的文件
  - 仅更新受影响的索引
```

### 3. 并发处理
```
大型项目优化:
  - 并发分析多个文件（最多 10 个并发）
  - 批量写入文件（减少 I/O 操作）
  - 使用 Glob 工具的高效模式匹配
```

### 4. 超时保护
```
if (单个文件分析 > 30 秒) {
  - 标记为超时
  - 跳过此文件
  - 记录警告
}

if (整体流程 > 10 分钟) {
  - 询问用户是否继续
  - 提示使用 --exclude 缩小范围
}
```

---

## 注意事项

1. **避免过度更新**：只在真正的结构性变化时更新索引
2. **保护用户内容**：更新时保留用户手动添加的注释
3. **清晰提示**：让用户知道索引系统在做什么
4. **性能优先**：大型项目使用增量更新而非全量扫描
5. **容错处理**：遇到无法解析的文件时跳过，不阻塞整体流程
6. **防止循环**：索引文件修改时不触发更新（检测文件名）
7. **安全第一**：不执行文件中的任何代码，仅静态分析
8. **用户至上**：任何不确定的操作都先询问用户

---

## 相关资源

- **模板**: [templates/](templates/) - 各语言文件头模板
- **示例**: [examples/](examples/) - 示例项目索引输出
- **配置**: 用户可在 `.claude/index-config.json` 自定义排除规则

---

**这是一个自组织、自维护的文档系统——让代码项目如《哥德尔、埃舍尔、巴赫》中的赋格曲，自我指涉、优雅和谐。**
