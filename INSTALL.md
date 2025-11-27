# Prossima AI - Quick Installation Guide

**Enterprise Visual Agent Builder by Prossimagen Technologies**

---

## Prerequisites

- Docker Desktop installed and running
- 8GB RAM available
- 10GB free disk space

**Get Docker:** https://www.docker.com/products/docker-desktop

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/ayushsom1/Agent-Builder.git
cd Agent-Builder
```

### 2. Configure Environment

Copy the example environment file:

```bash
cp deploy/docker/.env.example deploy/docker/.env
```

Edit `deploy/docker/.env` and add your API key:

```bash
# Option 1 (Recommended): OpenRouter - Access multiple AI models
OPENAI_API_KEY=sk-or-v1-YOUR_KEY_HERE
OPENAI_API_BASE=https://openrouter.ai/api/v1
OPENAI_MODEL_NAME=openai/gpt-4o-mini

# Option 2: OpenAI Direct
OPENAI_API_KEY=sk-YOUR_OPENAI_KEY
OPENAI_API_BASE=https://api.openai.com/v1
OPENAI_MODEL_NAME=gpt-4o-mini
```

**Get API Keys:**
- OpenRouter: https://openrouter.ai/keys (Recommended - access to GPT-4, Claude, Gemini, etc.)
- OpenAI: https://platform.openai.com/api-keys

### 3. Start Prossima AI

```bash
docker-compose -f deploy/docker/docker-compose.dev.yml up -d
```

First run will take 2-3 minutes to download images.

### 4. Access the Application

**Frontend:** http://localhost:5173

**Default Login:**
- Username: `admin`
- Password: `admin`

**Change password after first login!**

---

## Additional Services

- **Backend API:** http://localhost:5001
- **Keycloak (Auth):** http://localhost:8081
- **PgAdmin (Database UI):** http://localhost:8002
- **Redis Insight (Cache UI):** http://localhost:8001

---

## Common Commands

### View Logs
```bash
docker-compose -f deploy/docker/docker-compose.dev.yml logs -f
```

### Stop Services
```bash
docker-compose -f deploy/docker/docker-compose.dev.yml down
```

### Restart Services
```bash
docker-compose -f deploy/docker/docker-compose.dev.yml restart
```

### Update to Latest Version
```bash
git pull origin main
docker-compose -f deploy/docker/docker-compose.dev.yml up -d --build
```

---

## Quick Start Scripts

For automated setup, run:

**macOS/Linux:**
```bash
chmod +x quick-start.sh
./quick-start.sh
```

**Windows:**
```cmd
quick-start.bat
```

---

## Troubleshooting

### Services Won't Start
```bash
# Check Docker is running
docker ps

# Remove old containers and restart
docker-compose -f deploy/docker/docker-compose.dev.yml down
docker-compose -f deploy/docker/docker-compose.dev.yml up -d
```

### API Key Errors
```bash
# Verify key is set
docker-compose -f deploy/docker/docker-compose.dev.yml exec backend env | grep OPENAI_API_KEY

# Restart backend after editing .env
docker-compose -f deploy/docker/docker-compose.dev.yml restart backend
```

### Port Already in Use
Edit `deploy/docker/docker-compose.dev.yml` and change the port mapping:
```yaml
ports:
  - "3000:5173"  # Change 5173 to any available port
```

---

## Features

- **Visual Flow Builder** - Drag-and-drop agent creation
- **Multiple AI Models** - GPT-4, Claude, Gemini, local Ollama
- **Pre-built Agents** - Research, content generation, quick queries
- **Resizable Panels** - Drag borders to adjust sidebar and terminal
- **Light/Dark Themes** - Toggle with blur circle animation
- **Prossima Branding** - Purple accent theme, custom logo

---

## Support

**Documentation:**
- See `BRANDING.md` for branding details
- See `CONFIGURATION.md` for advanced configuration
- See `SHARE_WITH_TEAM.md` for team deployment options

**Contact:** contact@prossimagen.com

**Repository:** https://github.com/ayushsom1/Agent-Builder

---

**© 2024 Prossimagen Technologies - Enterprise AI Solutions**
