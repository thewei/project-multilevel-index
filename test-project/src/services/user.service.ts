import { User, CreateUserDTO } from '../models/User';
import { Logger } from '../utils/logger';

export class UserService {
  private users: User[] = [];

  async createUser(dto: CreateUserDTO): Promise<User> {
    Logger.info(`Creating user: ${dto.name}`);

    const user: User = {
      id: Math.random().toString(36),
      name: dto.name,
      email: dto.email,
      createdAt: new Date()
    };

    this.users.push(user);
    return user;
  }

  async findById(id: string): Promise<User | null> {
    return this.users.find(u => u.id === id) || null;
  }

  async findAll(): Promise<User[]> {
    return this.users;
  }
}
