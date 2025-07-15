# install.ps1

$project = "myapp"

# ✅ Step 1: Check if Laravel project exists
if (!(Test-Path -Path "./$project/artisan")) {
    Write-Host "📦 Creating new Laravel project '$project' with Composer (via Docker)..." -ForegroundColor Yellow
    docker run --rm -v ${PWD}:/app composer create-project laravel/laravel $project

    Write-Host "`n📁 Copying config files into '$project'..." -ForegroundColor Cyan
    Copy-Item -Path ".\docker-compose.yml" -Destination ".\$project\docker-compose.yml" -Force
    Copy-Item -Path ".\Dockerfile" -Destination ".\$project\Dockerfile" -Force
    Copy-Item -Path ".\install.ps1" -Destination ".\$project\install.ps1" -Force
    Copy-Item -Path ".\nginx.conf" -Destination ".\$project\nginx.conf" -Force
    Copy-Item -Path ".\.env" -Destination ".\$project\.env" -Force
} else {
    Write-Host "✅ Laravel project '$project' already exists, skipping creation." -ForegroundColor Green
}

# Move into the project folder
Set-Location $project

# ✅ Step 2: Stop and remove any existing containers and volumes
Write-Host "`n🧹 Cleaning up containers and volumes..." -ForegroundColor Magenta
docker compose down -v

# ✅ Step 3: Build and start containers
Write-Host "`n🔧 Building and starting containers..." -ForegroundColor Cyan
docker compose up -d --build

# ✅ Step 4: Wait for DB container to be ready
Write-Host "`n⏳ Waiting for containers to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# ✅ Step 5: Fix permissions for storage (inside container)
Write-Host "`n🔐 Fixing storage permissions..." -ForegroundColor Magenta
docker exec -it laravel-app chmod -R 777 storage/

# ✅ Step 6: Run Laravel commands
Write-Host "`n♻️ Running artisan config:clear..." -ForegroundColor Cyan
docker exec -it laravel-app php artisan config:clear

# ✅ Step 7: Run Laravel commands
Write-Host "`n♻️ Running artisan migrate..." -ForegroundColor Yellow
docker exec -it laravel-app php artisan migrate

Write-Host "`n✅ Laravel is up and running at: http://localhost:8000" -ForegroundColor Green
