# Java/Kotlin 文件头模板

## Java 使用 JavaDoc

```java
/**
 * Input: {导入包，如: com.example.models.User, java.util.List, org.springframework.beans}
 * Output: {公共类/接口，如: UserService 类, UserRepository 接口, createUser() 方法}
 * Pos: {定位，如: 业务层-用户服务, 数据层-用户仓库, API层-用户控制器}
 *
 * 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
 */

package com.example.service;

import com.example.model.User;
import com.example.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    @Autowired
    private UserRepository userRepository;

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public User createUser(User user) {
        return userRepository.save(user);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
}
```

## Kotlin 版本

```kotlin
/**
 * Input: com.example.models.User, kotlinx.coroutines, io.ktor.server.application
 * Output: UserService 类, suspend fun getUser(), suspend fun createUser()
 * Pos: 业务层-用户服务，提供用户管理业务逻辑
 *
 * 本注释在文件修改时自动更新
 */

package com.example.service

import com.example.model.User
import com.example.repository.UserRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.springframework.stereotype.Service

@Service
class UserService(
    private val userRepository: UserRepository
) {
    suspend fun getUserById(id: Long): User? = withContext(Dispatchers.IO) {
        userRepository.findById(id).orElse(null)
    }

    suspend fun createUser(user: User): User = withContext(Dispatchers.IO) {
        userRepository.save(user)
    }

    suspend fun getAllUsers(): List<User> = withContext(Dispatchers.IO) {
        userRepository.findAll()
    }
}
```

## Spring Boot Controller 示例

```java
/**
 * Input: org.springframework.web.bind.annotation, com.example.service.UserService, com.example.dto.UserDTO
 * Output: UserController 类, GET /api/users, POST /api/users, GET /api/users/{id}
 * Pos: API层-用户控制器，处理用户相关 HTTP 请求
 *
 * 本注释在文件修改时自动更新
 */

package com.example.controller;

import com.example.dto.UserDTO;
import com.example.model.User;
import com.example.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping
    public ResponseEntity<List<User>> getAllUsers() {
        return ResponseEntity.ok(userService.getAllUsers());
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userService.getUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody UserDTO userDTO) {
        User createdUser = userService.createUser(userDTO.toEntity());
        return ResponseEntity.status(HttpStatus.CREATED).body(createdUser);
    }

    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody UserDTO userDTO) {
        return userService.updateUser(id, userDTO.toEntity())
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }
}
```

## JPA Entity 示例

```java
/**
 * Input: javax.persistence, javax.validation.constraints, lombok
 * Output: User 实体类, @Entity, @Table, Getters/Setters
 * Pos: 数据层-用户实体模型，映射 users 表
 *
 * 本注释在文件修改时自动更新
 */

package com.example.model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import javax.persistence.*;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "Username is required")
    @Column(unique = true, nullable = false)
    private String username;

    @Email(message = "Invalid email format")
    @Column(unique = true, nullable = false)
    private String email;

    @NotBlank(message = "Password is required")
    @Column(nullable = false)
    private String password;

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
```

## Kotlin Data Class 示例

```kotlin
/**
 * Input: javax.persistence, kotlinx.serialization
 * Output: User data class, @Entity 注解, 序列化支持
 * Pos: 数据层-用户实体，Kotlin 风格的 JPA 实体
 *
 * 本注释在文件修改时自动更新
 */

package com.example.model

import kotlinx.serialization.Serializable
import javax.persistence.*
import java.time.LocalDateTime

@Entity
@Table(name = "users")
@Serializable
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long? = null,

    @Column(unique = true, nullable = false)
    val username: String,

    @Column(unique = true, nullable = false)
    val email: String,

    @Column(nullable = false)
    val password: String,

    @Column(name = "created_at")
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "updated_at")
    var updatedAt: LocalDateTime = LocalDateTime.now()
)
```
