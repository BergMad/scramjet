FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends     git     ca-certificates     curl     && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm

WORKDIR /app

# Download pre-built WASM from latest release
RUN mkdir -p packages/core/dist &&     curl -L -o /tmp/scramjet.tgz https://github.com/MercuryWorkshop/scramjet/releases/download/v2.0.67-alpha.2/mercuryworkshop-scramjet-2.0.67-alpha.2.tgz &&     cd /tmp && tar -xzf scramjet.tgz &&     cp /tmp/package/dist/scramjet.wasm /app/packages/core/dist/ 2>/dev/null || true &&     cp /tmp/package/dist/*.mjs /app/packages/core/dist/ 2>/dev/null || true &&     ls -la /app/packages/core/dist/

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc* ./
COPY patches/ ./patches/
COPY packages/ ./packages/
COPY rspack.config.ts devlib.ts ./
COPY assets/ ./assets/
COPY devserver.ts ./
COPY tsconfig.json ./

# Install dependencies (skip postinstall for speed)
RUN pnpm install --frozen-lockfile || pnpm install

# Environment variables
ENV DEMO_PORT=8080
ENV WISP_PORT=8081
ENV HOST=0.0.0.0
ENV NODE_ENV=production

# Expose the demo port
EXPOSE 8080

CMD ["node", "--no-warnings=ExperimentalWarning", "devserver.ts"]
