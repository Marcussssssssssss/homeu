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

## Chat & Conversation History Entry Points

Current UI entry points for chat are:

- `lib/pages/home/property_details_screen.dart`
  - `OutlinedButton` with key `chat_with_owner_button` and label **Chat with Owner**.
  - `IconButton` with key `owner_contact_shortcut` and chat icon.
  - Both navigate with:
    - `Navigator.of(context).push(MaterialPageRoute(...))`
    - destination: `HomeUChatScreen.start(property: property)`
  - Flow: **Property details** → **Chat screen** (starts/loads a conversation from the selected `PropertyItem`).

- `lib/pages/home/profile_screen.dart`
  - `OutlinedButton` with key `open_chats_button` and label **Chats** (shown for `HomeURole.owner`).
  - Navigates with:
    - `Navigator.of(context).push(MaterialPageRoute(...))`
    - destination: `const HomeUConversationListScreen()`
  - Flow: **Owner profile** → **Conversation list/history**.

- `lib/pages/home/conversation_list_screen.dart`
  - Each conversation `ListTile` is tappable.
  - Navigates with:
    - `Navigator.of(context).push(MaterialPageRoute(...))`
    - destination: `HomeUChatScreen.fromConversation(conversation: conversation)`
  - Flow: **Conversation list/history** → **Chat screen** for the selected conversation.

### Route registration note

Chat navigation currently uses direct `MaterialPageRoute` pushes, so no `MaterialApp.routes` or `onGenerateRoute` registration is required for these flows.
