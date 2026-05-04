<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RoleMiddleware
{
    public function handle(Request $request, Closure $next, string $roles): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json(['error' => 'Unauthenticated'], 401);
        }

        $allowedRoles = array_map('trim', explode(',', $roles));

        if ($user->hasAnyRole($allowedRoles)) {
            return $next($request);
        }

        return response()->json([
            'error' => 'Forbidden',
            'message' => 'You do not have permission to access this resource.',
        ], 403);
    }
}
