# 09 — Docker Backend (Laravel + PostgreSQL + PostGIS)

---

## Local Development — Managing RAM and Disk

Building locally is perfectly normal. But Docker can accumulate garbage quickly: build cache, old images, stopped containers. After a month you can easily lose 20–30 GB of disk space.

### Limit Docker Desktop Resources

```
Docker Desktop → Settings → Resources:
  CPUs:   half of your actual cores (e.g., 4 out of 8)
  Memory: 4 GB if you have 16 GB RAM, 6 GB if you have 32 GB RAM
           (the rest is needed by macOS and Xcode)
  Swap:   1 GB
  Disk:   50 GB maximum

⚠ By default Docker Desktop takes as much RAM as it needs —
  without a limit it can consume everything and Xcode will start lagging.
```

### Don't Rebuild the Image Every Time

```bash
# Bad — docker compose up --build rebuilds everything
docker compose up --build

# Good — only rebuild when Dockerfile or composer.json changed
docker compose up -d                       # just start (no rebuild)
docker compose up -d --build app           # rebuild only one service

# Ask yourself — is a rebuild even necessary?
# If you only changed PHP/Laravel code — no rebuild needed,
# code is mounted via volume: ./backend:/var/www/backend
```

### Build Cache — Works for You if the Dockerfile Is Correct

```dockerfile
# Bad — COPY . . before composer install
# Any change to any file triggers composer install again (slow!)
COPY . .
RUN composer install

# Good — copy only composer.json/lock first, then everything else
# composer install is cached as long as composer.json hasn't changed
COPY composer.json composer.lock ./
RUN composer install --no-scripts --no-autoloader

COPY . .
RUN composer dump-autoload --optimize
```

### Cleanup (Once a Week Is Enough)

```bash
# Remove stopped containers, unused networks, dangling images
docker system prune -f

# + remove build cache (frees up the most space)
docker system prune -f --volumes

# See how much space Docker is using right now
docker system df

# Example output:
# TYPE            TOTAL   ACTIVE   SIZE      RECLAIMABLE
# Images          12      3        8.2GB     6.1GB (74%)   ← garbage is usually here
# Containers      2       2        120MB     0B
# Build Cache     47      0        3.4GB     3.4GB         ← and here
```

### For Mac — Alpine Images Wherever Possible

```yaml
# docker-compose.yml for local development
redis:
  image: redis:7-alpine        # 30 MB instead of 130 MB
nginx:
  image: nginx:alpine          # 40 MB instead of 190 MB
# postgres/postgis — no Alpine variant with PostGIS, use the standard one
```

### When You Must Rebuild the Image

```
Changed Dockerfile                → docker compose up -d --build app
Added/removed a composer package  → docker compose up -d --build app
Changed PHP/Laravel code          → NO rebuild needed (volume mount)
Changed .env                      → docker compose restart app
Added a new migration             → docker exec myapp_app php artisan migrate
```

---

## docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: myapp_app
    volumes:
      - ./backend:/var/www/backend
    depends_on:
      - postgres
      - redis
    networks:
      - myapp

  nginx:
    image: nginx:alpine
    container_name: myapp_nginx
    ports:
      - "80:80"
    volumes:
      - ./backend:/var/www/backend
      - ./docker/nginx/default.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - app
    networks:
      - myapp

  postgres:
    image: postgis/postgis:16-3.4   # PostGIS included
    container_name: myapp_postgres
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: myapp
      POSTGRES_PASSWORD: secret
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - myapp

  redis:
    image: redis:7-alpine
    container_name: myapp_redis
    networks:
      - myapp

  meilisearch:
    image: getmeili/meilisearch:v1.7
    container_name: myapp_meilisearch
    environment:
      MEILI_MASTER_KEY: "meili_dev_key"   # REQUIRED even locally!
      MEILI_ENV: development
    ports:
      - "7700:7700"
    volumes:
      - meilisearch_data:/meili_data
    networks:
      - myapp

  minio:
    image: minio/minio
    container_name: myapp_minio
    command: server /data --console-address ":9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin_secret
    ports:
      - "9000:9000"
      - "9001:9001"
    volumes:
      - minio_data:/data
    networks:
      - myapp

  worker:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: myapp_worker
    command: php artisan queue:work redis --sleep=3 --tries=3
    volumes:
      - ./backend:/var/www/backend
    depends_on:
      - app
      - redis
    networks:
      - myapp

volumes:
  postgres_data:
  meilisearch_data:
  minio_data:

networks:
  myapp:
    driver: bridge
```

---

## Meilisearch — Critical Notes

**Problem:** Meilisearch requires `MEILI_MASTER_KEY` even in `development` mode. Without it, all requests will return 401 Unauthorized.

### Laravel .env
```
MEILISEARCH_HOST=http://meilisearch:7700
MEILISEARCH_KEY=meili_dev_key    # must match MEILI_MASTER_KEY
SCOUT_DRIVER=meilisearch
```

### If Meilisearch Returns 401

```bash
# Recreate the container with the key
docker compose down meilisearch
docker volume rm myapp_meilisearch_data
docker compose up -d meilisearch

# Re-index the data
docker exec myapp_app php artisan scout:import "App\Models\Listing"
```

---

## PostGIS — Activation

```bash
# After the first postgres startup
docker exec -it myapp_postgres psql -U myapp -d myapp -c "CREATE EXTENSION IF NOT EXISTS postgis;"
docker exec -it myapp_postgres psql -U myapp -d myapp -c "CREATE EXTENSION IF NOT EXISTS postgis_topology;"
```

Or in a Laravel migration:
```php
public function up(): void
{
    DB::statement('CREATE EXTENSION IF NOT EXISTS postgis');
}
```

---

## Dockerfile for Laravel

```dockerfile
FROM php:8.3-fpm

# System dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpq-dev libzip-dev libgd-dev \
    && docker-php-ext-install pdo pdo_pgsql zip gd

# PostGIS support
RUN apt-get install -y libgeos-dev libproj-dev \
    && pecl install redis \
    && docker-php-ext-enable redis

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/backend
COPY . .

RUN composer install --no-interaction --optimize-autoloader
RUN chown -R www-data:www-data /var/www/backend/storage
```

---

## Nginx Config

```nginx
server {
    listen 80;
    server_name _;
    root /var/www/backend/public;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass app:9000;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Media files (Spatie MediaLibrary)
    location /storage {
        alias /var/www/backend/storage/app/public;
    }
}
```

---

## Laravel .env for Docker

```
APP_URL=http://192.168.1.100    # your machine's IP (not localhost — an iOS device can't reach it)

DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=myapp
DB_USERNAME=myapp
DB_PASSWORD=secret

REDIS_HOST=redis
REDIS_PORT=6379

MEILISEARCH_HOST=http://meilisearch:7700
MEILISEARCH_KEY=meili_dev_key

FILESYSTEM_DISK=public          # or s3 for MinIO

AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin_secret
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=myapp
AWS_ENDPOINT=http://minio:9000
AWS_USE_PATH_STYLE_ENDPOINT=true
```

---

## RAM Optimization: Don't Build Images on the Production Server

**Problem:** Running `docker compose up --build` directly on the server causes a peak RAM load during the build. The server is overloaded and you end up needing an expensive instance.

**Solution:** Move the build to a CI Runner; deliver only the ready-made image to the server.

```
Before:
  git push → GitLab/GitHub → server builds the image itself + starts it
  Server RAM: 4–8 GB (must keep in reserve for the build)

After:
  git push → GitLab/GitHub → Runner builds the image → pushes to Registry
                                                            ↓
                                             Server: docker pull + docker run
  Server RAM: 1–2 GB is enough (only running containers)
```

**Result:** you can downscale the server. Real-world example:
- `srv-front`: `t3.medium` (4 GB) → `t3.micro` (1 GB) = −$20/month
- `srv-back`: `t3.large` (8 GB) → `t3.small` (2 GB) = −$46/month

---

### Dockerfile — Image Size Optimization

```dockerfile
# Multi-stage build — final image has no build dependencies
FROM php:8.3-fpm AS builder

RUN apt-get update && apt-get install -y \
    git curl zip unzip libpq-dev libzip-dev libgd-dev \
    && docker-php-ext-install pdo pdo_pgsql zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/backend
COPY . .

# Install dependencies without dev packages
RUN composer install --no-dev --no-interaction --optimize-autoloader

# ------- Final image (runtime only) -------
FROM php:8.3-fpm AS production

# Copy only the result, not the entire builder
COPY --from=builder /var/www/backend /var/www/backend
COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions

RUN chown -R www-data:www-data /var/www/backend/storage
```

**Why it matters:**
- `composer install --no-dev` — does not pull test packages into production
- Multi-stage build — git, composer, and build tools don't end up in the final image
- Size difference: monolithic Dockerfile ~800 MB vs multi-stage ~200 MB

---

### .dockerignore — Don't Copy Unnecessary Files into the Image

```
# backend/.dockerignore
.git
.env
.env.*
node_modules
vendor        # composer install will run inside the container
storage/logs
storage/app/public
tests
*.md
docker/
.gitlab-ci.yml
```

---

### GitLab CI — Moving the Build to a Runner

```yaml
# .gitlab-ci.yml
stages:
  - build
  - deploy

build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind        # Docker inside Docker
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA ./backend
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - docker tag $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA $CI_REGISTRY_IMAGE:latest
    - docker push $CI_REGISTRY_IMAGE:latest
  only:
    - main

deploy:
  stage: deploy
  image: alpine:latest
  before_script:
    - apk add --no-cache openssh-client
    - eval $(ssh-agent -s)
    - echo "$SSH_PRIVATE_KEY" | ssh-add -
  script:
    # The server only pulls and runs — it does not build!
    - ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_HOST "
        docker pull $CI_REGISTRY_IMAGE:latest &&
        docker compose -f /app/docker-compose.prod.yml up -d --no-build &&
        docker image prune -f"
  only:
    - main
```

---

### docker-compose.prod.yml — Production Without Build

```yaml
# The server has no build: section — only image:
services:
  app:
    image: registry.gitlab.com/yourproject/backend:latest  # pre-built image
    restart: unless-stopped
    env_file: .env.production
    depends_on:
      - postgres
      - redis
    networks:
      - myapp

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx/prod.conf:/etc/nginx/conf.d/default.conf
      - ./certbot/conf:/etc/letsencrypt:ro
    networks:
      - myapp
```

---

### Memory Savings — Practical Rules

```
1. Never run docker compose build on the production server
   → Building = peak RAM load
   → Move it to a CI Runner

2. Clean up old images regularly
   docker image prune -a -f                    # remove all unused images
   docker system prune -f                      # + build cache
   → Add to cron or to the end of your deploy script

3. Use :alpine images wherever possible
   redis:7-alpine instead of redis:7           # −150 MB
   nginx:alpine instead of nginx:latest        # −100 MB
   node:20-alpine instead of node:20           # −700 MB!

4. Limit container memory in production
   services:
     app:
       mem_limit: 512m          # prevents the container from consuming everything
       memswap_limit: 512m      # no swap — it will crash, not hang

5. Monitor memory usage
   docker stats                                 # live
   docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}"
```

---

### Downscaling Instances — When It Is Safe

```
WHEN YOU CAN REDUCE THE SERVER:
  ✓ Image builds are moved to a CI Runner
  ✓ Memory limits are set on containers
  ✓ Metrics show real consumption < 50% of RAM
  ✓ Monitoring is configured (Grafana / CloudWatch)

TYPICAL SIZE FOR AN MVP (no build on the server):
  Frontend + Nginx:  t3.micro (1 GB) — sufficient
  Backend Laravel:   t3.small (2 GB) — with headroom
  PostgreSQL RDS:    db.t3.small (2 GB) — for < 10k users

MONITORING BEFORE DOWNSCALING:
  # Watch real RAM consumption for at least a week
  docker stats --no-stream
  free -h
  # If peak < 60% of current capacity — safe to downscale
```

---

## Useful Commands

```bash
# Start
docker compose up -d

# Logs
docker compose logs -f app
docker compose logs -f worker

# Run a command inside a container
docker exec myapp_app php artisan migrate
docker exec myapp_app php artisan db:seed
docker exec myapp_app php artisan cache:clear

# Restart after code changes
docker compose restart app worker

# Full rebuild
docker compose down && docker compose up -d --build

# Check that Meilisearch is responding
curl http://localhost:7700/health

# Storage symlink (once)
docker exec myapp_app php artisan storage:link
```

---

## MinIO — Creating a Bucket

```bash
# Via CLI inside the container
docker exec myapp_minio mc alias set local http://localhost:9000 minioadmin minioadmin_secret
docker exec myapp_minio mc mb local/myapp
docker exec myapp_minio mc anonymous set public local/myapp
```

Or via Web UI: `http://localhost:9001` (minioadmin / minioadmin_secret)

---

## Reverb (WebSockets for Chats)

```yaml
# Add to docker-compose.yml
reverb:
  build:
    context: ./backend
  container_name: myapp_reverb
  command: php artisan reverb:start --host=0.0.0.0 --port=8080
  ports:
    - "8080:8080"
  networks:
    - myapp
```

```
BROADCAST_DRIVER=reverb
REVERB_APP_ID=myapp
REVERB_APP_KEY=myapp-key
REVERB_APP_SECRET=myapp-secret
REVERB_HOST=192.168.1.100
REVERB_PORT=8080
```
