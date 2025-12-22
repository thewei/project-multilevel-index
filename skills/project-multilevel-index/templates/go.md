# Go 文件头模板

## 使用单行注释

```go
// Input: {导入包，如: net/http, database/sql, github.com/gin-gonic/gin}
// Output: {导出函数/类型，如: func GetUser(), type UserService struct}
// Pos: {定位，如: API层-用户路由处理, 业务层-用户服务, 数据层-用户模型}
//
// 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新

package user

import (
    "database/sql"
    "net/http"

    "github.com/gin-gonic/gin"
    "myapp/models"
)

// UserService 用户服务
type UserService struct {
    db *sql.DB
}

// NewUserService 创建用户服务实例
func NewUserService(db *sql.DB) *UserService {
    return &UserService{db: db}
}

// GetUser 获取用户
func (s *UserService) GetUser(id int) (*models.User, error) {
    // 实现...
    return nil, nil
}
```

## Gin Web 框架示例

```go
// Input: github.com/gin-gonic/gin, myapp/service, myapp/models, net/http
// Output: func RegisterUserRoutes(), func GetUsers(), func CreateUser()
// Pos: API层-用户路由，处理用户相关 HTTP 请求
//
// 本注释在文件修改时自动更新

package handlers

import (
    "net/http"
    "strconv"

    "github.com/gin-gonic/gin"
    "myapp/models"
    "myapp/service"
)

type UserHandler struct {
    userService *service.UserService
}

func NewUserHandler(userService *service.UserService) *UserHandler {
    return &UserHandler{userService: userService}
}

// RegisterUserRoutes 注册用户路由
func (h *UserHandler) RegisterUserRoutes(router *gin.RouterGroup) {
    users := router.Group("/users")
    {
        users.GET("", h.GetUsers)
        users.GET("/:id", h.GetUser)
        users.POST("", h.CreateUser)
        users.PUT("/:id", h.UpdateUser)
        users.DELETE("/:id", h.DeleteUser)
    }
}

// GetUsers godoc
// @Summary 获取用户列表
// @Tags users
// @Produce json
// @Success 200 {array} models.User
// @Router /users [get]
func (h *UserHandler) GetUsers(c *gin.Context) {
    users, err := h.userService.GetAllUsers()
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }
    c.JSON(http.StatusOK, users)
}

// GetUser godoc
// @Summary 获取单个用户
// @Tags users
// @Param id path int true "用户ID"
// @Produce json
// @Success 200 {object} models.User
// @Router /users/{id} [get]
func (h *UserHandler) GetUser(c *gin.Context) {
    id, _ := strconv.Atoi(c.Param("id"))
    user, err := h.userService.GetUserByID(id)
    if err != nil {
        c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
        return
    }
    c.JSON(http.StatusOK, user)
}

// CreateUser godoc
// @Summary 创建用户
// @Tags users
// @Accept json
// @Produce json
// @Param user body models.CreateUserRequest true "用户信息"
// @Success 201 {object} models.User
// @Router /users [post]
func (h *UserHandler) CreateUser(c *gin.Context) {
    var req models.CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    user, err := h.userService.CreateUser(&req)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusCreated, user)
}
```

## Service 层示例

```go
// Input: database/sql, myapp/models, myapp/repository, golang.org/x/crypto/bcrypt
// Output: type UserService struct, func GetUserByID(), func CreateUser()
// Pos: 业务层-用户服务，封装用户管理业务逻辑
//
// 本注释在文件修改时自动更新

package service

import (
    "database/sql"
    "errors"

    "golang.org/x/crypto/bcrypt"
    "myapp/models"
    "myapp/repository"
)

type UserService struct {
    userRepo *repository.UserRepository
}

func NewUserService(db *sql.DB) *UserService {
    return &UserService{
        userRepo: repository.NewUserRepository(db),
    }
}

func (s *UserService) GetUserByID(id int) (*models.User, error) {
    user, err := s.userRepo.FindByID(id)
    if err != nil {
        return nil, err
    }
    if user == nil {
        return nil, errors.New("user not found")
    }
    return user, nil
}

func (s *UserService) GetAllUsers() ([]*models.User, error) {
    return s.userRepo.FindAll()
}

func (s *UserService) CreateUser(req *models.CreateUserRequest) (*models.User, error) {
    // 密码加密
    hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
    if err != nil {
        return nil, err
    }

    user := &models.User{
        Username: req.Username,
        Email:    req.Email,
        Password: string(hashedPassword),
    }

    if err := s.userRepo.Create(user); err != nil {
        return nil, err
    }

    return user, nil
}

func (s *UserService) Authenticate(username, password string) (*models.User, error) {
    user, err := s.userRepo.FindByUsername(username)
    if err != nil {
        return nil, err
    }
    if user == nil {
        return nil, errors.New("invalid credentials")
    }

    if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)); err != nil {
        return nil, errors.New("invalid credentials")
    }

    return user, nil
}
```

## Model 定义示例

```go
// Input: time, encoding/json
// Output: type User struct, type CreateUserRequest struct
// Pos: 数据层-用户模型定义，数据结构和 JSON 序列化
//
// 本注释在文件修改时自动更新

package models

import (
    "time"
)

// User 用户模型
type User struct {
    ID        int       `json:"id" db:"id"`
    Username  string    `json:"username" db:"username"`
    Email     string    `json:"email" db:"email"`
    Password  string    `json:"-" db:"password"` // 不在 JSON 中返回
    CreatedAt time.Time `json:"created_at" db:"created_at"`
    UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// CreateUserRequest 创建用户请求
type CreateUserRequest struct {
    Username string `json:"username" binding:"required,min=3,max=50"`
    Email    string `json:"email" binding:"required,email"`
    Password string `json:"password" binding:"required,min=6"`
}

// UpdateUserRequest 更新用户请求
type UpdateUserRequest struct {
    Username string `json:"username" binding:"omitempty,min=3,max=50"`
    Email    string `json:"email" binding:"omitempty,email"`
}

// UserResponse 用户响应（隐藏敏感信息）
type UserResponse struct {
    ID        int       `json:"id"`
    Username  string    `json:"username"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}

// ToResponse 转换为响应对象
func (u *User) ToResponse() *UserResponse {
    return &UserResponse{
        ID:        u.ID,
        Username:  u.Username,
        Email:     u.Email,
        CreatedAt: u.CreatedAt,
    }
}
```

## Repository 层示例（GORM）

```go
// Input: gorm.io/gorm, myapp/models
// Output: type UserRepository struct, func FindByID(), func Create()
// Pos: 数据层-用户仓库，封装数据库操作
//
// 本注释在文件修改时自动更新

package repository

import (
    "gorm.io/gorm"
    "myapp/models"
)

type UserRepository struct {
    db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
    return &UserRepository{db: db}
}

func (r *UserRepository) FindByID(id int) (*models.User, error) {
    var user models.User
    result := r.db.First(&user, id)
    if result.Error != nil {
        return nil, result.Error
    }
    return &user, nil
}

func (r *UserRepository) FindAll() ([]*models.User, error) {
    var users []*models.User
    result := r.db.Find(&users)
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}

func (r *UserRepository) FindByUsername(username string) (*models.User, error) {
    var user models.User
    result := r.db.Where("username = ?", username).First(&user)
    if result.Error != nil {
        return nil, result.Error
    }
    return &user, nil
}

func (r *UserRepository) Create(user *models.User) error {
    return r.db.Create(user).Error
}

func (r *UserRepository) Update(user *models.User) error {
    return r.db.Save(user).Error
}

func (r *UserRepository) Delete(id int) error {
    return r.db.Delete(&models.User{}, id).Error
}
```
