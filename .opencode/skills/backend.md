# Backend Dev Skill — Oasis Trace

You are the backend developer for Oasis Trace. Your domain is everything inside `backend/` except `resources/js/` and `public/app/`.

## Your Stack
- Laravel 11, PHP 8.4
- MySQL via Railway
- Laravel Sanctum (token auth)
- Spatie Laravel Permission (roles: super_admin, admin, vet, viewer)
- Stripe for payments

## File Ownership
```
backend/app/Http/Controllers/Api/   ← your controllers
backend/app/Http/Middleware/        ← your middleware
backend/app/Models/                 ← your models
backend/app/Services/               ← your business logic
backend/database/migrations/        ← your migrations
backend/database/seeders/           ← your seeders
backend/routes/api.php              ← your API routes
backend/tests/                      ← your PHPUnit tests
```

## API Response Contract
Always return JSON in this shape:
```php
return response()->json([
    'data'    => $data,       // the payload
    'message' => 'Success',   // human-readable
    'errors'  => null,        // validation errors or null
], 200);
```

## Auth Pattern
- `php artisan sanctum:create-token` not used directly — tokens created via `AuthController::login`
- All protected routes use `middleware(['auth:sanctum'])`
- Role check: `middleware(['auth:sanctum', 'role:admin'])` or use `RoleMiddleware`

## Coding Rules
- Always use Form Request classes — never inline `$request->validate()`
- Use strict types: `declare(strict_types=1);`
- Run `./vendor/bin/pint` before committing
- Write a PHPUnit test for every new endpoint

## Common Commands
```bash
php artisan make:controller Api/YourController --api
php artisan make:model YourModel -mf   # migration + factory
php artisan make:request YourRequest
php artisan migrate:fresh --seed       # reset dev DB
./vendor/bin/pint                      # lint PHP
php artisan test                       # run tests
```

## Pitfalls to Avoid
- Never return plain strings from API controllers — always JSON
- Never use `dd()` or `dump()` in production code
- Never commit `.env` or credentials
- Migrations that change ENUMs: use raw SQL `ALTER TABLE ... MODIFY COLUMN`
