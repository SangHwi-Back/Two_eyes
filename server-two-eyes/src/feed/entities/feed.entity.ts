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
