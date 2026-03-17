import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { GoogleLoginDto } from './dto/google-login.dto';
import { AppleLoginDto } from './dto/apple-login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * POST /auth/google
   * Body: { idToken: string }
   * 구글 로그인 - 클라이언트에서 받은 ID 토큰으로 인증
   */
  @Post('google')
  googleLogin(@Body() dto: GoogleLoginDto) {
    return this.authService.googleLogin(dto);
  }

  /**
   * POST /auth/apple
   * Body: { identityToken: string, authorizationCode?: string, fullName?: { firstName, lastName } }
   * 애플 로그인 - 클라이언트에서 받은 identity 토큰으로 인증
   */
  @Post('apple')
  appleLogin(@Body() dto: AppleLoginDto) {
    return this.authService.appleLogin(dto);
  }

  /**
   * POST /auth/refresh
   * Body: { refreshToken: string }
   * 액세스 토큰 갱신
   */
  @Post('refresh')
  refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refresh(dto.refreshToken);
  }

  /**
   * POST /auth/logout
   * Authorization: Bearer <accessToken>
   * 로그아웃 (클라이언트에서 토큰 삭제)
   */
  @UseGuards(JwtAuthGuard)
  @Post('logout')
  logout(@CurrentUser() user: User) {
    return { message: 'Logged out successfully', userId: user.id };
  }
}
