# Rust 文件头模板

## 使用模块级文档注释（推荐）

```rust
//! Input: {依赖 crate，如: serde, tokio, crate::models::User}
//! Output: {pub 函数/结构，如: pub fn process(), pub struct Config}
//! Pos: {定位，如: 业务层-用户服务, 数据层-模型定义, 工具层-配置管理}
//!
//! 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新

use serde::{Deserialize, Serialize};
use tokio::sync::RwLock;
use crate::models::User;

pub struct UserService {
    // 字段...
}

impl UserService {
    pub fn new() -> Self {
        // 实现...
    }
}
```

## 使用项注释（针对结构体/函数）

```rust
/// Input: {依赖}
/// Output: {导出内容}
/// Pos: {定位}
pub struct MyStruct {
    // 字段...
}

/// Input: std::fs, std::io
/// Output: read_file() -> Result<String>
/// Pos: 工具层-文件读取
pub fn read_file(path: &str) -> Result<String, std::io::Error> {
    // 实现...
}
```

## 示例：完整文件

```rust
//! Input: actix_web, sqlx, serde, bcrypt, crate::models::User, crate::db::DbPool
//! Output: pub fn configure_routes(), pub async fn get_users(), pub async fn create_user()
//! Pos: API层-用户路由处理器，处理用户相关 HTTP 请求
//!
//! 本注释在文件修改时自动更新

use actix_web::{web, HttpResponse, Result};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;

use crate::models::User;
use crate::db::DbPool;

#[derive(Debug, Deserialize)]
pub struct CreateUserRequest {
    pub username: String,
    pub email: String,
    pub password: String,
}

#[derive(Debug, Serialize)]
pub struct UserResponse {
    pub id: i32,
    pub username: String,
    pub email: String,
}

pub fn configure_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api/users")
            .route("", web::get().to(get_users))
            .route("", web::post().to(create_user))
            .route("/{id}", web::get().to(get_user)),
    );
}

pub async fn get_users(pool: web::Data<DbPool>) -> Result<HttpResponse> {
    let users = sqlx::query_as!(User, "SELECT * FROM users")
        .fetch_all(pool.get_ref())
        .await
        .map_err(|e| actix_web::error::ErrorInternalServerError(e))?;

    Ok(HttpResponse::Ok().json(users))
}

pub async fn create_user(
    user: web::Json<CreateUserRequest>,
    pool: web::Data<DbPool>,
) -> Result<HttpResponse> {
    // 创建用户逻辑...
    Ok(HttpResponse::Created().json(UserResponse {
        id: 1,
        username: user.username.clone(),
        email: user.email.clone(),
    }))
}

pub async fn get_user(
    user_id: web::Path<i32>,
    pool: web::Data<DbPool>,
) -> Result<HttpResponse> {
    // 获取用户逻辑...
    Ok(HttpResponse::Ok().finish())
}
```

## 库 crate 示例

```rust
//! Input: std::collections::HashMap, serde::Serialize
//! Output: pub struct Cache<K, V>, pub trait Cacheable
//! Pos: 工具层-缓存系统，提供通用键值缓存功能
//!
//! 本注释在文件修改时自动更新

use std::collections::HashMap;
use std::hash::Hash;
use serde::Serialize;

pub trait Cacheable {
    fn cache_key(&self) -> String;
}

pub struct Cache<K: Eq + Hash, V> {
    store: HashMap<K, V>,
}

impl<K: Eq + Hash, V> Cache<K, V> {
    pub fn new() -> Self {
        Self {
            store: HashMap::new(),
        }
    }

    pub fn get(&self, key: &K) -> Option<&V> {
        self.store.get(key)
    }

    pub fn insert(&mut self, key: K, value: V) -> Option<V> {
        self.store.insert(key, value)
    }
}
```
