# ---- Build Stage ----
FROM node:20-alpine AS builder

# corepack 으로 pnpm 활성화 (package.json 의 packageManager 필드 자동 인식)
RUN corepack enable

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build

# ---- Production Stage ----
FROM node:20-alpine AS production

RUN corepack enable

WORKDIR /app

ENV NODE_ENV=production

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

COPY --from=builder /app/dist ./dist

# 업로드 디렉토리 생성
RUN mkdir -p uploads

EXPOSE 3000

CMD ["node", "dist/main"]
