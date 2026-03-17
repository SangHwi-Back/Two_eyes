import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class AppleLoginDto {
  @IsString()
  @IsNotEmpty()
  identityToken: string;

  @IsString()
  @IsOptional()
  authorizationCode?: string;

  @IsOptional()
  fullName?: {
    firstName?: string;
    lastName?: string;
  };
}
