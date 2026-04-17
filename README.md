# HomeU

HomeU is a Flutter mobile app for rental discovery and property management.

## Backend Foundation (Supabase Setup)

This project now includes the Supabase initialization foundation only.
Auth features and SQLite data layer are intentionally deferred to next steps.

### Added foundation

- Environment loading via `flutter_dotenv`
- Supabase SDK setup via `supabase_flutter`
- Centralized env config in `lib/core/config/app_env.dart`
- Reusable Supabase client helper in `lib/core/supabase/app_supabase.dart`
- Basic auth/session foundation in `lib/app/auth/homeu_auth_service.dart`
- Startup session resolver scaffold in `lib/app/startup/startup_session_resolver.dart`

### Configure environment

1. Copy `.env.example` to `.env` (already scaffolded in this workspace).
2. Set your real project values:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
```

If values remain placeholders, app UI still starts, but Supabase is skipped safely.

### Run

```bash
flutter pub get
flutter run
```
