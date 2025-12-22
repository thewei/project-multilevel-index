# Swift 文件头模板

## 使用 Swift Doc Comments

```swift
/**
 Input: {导入模块，如: Foundation, UIKit, Combine, Alamofire}
 Output: {类/结构/协议，如: UserService 类, fetchUser() 方法, User 模型}
 Pos: {定位，如: 业务层-用户服务, UI层-用户视图控制器, 数据层-用户模型}

 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新
 */

import Foundation
import Combine

/// 用户服务，处理用户相关业务逻辑
class UserService {
    private let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    /// 获取用户列表
    /// - Returns: Publisher that emits users array
    func fetchUsers() -> AnyPublisher<[User], Error> {
        apiClient.request(endpoint: .users)
            .decode(type: [User].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    /// 根据 ID 获取用户
    /// - Parameter id: 用户 ID
    /// - Returns: Publisher that emits a user
    func fetchUser(id: Int) -> AnyPublisher<User, Error> {
        apiClient.request(endpoint: .user(id: id))
            .decode(type: User.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    /// 创建新用户
    /// - Parameter user: 用户数据
    /// - Returns: Publisher that emits created user
    func createUser(_ user: CreateUserRequest) -> AnyPublisher<User, Error> {
        apiClient.request(endpoint: .createUser(user))
            .decode(type: User.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
```

## SwiftUI View 示例

```swift
/**
 Input: SwiftUI, Combine, UserViewModel
 Output: UserListView 结构体, View protocol
 Pos: UI层-用户列表视图，展示用户列表

 本注释在文件修改时自动更新
 */

import SwiftUI

struct UserListView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var showingAddUser = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.users) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        UserRow(user: user)
                    }
                }
                .onDelete(perform: deleteUsers)
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(viewModel: viewModel)
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .task {
            await viewModel.loadUsers()
        }
    }

    private func deleteUsers(at offsets: IndexSet) {
        Task {
            await viewModel.deleteUsers(at: offsets)
        }
    }
}

struct UserRow: View {
    let user: User

    var body: some View {
        HStack {
            AsyncImage(url: user.avatarURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
```

## ViewModel 示例 (MVVM)

```swift
/**
 Input: Foundation, Combine, UserService, User 模型
 Output: UserViewModel 类, @Published properties, async methods
 Pos: 业务层-用户视图模型，管理用户数据和业务逻辑

 本注释在文件修改时自动更新
 */

import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserService = UserService()) {
        self.userService = userService
    }

    /// 加载用户列表
    func loadUsers() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedUsers = try await userService.fetchUsers()
                .async()
            users = fetchedUsers
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// 刷新用户列表
    func refresh() async {
        await loadUsers()
    }

    /// 创建新用户
    /// - Parameter request: 创建用户请求
    func createUser(_ request: CreateUserRequest) async throws {
        let newUser = try await userService.createUser(request).async()
        users.append(newUser)
    }

    /// 删除用户
    /// - Parameter offsets: 索引集合
    func deleteUsers(at offsets: IndexSet) async {
        let usersToDelete = offsets.map { users[$0] }

        for user in usersToDelete {
            do {
                try await userService.deleteUser(id: user.id).async()
                users.removeAll { $0.id == user.id }
            } catch {
                errorMessage = "Failed to delete user: \(error.localizedDescription)"
            }
        }
    }
}

// Combine to async/await helper
extension Publisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = first()
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { value in
                    continuation.resume(returning: value)
                }
        }
    }
}
```

## Model 示例 (Codable)

```swift
/**
 Input: Foundation, Codable 协议
 Output: User 结构体, Codable, Identifiable
 Pos: 数据层-用户模型，定义用户数据结构

 本注释在文件修改时自动更新
 */

import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let email: String
    let avatarURL: URL?
    let bio: String?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarURL = "avatar_url"
        case bio
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// 用户全名（计算属性）
    var displayName: String {
        name.isEmpty ? email : name
    }

    /// 用户是否为新用户（24小时内创建）
    var isNewUser: Bool {
        let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        return createdAt > oneDayAgo
    }
}

struct CreateUserRequest: Codable {
    let name: String
    let email: String
    let password: String
    let bio: String?

    init(name: String, email: String, password: String, bio: String? = nil) {
        self.name = name
        self.email = email
        self.password = password
        self.bio = bio
    }
}

struct UpdateUserRequest: Codable {
    let name: String?
    let email: String?
    let bio: String?
}
```

## Repository Pattern 示例

```swift
/**
 Input: Foundation, Combine, CoreData, User 模型
 Output: UserRepository 协议, LocalUserRepository 实现, RemoteUserRepository 实现
 Pos: 数据层-用户仓库，抽象数据访问

 本注释在文件修改时自动更新
 */

import Foundation
import Combine

/// 用户仓库协议
protocol UserRepository {
    func fetchUsers() -> AnyPublisher<[User], Error>
    func fetchUser(id: Int) -> AnyPublisher<User, Error>
    func createUser(_ user: CreateUserRequest) -> AnyPublisher<User, Error>
    func updateUser(id: Int, request: UpdateUserRequest) -> AnyPublisher<User, Error>
    func deleteUser(id: Int) -> AnyPublisher<Void, Error>
}

/// 远程用户仓库（API）
class RemoteUserRepository: UserRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchUsers() -> AnyPublisher<[User], Error> {
        apiClient.request(endpoint: .users)
            .decode(type: [User].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func fetchUser(id: Int) -> AnyPublisher<User, Error> {
        apiClient.request(endpoint: .user(id: id))
            .decode(type: User.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func createUser(_ user: CreateUserRequest) -> AnyPublisher<User, Error> {
        apiClient.request(endpoint: .createUser(user))
            .decode(type: User.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func updateUser(id: Int, request: UpdateUserRequest) -> AnyPublisher<User, Error> {
        apiClient.request(endpoint: .updateUser(id: id, request: request))
            .decode(type: User.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    func deleteUser(id: Int) -> AnyPublisher<Void, Error> {
        apiClient.request(endpoint: .deleteUser(id: id))
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}

/// 本地用户仓库（Core Data）
class LocalUserRepository: UserRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func fetchUsers() -> AnyPublisher<[User], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "Repository", code: -1)))
                return
            }

            let request = UserEntity.fetchRequest()

            do {
                let entities = try self.context.fetch(request)
                let users = entities.compactMap { $0.toModel() }
                promise(.success(users))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    // 其他方法实现...
}
```

## Coordinator Pattern 示例

```swift
/**
 Input: UIKit, UserService
 Output: UserCoordinator 类, Coordinator 协议
 Pos: UI层-用户协调器，管理用户模块的导航流程

 本注释在文件修改时自动更新
 */

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }

    func start()
}

class UserCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let userService: UserService

    init(navigationController: UINavigationController,
         userService: UserService = UserService()) {
        self.navigationController = navigationController
        self.userService = userService
    }

    func start() {
        showUserList()
    }

    func showUserList() {
        let viewModel = UserListViewModel(
            userService: userService,
            coordinator: self
        )
        let viewController = UserListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func showUserDetail(user: User) {
        let viewModel = UserDetailViewModel(
            user: user,
            userService: userService,
            coordinator: self
        )
        let viewController = UserDetailViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }

    func showEditUser(user: User) {
        let viewModel = EditUserViewModel(
            user: user,
            userService: userService,
            coordinator: self
        )
        let viewController = EditUserViewController(viewModel: viewModel)
        let navController = UINavigationController(rootViewController: viewController)
        navigationController.present(navController, animated: true)
    }
}
```

## Unit Test 示例 (XCTest)

```swift
/**
 Input: XCTest, @testable import MyApp, UserService
 Output: UserServiceTests 类, test methods
 Pos: 测试层-用户服务测试，验证业务逻辑

 本注释在文件修改时自动更新
 */

import XCTest
import Combine
@testable import MyApp

final class UserServiceTests: XCTestCase {
    var sut: UserService!
    var mockAPIClient: MockAPIClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        sut = UserService(apiClient: mockAPIClient)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockAPIClient = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchUsers_Success() {
        // Given
        let expectedUsers = [
            User(id: 1, name: "John", email: "john@example.com"),
            User(id: 2, name: "Jane", email: "jane@example.com")
        ]
        mockAPIClient.mockResponse = expectedUsers

        let expectation = XCTestExpectation(description: "Fetch users")
        var receivedUsers: [User]?

        // When
        sut.fetchUsers()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success, got error: \(error)")
                    }
                },
                receiveValue: { users in
                    receivedUsers = users
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedUsers?.count, 2)
        XCTAssertEqual(receivedUsers?.first?.name, "John")
    }

    func testCreateUser_Success() async throws {
        // Given
        let request = CreateUserRequest(
            name: "New User",
            email: "new@example.com",
            password: "password123"
        )
        let expectedUser = User(id: 3, name: "New User", email: "new@example.com")
        mockAPIClient.mockResponse = expectedUser

        // When
        let createdUser = try await sut.createUser(request).async()

        // Then
        XCTAssertEqual(createdUser.id, 3)
        XCTAssertEqual(createdUser.name, "New User")
    }
}
```
