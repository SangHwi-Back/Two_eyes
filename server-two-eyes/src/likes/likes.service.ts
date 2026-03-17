import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Like } from './entities/like.entity';
import { Feed } from '../feed/entities/feed.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class LikesService {
  constructor(
    @InjectRepository(Like)
    private readonly likeRepository: Repository<Like>,
    @InjectRepository(Feed)
    private readonly feedRepository: Repository<Feed>,
  ) {}

  async like(feedId: string, user: User) {
    const feed = await this.feedRepository.findOne({ where: { id: feedId } });
    if (!feed) {
      throw new NotFoundException('Feed not found');
    }

    const existing = await this.likeRepository.findOne({
      where: { feed: { id: feedId }, user: { id: user.id } },
    });

    if (existing) {
      throw new ConflictException('Already liked this feed');
    }

    const like = this.likeRepository.create({ feed, user });
    await this.likeRepository.save(like);

    const likeCount = await this.likeRepository.count({
      where: { feed: { id: feedId } },
    });

    return { feedId, likeCount, isLiked: true };
  }

  async unlike(feedId: string, user: User) {
    const feed = await this.feedRepository.findOne({ where: { id: feedId } });
    if (!feed) {
      throw new NotFoundException('Feed not found');
    }

    const existing = await this.likeRepository.findOne({
      where: { feed: { id: feedId }, user: { id: user.id } },
    });

    if (!existing) {
      throw new NotFoundException('Like not found');
    }

    await this.likeRepository.remove(existing);

    const likeCount = await this.likeRepository.count({
      where: { feed: { id: feedId } },
    });

    return { feedId, likeCount, isLiked: false };
  }
}
