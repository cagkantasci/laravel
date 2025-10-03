#!/bin/bash

# SmartOP Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="smartop"
DOCKER_REGISTRY="your-registry.com"
VERSION=${1:-latest}
ENVIRONMENT=${2:-production}

echo -e "${GREEN}Starting SmartOP deployment...${NC}"
echo -e "Version: ${VERSION}"
echo -e "Environment: ${ENVIRONMENT}"

# Function to log with timestamp
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    error "Docker is not running. Please start Docker and try again."
fi

# Check if docker-compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    error "docker-compose is not installed. Please install it and try again."
fi

# Production deployment
if [ "$ENVIRONMENT" = "production" ]; then
    log "Deploying to production environment..."

    # Build production images
    log "Building production Docker images..."
    docker build -t ${APP_NAME}:${VERSION} .

    # Tag for registry
    if [ ! -z "$DOCKER_REGISTRY" ]; then
        docker tag ${APP_NAME}:${VERSION} ${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}
        docker tag ${APP_NAME}:${VERSION} ${DOCKER_REGISTRY}/${APP_NAME}:latest

        log "Pushing images to registry..."
        docker push ${DOCKER_REGISTRY}/${APP_NAME}:${VERSION}
        docker push ${DOCKER_REGISTRY}/${APP_NAME}:latest
    fi

    # Create production environment file
    if [ ! -f .env.production ]; then
        warning ".env.production file not found. Creating from .env.docker..."
        cp .env.docker .env.production
    fi

    # Backup current database
    log "Creating database backup..."
    docker-compose exec mysql mysqldump -u smartop -p smartop > backup_$(date +%Y%m%d_%H%M%S).sql

    # Deploy with zero downtime
    log "Starting zero-downtime deployment..."
    docker-compose -f docker-compose.yml up -d --remove-orphans

    # Wait for services to be healthy
    log "Waiting for services to be healthy..."
    sleep 30

    # Run database migrations
    log "Running database migrations..."
    docker-compose exec app php artisan migrate --force

    # Clear and cache configurations
    log "Clearing and caching configurations..."
    docker-compose exec app php artisan config:cache
    docker-compose exec app php artisan route:cache
    docker-compose exec app php artisan view:cache

    # Restart queue workers
    log "Restarting queue workers..."
    docker-compose exec app php artisan queue:restart

# Development deployment
elif [ "$ENVIRONMENT" = "development" ]; then
    log "Deploying to development environment..."

    # Build development images
    log "Building development Docker images..."
    docker build -f Dockerfile.dev -t ${APP_NAME}:dev .

    # Start development environment
    log "Starting development environment..."
    docker-compose -f docker-compose.dev.yml up -d --remove-orphans

    # Wait for services
    sleep 20

    # Install dependencies
    log "Installing dependencies..."
    docker-compose -f docker-compose.dev.yml exec app composer install
    docker-compose -f docker-compose.dev.yml exec app npm install

    # Generate app key if needed
    log "Setting up application..."
    docker-compose -f docker-compose.dev.yml exec app php artisan key:generate

    # Run migrations and seeders
    log "Running migrations and seeders..."
    docker-compose -f docker-compose.dev.yml exec app php artisan migrate:fresh --seed

    # Create storage link
    docker-compose -f docker-compose.dev.yml exec app php artisan storage:link

# Staging deployment
elif [ "$ENVIRONMENT" = "staging" ]; then
    log "Deploying to staging environment..."

    # Build staging images
    log "Building staging Docker images..."
    docker build -t ${APP_NAME}:staging .

    # Start staging environment
    log "Starting staging environment..."
    docker-compose -f docker-compose.staging.yml up -d --remove-orphans

    # Wait for services
    sleep 30

    # Run migrations
    log "Running database migrations..."
    docker-compose -f docker-compose.staging.yml exec app php artisan migrate --force

    # Seed test data
    log "Seeding test data..."
    docker-compose -f docker-compose.staging.yml exec app php artisan db:seed --class=TestDataSeeder

else
    error "Unknown environment: $ENVIRONMENT. Supported: production, development, staging"
fi

# Health check
log "Performing health check..."
sleep 10

if [ "$ENVIRONMENT" = "development" ]; then
    HEALTH_URL="http://localhost:8000/api/health"
else
    HEALTH_URL="http://localhost/api/health"
fi

if curl -f -s $HEALTH_URL >/dev/null; then
    log "Health check passed!"
else
    warning "Health check failed. Please check the logs."
fi

# Show running containers
log "Running containers:"
docker-compose ps

log "Deployment completed successfully!"
log "Application is available at: $HEALTH_URL"

if [ "$ENVIRONMENT" = "development" ]; then
    echo -e "${GREEN}Development services:${NC}"
    echo -e "  - Application: http://localhost:8000"
    echo -e "  - PhpMyAdmin: http://localhost:8080"
    echo -e "  - Redis Commander: http://localhost:8081"
    echo -e "  - Mailpit: http://localhost:8025"
elif [ "$ENVIRONMENT" = "production" ]; then
    echo -e "${GREEN}Production services:${NC}"
    echo -e "  - Application: http://localhost"
    echo -e "  - Monitoring: http://localhost:3000 (Grafana)"
    echo -e "  - Metrics: http://localhost:9090 (Prometheus)"
fi

echo -e "${GREEN}Deployment script completed!${NC}"