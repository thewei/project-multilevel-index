# PHP 文件头模板

## 使用 PHPDoc

```php
<?php
/**
 * Input: {依赖类/文件，如: User, Database, Illuminate\Support\Facades\Hash}
 * Output: {类/函数，如: UserService 类, createUser() 方法, updateUser() 方法}
 * Pos: {定位，如: 业务层-用户服务, API层-用户控制器, 数据层-用户模型}
 *
 * 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
 */

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class UserService
{
    /**
     * 创建新用户
     */
    public function createUser(array $data): User
    {
        $data['password'] = Hash::make($data['password']);
        return User::create($data);
    }

    /**
     * 根据 ID 获取用户
     */
    public function getUserById(int $id): ?User
    {
        return User::find($id);
    }

    /**
     * 更新用户信息
     */
    public function updateUser(int $id, array $data): bool
    {
        $user = User::find($id);
        if (!$user) {
            return false;
        }
        return $user->update($data);
    }
}
```

## Laravel Controller 示例

```php
<?php
/**
 * Input: Illuminate\Http\Request, App\Services\UserService, App\Http\Resources\UserResource
 * Output: UserController 类, index(), store(), show(), update(), destroy()
 * Pos: API层-用户控制器，处理用户相关 HTTP 请求
 *
 * 本注释在文件修改时自动更新
 */

namespace App\Http\Controllers;

use App\Http\Requests\CreateUserRequest;
use App\Http\Requests\UpdateUserRequest;
use App\Http\Resources\UserResource;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class UserController extends Controller
{
    protected UserService $userService;

    public function __construct(UserService $userService)
    {
        $this->userService = $userService;
    }

    /**
     * 获取用户列表
     *
     * @return AnonymousResourceCollection
     */
    public function index(Request $request): AnonymousResourceCollection
    {
        $users = $this->userService->getAllUsers(
            $request->input('page', 1),
            $request->input('per_page', 15)
        );

        return UserResource::collection($users);
    }

    /**
     * 创建新用户
     *
     * @param CreateUserRequest $request
     * @return JsonResponse
     */
    public function store(CreateUserRequest $request): JsonResponse
    {
        $user = $this->userService->createUser($request->validated());

        return response()->json([
            'message' => 'User created successfully',
            'data' => new UserResource($user)
        ], 201);
    }

    /**
     * 获取单个用户
     *
     * @param int $id
     * @return JsonResponse
     */
    public function show(int $id): JsonResponse
    {
        $user = $this->userService->getUserById($id);

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json([
            'data' => new UserResource($user)
        ]);
    }

    /**
     * 更新用户
     *
     * @param UpdateUserRequest $request
     * @param int $id
     * @return JsonResponse
     */
    public function update(UpdateUserRequest $request, int $id): JsonResponse
    {
        $updated = $this->userService->updateUser($id, $request->validated());

        if (!$updated) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json(['message' => 'User updated successfully']);
    }

    /**
     * 删除用户
     *
     * @param int $id
     * @return JsonResponse
     */
    public function destroy(int $id): JsonResponse
    {
        $deleted = $this->userService->deleteUser($id);

        if (!$deleted) {
            return response()->json(['message' => 'User not found'], 404);
        }

        return response()->json(['message' => 'User deleted successfully']);
    }
}
```

## Eloquent Model 示例

```php
<?php
/**
 * Input: Illuminate\Database\Eloquent\Model, Illuminate\Database\Eloquent\Factories\HasFactory
 * Output: User 模型类, $fillable, $hidden, relationships
 * Pos: 数据层-用户模型，映射 users 表
 *
 * 本注释在文件修改时自动更新
 */

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * 数据表名称
     *
     * @var string
     */
    protected $table = 'users';

    /**
     * 可批量赋值的属性
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'avatar',
        'bio',
    ];

    /**
     * 隐藏的属性
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * 属性转换
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * 用户的文章
     *
     * @return HasMany
     */
    public function posts(): HasMany
    {
        return $this->hasMany(Post::class);
    }

    /**
     * 用户的评论
     *
     * @return HasMany
     */
    public function comments(): HasMany
    {
        return $this->hasMany(Comment::class);
    }

    /**
     * 获取用户全名
     *
     * @return string
     */
    public function getFullNameAttribute(): string
    {
        return "{$this->first_name} {$this->last_name}";
    }
}
```

## Repository Pattern 示例

```php
<?php
/**
 * Input: App\Models\User, Illuminate\Database\Eloquent\Collection
 * Output: UserRepository 类, find(), create(), update(), delete()
 * Pos: 数据层-用户仓库，封装数据访问逻辑
 *
 * 本注释在文件修改时自动更新
 */

namespace App\Repositories;

use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class UserRepository
{
    protected User $model;

    public function __construct(User $model)
    {
        $this->model = $model;
    }

    /**
     * 获取所有用户
     *
     * @return Collection
     */
    public function all(): Collection
    {
        return $this->model->all();
    }

    /**
     * 分页获取用户
     *
     * @param int $page
     * @param int $perPage
     * @return LengthAwarePaginator
     */
    public function paginate(int $page = 1, int $perPage = 15): LengthAwarePaginator
    {
        return $this->model->paginate($perPage, ['*'], 'page', $page);
    }

    /**
     * 根据 ID 查找用户
     *
     * @param int $id
     * @return User|null
     */
    public function find(int $id): ?User
    {
        return $this->model->find($id);
    }

    /**
     * 根据条件查找用户
     *
     * @param array $conditions
     * @return Collection
     */
    public function findWhere(array $conditions): Collection
    {
        return $this->model->where($conditions)->get();
    }

    /**
     * 创建用户
     *
     * @param array $data
     * @return User
     */
    public function create(array $data): User
    {
        return $this->model->create($data);
    }

    /**
     * 更新用户
     *
     * @param int $id
     * @param array $data
     * @return bool
     */
    public function update(int $id, array $data): bool
    {
        $user = $this->find($id);
        if (!$user) {
            return false;
        }
        return $user->update($data);
    }

    /**
     * 删除用户
     *
     * @param int $id
     * @return bool
     */
    public function delete(int $id): bool
    {
        $user = $this->find($id);
        if (!$user) {
            return false;
        }
        return $user->delete();
    }

    /**
     * 根据邮箱查找用户
     *
     * @param string $email
     * @return User|null
     */
    public function findByEmail(string $email): ?User
    {
        return $this->model->where('email', $email)->first();
    }
}
```

## Middleware 示例

```php
<?php
/**
 * Input: Illuminate\Http\Request, Closure, Illuminate\Support\Facades\Auth
 * Output: AuthMiddleware 类, handle() 方法
 * Pos: 中间件层-认证中间件，验证用户身份
 *
 * 本注释在文件修改时自动更新
 */

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AuthMiddleware
{
    /**
     * 处理传入请求
     *
     * @param Request $request
     * @param Closure $next
     * @return Response
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!Auth::check()) {
            return response()->json([
                'message' => 'Unauthenticated'
            ], 401);
        }

        return $next($request);
    }
}
```

## Plain PHP (非框架) 示例

```php
<?php
/**
 * Input: PDO, Config 类, Logger 类
 * Output: Database 类, connect(), query(), execute()
 * Pos: 数据层-数据库连接管理
 *
 * 本注释在文件修改时自动更新
 */

class Database
{
    private ?PDO $connection = null;
    private Config $config;
    private Logger $logger;

    public function __construct(Config $config, Logger $logger)
    {
        $this->config = $config;
        $this->logger = $logger;
    }

    /**
     * 建立数据库连接
     *
     * @return PDO
     * @throws PDOException
     */
    public function connect(): PDO
    {
        if ($this->connection !== null) {
            return $this->connection;
        }

        try {
            $dsn = sprintf(
                'mysql:host=%s;dbname=%s;charset=utf8mb4',
                $this->config->get('db.host'),
                $this->config->get('db.database')
            );

            $this->connection = new PDO(
                $dsn,
                $this->config->get('db.username'),
                $this->config->get('db.password'),
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );

            $this->logger->info('Database connection established');

            return $this->connection;
        } catch (PDOException $e) {
            $this->logger->error('Database connection failed: ' . $e->getMessage());
            throw $e;
        }
    }

    /**
     * 执行查询
     *
     * @param string $sql
     * @param array $params
     * @return array
     */
    public function query(string $sql, array $params = []): array
    {
        $connection = $this->connect();
        $statement = $connection->prepare($sql);
        $statement->execute($params);
        return $statement->fetchAll();
    }

    /**
     * 执行插入/更新/删除
     *
     * @param string $sql
     * @param array $params
     * @return int 受影响的行数
     */
    public function execute(string $sql, array $params = []): int
    {
        $connection = $this->connect();
        $statement = $connection->prepare($sql);
        $statement->execute($params);
        return $statement->rowCount();
    }

    /**
     * 关闭连接
     */
    public function disconnect(): void
    {
        $this->connection = null;
        $this->logger->info('Database connection closed');
    }
}
```
