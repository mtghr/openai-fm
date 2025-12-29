# Forking and Pushing Docker Changes

## Step 1: Create a Fork on GitHub

1. Go to https://github.com/openai/openai-fm
2. Click the **"Fork"** button in the top right
3. Choose your GitHub account/organization
4. This creates a copy at `https://github.com/YOUR_USERNAME/openai-fm`

## Step 2: Add Your Fork as a Remote

After forking, add your fork as a new remote:

```bash
# Add your fork as 'myfork' remote
git remote add myfork https://github.com/YOUR_USERNAME/openai-fm.git

# Verify remotes
git remote -v
# Should show:
# origin    https://github.com/openai/openai-fm.git (fetch)
# origin    https://github.com/openai/openai-fm.git (push)
# myfork    https://github.com/YOUR_USERNAME/openai-fm.git (fetch)
# myfork    https://github.com/YOUR_USERNAME/openai-fm.git (push)
```

## Step 3: Commit Your Docker Changes

```bash
# Stage all your Docker-related changes
git add Dockerfile docker-compose.yml docker-compose.simple.yml .dockerignore
git add init-db.sql DEPLOYMENT.md
git add next.config.ts README.md

# Commit with a descriptive message
git commit -m "Add Docker support with multi-stage build and docker-compose

- Add Dockerfile with multi-stage build for production
- Add docker-compose.yml with PostgreSQL support
- Add docker-compose.simple.yml for simplified deployment
- Add database initialization script
- Update next.config.ts for standalone output
- Add deployment documentation
- Update README with Docker instructions"
```

## Step 4: Push to Your Fork

```bash
# Push to your fork
git push myfork main

# Or if you want to create a new branch for Docker changes:
git checkout -b docker-support
git push myfork docker-support
```

## Step 5: Keep Your Fork Updated

To sync with the original repository:

```bash
# Fetch updates from original repo
git fetch origin

# Merge updates into your main branch
git checkout main
git merge origin/main

# Push updates to your fork
git push myfork main
```

## Alternative: Create a Pull Request

If you want to contribute your Docker changes back to OpenAI:

1. Push your changes to your fork
2. Go to https://github.com/openai/openai-fm
3. Click **"Pull requests"** → **"New pull request"**
4. Select your fork and branch
5. Describe your changes and submit

## Best Practices

- **Keep your fork updated** regularly with the original repository
- **Use descriptive commit messages** explaining what you added
- **Consider creating a branch** for your Docker changes instead of modifying main
- **Add a note in your README** that this is a fork with Docker support

