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

## Grant Copilot access to scan this repo (main branch)

If you want Copilot to scan `Marcussssssssssss/homeu` and locate where the chat button/navigation entry point is implemented:

1. Make sure the repository is **public**  
   **or** add `TiuKaiHann` as a collaborator with read access:
   - GitHub repo → **Settings** → **Collaborators and teams** → **Add people** → `TiuKaiHann`
2. Confirm the **GitHub Copilot/Copilot coding agent app** is installed and has access to this repository:
   - GitHub → **Settings** → **Applications** → **Installed GitHub Apps** → Copilot-related app
   - Ensure repository access includes `Marcussssssssssss/homeu`
3. Ensure access is for the **main branch** (or share the exact branch/commit to scan).

### If you cannot grant access

Run this locally and paste the output:

```bash
cd /path/to/homeu
git checkout main
git pull
rg -n "chat|message|conversation|bottomnavigationbar|navigation|nav" lib
```
