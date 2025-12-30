# Stage 1: Dependencies
FROM node:20-alpine AS deps
ARG NPM_TOKEN
# Native builds (e.g., bufferutil) and private package installs need these tools/credentials.
RUN apk add --no-cache libc6-compat python3 make g++
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Configure private registry auth and install dependencies
RUN test -n "$NPM_TOKEN" || (echo "NPM_TOKEN is required to install private packages" >&2; exit 1) \
  && npm config set @data-phone:registry https://npm.pkg.github.com \
  && npm config set //npm.pkg.github.com/:_authToken "$NPM_TOKEN" \
  && npm ci \
  && npm config delete //npm.pkg.github.com/:_authToken || true

# Stage 2: Builder
FROM node:20-alpine AS builder
ARG REACT_APP_AUTH_API
ARG REACT_APP_LOGIN_PORTAL
ENV REACT_APP_AUTH_API=$REACT_APP_AUTH_API
ENV REACT_APP_LOGIN_PORTAL=$REACT_APP_LOGIN_PORTAL
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1

# Build the application
RUN npm run build

# Stage 3: Runner
FROM node:20-alpine AS runner
ARG REACT_APP_AUTH_API
ARG REACT_APP_LOGIN_PORTAL
ENV REACT_APP_AUTH_API=$REACT_APP_AUTH_API
ENV REACT_APP_LOGIN_PORTAL=$REACT_APP_LOGIN_PORTAL
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files from standalone build
# The standalone output includes server.js and necessary dependencies
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]

