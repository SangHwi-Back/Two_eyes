import {
  CreateDateColumn,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Feed } from '../../feed/entities/feed.entity';

@Entity('likes')
@Unique(['user', 'feed'])
export class Like {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, (user) => user.likes, { onDelete: 'CASCADE' })
  user: User;

  @ManyToOne(() => Feed, (feed) => feed.likes, { onDelete: 'CASCADE' })
  feed: Feed;

  @CreateDateColumn()
  createdAt: Date;
}
