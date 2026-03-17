import {
  Body,
  Controller,
  DefaultValuePipe,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseIntPipe,
  Post,
  Query,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { v4 as uuidv4 } from 'uuid';
import { FeedService } from './feed.service';
import { CreateFeedDto } from './dto/create-feed.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { User } from '../users/entities/user.entity';
import { ConfigService } from '@nestjs/config';

const imageStorage = diskStorage({
  destination: (req, file, cb) => {
    const configService: ConfigService = req['configService'];
    const uploadDir = process.env.UPLOAD_DIR ?? './uploads';
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const uniqueName = `${uuidv4()}${extname(file.originalname)}`;
    cb(null, uniqueName);
  },
});

const imageFilter = (req: any, file: Express.Multer.File, cb: any) => {
  if (!file.mimetype.match(/\/(jpg|jpeg|png|gif|webp|heic)$/)) {
    return cb(new Error('Only image files are allowed'), false);
  }
  cb(null, true);
};

@Controller('feed')
@UseGuards(JwtAuthGuard)
export class FeedController {
  constructor(private readonly feedService: FeedService) {}

  /**
   * GET /feed?page=1&limit=20
   * 피드 목록 조회 (최신순, 페이지네이션)
   */
  @Get()
  getFeeds(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
    @CurrentUser() user: User,
  ) {
    const safeLimit = Math.min(limit, 50);
    return this.feedService.getFeeds(page, safeLimit, user.id);
  }

  /**
   * GET /feed/:id
   * 특정 피드 상세 조회
   */
  @Get(':id')
  getFeed(@Param('id') id: string, @CurrentUser() user: User) {
    return this.feedService.getFeedById(id, user.id);
  }

  /**
   * POST /feed
   * 피드 생성 (multipart/form-data)
   * - content: 텍스트 (선택)
   * - images: 이미지 파일 (최대 10장)
   */
  @Post()
  @UseInterceptors(
    FilesInterceptor('images', 10, {
      storage: diskStorage({
        destination: join(process.cwd(), process.env.UPLOAD_DIR ?? 'uploads'),
        filename: (req, file, cb) => {
          const uniqueName = `${uuidv4()}${extname(file.originalname)}`;
          cb(null, uniqueName);
        },
      }),
      fileFilter: imageFilter,
      limits: {
        fileSize: parseInt(process.env.MAX_FILE_SIZE ?? '10485760', 10),
      },
    }),
  )
  createFeed(
    @CurrentUser() user: User,
    @Body() dto: CreateFeedDto,
    @UploadedFiles() files: Express.Multer.File[],
  ) {
    return this.feedService.createFeed(user, dto, files ?? []);
  }

  /**
   * DELETE /feed/:id
   * 피드 삭제 (본인 피드만 가능)
   */
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  deleteFeed(@Param('id') id: string, @CurrentUser() user: User) {
    return this.feedService.deleteFeed(id, user.id);
  }
}
