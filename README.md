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

## Module 3 (Booking, Viewing & Payment) Audit Snapshot

### Feature progress map

| Feature | Status | Evidence |
|---|---|---|
| In-app enquiry / chat with owner | **Implemented** | `lib/pages/home/chat_screen.dart`, `lib/pages/home/conversation_list_screen.dart`, `lib/app/chat/chat_remote_datasource.dart` |
| Schedule viewing session | **Implemented** | `lib/pages/home/viewing_screen.dart`, `lib/app/viewing/viewing_remote_datasource.dart#createViewingRequest` |
| Viewing reservation | **Implemented** | `HomeUViewingScreen._confirmViewing`, `viewing_requests` insert in `viewing_remote_datasource.dart` |
| Reschedule viewing request | **Implemented** | `lib/pages/home/viewing_history_screen.dart#_handleReschedule`, `requestReschedule()` |
| Send booking request | **Implemented** | `lib/pages/home/booking_screen.dart#_confirmBooking`, `booking_remote_datasource.dart#createBooking` |
| View booking status | **Partial** | Status shown in booking history cards only (`booking_history_screen.dart`) |
| View booking history | **Implemented** | `lib/pages/home/booking_history_screen.dart`, `getUserBookings()` |
| Cancel booking request | **Partial** | API exists (`cancelBookingIfPending`) but no tenant UI action in booking history |
| View billing summary | **Partial** | Payment summary section only in payment page (`payment_screen.dart`), no standalone billing screen |
| Select payment method (Card / E-Wallet / Online Banking) | **Implemented** | `HomeUPaymentMethod`, method tiles in `lib/pages/home/payment_screen.dart` |
| View payment status | **Partial** | Latest payment status shown in payment summary only (`_loadLatestPayment`) |
| Generate receipt / invoice | **Not started** | No receipt/invoice model/screen/export flow found |
| Simulated payment workflow (advanced) | **Implemented** | `payment_remote_datasource.dart#createPaymentSimulated` |
| QR code for booking/viewing confirmation (advanced) | **Partial** | Home FAB scan entry exists (`home_page.dart`), no generation/verification flow |

### Defects / gaps and improvement opportunities

- **UI/UX consistency**
  - Viewing history previously lacked booking-style status filters and tenant nav consistency; now aligned in `viewing_history_screen.dart`.
  - Booking history has no cancel action although backend supports pending cancellation.
- **State management / loading / empty / error**
  - Repeated in-widget async and state logic across booking/viewing/chat screens; introduce shared view-model/controller pattern.
  - Errors are mostly generic strings without retry affordances.
- **Data validation / formatting**
  - Date/currency formatting is hand-rolled in multiple files (`booking_screen.dart`, `payment_screen.dart`, `viewing_screen.dart`, `booking_history_screen.dart`).
  - Payment card fields are UI-only with no format validation/masking.
- **Architecture / code quality**
  - Feature logic, data access, and UI are tightly coupled in pages; move business flows to controllers/use-cases.
  - Status strings are raw and duplicated; define shared status enums + mapper utilities.
- **Security (payment simulation)**
  - Ensure simulated mode is clearly labeled and cannot be confused with real processing.
  - Avoid logging sensitive payment input; keep transaction refs server-traceable and non-sequential (already randomized).

### Professional completion plan (milestones)

- [ ] **M1: Domain and architecture hardening (1-2 days)**
  - [ ] Introduce shared status/value formatters and central error mapper.
  - [ ] Move booking/viewing/payment/chat actions into controllers/use-cases.
  - **Acceptance:** UI pages become orchestration-only; no duplicated status/date/currency formatter logic.
- [ ] **M2: Booking and viewing completion (1-2 days)**
  - [ ] Add tenant cancel booking action with confirmation and optimistic refresh.
  - [ ] Add booking status detail drill-down (request timeline + owner response).
  - [ ] Add viewing reschedule/cancel guardrails (disable invalid transitions).
  - **Acceptance:** Pending booking can be cancelled from UI and reflected in history/status.
- [ ] **M3: Payment completion (2 days)**
  - [ ] Add payment result screen and standalone billing summary (line items + status + transaction reference).
  - [ ] Add method-specific simulated validation (card format, expiry, CVV length, e-wallet/banking required fields).
  - **Acceptance:** Payment workflow returns deterministic success/failure states with clear status history.
- [ ] **M4: Receipt/invoice + QR confirmation (2-3 days)**
  - [ ] Generate in-app receipt/invoice view with share/export support.
  - [ ] Generate booking/viewing QR payload and add scanner verification handling.
  - **Acceptance:** User can open/download receipt and present QR for booking/viewing confirmation.
- [ ] **M5: Testing, QA, and release readiness (1-2 days)**
  - [ ] Unit tests: status mappers, validators, formatters, payment simulation branching.
  - [ ] Widget tests: booking cancel flow, viewing filter/reschedule transitions, payment method validation.
  - [ ] Integration tests: booking → payment → history, viewing schedule → reschedule/cancel, chat send/list.
  - [ ] QA checklist: loading/empty/error states, localization text, role-based access, offline failure messaging.
  - [ ] Documentation updates: module API contracts, status state machine, simulation guardrails, test matrix.
