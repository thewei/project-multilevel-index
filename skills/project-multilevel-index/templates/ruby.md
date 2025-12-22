# Ruby 文件头模板

## 使用 YARD 注释风格

```ruby
##
# Input: {依赖模块/gem，如: active_record, bcrypt, ./models/user}
# Output: {类/模块，如: UserService 类, create_user 方法, update_user 方法}
# Pos: {定位，如: 业务层-用户服务, API层-用户控制器, 数据层-用户模型}
#
# 本注释在文件修改时自动更新，同时触发 FOLDER_INDEX 和 PROJECT_INDEX 更新

require 'bcrypt'
require_relative 'models/user'

class UserService
  # 创建新用户
  #
  # @param [Hash] attributes 用户属性
  # @return [User] 创建的用户对象
  def create_user(attributes)
    attributes[:password] = BCrypt::Password.create(attributes[:password])
    User.create(attributes)
  end

  # 根据 ID 获取用户
  #
  # @param [Integer] id 用户 ID
  # @return [User, nil] 用户对象或 nil
  def find_user(id)
    User.find_by(id: id)
  end

  # 更新用户
  #
  # @param [Integer] id 用户 ID
  # @param [Hash] attributes 更新的属性
  # @return [Boolean] 是否成功
  def update_user(id, attributes)
    user = find_user(id)
    return false unless user

    user.update(attributes)
  end
end
```

## Rails Controller 示例

```ruby
##
# Input: ApplicationController, UserService, User 模型, Pundit
# Output: UsersController 类, index, create, show, update, destroy
# Pos: API层-用户控制器，处理用户相关 HTTP 请求
#
# 本注释在文件修改时自动更新

class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authorize_user, only: [:update, :destroy]

  # GET /users
  def index
    @users = User.page(params[:page]).per(params[:per_page] || 15)
    render json: @users, each_serializer: UserSerializer
  end

  # GET /users/:id
  def show
    render json: @user, serializer: UserSerializer
  end

  # POST /users
  def create
    @user = UserService.new.create_user(user_params)

    if @user.persisted?
      render json: @user, serializer: UserSerializer, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:id
  def update
    if @user.update(user_params)
      render json: @user, serializer: UserSerializer
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :avatar, :bio)
  end

  def authorize_user
    authorize @user
  end
end
```

## Active Record Model 示例

```ruby
##
# Input: ActiveRecord::Base, BCrypt, Paperclip (图片上传)
# Output: User 模型类, associations, validations, callbacks
# Pos: 数据层-用户模型，映射 users 表
#
# 本注释在文件修改时自动更新

class User < ApplicationRecord
  has_secure_password

  # 关联
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # 验证
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: :password_required?

  # 回调
  before_save :downcase_email
  after_create :send_welcome_email

  # Scopes
  scope :active, -> { where(active: true) }
  scope :recent, -> { order(created_at: :desc) }

  # 实例方法
  def full_name
    "#{first_name} #{last_name}"
  end

  def admin?
    role == 'admin'
  end

  def activate!
    update(active: true, activated_at: Time.current)
  end

  # 类方法
  def self.search(query)
    where('name LIKE ? OR email LIKE ?', "%#{query}%", "%#{query}%")
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later
  end

  def password_required?
    new_record? || password.present?
  end
end
```

## Service Object 示例

```ruby
##
# Input: User 模型, EmailService, Logger
# Output: UserRegistrationService 类, call 方法
# Pos: 业务层-用户注册服务，封装注册业务逻辑
#
# 本注释在文件修改时自动更新

class UserRegistrationService
  attr_reader :user, :errors

  def initialize(params)
    @params = params
    @errors = []
  end

  # 执行注册
  #
  # @return [Boolean] 是否成功
  def call
    ActiveRecord::Base.transaction do
      create_user
      send_verification_email
      log_registration
    end

    errors.empty?
  rescue StandardError => e
    @errors << e.message
    Rails.logger.error("User registration failed: #{e.message}")
    false
  end

  private

  def create_user
    @user = User.new(@params)
    unless @user.save
      @errors.concat(@user.errors.full_messages)
      raise ActiveRecord::Rollback
    end
  end

  def send_verification_email
    EmailService.new.send_verification(@user)
  rescue StandardError => e
    @errors << "Failed to send email: #{e.message}"
    raise ActiveRecord::Rollback
  end

  def log_registration
    Rails.logger.info("New user registered: #{@user.email}")
  end
end
```

## Interactor Pattern 示例

```ruby
##
# Input: Interactor gem, User 模型, AuthToken 模型
# Output: AuthenticateUser interactor, call 方法, context
# Pos: 业务层-用户认证交互器，处理登录逻辑
#
# 本注释在文件修改时自动更新

class AuthenticateUser
  include Interactor

  # 执行认证
  def call
    find_user
    verify_password
    generate_token
  end

  private

  def find_user
    context.user = User.find_by(email: context.email)

    unless context.user
      context.fail!(error: 'Invalid email or password')
    end
  end

  def verify_password
    unless context.user.authenticate(context.password)
      context.fail!(error: 'Invalid email or password')
    end
  end

  def generate_token
    context.token = AuthToken.create(user: context.user)
  end
end

# 使用示例:
# result = AuthenticateUser.call(email: 'user@example.com', password: 'password123')
# if result.success?
#   puts result.token
# else
#   puts result.error
# end
```

## Grape API 示例

```ruby
##
# Input: Grape::API, User 模型, UserService, Entities::User
# Output: Users API 类, endpoints (GET, POST, PUT, DELETE)
# Pos: API层-用户 API，Grape 风格的 RESTful 接口
#
# 本注释在文件修改时自动更新

module API
  module V1
    class Users < Grape::API
      version 'v1', using: :path
      format :json
      prefix :api

      helpers do
        def current_user
          @current_user ||= User.find_by(id: headers['X-User-Id'])
        end

        def authenticate!
          error!('Unauthorized', 401) unless current_user
        end
      end

      resource :users do
        # GET /api/v1/users
        desc 'Get all users'
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 15
        end
        get do
          users = User.page(params[:page]).per(params[:per_page])
          present users, with: Entities::User
        end

        # GET /api/v1/users/:id
        desc 'Get a user by ID'
        params do
          requires :id, type: Integer, desc: 'User ID'
        end
        get ':id' do
          user = User.find(params[:id])
          present user, with: Entities::User
        end

        # POST /api/v1/users
        desc 'Create a new user'
        params do
          requires :name, type: String, desc: 'User name'
          requires :email, type: String, desc: 'User email'
          requires :password, type: String, desc: 'User password'
        end
        post do
          user = UserService.new.create_user(declared(params))
          if user.persisted?
            present user, with: Entities::User
          else
            error!(user.errors.full_messages, 422)
          end
        end

        # PUT /api/v1/users/:id
        desc 'Update a user'
        params do
          requires :id, type: Integer, desc: 'User ID'
          optional :name, type: String
          optional :email, type: String
        end
        put ':id' do
          authenticate!
          user = User.find(params[:id])
          if user.update(declared(params, include_missing: false))
            present user, with: Entities::User
          else
            error!(user.errors.full_messages, 422)
          end
        end

        # DELETE /api/v1/users/:id
        desc 'Delete a user'
        params do
          requires :id, type: Integer, desc: 'User ID'
        end
        delete ':id' do
          authenticate!
          user = User.find(params[:id])
          user.destroy
          status 204
        end
      end
    end
  end
end
```

## RSpec 测试示例

```ruby
##
# Input: RSpec, FactoryBot, User 模型, UserService
# Output: UserService spec, describe/context/it 块
# Pos: 测试层-用户服务测试，验证业务逻辑
#
# 本注释在文件修改时自动更新

require 'rails_helper'

RSpec.describe UserService, type: :service do
  let(:service) { described_class.new }
  let(:valid_attributes) do
    {
      name: 'John Doe',
      email: 'john@example.com',
      password: 'password123'
    }
  end

  describe '#create_user' do
    context 'with valid attributes' do
      it 'creates a new user' do
        expect {
          service.create_user(valid_attributes)
        }.to change(User, :count).by(1)
      end

      it 'hashes the password' do
        user = service.create_user(valid_attributes)
        expect(user.password_digest).not_to eq('password123')
      end

      it 'returns the created user' do
        user = service.create_user(valid_attributes)
        expect(user).to be_a(User)
        expect(user).to be_persisted
      end
    end

    context 'with invalid attributes' do
      it 'returns false when email is missing' do
        result = service.create_user(valid_attributes.except(:email))
        expect(result).to be_falsey
      end
    end
  end

  describe '#find_user' do
    let!(:user) { create(:user) }

    it 'finds user by id' do
      found_user = service.find_user(user.id)
      expect(found_user).to eq(user)
    end

    it 'returns nil when user not found' do
      found_user = service.find_user(99999)
      expect(found_user).to be_nil
    end
  end
end
```
