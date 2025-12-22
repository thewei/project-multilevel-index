# C# 文件头模板

## 使用 XML Documentation Comments

```csharp
/**
 * Input: {依赖命名空间，如: System.Linq, Microsoft.EntityFrameworkCore, MyApp.Models}
 * Output: {类/接口，如: UserService 类, IUserService 接口, CreateUser() 方法}
 * Pos: {定位，如: 业务层-用户服务, API层-用户控制器, 数据层-用户仓库}
 *
 * 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
 */

using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MyApp.Models;
using MyApp.Data;

namespace MyApp.Services
{
    /// <summary>
    /// 用户服务，提供用户管理业务逻辑
    /// </summary>
    public class UserService : IUserService
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<UserService> _logger;

        public UserService(ApplicationDbContext context, ILogger<UserService> logger)
        {
            _context = context;
            _logger = logger;
        }

        /// <summary>
        /// 获取所有用户
        /// </summary>
        /// <returns>用户列表</returns>
        public async Task<List<User>> GetAllUsersAsync()
        {
            return await _context.Users
                .AsNoTracking()
                .ToListAsync();
        }

        /// <summary>
        /// 根据 ID 获取用户
        /// </summary>
        /// <param name="id">用户 ID</param>
        /// <returns>用户对象，如果不存在则返回 null</returns>
        public async Task<User?> GetUserByIdAsync(int id)
        {
            return await _context.Users
                .AsNoTracking()
                .FirstOrDefaultAsync(u => u.Id == id);
        }

        /// <summary>
        /// 创建新用户
        /// </summary>
        /// <param name="user">用户对象</param>
        /// <returns>创建的用户</returns>
        public async Task<User> CreateUserAsync(User user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            _logger.LogInformation("User created: {UserId}", user.Id);

            return user;
        }

        /// <summary>
        /// 更新用户
        /// </summary>
        /// <param name="id">用户 ID</param>
        /// <param name="user">更新的用户数据</param>
        /// <returns>是否成功</returns>
        public async Task<bool> UpdateUserAsync(int id, User user)
        {
            var existingUser = await _context.Users.FindAsync(id);
            if (existingUser == null)
                return false;

            existingUser.Name = user.Name;
            existingUser.Email = user.Email;
            existingUser.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// 删除用户
        /// </summary>
        /// <param name="id">用户 ID</param>
        /// <returns>是否成功</returns>
        public async Task<bool> DeleteUserAsync(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return false;

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            _logger.LogInformation("User deleted: {UserId}", id);

            return true;
        }
    }
}
```

## ASP.NET Core Controller 示例

```csharp
/**
 * Input: Microsoft.AspNetCore.Mvc, MyApp.Services.IUserService, MyApp.DTOs
 * Output: UsersController 类, GET/POST/PUT/DELETE endpoints
 * Pos: API层-用户控制器，处理用户相关 HTTP 请求
 *
 * 本注释在文件修改时自动更新
 */

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using MyApp.Services;
using MyApp.DTOs;
using MyApp.Models;

namespace MyApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;
        private readonly ILogger<UsersController> _logger;

        public UsersController(IUserService userService, ILogger<UsersController> logger)
        {
            _userService = userService;
            _logger = logger;
        }

        /// <summary>
        /// 获取用户列表
        /// </summary>
        /// <returns>用户列表</returns>
        [HttpGet]
        [ProducesResponseType(typeof(IEnumerable<UserDto>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetUsers()
        {
            var users = await _userService.GetAllUsersAsync();
            var userDtos = users.Select(u => new UserDto(u));
            return Ok(userDtos);
        }

        /// <summary>
        /// 根据 ID 获取用户
        /// </summary>
        /// <param name="id">用户 ID</param>
        /// <returns>用户对象</returns>
        [HttpGet("{id}")]
        [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<UserDto>> GetUser(int id)
        {
            var user = await _userService.GetUserByIdAsync(id);
            if (user == null)
                return NotFound(new { message = "User not found" });

            return Ok(new UserDto(user));
        }

        /// <summary>
        /// 创建新用户
        /// </summary>
        /// <param name="request">创建用户请求</param>
        /// <returns>创建的用户</returns>
        [HttpPost]
        [ProducesResponseType(typeof(UserDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<UserDto>> CreateUser([FromBody] CreateUserRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = new User
            {
                Name = request.Name,
                Email = request.Email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                CreatedAt = DateTime.UtcNow
            };

            var createdUser = await _userService.CreateUserAsync(user);

            return CreatedAtAction(
                nameof(GetUser),
                new { id = createdUser.Id },
                new UserDto(createdUser)
            );
        }

        /// <summary>
        /// 更新用户
        /// </summary>
        /// <param name="id">用户 ID</param>
        /// <param name="request">更新用户请求</param>
        /// <returns>无内容</returns>
        [HttpPut("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = new User
            {
                Id = id,
                Name = request.Name,
                Email = request.Email
            };

            var success = await _userService.UpdateUserAsync(id, user);
            if (!success)
                return NotFound(new { message = "User not found" });

            return NoContent();
        }

        /// <summary>
        /// 删除用户
        /// </summary>
        /// <param name="id">用户 ID</param>
        /// <returns>无内容</returns>
        [HttpDelete("{id}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var success = await _userService.DeleteUserAsync(id);
            if (!success)
                return NotFound(new { message = "User not found" });

            return NoContent();
        }
    }
}
```

## Entity Framework Model 示例

```csharp
/**
 * Input: System.ComponentModel.DataAnnotations, Microsoft.EntityFrameworkCore
 * Output: User 实体类, navigation properties, data annotations
 * Pos: 数据层-用户实体模型，映射 Users 表
 *
 * 本注释在文件修改时自动更新
 */

using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyApp.Models
{
    /// <summary>
    /// 用户实体
    /// </summary>
    [Table("Users")]
    public class User
    {
        /// <summary>
        /// 用户 ID
        /// </summary>
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }

        /// <summary>
        /// 用户名
        /// </summary>
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;

        /// <summary>
        /// 邮箱地址
        /// </summary>
        [Required]
        [MaxLength(255)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        /// <summary>
        /// 密码哈希
        /// </summary>
        [Required]
        public string PasswordHash { get; set; } = string.Empty;

        /// <summary>
        /// 头像 URL
        /// </summary>
        [MaxLength(500)]
        public string? AvatarUrl { get; set; }

        /// <summary>
        /// 个人简介
        /// </summary>
        [MaxLength(1000)]
        public string? Bio { get; set; }

        /// <summary>
        /// 是否激活
        /// </summary>
        public bool IsActive { get; set; } = true;

        /// <summary>
        /// 创建时间
        /// </summary>
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        /// <summary>
        /// 更新时间
        /// </summary>
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // 导航属性

        /// <summary>
        /// 用户的文章
        /// </summary>
        public virtual ICollection<Post> Posts { get; set; } = new List<Post>();

        /// <summary>
        /// 用户的评论
        /// </summary>
        public virtual ICollection<Comment> Comments { get; set; } = new List<Comment>();
    }
}
```

## Repository Pattern 示例

```csharp
/**
 * Input: System.Linq.Expressions, Microsoft.EntityFrameworkCore, MyApp.Models
 * Output: IRepository<T> 接口, Repository<T> 类, 泛型数据访问
 * Pos: 数据层-通用仓储，提供 CRUD 操作抽象
 *
 * 本注释在文件修改时自动更新
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using MyApp.Data;

namespace MyApp.Repositories
{
    /// <summary>
    /// 通用仓储接口
    /// </summary>
    /// <typeparam name="T">实体类型</typeparam>
    public interface IRepository<T> where T : class
    {
        Task<IEnumerable<T>> GetAllAsync();
        Task<T?> GetByIdAsync(int id);
        Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate);
        Task<T> AddAsync(T entity);
        Task UpdateAsync(T entity);
        Task DeleteAsync(int id);
        Task<bool> ExistsAsync(int id);
    }

    /// <summary>
    /// 通用仓储实现
    /// </summary>
    /// <typeparam name="T">实体类型</typeparam>
    public class Repository<T> : IRepository<T> where T : class
    {
        protected readonly ApplicationDbContext _context;
        protected readonly DbSet<T> _dbSet;

        public Repository(ApplicationDbContext context)
        {
            _context = context;
            _dbSet = context.Set<T>();
        }

        public virtual async Task<IEnumerable<T>> GetAllAsync()
        {
            return await _dbSet.AsNoTracking().ToListAsync();
        }

        public virtual async Task<T?> GetByIdAsync(int id)
        {
            return await _dbSet.FindAsync(id);
        }

        public virtual async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
        {
            return await _dbSet.AsNoTracking().Where(predicate).ToListAsync();
        }

        public virtual async Task<T> AddAsync(T entity)
        {
            await _dbSet.AddAsync(entity);
            await _context.SaveChangesAsync();
            return entity;
        }

        public virtual async Task UpdateAsync(T entity)
        {
            _dbSet.Update(entity);
            await _context.SaveChangesAsync();
        }

        public virtual async Task DeleteAsync(int id)
        {
            var entity = await GetByIdAsync(id);
            if (entity != null)
            {
                _dbSet.Remove(entity);
                await _context.SaveChangesAsync();
            }
        }

        public virtual async Task<bool> ExistsAsync(int id)
        {
            var entity = await GetByIdAsync(id);
            return entity != null;
        }
    }
}
```

## Middleware 示例

```csharp
/**
 * Input: Microsoft.AspNetCore.Http, System.Threading.Tasks, Serilog
 * Output: RequestLoggingMiddleware 类, InvokeAsync() 方法
 * Pos: 中间件层-请求日志中间件，记录 HTTP 请求详情
 *
 * 本注释在文件修改时自动更新
 */

using Microsoft.AspNetCore.Http;
using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Serilog;

namespace MyApp.Middleware
{
    /// <summary>
    /// 请求日志中间件
    /// </summary>
    public class RequestLoggingMiddleware
    {
        private readonly RequestDelegate _next;
        private readonly ILogger _logger;

        public RequestLoggingMiddleware(RequestDelegate next, ILogger logger)
        {
            _next = next;
            _logger = logger;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            var stopwatch = Stopwatch.StartNew();

            // 记录请求
            await LogRequest(context);

            // 保存原始响应流
            var originalBodyStream = context.Response.Body;

            try
            {
                using var responseBody = new MemoryStream();
                context.Response.Body = responseBody;

                // 执行下一个中间件
                await _next(context);

                stopwatch.Stop();

                // 记录响应
                await LogResponse(context, stopwatch.ElapsedMilliseconds);

                // 复制响应到原始流
                await responseBody.CopyToAsync(originalBodyStream);
            }
            finally
            {
                context.Response.Body = originalBodyStream;
            }
        }

        private async Task LogRequest(HttpContext context)
        {
            context.Request.EnableBuffering();

            var body = await ReadRequestBody(context.Request);

            _logger.Information(
                "HTTP {Method} {Path} {QueryString} - Body: {Body}",
                context.Request.Method,
                context.Request.Path,
                context.Request.QueryString,
                body
            );

            context.Request.Body.Position = 0;
        }

        private async Task LogResponse(HttpContext context, long elapsedMs)
        {
            context.Response.Body.Seek(0, SeekOrigin.Begin);
            var body = await new StreamReader(context.Response.Body).ReadToEndAsync();
            context.Response.Body.Seek(0, SeekOrigin.Begin);

            _logger.Information(
                "HTTP {Method} {Path} responded {StatusCode} in {ElapsedMs}ms - Body: {Body}",
                context.Request.Method,
                context.Request.Path,
                context.Response.StatusCode,
                elapsedMs,
                body
            );
        }

        private async Task<string> ReadRequestBody(HttpRequest request)
        {
            using var reader = new StreamReader(
                request.Body,
                encoding: Encoding.UTF8,
                detectEncodingFromByteOrderMarks: false,
                leaveOpen: true
            );

            return await reader.ReadToEndAsync();
        }
    }
}
```

## xUnit Test 示例

```csharp
/**
 * Input: Xunit, Moq, FluentAssertions, MyApp.Services, MyApp.Models
 * Output: UserServiceTests 类, Fact/Theory 测试方法
 * Pos: 测试层-用户服务测试，验证业务逻辑
 *
 * 本注释在文件修改时自动更新
 */

using System.Collections.Generic;
using System.Threading.Tasks;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Moq;
using MyApp.Data;
using MyApp.Models;
using MyApp.Services;
using Xunit;

namespace MyApp.Tests.Services
{
    public class UserServiceTests
    {
        private readonly ApplicationDbContext _context;
        private readonly UserService _sut;

        public UserServiceTests()
        {
            var options = new DbContextOptionsBuilder<ApplicationDbContext>()
                .UseInMemoryDatabase(databaseName: "TestDatabase")
                .Options;

            _context = new ApplicationDbContext(options);
            _sut = new UserService(_context, Mock.Of<ILogger<UserService>>());
        }

        [Fact]
        public async Task GetAllUsersAsync_ShouldReturnAllUsers()
        {
            // Arrange
            var users = new List<User>
            {
                new User { Id = 1, Name = "John", Email = "john@example.com" },
                new User { Id = 2, Name = "Jane", Email = "jane@example.com" }
            };

            await _context.Users.AddRangeAsync(users);
            await _context.SaveChangesAsync();

            // Act
            var result = await _sut.GetAllUsersAsync();

            // Assert
            result.Should().HaveCount(2);
            result.Should().ContainEquivalentOf(users[0]);
            result.Should().ContainEquivalentOf(users[1]);
        }

        [Fact]
        public async Task GetUserByIdAsync_ExistingId_ShouldReturnUser()
        {
            // Arrange
            var user = new User { Id = 1, Name = "John", Email = "john@example.com" };
            await _context.Users.AddAsync(user);
            await _context.SaveChangesAsync();

            // Act
            var result = await _sut.GetUserByIdAsync(1);

            // Assert
            result.Should().NotBeNull();
            result!.Name.Should().Be("John");
        }

        [Fact]
        public async Task GetUserByIdAsync_NonExistingId_ShouldReturnNull()
        {
            // Act
            var result = await _sut.GetUserByIdAsync(999);

            // Assert
            result.Should().BeNull();
        }

        [Fact]
        public async Task CreateUserAsync_ValidUser_ShouldCreateAndReturnUser()
        {
            // Arrange
            var user = new User { Name = "New User", Email = "new@example.com" };

            // Act
            var result = await _sut.CreateUserAsync(user);

            // Assert
            result.Should().NotBeNull();
            result.Id.Should().BeGreaterThan(0);
            result.Name.Should().Be("New User");

            var savedUser = await _context.Users.FindAsync(result.Id);
            savedUser.Should().NotBeNull();
        }

        public void Dispose()
        {
            _context.Database.EnsureDeleted();
            _context.Dispose();
        }
    }
}
```
