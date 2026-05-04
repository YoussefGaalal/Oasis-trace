#!/usr/bin/env pwsh
# deploy.ps1 — Build frontend and push all changes to GitHub for Railway redeploy
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backend = Join-Path $root "backend"

Write-Host "=== Step 1: Build React frontend ===" -ForegroundColor Cyan
Set-Location $backend
npm run build
if ($LASTEXITCODE -ne 0) { Write-Error "npm run build failed"; exit 1 }
Write-Host "Build complete." -ForegroundColor Green

Write-Host "`n=== Step 2: Stage all files ===" -ForegroundColor Cyan
Set-Location $root

# Force-add the built frontend (was excluded by old .gitignore)
git add -f backend/public/app/

# Backend changes
git add backend/nixpacks.toml
git add backend/database/seeders/DemoDataSeeder.php
git add backend/config/view.php
git add backend/config/cors.php
git add backend/routes/web.php
git add backend/app/Models/User.php
git add "backend/app/Http/Middleware/CheckSubscriptionLimits.php"
git add backend/database/migrations/
git add .gitignore

# Frontend source changes
git add backend/resources/js/

Write-Host "`n=== Step 3: Commit ===" -ForegroundColor Cyan
git status --short
git commit -m "feat: full deployment fix + demo data seeder

- Wire DemoDataSeeder into Railway start command (18 animals across 6 species,
  4 animal groups, 14 devices, 120 location points, 5 geofences, 6 alerts,
  12 tasks, 8 medical records, 10 vaccination schedules, 4 auctions)
- Fix api.js: relative URLs, Bearer token auth header
- Fix AuthContext: store/read token in localStorage
- Fix PlatformContext, AIAssistant, export.js: remove hardcoded localhost
- Fix App.jsx: add BrowserRouter basename='/app'
- Dashboard: mobile-responsive layout + graceful demo-data fallback
- config/view.php: remove realpath() to fix Blade cache error
- config/cors.php: explicit allowed_origins (no wildcard with credentials)
- routes/web.php: SPA catch-all serving public/app/index.html
- User.php: fix fillable + settings cast
- CheckSubscriptionLimits: use authenticated user, not spoofable headers
- Migration: add settings JSON column to users table
- .gitignore: allow backend/public/app/ built assets to be committed"

if ($LASTEXITCODE -ne 0) { Write-Error "git commit failed"; exit 1 }

Write-Host "`n=== Step 4: Push to GitHub ===" -ForegroundColor Cyan
git push
if ($LASTEXITCODE -ne 0) { Write-Error "git push failed"; exit 1 }

Write-Host "`n=== Done! Railway will now redeploy automatically. ===" -ForegroundColor Green
Write-Host "Watch progress at: https://railway.app/dashboard" -ForegroundColor Yellow
Write-Host "App URL: https://oasis-trace-production.up.railway.app/app/" -ForegroundColor Yellow
