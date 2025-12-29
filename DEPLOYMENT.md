# Deployment Guide

## Files Required on Server

### Essential Files (Required)

These files are **required** for the Docker build to work:

#### Docker Configuration
- `Dockerfile` - Docker build instructions
- `docker compose.yml` - Full setup with PostgreSQL
- `docker compose.simple.yml` - Simplified setup without PostgreSQL (optional, choose one)
- `.dockerignore` - Excludes unnecessary files from build

#### Application Source Code
- `package.json` - Node.js dependencies
- `package-lock.json` - Locked dependency versions
- `next.config.ts` - Next.js configuration
- `tsconfig.json` - TypeScript configuration
- `tailwind.config.mjs` - Tailwind CSS configuration
- `postcss.config.mjs` - PostCSS configuration
- `eslint.config.mjs` - ESLint configuration
- `global.d.ts` - TypeScript global definitions

#### Source Code Directory
- `src/` - **Entire directory** (all TypeScript/React source files)
- `public/` - **Entire directory** (static assets: images, sounds, etc.)

#### Database (if using PostgreSQL)
- `init-db.sql` - Database schema initialization

#### Environment Configuration
- `.env` - **Create this on the server** (DO NOT commit to git)
  ```
  OPENAI_API_KEY=your_api_key_here
  POSTGRES_USER=postgres
  POSTGRES_PASSWORD=your_secure_password
  POSTGRES_DB=openai_fm
  ```

### Files NOT Needed (Excluded by .dockerignore)

These files are automatically excluded and don't need to be on the server:
- `node_modules/` - Installed during Docker build
- `.next/` - Built during Docker build
- `.env.local`, `.env.development.local`, etc. - Local env files
- `.git/` - Git repository (unless you want version control on server)
- `README.md` - Documentation (optional)
- `LICENSE` - License file (optional)
- Coverage reports, IDE files, etc.

## Deployment Methods

### Method 1: Git Clone (Recommended)

```bash
# On your server
git clone https://github.com/openai/openai-fm.git
cd openai-fm
cp .env.example .env
# Edit .env with your API keys
nano .env
docker compose up -d
```

### Method 2: Copy Files via SCP/RSYNC

```bash
# From your local machine
rsync -av --exclude='node_modules' --exclude='.next' --exclude='.git' \
  ./openai-fm/ user@server:/path/to/openai-fm/
```

### Method 3: Archive and Transfer

Create a deployment archive:

```bash
# Create archive excluding unnecessary files
tar -czf openai-fm-deploy.tar.gz \
  --exclude='node_modules' \
  --exclude='.next' \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='*.log' \
  Dockerfile docker compose.yml docker compose.simple.yml \
  .dockerignore init-db.sql \
  package.json package-lock.json \
  *.config.* *.json *.ts *.mjs \
  src/ public/
```

Then transfer and extract on server:
```bash
scp openai-fm-deploy.tar.gz user@server:/path/to/
ssh user@server "cd /path/to && tar -xzf openai-fm-deploy.tar.gz"
```

## Minimum File List

If you want to manually copy only essential files:

```
openai-fm/
├── Dockerfile
├── docker compose.yml (or docker compose.simple.yml)
├── .dockerignore
├── init-db.sql
├── package.json
├── package-lock.json
├── next.config.ts
├── tsconfig.json
├── tailwind.config.mjs
├── postcss.config.mjs
├── eslint.config.mjs
├── global.d.ts
├── src/          (entire directory)
└── public/       (entire directory)
```

## Server Setup Steps

1. **Transfer files** to server (using one of the methods above)

2. **Create `.env` file** on the server:
   ```bash
   cd /path/to/openai-fm
   nano .env
   # Add your OPENAI_API_KEY and database credentials
   ```

3. **Build and run**:
   ```bash
   docker compose up -d --build
   ```

4. **Check logs**:
   ```bash
   docker compose logs -f
   ```

5. **Verify** the app is running:
   ```bash
   curl http://localhost:3000
   ```

## Environment Variables

Required in `.env` file:
- `OPENAI_API_KEY` - Your OpenAI API key (required)

Optional (for sharing feature):
- `POSTGRES_USER` - PostgreSQL username (default: postgres)
- `POSTGRES_PASSWORD` - PostgreSQL password (default: postgres)
- `POSTGRES_DB` - Database name (default: openai_fm)

Or use external database:
- `POSTGRES_URL` - Full PostgreSQL connection string

## Notes

- The Dockerfile builds everything from source, so you need all source files
- `node_modules` and `.next` are built during the Docker build process
- Never commit `.env` file to version control
- The database is automatically initialized on first run (if using docker compose.yml)

