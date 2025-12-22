# Python 文件头模板

## 使用文档字符串（推荐）

```python
"""
Input: {导入模块，如: os, typing, .models.user}
Output: {导出函数/类，如: UserService 类, get_user(), create_user()}
Pos: {定位，如: 业务层-用户服务, 数据层-用户模型, 工具层-配置管理}

本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
"""

import os
from typing import List, Optional
from .models import User

class UserService:
    def get_user(self, user_id: int) -> Optional[User]:
        # 实现...
        pass
```

## 使用注释（简化版）

```python
# Input: {导入模块}
# Output: {导出内容}
# Pos: {定位}
# 本注释在文件修改时自动更新

def process_data(data):
    # 实现...
    pass
```

## 示例：完整文件

```python
"""
Input: flask, sqlalchemy, bcrypt, .models.User, .schemas.UserSchema
Output: UserController 类, /api/users 路由, /api/users/<id> 路由
Pos: API层-用户控制器，处理用户相关 HTTP 请求

本注释在文件修改时自动更新
"""

from flask import Blueprint, request, jsonify
from sqlalchemy.orm import Session
from bcrypt import hashpw, gensalt
from .models import User
from .schemas import UserSchema

user_bp = Blueprint('users', __name__)

@user_bp.route('/api/users', methods=['GET'])
def get_users():
    """获取用户列表"""
    # 实现...
    pass

@user_bp.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id: int):
    """获取单个用户"""
    # 实现...
    pass

@user_bp.route('/api/users', methods=['POST'])
def create_user():
    """创建新用户"""
    # 实现...
    pass
```

## FastAPI 示例

```python
"""
Input: fastapi, pydantic, sqlalchemy, .database, .models.User, .schemas.UserCreate
Output: router (APIRouter), GET /users, POST /users, GET /users/{user_id}
Pos: API层-用户路由，RESTful 用户管理接口

本注释在文件修改时自动更新
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from .database import get_db
from .models import User
from .schemas import UserCreate, UserResponse

router = APIRouter()

@router.get("/users", response_model=List[UserResponse])
async def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = db.query(User).offset(skip).limit(limit).all()
    return users

@router.post("/users", response_model=UserResponse)
async def create_user(user: UserCreate, db: Session = Depends(get_db)):
    db_user = User(**user.dict())
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user
```
