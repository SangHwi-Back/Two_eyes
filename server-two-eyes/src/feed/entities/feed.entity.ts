import {
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { FeedMedia } from './feed-media.entity';
import { Like } from '../../likes/entities/like.entity';

@Entity('feeds')
export class Feed {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, (user) => user.feeds, { onDelete: 'CASCADE' })
  user: User;

  @Column({ nullable: true, type: 'text' })
  content: string;

  /**
   * 해시태그 키워드 목록.
   * PostgreSQL text[] 배열로 저장하며, 앱에서 '#' 없이 순수 문자열로 전달합니다.
   * 예: ["풍경", "야경", "감성"]
   */
  @Column('text', { array: true, default: [] })
  tags: string[];

  @OneToMany(() => FeedMedia, (media) => media.feed, {
    cascade: true,
    eager: false,
  })
  medias: FeedMedia[];

  @OneToMany(() => Like, (like) => like.feed)
  likes: Like[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
