import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { OAuth2Client } from 'google-auth-library';
import * as appleSignin from 'apple-signin-auth';
import { UsersService } from '../users/users.service';
import { GoogleLoginDto } from './dto/google-login.dto';
import { AppleLoginDto } from './dto/apple-login.dto';
import { JwtPayload } from './strategies/jwt.strategy';
import { User } from '../users/entities/user.entity';

@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;

  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {
    this.googleClient = new OAuth2Client(
      configService.get<string>('GOOGLE_CLIENT_ID'),
    );
  }

  async googleLogin(dto: GoogleLoginDto) {
    const { idToken } = dto;

    let payload: any;
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken,
        audience: this.configService.get<string>('GOOGLE_CLIENT_ID'),
      });
      payload = ticket.getPayload();
    } catch {
      throw new UnauthorizedException('Invalid Google ID token');
    }

    const { sub: providerId, email, name, picture } = payload;

    const user = await this.usersService.findOrCreate({
      provider: 'google',
      providerId,
      email,
      name,
      profileImage: picture,
    });

    return this.issueTokens(user);
  }

  async appleLogin(dto: AppleLoginDto) {
    const { identityToken, fullName } = dto;

    let payload: any;
    try {
      payload = await appleSignin.verifyIdToken(identityToken, {
        audience: this.configService.get<string>('APPLE_CLIENT_ID'),
        ignoreExpiration: false,
      });
    } catch {
      throw new UnauthorizedException('Invalid Apple identity token');
    }

    const { sub: providerId, email } = payload;

    const name =
      fullName?.firstName || fullName?.lastName
        ? `${fullName?.firstName ?? ''} ${fullName?.lastName ?? ''}`.trim()
        : undefined;

    const user = await this.usersService.findOrCreate({
      provider: 'apple',
      providerId,
      email,
      name,
    });

    return this.issueTokens(user);
  }

  async refresh(refreshToken: string) {
    let payload: JwtPayload;
    try {
      payload = this.jwtService.verify<JwtPayload>(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });
    } catch {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    if (payload.type !== 'refresh') {
      throw new BadRequestException('Not a refresh token');
    }

    const user = await this.usersService.findById(payload.sub);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.issueTokens(user);
  }

  private issueTokens(user: User) {
    const basePayload = { sub: user.id, provider: user.provider };

    const accessToken = this.jwtService.sign(
      { ...basePayload, type: 'access' },
      {
        secret: this.configService.get<string>('JWT_ACCESS_SECRET'),
        expiresIn: this.configService.get<string>('JWT_ACCESS_EXPIRES_IN'),
      },
    );

    const refreshToken = this.jwtService.sign(
      { ...basePayload, type: 'refresh' },
      {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRES_IN'),
      },
    );

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        provider: user.provider,
        email: user.email,
        name: user.name,
        profileImage: user.profileImage,
      },
    };
  }
}
