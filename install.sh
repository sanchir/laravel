#!/bin/bash

project="myapp"

# Step 1: Check if Laravel project exists
if [ ! -f "./$project/artisan" ]; then
    echo -e "\e[33m📦 Creating new Laravel project '$project' with Composer (via Docker)...\e[0m"
    docker run --rm -u "$(id -u):$(id -g)" -v "$(pwd)":/app composer create-project laravel/laravel "$project"
	sleep 2

    echo -e "\n\e[36m📁 Copying config files into '$project'...\e[0m"
    cp ./docker-compose.yml "./$project/docker-compose.yml"
    cp ./Dockerfile "./$project/Dockerfile"
    cp ./install.sh "./$project/install.sh"
    cp ./nginx.conf "./$project/nginx.conf"
    cp ./.env "./$project/.env"
else
    echo -e "\e[32m✅ Laravel project '$project' already exists, skipping creation.\e[0m"
fi

# Move into the project folder
cd "$project" || exit

# Step 2: Stop and remove any existing containers and volumes
echo -e "\n\e[35m🧹 Cleaning up containers and volumes...\e[0m"
docker compose down -v
sleep 2

# Step 3: Build and start containers
echo -e "\n\e[36m🔧 Building and starting containers...\e[0m"
docker compose up -d --build
sleep 2

# Step 4: Wait for DB container to be ready
echo -e "\n\e[33m⏳ Waiting for containers to start...\e[0m"
sleep 2

# Step 5: Fix permissions for storage (inside container)
echo -e "\n\e[35m🔐 Fixing storage permissions...\e[0m"
docker exec -it laravel-app chmod -R 777 storage/
sleep 2

# Step 6: Run Laravel artisan commands
echo -e "\n\e[36m♻️ Running artisan config:clear...\e[0m"
docker exec -it laravel-app php artisan config:clear
sleep 2

echo -e "\n\e[33m♻️ Running artisan migrate...\e[0m"
docker exec -it laravel-app php artisan migrate

echo -e "\n\e[32m✅ Laravel is up and running at: http://localhost:8000\e[0m"
