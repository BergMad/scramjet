FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends     git     ca-certificates     && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm

WORKDIR /app

# Copy package files first for layer caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc* ./
COPY patches/ ./patches/
COPY packages/ ./packages/
COPY rspack.config.ts devlib.ts ./
COPY assets/ ./assets/
COPY devserver.ts ./

# Install dependencies
RUN pnpm install --frozen-lockfile || pnpm install

# Environment variables
ENV DEMO_PORT=8080
ENV WISP_PORT=8081
ENV HOST=0.0.0.0
ENV NODE_ENV=production

# Expose the demo port (Traefik will route here)
EXPOSE 8080

CMD ["node", "--no-warnings=ExperimentalWarning", "devserver.ts"]
