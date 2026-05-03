# Deployment Guide — Oasis Trace (Client Preview)

**Stack:** Laravel 11 + React (Railway) · Flutter Web (Netlify)
**Cost:** Free — Railway $5 credit + Netlify free tier

---

## Part 1 — Deploy Backend + Frontend (Railway)

### Step 1: Create a Railway account
Go to [railway.app](https://railway.app) and sign up (GitHub login is easiest).

### Step 2: Push your code to GitHub
If not already on GitHub, create a repo and push the project:
```bash
cd D:\animal-trading-v2
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/oasis-trace.git
git push -u origin main
```

### Step 3: Create a new Railway project
1. In Railway dashboard → **New Project** → **Deploy from GitHub repo**
2. Select your repo
3. Railway will auto-detect PHP via Nixpacks

### Step 4: Add MySQL database
1. In your Railway project → **New Service** → **Database** → **MySQL**
2. Railway will auto-inject these env vars into your app:
   - `MYSQLHOST`, `MYSQLPORT`, `MYSQLDATABASE`, `MYSQLUSER`, `MYSQLPASSWORD`

### Step 5: Set environment variables
In Railway → your app service → **Variables**, add:

```
APP_NAME=The Oasis
APP_ENV=production
APP_DEBUG=false
APP_KEY=         ← Run: php artisan key:generate --show  (paste the output)
APP_URL=         ← Set AFTER deploy (copy from Railway's generated domain)

SESSION_DRIVER=cookie
SESSION_SECURE_COOKIE=true
CACHE_DRIVER=file
QUEUE_CONNECTION=sync
```

> Tip: Leave Twilio/WhatsApp/Stripe/Gemini empty for demo — all features gracefully disable.

### Step 6: Set the root directory
Railway needs to know the Laravel app is in `/backend`:
- In Railway app service → **Settings** → **Root Directory** → set to `backend`

### Step 7: Deploy
Click **Deploy**. Railway will:
1. Install PHP + Node dependencies
2. Build the React frontend (`npm run build` → `public/app/`)
3. Run migrations automatically on startup
4. Start the PHP server

### Step 8: Get your URL
Railway gives you a free `.railway.app` domain (e.g. `oasis-trace-production.up.railway.app`).

- **React web app:** `https://YOUR-APP.railway.app/app/`
- **API:** `https://YOUR-APP.railway.app/api/`

### Step 9: Create admin user
SSH into Railway or run via the Railway CLI:
```bash
php artisan tinker
# Then:
$user = App\Models\User::create(['name'=>'Admin','email'=>'admin@oasis.com','password'=>bcrypt('password123'),'is_active'=>true]);
$user->assignRole('Admin');
```

---

## Part 2 — Deploy Flutter Mobile Web (Netlify)

### Step 1: Install Flutter (if not installed)
[flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

### Step 2: Enable Flutter web
```bash
flutter channel stable
flutter upgrade
flutter config --enable-web
```

### Step 3: Build Flutter web
```bash
cd D:\animal-trading-v2\mobile
flutter build web --dart-define=API_URL=https://YOUR-RAILWAY-APP.railway.app/api --release
```
Output will be in `mobile/build/web/`

### Step 4: Deploy to Netlify
**Option A — Drag and drop (easiest):**
1. Go to [netlify.com](https://netlify.com) → Login → **Sites**
2. Drag the `mobile/build/web/` folder onto the deploy area
3. Done — you get a free `.netlify.app` URL

**Option B — Via GitHub (auto-deploys on push):**
1. Connect your GitHub repo to Netlify
2. Set root directory to `mobile`
3. The `netlify.toml` file handles the rest automatically
4. Update `YOUR-RAILWAY-APP` in `mobile/netlify.toml` with your actual Railway URL first

---

## Summary — What the Client Sees

| URL | What it is |
|-----|------------|
| `https://YOUR-APP.railway.app/app/` | React web dashboard |
| `https://YOUR-MOBILE.netlify.app/` | Flutter mobile app (web version) |
| `https://YOUR-APP.railway.app/api/` | REST API (for Postman testing) |

---

## Bugs Fixed Before This Deployment

The following critical issues were resolved:

1. **Removed `/fix-roles` public route** — was a public endpoint that could alter the database schema
2. **Added `auth:sanctum` to all protected routes** — animals, devices, geofences, tasks, auctions, medical records, subscriptions, admin settings
3. **Protected `/ai/chat`** — was publicly accessible with no authentication
4. **Protected `/reports`** — was publicly accessible with no authentication
5. **Removed `debug_url` from password reset response** — was leaking raw reset tokens in API responses
6. **`APP_DEBUG=false` in production** — prevents stack traces from being exposed to clients

---

## Notes for Production (Post-Demo)

- Migrate `QUEUE_CONNECTION` from `sync` to Redis + Horizon for async notifications
- Replace file cache with Redis for geofence state tracking
- Enable HTTPS-only and set `SESSION_SECURE_COOKIE=true` (already in template)
- Replace `shared_preferences` token storage in Flutter with `flutter_secure_storage`
