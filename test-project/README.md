# 测试项目

这是一个小型测试项目，用于验证项目多级索引系统的功能。

## 项目结构

```
test-project/
├── src/
│   ├── controllers/
│   │   ├── user.controller.ts
│   │   └── auth.controller.ts
│   ├── services/
│   │   ├── user.service.ts
│   │   └── auth.service.ts
│   ├── models/
│   │   └── User.ts
│   └── utils/
│       └── logger.ts
└── README.md
```

## 测试流程

1. **初始化索引**
   ```
   cd test-project
   /init-index
   ```

2. **验证生成的文件**
   - 检查每个代码文件是否有文件头注释
   - 检查每个文件夹是否有 FOLDER_INDEX.md
   - 检查根目录是否有 PROJECT_INDEX.md

3. **测试更新功能**
   ```
   # 修改 src/services/user.service.ts，添加新的 import
   /update-index
   ```

4. **测试检查功能**
   ```
   /check-index
   ```

## 预期结果

- 生成 6 个文件头注释
- 生成 4 个 FOLDER_INDEX.md (controllers, services, models, utils)
- 生成 1 个 PROJECT_INDEX.md 和依赖关系图
- 依赖图应包含约 6-8 个节点
