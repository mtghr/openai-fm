# Server Installation Guide

## Prerequisites

- Server with Docker and Docker Compose installed
- SSH access to your server
- Your OpenAI API key

## Quick Installation Steps

### 1. Connect to Your Server

```bash
ssh user@your-server-ip
```

### 2. Install Docker (if not already installed)

**Ubuntu/Debian:**
```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker compose-plugin

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (optional, to run without sudo)
sudo usermod -aG docker $USER
# Log out and back in for this to take effect
```

**CentOS/RHEL:**
```bash
# Install Docker
sudo yum install -y docker docker compose-plugin
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### 3. Clone Your Fork

```bash
# Navigate to where you want to install
cd /opt  # or /home/your-user, or wherever you prefer

# Clone your fork
git clone https://github.com/mtghr/openai-fm.git
cd openai-fm
```

### 4. Create Environment File

```bash
# Create .env file
nano .env
```

Add your configuration:
```bash
# Required: Your OpenAI API Key
OPENAI_API_KEY=sk-your-actual-api-key-here

# Optional: PostgreSQL settings (if using docker compose.yml)
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-secure-password-here
POSTGRES_DB=openai_fm
```

Save and exit (Ctrl+X, then Y, then Enter)

### 5. Build and Start the Application

**Option A: With PostgreSQL (Full Features)**
```bash
docker compose up -d --build
```

**Option B: Without PostgreSQL (Simplified)**
```bash
docker compose -f docker compose.simple.yml up -d --build
```

### 6. Verify Installation

```bash
# Check if containers are running
docker compose ps

# View logs
docker compose logs -f

# Test the application
curl http://localhost:3000
```

### 7. Access the Application

- **Local access:** http://localhost:3000
- **Remote access:** http://your-server-ip:3000

## Firewall Configuration

If you need to access from outside, open port 3000:

**UFW (Ubuntu):**
```bash
sudo ufw allow 3000/tcp
sudo ufw reload
```

**firewalld (CentOS/RHEL):**
```bash
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --reload
```

## Using a Reverse Proxy (Recommended for Production)

### Nginx Configuration

Create `/etc/nginx/sites-available/openai-fm`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/openai-fm /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### SSL with Let's Encrypt (Recommended)

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## Management Commands

### View Logs
```bash
docker compose logs -f
```

### Stop the Application
```bash
docker compose down
```

### Restart the Application
```bash
docker compose restart
```

### Update the Application
```bash
# Pull latest changes
git pull

# Rebuild and restart
docker compose up -d --build
```

### View Container Status
```bash
docker compose ps
```

### Access Container Shell
```bash
docker compose exec app sh
```

### Backup Database (if using PostgreSQL)
```bash
docker compose exec postgres pg_dump -U postgres openai_fm > backup.sql
```

### Restore Database
```bash
docker compose exec -T postgres psql -U postgres openai_fm < backup.sql
```

## Troubleshooting

### Port Already in Use
```bash
# Check what's using port 3000
sudo lsof -i :3000

# Or change the port in docker compose.yml:
# ports:
#   - "8080:3000"  # Use port 8080 instead
```

### Permission Denied
```bash
# Make sure Docker is running
sudo systemctl status docker

# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in
```

### Container Won't Start
```bash
# Check logs
docker compose logs app

# Check if .env file exists and has correct values
cat .env

# Rebuild from scratch
docker compose down -v
docker compose up -d --build
```

### Database Connection Issues
```bash
# Check if PostgreSQL container is running
docker compose ps postgres

# Check PostgreSQL logs
docker compose logs postgres

# Test database connection
docker compose exec postgres psql -U postgres -d openai_fm -c "SELECT 1;"
```

## Production Recommendations

1. **Use a reverse proxy** (Nginx/Apache) with SSL
2. **Set strong database passwords** in `.env`
3. **Keep your `.env` file secure** - never commit it
4. **Set up automatic backups** for the database
5. **Monitor logs** regularly
6. **Keep Docker updated**: `sudo apt-get update && sudo apt-get upgrade docker-ce`
7. **Use a firewall** to restrict access
8. **Set up monitoring** (optional: use tools like Prometheus/Grafana)

## Systemd Service (Optional - Auto-start on Boot)

Create `/etc/systemd/system/openai-fm.service`:

```ini
[Unit]
Description=OpenAI.fm Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/openai-fm
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Enable the service:
```bash
sudo systemctl enable openai-fm
sudo systemctl start openai-fm
```

