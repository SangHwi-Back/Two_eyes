import {
  Controller,
  Delete,
  HttpCode,
  HttpStatus,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { LikesService } from './likes.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';

@Controller('feed/:feedId/like')
@UseGuards(JwtAuthGuard)
export class LikesController {
  constructor(private readonly likesService: LikesService) {}

  /**
   * POST /feed/:feedId/like
   * 피드 좋아요
   */
  @Post()
  @HttpCode(HttpStatus.OK)
  like(@Param('feedId') feedId: string, @CurrentUser() user: User) {
    return this.likesService.like(feedId, user);
  }

  /**
   * DELETE /feed/:feedId/like
   * 피드 좋아요 취소
   */
  @Delete()
  @HttpCode(HttpStatus.OK)
  unlike(@Param('feedId') feedId: string, @CurrentUser() user: User) {
    return this.likesService.unlike(feedId, user);
  }
}
