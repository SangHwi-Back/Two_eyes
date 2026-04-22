import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Feed } from './entities/feed.entity';
import { FeedMedia } from './entities/feed-media.entity';
import { Like } from '../likes/entities/like.entity';
import { User } from '../users/entities/user.entity';
import { CreateFeedDto } from './dto/create-feed.dto';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class FeedService {
  constructor(
    @InjectRepository(Feed)
    private readonly feedRepository: Repository<Feed>,
    @InjectRepository(FeedMedia)
    private readonly feedMediaRepository: Repository<FeedMedia>,
    @InjectRepository(Like)
    private readonly likeRepository: Repository<Like>,
    private readonly configService: ConfigService,
  ) {}

  async getFeeds(page: number, limit: number, currentUserId?: string) {
    const skip = (page - 1) * limit;

    const [feeds, total] = await this.feedRepository.findAndCount({
      relations: ['user', 'medias'],
      order: { createdAt: 'DESC' },
      skip,
      take: limit,
    });

    const feedIds = feeds.map((f) => f.id);
    const likeCounts = await this.getLikeCounts(feedIds);
    const likedByMe = currentUserId
      ? await this.getLikedByUser(feedIds, currentUserId)
      : new Set<string>();

    return {
      data: feeds.map((feed) =>
        this.formatFeed(feed, likeCounts[feed.id] ?? 0, likedByMe.has(feed.id)),
      ),
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getFeedById(id: string, currentUserId?: string) {
    const feed = await this.feedRepository.findOne({
      where: { id },
      relations: ['user', 'medias'],
    });

    if (!feed) {
      throw new NotFoundException('Feed not found');
    }

    const likeCount = await this.likeRepository.count({ where: { feed: { id } } });
    const isLiked = currentUserId
      ? !!(await this.likeRepository.findOne({
          where: { feed: { id }, user: { id: currentUserId } },
        }))
      : false;

    return this.formatFeed(feed, likeCount, isLiked);
  }

  async createFeed(
    user: User,
    dto: CreateFeedDto,
    files: Express.Multer.File[],
  ) {
    const feed = this.feedRepository.create({
      user,
      content: dto.content,
      tags: dto.tags ?? [],
    });
    const savedFeed = await this.feedRepository.save(feed);

    if (files && files.length > 0) {
      const medias = files.map((file, index) =>
        this.feedMediaRepository.create({
          feed: savedFeed,
          filename: file.filename,
          filePath: file.path,
          order: index,
        }),
      );
      await this.feedMediaRepository.save(medias);
      savedFeed.medias = medias;
    }

    return this.formatFeed(savedFeed, 0, false);
  }

  async deleteFeed(id: string, userId: string) {
    const feed = await this.feedRepository.findOne({
      where: { id },
      relations: ['user', 'medias'],
    });

    if (!feed) {
      throw new NotFoundException('Feed not found');
    }

    if (feed.user.id !== userId) {
      throw new ForbiddenException('You can only delete your own feed');
    }

    // 파일 삭제
    for (const media of feed.medias ?? []) {
      try {
        fs.unlinkSync(media.filePath);
      } catch {
        // 파일이 없어도 무시
      }
    }

    await this.feedRepository.remove(feed);
    return { message: 'Feed deleted successfully' };
  }

  private formatFeed(feed: Feed, likeCount: number, isLiked: boolean) {
    const appUrl = this.configService.get<string>('APP_URL');
    return {
      id: feed.id,
      content: feed.content,
      tags: feed.tags ?? [],
      likeCount,
      isLiked,
      user: {
        id: feed.user.id,
        name: feed.user.name,
        profileImage: feed.user.profileImage,
      },
      images: (feed.medias ?? [])
        .sort((a, b) => a.order - b.order)
        .map((m) => ({
          id: m.id,
          url: `${appUrl}/media/${m.filename}`,
          order: m.order,
        })),
      createdAt: feed.createdAt,
      updatedAt: feed.updatedAt,
    };
  }

  private async getLikeCounts(feedIds: string[]): Promise<Record<string, number>> {
    if (feedIds.length === 0) return {};

    const result = await this.likeRepository
      .createQueryBuilder('like')
      .select('like.feedId', 'feedId')
      .addSelect('COUNT(*)', 'count')
      .where('like.feedId IN (:...feedIds)', { feedIds })
      .groupBy('like.feedId')
      .getRawMany();

    return result.reduce((acc, row) => {
      acc[row.feedId] = parseInt(row.count, 10);
      return acc;
    }, {} as Record<string, number>);
  }

  private async getLikedByUser(feedIds: string[], userId: string): Promise<Set<string>> {
    if (feedIds.length === 0) return new Set();

    const result = await this.likeRepository
      .createQueryBuilder('like')
      .select('like.feedId', 'feedId')
      .where('like.feedId IN (:...feedIds)', { feedIds })
      .andWhere('like.userId = :userId', { userId })
      .getRawMany();

    return new Set(result.map((r) => r.feedId));
  }
}
