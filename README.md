# HomeU

HomeU is a Flutter mobile app for rental discovery and property management.

## Backend and Auth

This project uses Supabase for authentication and profile-role lookup.
Current flow is configured for direct email/password sign up and login (Confirm Email disabled).

### Implemented

- Environment loading via `flutter_dotenv`
- Supabase SDK setup via `supabase_flutter`
- Centralized env config in `lib/core/config/app_env.dart`
- Reusable Supabase client helper in `lib/core/supabase/app_supabase.dart`
- Register flow with duplicate email handling (`This email is already in use.`)
- Login flow with role-based routing (`tenant` / `owner`)
- Session restore via `lib/app/startup/startup_session_resolver.dart`
- Forgot password and update password flows

### Configure environment

1. Copy `.env.example` to `.env` (already scaffolded in this workspace).
2. Set your real project values:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_PASSWORD_RESET_REDIRECT_URL=homeu://auth/reset
```

If values remain placeholders, app UI still starts, but Supabase is skipped safely.

### Run

```bash
flutter pub get
flutter run
```

### Property Report RLS (Supabase)

`public.property_reports` insert requires an authenticated tenant and `tenant_id = auth.uid()`.

```sql
-- Allow authenticated users to insert reports only for themselves.
create policy "tenant_can_insert_own_property_report"
on public.property_reports
for insert
to authenticated
with check (tenant_id = auth.uid());
```

