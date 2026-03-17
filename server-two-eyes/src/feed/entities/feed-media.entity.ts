import {
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Feed } from './feed.entity';

@Entity('feed_medias')
export class FeedMedia {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Feed, (feed) => feed.medias, { onDelete: 'CASCADE' })
  feed: Feed;

  @Column()
  filename: string;

  @Column()
  filePath: string;

  @Column({ default: 0 })
  order: number;

  @CreateDateColumn()
  createdAt: Date;
}
