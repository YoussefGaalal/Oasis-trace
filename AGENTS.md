# Oasis Trace — Agent Context

> This file is read by OpenCode (AGENTS.md) and Claude Code (CLAUDE.md fallback).
> It gives every agent full context about the project without asking the developer to re-explain things.

---

## Project Overview

**Oasis Trace** is a multi-tenant livestock management SaaS platform.  
It tracks animals, devices (GPS collars), geofences, health records, and trading with full Arabic/English i18n support.

- **Live URL**: https://oasis-trace-production.up.railway.app/app/login  
- **GitHub**: https://github.com/YoussefGaalal/Oasis-trace  
- **Branch strategy**: `main` → production on Railway. Feature work on `develop` or `feature/*` branches.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Laravel 11, PHP 8.4 |
| Database | MySQL (Railway managed) |
| Auth | Laravel Sanctum (token-based) |
| Roles | Spatie Laravel Permission |
| Payments | Stripe |
| Frontend | React 18, Vite, Tailwind CSS |
| i18n | i18next + react-i18next (Arabic/English, RTL support) |
| Mobile | Flutter (in development) |
| Deployment | Railway (backend + frontend SPA) |
| Maps | Leaflet + react-leaflet |

---

## Repository Layout

```
oasis-trace/
├── backend/                  # Laravel 11 app — also builds the React SPA
│   ├── app/
│   │   ├── Http/Controllers/Api/   # All API controllers
│   │   ├── Http/Middleware/        # RoleMiddleware, etc.
│   │   ├── Models/                 # Eloquent models
│   │   └── Services/               # Business logic services
│   ├── database/
│   │   ├── migrations/
│   │   └── seeders/
│   ├── resources/js/               # React source (THIS is what gets compiled)
│   │   ├── App.jsx                 # Router root
│   │   ├── main.jsx                # React entry point
│   │   ├── i18n.jsx                # i18next setup + useI18n hook
│   │   ├── context/AuthContext.jsx # Auth state + useAuth hook
│   │   ├── components/             # Shared UI components
│   │   ├── pages/                  # Route-level page components
│   │   ├── hooks/                  # Custom React hooks
│   │   └── utils/api.js            # Fetch wrapper (base URL, auth headers)
│   ├── public/app/                 # Vite build output — committed to git
│   │   └── assets/                 # Hashed JS/CSS bundles
│   ├── routes/
│   │   ├── api.php                 # All /api/* routes
│   │   └── web.php                 # Catch-all → serves SPA
│   ├── vite.config.js              # base: '/app/', outDir: 'public/app'
│   ├── package.json                # Frontend dependencies
│   └── nixpacks.toml               # Railway build config
├── frontend/                 # Legacy/local dev config — NOT deployed
├── mobile/                   # Flutter app
├── AGENTS.md                 # This file (OpenCode context)
├── DEPLOYMENT_GUIDE.md
├── CONTRIBUTING.md
└── README.md
```

---

## Critical Architecture Facts

### React SPA
- The React app lives in `backend/resources/js/` — **not** `frontend/src/`
- Vite builds to `backend/public/app/` with `base: '/app/'`
- The built files are **committed to git** — Railway serves them directly
- If you change React source, you MUST rebuild and commit `backend/public/app/`
- To rebuild locally: `cd backend && npm install && npm run build`

### i18n System
- Uses `i18next` + `react-i18next` (added in the `ramy-version` merge)
- Entry: `backend/resources/js/i18n.jsx` — exports `useI18n()` hook
- `useI18n()` returns: `{ t, dir, language, changeLanguage }`
- **Do NOT use** `setLanguage`, `locale`, or `setLocale` — these are from the old system
- Translation JSON files live in `backend/resources/js/i18n/locales/`

### API Layer
- All API calls go through `backend/resources/js/utils/api.js`
- Auth token stored in localStorage as `token`
- API base URL resolves relative to the current origin

### Auth & Roles
- Roles: `super_admin`, `admin`, `vet`, `viewer`
- Protected routes use `<RoleRoute allowedRoles={[...]}>` in `App.jsx`
- Auth state managed via `useAuth()` from `context/AuthContext.jsx`

### Deployment (Railway)
- `nixpacks.toml` controls build phases
- Build: `npm install && npm run build` (PHP deps via Composer)
- Start: `php artisan migrate --force && php artisan db:seed --class=DemoDataSeeder && php artisan serve`
- Environment variables set in Railway dashboard (never commit `.env`)

---

## Team Roles

| Agent / Person | Owns |
|---------------|------|
| Tech Lead | Architecture, PR reviews, Railway setup, security |
| Backend Dev | Laravel API, migrations, seeders, PHPUnit tests |
| Frontend Dev | React components, Vite build, Playwright E2E tests |
| Flutter Dev | Mobile app (`/mobile` directory) |

---

## Coding Standards

### PHP / Laravel
- PHP 8.4, strict types preferred
- Follow PSR-12 (run `./vendor/bin/pint` before committing)
- Use type hints and return types on all methods
- API responses: always JSON with consistent `{ data, message, errors }` shape
- Use Form Request classes for validation, not inline `$request->validate()`

### JavaScript / React
- React 18, functional components + hooks only (no class components)
- Tailwind CSS for all styling — no inline styles
- Run `npm run lint` before committing
- i18n: always use `t('key')` for user-facing strings, never hardcode English
- RTL support: use `dir` from `useI18n()` on root containers

### Git
- Commit messages: `type: short description` (e.g., `fix: correct i18n hook usage`)
- PR target: `develop` for features, `main` only for production releases
- Never force-push `main`

---

## Common Pitfalls (Learned from Bugs)

1. **Blank page after deploy** — The old build is likely still in `backend/public/app/`. Rebuild and commit.
2. **`language is not defined`** — You used `language` in JSX without destructuring it from `useI18n()`.
3. **`setLanguage is not defined`** — Old i18n API. Use `changeLanguage` from `useI18n()`.
4. **Git index corruption on Windows** — Don't run `git reset --hard` from a Linux sandbox on a Windows-mounted path. Use Windows terminal (PowerShell/CMD) for git operations.
5. **Truncated files from ramy-version merge** — All files from that branch were cut off mid-content. Any file that seems to end abruptly is likely truncated — check the last few lines.
6. **LanguageSwitcher using old API** — Must import `useI18n` from `../i18n.jsx`, not the old `./index`.

---

## Running the Project Locally

```bash
# Backend API
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve        # http://localhost:8000

# Frontend (dev with hot reload)
cd backend
npm install
npm run dev              # Vite dev server at http://localhost:5173/app/

# Mobile
cd mobile
flutter pub get
flutter run
```
