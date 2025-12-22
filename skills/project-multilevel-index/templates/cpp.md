# C/C++ 文件头模板

## 头文件 (.h / .hpp) 使用 Doxygen

```cpp
/**
 * @file User.h
 * @brief 用户模型定义
 *
 * Input: {依赖头文件，如: <string>, <vector>, "Database.h"}
 * Output: {类/函数声明，如: class User, getUserById()}
 * Pos: {定位，如: 数据层-用户模型, 业务层-用户服务, 工具层-日志管理}
 *
 * 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
 */

#ifndef USER_H
#define USER_H

#include <string>
#include <vector>
#include <memory>
#include "Database.h"

namespace myapp {
namespace models {

/**
 * @class User
 * @brief 用户实体类
 */
class User {
public:
    User();
    User(int id, const std::string& username, const std::string& email);
    ~User();

    // Getters
    int getId() const;
    std::string getUsername() const;
    std::string getEmail() const;

    // Setters
    void setUsername(const std::string& username);
    void setEmail(const std::string& email);

    // 业务方法
    bool validate() const;
    std::string toJson() const;

private:
    int id_;
    std::string username_;
    std::string email_;
    std::string password_hash_;
};

} // namespace models
} // namespace myapp

#endif // USER_H
```

## 实现文件 (.cpp)

```cpp
/**
 * @file User.cpp
 * @brief 用户模型实现
 *
 * Input: "User.h", <sstream>, <regex>
 * Output: User 类方法实现
 * Pos: 数据层-用户模型实现
 *
 * 本注释在文件修改时自动更新
 */

#include "User.h"
#include <sstream>
#include <regex>

namespace myapp {
namespace models {

User::User() : id_(0), username_(""), email_(""), password_hash_("") {}

User::User(int id, const std::string& username, const std::string& email)
    : id_(id), username_(username), email_(email), password_hash_("") {}

User::~User() {}

int User::getId() const {
    return id_;
}

std::string User::getUsername() const {
    return username_;
}

std::string User::getEmail() const {
    return email_;
}

void User::setUsername(const std::string& username) {
    username_ = username;
}

void User::setEmail(const std::string& email) {
    email_ = email;
}

bool User::validate() const {
    if (username_.empty() || email_.empty()) {
        return false;
    }

    // 验证邮箱格式
    std::regex email_pattern(R"((\w+)(\.|_)?(\w*)@(\w+)(\.(\w+))+)");
    return std::regex_match(email_, email_pattern);
}

std::string User::toJson() const {
    std::ostringstream oss;
    oss << "{"
        << "\"id\":" << id_ << ","
        << "\"username\":\"" << username_ << "\","
        << "\"email\":\"" << email_ << "\""
        << "}";
    return oss.str();
}

} // namespace models
} // namespace myapp
```

## Service 类示例

```cpp
/**
 * @file UserService.h
 * @brief 用户业务逻辑服务
 *
 * Input: "User.h", "UserRepository.h", <memory>, <vector>
 * Output: class UserService, getUserById(), createUser()
 * Pos: 业务层-用户服务，封装用户管理业务逻辑
 *
 * 本注释在文件修改时自动更新
 */

#ifndef USER_SERVICE_H
#define USER_SERVICE_H

#include <memory>
#include <vector>
#include <optional>
#include "User.h"
#include "UserRepository.h"

namespace myapp {
namespace service {

/**
 * @class UserService
 * @brief 用户服务类，提供用户管理业务逻辑
 */
class UserService {
public:
    explicit UserService(std::shared_ptr<repository::UserRepository> repo);
    ~UserService();

    /**
     * @brief 根据 ID 获取用户
     * @param id 用户 ID
     * @return 用户对象（如果存在）
     */
    std::optional<models::User> getUserById(int id);

    /**
     * @brief 获取所有用户
     * @return 用户列表
     */
    std::vector<models::User> getAllUsers();

    /**
     * @brief 创建新用户
     * @param username 用户名
     * @param email 邮箱
     * @param password 密码
     * @return 创建的用户对象
     */
    models::User createUser(const std::string& username,
                           const std::string& email,
                           const std::string& password);

    /**
     * @brief 验证用户登录
     * @param username 用户名
     * @param password 密码
     * @return 用户对象（如果验证成功）
     */
    std::optional<models::User> authenticate(const std::string& username,
                                             const std::string& password);

private:
    std::shared_ptr<repository::UserRepository> repository_;

    std::string hashPassword(const std::string& password);
    bool verifyPassword(const std::string& password, const std::string& hash);
};

} // namespace service
} // namespace myapp

#endif // USER_SERVICE_H
```

## Modern C++ (C++17/20) 示例

```cpp
/**
 * @file RestController.h
 * @brief RESTful API 控制器基类
 *
 * Input: <string>, <functional>, <map>, "HttpRequest.h", "HttpResponse.h"
 * Output: class RestController, template<typename T> Response
 * Pos: API层-REST控制器基类，提供 HTTP 处理框架
 *
 * 本注释在文件修改时自动更新
 */

#ifndef REST_CONTROLLER_H
#define REST_CONTROLLER_H

#include <string>
#include <functional>
#include <map>
#include <memory>
#include <string_view>
#include "HttpRequest.h"
#include "HttpResponse.h"

namespace myapp {
namespace api {

/**
 * @brief HTTP 响应包装器
 */
template<typename T>
struct Response {
    int statusCode;
    T data;
    std::string message;

    static Response<T> ok(const T& data) {
        return {200, data, "OK"};
    }

    static Response<T> created(const T& data) {
        return {201, data, "Created"};
    }

    static Response<T> notFound(const std::string& msg = "Not Found") {
        return {404, T{}, msg};
    }

    static Response<T> badRequest(const std::string& msg = "Bad Request") {
        return {400, T{}, msg};
    }
};

/**
 * @class RestController
 * @brief REST API 控制器基类
 */
class RestController {
public:
    using Handler = std::function<HttpResponse(const HttpRequest&)>;

    RestController() = default;
    virtual ~RestController() = default;

    // 禁止拷贝
    RestController(const RestController&) = delete;
    RestController& operator=(const RestController&) = delete;

    // 允许移动
    RestController(RestController&&) = default;
    RestController& operator=(RestController&&) = default;

    /**
     * @brief 注册路由
     */
    void registerRoute(std::string_view method,
                      std::string_view path,
                      Handler handler);

    /**
     * @brief 处理请求
     */
    HttpResponse handleRequest(const HttpRequest& request);

protected:
    // 辅助方法
    template<typename T>
    HttpResponse jsonResponse(const Response<T>& response);

    HttpResponse parseJsonBody(const HttpRequest& request);

private:
    std::map<std::string, Handler> routes_;
};

} // namespace api
} // namespace myapp

#endif // REST_CONTROLLER_H
```

## Qt 框架示例

```cpp
/**
 * @file UserModel.h
 * @brief Qt 用户模型（Model-View 架构）
 *
 * Input: <QObject>, <QString>, <QDateTime>, "DatabaseManager.h"
 * Output: class UserModel : public QObject, signals, slots
 * Pos: 数据层-Qt 用户模型，支持信号槽机制
 *
 * 本注释在文件修改时自动更新
 */

#ifndef USERMODEL_H
#define USERMODEL_H

#include <QObject>
#include <QString>
#include <QDateTime>
#include <QList>
#include <memory>
#include "DatabaseManager.h"

class UserModel : public QObject {
    Q_OBJECT
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString email READ email WRITE setEmail NOTIFY emailChanged)

public:
    explicit UserModel(QObject *parent = nullptr);
    ~UserModel();

    // Getters
    int id() const;
    QString username() const;
    QString email() const;
    QDateTime createdAt() const;

    // Setters
    void setId(int id);
    void setUsername(const QString &username);
    void setEmail(const QString &email);

public slots:
    /**
     * @brief 保存用户到数据库
     */
    bool save();

    /**
     * @brief 从数据库加载用户
     */
    bool load(int id);

    /**
     * @brief 删除用户
     */
    bool remove();

    /**
     * @brief 验证用户数据
     */
    bool validate() const;

signals:
    void idChanged(int id);
    void usernameChanged(const QString &username);
    void emailChanged(const QString &email);
    void userSaved();
    void userLoaded();
    void errorOccurred(const QString &error);

private:
    int m_id;
    QString m_username;
    QString m_email;
    QString m_passwordHash;
    QDateTime m_createdAt;
    QDateTime m_updatedAt;

    std::shared_ptr<DatabaseManager> m_db;
};

#endif // USERMODEL_H
```

## CMakeLists.txt 注释示例

```cmake
# Input: C++17, Qt5::Core, Qt5::Sql, pthread
# Output: myapp 可执行文件, libuser.so 共享库
# Pos: 构建配置-主 CMakeLists，定义项目构建规则
#
# 本注释在文件修改时自动更新

cmake_minimum_required(VERSION 3.15)
project(MyApp VERSION 1.0.0 LANGUAGES CXX)

# C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找依赖
find_package(Qt5 REQUIRED COMPONENTS Core Sql Network)
find_package(Threads REQUIRED)

# 包含目录
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/src
)

# 源文件
set(SOURCES
    src/main.cpp
    src/models/User.cpp
    src/services/UserService.cpp
    src/repositories/UserRepository.cpp
)

# 头文件
set(HEADERS
    include/User.h
    include/UserService.h
    include/UserRepository.h
)

# 创建可执行文件
add_executable(myapp ${SOURCES} ${HEADERS})

# 链接库
target_link_libraries(myapp
    Qt5::Core
    Qt5::Sql
    Qt5::Network
    Threads::Threads
)

# 安装规则
install(TARGETS myapp DESTINATION bin)
```
