import { IsOptional, IsString } from 'class-validator';

export class CreateFeedDto {
  @IsString()
  @IsOptional()
  content?: string;
}
