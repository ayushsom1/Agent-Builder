@echo off
REM Prossima AI - Quick Start Script for Windows
REM Prossimagen Technologies

setlocal enabledelayedexpansion

REM Colors (Windows 10+)
color 0D

echo.
echo ===============================================================
echo.
echo                    PROSSIMA AI
echo             Enterprise Visual Agent Builder
echo.
echo           Powered by Prossimagen Technologies
echo.
echo ===============================================================
echo.

REM Check if Docker is running
echo [1/5] Checking Docker installation...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is not running!
    echo.
    echo Please start Docker Desktop and try again.
    echo Download from: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)
echo SUCCESS: Docker is running
echo.

REM Check if .env exists
echo [2/5] Setting up environment configuration...
if exist "deploy\docker\.env" (
    echo WARNING: .env file already exists
    set /p "overwrite=Do you want to overwrite it? (y/N): "
    if /i not "!overwrite!"=="y" (
        echo Keeping existing .env file
        goto skip_env
    )
)

if not exist "deploy\docker\.env.example" (
    echo ERROR: .env.example not found!
    pause
    exit /b 1
)

copy "deploy\docker\.env.example" "deploy\docker\.env" >nul
echo SUCCESS: Created .env file from template
echo.

echo ===============================================================
echo  IMPORTANT: You need to configure your API key!
echo ===============================================================
echo.
echo Please edit deploy\docker\.env and add your API key:
echo.
echo   Option 1 (Recommended): OpenRouter
echo     OPENAI_API_KEY=sk-or-v1-YOUR_KEY_HERE
echo     OPENAI_API_BASE=https://openrouter.ai/api/v1
echo     OPENAI_MODEL_NAME=openai/gpt-4o-mini
echo.
echo   Option 2: OpenAI Direct
echo     OPENAI_API_KEY=sk-YOUR_OPENAI_KEY
echo     OPENAI_API_BASE=https://api.openai.com/v1
echo     OPENAI_MODEL_NAME=gpt-4o-mini
echo.
echo.

echo Opening .env file in notepad...
start notepad "deploy\docker\.env"
echo.
pause
echo.

set /p "configured=Have you added your API key? (y/N): "
if /i not "!configured!"=="y" (
    echo.
    echo Please configure your API key before starting the application
    pause
    exit /b 1
)

:skip_env

echo.
echo [3/5] Starting Prossima AI services...
echo.
echo This may take 2-3 minutes on first run (downloading images)...
echo.

docker-compose -f deploy\docker\docker-compose.dev.yml up -d

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to start services
    echo Check the error messages above for details
    pause
    exit /b 1
)

echo.
echo SUCCESS: Services started!
echo.

echo [4/5] Waiting for services to initialize...
timeout /t 15 /nobreak >nul
echo.

echo [5/5] Checking service status...
echo.
docker-compose -f deploy\docker\docker-compose.dev.yml ps
echo.

echo ===============================================================
echo                   SETUP COMPLETE!
echo ===============================================================
echo.
echo Prossima AI is now running!
echo.
echo   Frontend:        http://localhost:5173
echo   Backend API:     http://localhost:5001
echo   Keycloak Admin:  http://localhost:8081
echo   PgAdmin:         http://localhost:8002
echo   Redis Insight:   http://localhost:8001
echo.
echo   Default Login:
echo     Username: admin
echo     Password: admin
echo.
echo   WARNING: Change the password after first login!
echo.
echo ===============================================================
echo.
echo Useful commands:
echo.
echo   View logs:
echo     docker-compose -f deploy\docker\docker-compose.dev.yml logs -f
echo.
echo   Stop services:
echo     docker-compose -f deploy\docker\docker-compose.dev.yml down
echo.
echo   Restart services:
echo     docker-compose -f deploy\docker\docker-compose.dev.yml restart
echo.
echo ===============================================================
echo.

set /p "browser=Open Prossima AI in browser? (Y/n): "
if /i not "!browser!"=="n" (
    start http://localhost:5173
)

echo.
echo Happy building with Prossima AI!
echo.
pause
