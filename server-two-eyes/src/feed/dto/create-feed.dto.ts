import { IsArray, IsOptional, IsString, ArrayMaxSize } from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateFeedDto {
  @IsString()
  @IsOptional()
  content?: string;

  /**
   * 해시태그 키워드 배열.
   * multipart form-data 로 전송 시 같은 키를 여러 번 쓰거나 JSON 문자열로 보낼 수 있습니다.
   * - 배열: tags=풍경&tags=야경
   * - JSON 문자열: tags=["풍경","야경"]  ← Transform 으로 파싱
   * 최대 10개, 각 항목은 문자열이어야 합니다.
   */
  @IsArray()
  @IsString({ each: true })
  @ArrayMaxSize(10)
  @IsOptional()
  @Transform(({ value }) => {
    if (!value) return [];
    // JSON 문자열로 넘어온 경우 파싱
    if (typeof value === 'string') {
      try {
        const parsed = JSON.parse(value);
        return Array.isArray(parsed) ? parsed : [value];
      } catch {
        return [value];
      }
    }
    return value;
  })
  tags?: string[];
}
