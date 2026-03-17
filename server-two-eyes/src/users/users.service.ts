import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, AuthProvider } from './entities/user.entity';

interface FindOrCreateDto {
  provider: AuthProvider;
  providerId: string;
  email?: string;
  name?: string;
  profileImage?: string;
}

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async findOrCreate(dto: FindOrCreateDto): Promise<User> {
    const { provider, providerId, email, name, profileImage } = dto;

    let user = await this.userRepository.findOne({
      where: { provider, providerId },
    });

    if (user) {
      // 이메일, 이름, 프로필 이미지 최신화
      let changed = false;
      if (email && user.email !== email) { user.email = email; changed = true; }
      if (name && !user.name) { user.name = name; changed = true; }
      if (profileImage && user.profileImage !== profileImage) { user.profileImage = profileImage; changed = true; }
      if (changed) await this.userRepository.save(user);
      return user;
    }

    user = this.userRepository.create({ provider, providerId, email, name, profileImage });
    return this.userRepository.save(user);
  }
}
