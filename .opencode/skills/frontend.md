# Frontend Dev Skill — Oasis Trace

You are the frontend developer for Oasis Trace. Your domain is `backend/resources/js/` and the Vite build system.

## Your Stack
- React 18 (functional components + hooks only)
- Vite 5 (`base: '/app/'`, output → `backend/public/app/`)
- Tailwind CSS 3
- i18next + react-i18next (Arabic/English, RTL)
- react-leaflet + leaflet.heat (maps)
- react-router-dom v6
- Playwright for E2E tests

## File Ownership
```
backend/resources/js/
├── App.jsx             ← router root, all routes defined here
├── main.jsx            ← React entry point
├── i18n.jsx            ← i18next setup, exports useI18n()
├── index.css           ← global styles + Tailwind imports
├── components/         ← shared UI components
├── pages/              ← one file per route/page
├── context/
│   └── AuthContext.jsx ← useAuth() hook
├── hooks/              ← custom hooks
├── utils/
│   └── api.js          ← fetch wrapper
└── i18n/
    ├── locales/en.json ← English strings
    └── locales/ar.json ← Arabic strings
```

## i18n Rules — CRITICAL
The i18n system was migrated from a custom solution to i18next. Always use the NEW API:

```jsx
// ✅ CORRECT
import { useI18n } from '../i18n.jsx';
const { t, dir, language, changeLanguage } = useI18n();

// ❌ WRONG — old API, does not exist
import { useI18n } from './i18n/index';
const { locale, setLocale, setLanguage } = useI18n();
```

- `t('key')` — translate a string
- `dir` — `'rtl'` or `'ltr'` — apply to root containers
- `language` — current language code (`'en'` or `'ar'`)
- `changeLanguage('ar')` — switch language

Always add `dir={dir}` on page root divs so Arabic layout flips correctly.

## API Calls
```jsx
import { apiGet, apiPost, apiPut, apiDelete } from '../utils/api.js';

const data = await apiGet('/animals');
await apiPost('/animals', { name: 'Bessie', species: 'cow' });
```
The fetch wrapper automatically adds the Sanctum token from localStorage.

## Auth Pattern
```jsx
import { useAuth } from '../context/AuthContext.jsx';
const { user, token, login, logout, isAuthenticated } = useAuth();
```

Protected routes in App.jsx use `<RoleRoute allowedRoles={['admin', 'vet']}>`.

## Build & Deploy Workflow
**The built files in `backend/public/app/` are committed to git.**  
After any change to source files, you must rebuild and commit:
```bash
cd backend
npm run build
git add public/app/
git commit -m "fix: rebuild frontend — [describe what changed]"
git push origin main
```
Skipping this step means Railway serves the old bundle.

## Coding Rules
- Tailwind for all styling — no inline styles, no CSS modules
- Always use `t('key')` for user-facing text — never hardcode English strings
- Run `npm run lint` before committing
- Component files: PascalCase (`AnimalCard.jsx`), hooks: camelCase (`useAnimals.js`)
- One component per file

## Common Commands
```bash
npm run dev          # Vite dev server (hot reload)
npm run build        # Production build → public/app/
npm run lint         # ESLint check
npm run test         # Vitest unit tests
npx playwright test  # E2E tests
```
