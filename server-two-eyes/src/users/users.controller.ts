import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from './entities/user.entity';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  /**
   * GET /users/me
   * 현재 로그인된 사용자 정보 반환
   */
  @Get('me')
  getMe(@CurrentUser() user: User) {
    return {
      id: user.id,
      provider: user.provider,
      email: user.email,
      name: user.name,
      profileImage: user.profileImage,
      createdAt: user.createdAt,
    };
  }
}
