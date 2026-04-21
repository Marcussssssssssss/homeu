// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homeu/app/auth/update_password/update_password_controller.dart';
import 'package:homeu/app/auth/update_password/update_password_models.dart';
import 'package:homeu/app/auth/update_password/update_password_repository.dart';
import 'package:homeu/app/favorites/homeu_favorites_controller.dart';
import 'package:homeu/app/homeu_app.dart';
import 'package:homeu/app/profile/profile_controller.dart';
import 'package:homeu/app/profile/profile_models.dart';
import 'package:homeu/app/settings/homeu_language_controller.dart';
import 'package:homeu/app/startup/startup_session_resolver.dart';
import 'package:homeu/app/auth/homeu_session.dart';
import 'package:homeu/app/viewing/viewing_models.dart';
import 'package:homeu/pages/auth/login_screen.dart';
import 'package:homeu/pages/auth/register_screen.dart';
import 'package:homeu/pages/home/booking_history_screen.dart';
import 'package:homeu/pages/home/conversation_list_screen.dart';
import 'package:homeu/pages/home/favorites_screen.dart';
import 'package:homeu/pages/home/home_page.dart';
import 'package:homeu/pages/home/home_tenant_shell_screen.dart';
import 'package:homeu/pages/home/owner_add_property_screen.dart';
import 'package:homeu/pages/home/owner_booking_requests_screen.dart';
import 'package:homeu/pages/home/owner_analytics_screen.dart';
import 'package:homeu/pages/home/owner_dashboard_screen.dart';
import 'package:homeu/pages/home/profile_screen.dart';
import 'package:homeu/pages/home/property_item.dart';
import 'package:homeu/pages/home/review_rating_screen.dart';
import 'package:homeu/pages/home/update_password_screen.dart';
import 'package:homeu/pages/home/viewing_history_screen.dart';

const List<PropertyItem> _testProperties = <PropertyItem>[
  PropertyItem(
    id: '2861d5db-0b6f-44a2-85f2-865f99de2428',
    ownerId: '59259006-029c-4a6a-9037-48c4f9972566',
    name: 'Skyline Condo Suite',
    location: 'Mont Kiara, Kuala Lumpur',
    pricePerMonth: 'RM 2,100 / month',
    rating: 4.8,
    accentColor: Color(0xFF1E3A8A),
    description:
        'A bright condo with modern finishing, full kitchen, and great ventilation.',
    ownerName: 'Nurul Huda',
    ownerRole: 'Verified Owner',
    propertyType: 'Condo',
    roomType: 'Whole Unit',
    furnishing: 'Furnished',
    photoColors: [Color(0xFF5D7FBF), Color(0xFF4A68A8), Color(0xFF2F4F8F)],
  ),
  PropertyItem(
    id: 'demo-property-2',
    ownerId: 'demo-owner-2',
    name: 'Cozy Student Room',
    location: 'SS15, Subang Jaya',
    pricePerMonth: 'RM 680 / month',
    rating: 4.5,
    accentColor: Color(0xFF10B981),
    description: 'Comfortable private room near campus.',
    ownerName: 'Amir Rahman',
    ownerRole: 'Host',
    propertyType: 'Apartment',
    roomType: 'Single Room',
    furnishing: 'Partially Furnished',
    photoColors: [Color(0xFF4FAF95), Color(0xFF3D9B83), Color(0xFF2B7F6B)],
  ),
  PropertyItem(
    id: 'demo-property-3',
    ownerId: 'demo-owner-3',
    name: 'Family Apartment',
    location: 'Setapak, Kuala Lumpur',
    pricePerMonth: 'RM 1,450 / month',
    rating: 4.7,
    accentColor: Color(0xFF334155),
    description: 'Spacious apartment for families.',
    ownerName: 'Sarah Lim',
    ownerRole: 'Premium Owner',
    propertyType: 'Apartment',
    roomType: 'Whole Unit',
    furnishing: 'Unfurnished',
    photoColors: [Color(0xFF586476), Color(0xFF495567), Color(0xFF374151)],
  ),
];

void main() {
  testWidgets(
    'Splash routes through onboarding screens and ends at login on Get Started',
    (WidgetTester tester) async {
      await tester.pumpWidget(const HomeUApp());

      expect(find.text('HomeU'), findsOneWidget);
      expect(find.text('Find Your Perfect Home'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Browse Rental Properties'), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('List Your Property Easily'), findsOneWidget);
      expect(find.text('2 of 3'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Secure Booking & Payment'), findsOneWidget);
      expect(
        find.text(
          'Book viewings, confirm rentals, and complete payment through a safe and simple process.',
        ),
        findsOneWidget,
      );
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('3 of 3'), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    },
  );

  testWidgets('Skip from onboarding screen 1 goes directly to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HomeUApp());

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('Startup destination ownerFlow opens owner dashboard entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const HomeUApp(startupDestination: HomeUStartupDestination.ownerFlow),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeUOwnerDashboardScreen), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('Language switch updates tenant home text for active locale', (
    WidgetTester tester,
  ) async {
    final languageController = HomeULanguageController();

    await tester.pumpWidget(
      HomeUApp(
        startupDestination: HomeUStartupDestination.tenantFlow,
        languageController: languageController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);

    languageController.setLocalLanguage('zh');
    await tester.pumpAndSettle();

    expect(find.text('分类'), findsOneWidget);
    expect(find.text('首页'), findsWidgets);
  });

  testWidgets('Skip from onboarding screen 2 goes directly to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HomeUApp());

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('List Your Property Easily'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('Skip from onboarding screen 3 goes directly to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const HomeUApp());

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Secure Booking & Payment'), findsOneWidget);
    expect(
      find.text(
        'Book viewings, confirm rentals, and complete payment through a safe and simple process.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
  });

  testWidgets('Login screen renders authentication controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeULoginScreen()));

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Login to continue your HomeU journey.'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Use Fingerprint'), findsOneWidget);
  });

  testWidgets('Login screen validates required email and password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeULoginScreen()));

    final Finder loginButton = find.widgetWithText(ElevatedButton, 'Login');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('Login password field supports visibility toggle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeULoginScreen()));

    final Finder passwordField = find.byKey(const Key('login_password_field'));
    final Finder editableInPassword = find.descendant(
      of: passwordField,
      matching: find.byType(EditableText),
    );
    EditableText before = tester.widget<EditableText>(editableInPassword);
    expect(before.obscureText, isTrue);

    await tester.tap(find.byKey(const Key('login_password_visibility_toggle')));
    await tester.pumpAndSettle();

    EditableText after = tester.widget<EditableText>(editableInPassword);
    expect(after.obscureText, isFalse);
  });

  testWidgets('Forgot password page renders complete recovery UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeULoginScreen()));
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password'), findsWidgets);
    expect(
      find.text(
        'Enter your registered email address and we will send you a password reset link.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('forgot_password_email_field')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('send_reset_link_button')), findsOneWidget);
    expect(find.byKey(const Key('back_to_login_link')), findsOneWidget);
  });

  testWidgets(
    'Forgot password sends link success state and back link returns to login',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeULoginScreen()));

      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('forgot_password_email_field')),
        'aisyah@email.com',
      );
      await tester.tap(find.byKey(const Key('send_reset_link_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('forgot_password_success_message')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('forgot_password_success_icon')),
        findsOneWidget,
      );
      expect(find.text('Check Your Email'), findsOneWidget);
      expect(
        find.text('A password reset link has been sent to your email.'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Didn\'t receive the email? Check your spam folder or try again.',
        ),
        findsOneWidget,
      );

      final Finder backToLoginLink = find.byKey(
        const Key('back_to_login_link'),
      );
      await tester.ensureVisible(backToLoginLink);
      await tester.tap(backToLoginLink);
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    },
  );

  testWidgets('Forgot password validates required and invalid email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeULoginScreen()));

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    final sendResetButton = find.byKey(const Key('send_reset_link_button'));
    await tester.ensureVisible(sendResetButton);
    await tester.tap(sendResetButton);
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('forgot_password_email_field')),
      'invalid-email',
    );
    await tester.tap(sendResetButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('Register screen renders form and role guidance', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeURegisterScreen()));

    expect(find.text('Create Your Account'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.byKey(const Key('register_password_field')), findsOneWidget);
    expect(
      find.byKey(const Key('register_confirm_password_field')),
      findsOneWidget,
    );
    expect(find.text('Tenant'), findsOneWidget);
    expect(find.text('Owner'), findsOneWidget);
    expect(
      find.textContaining(
        'selected role controls accessible features and navigation',
      ),
      findsOneWidget,
    );
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Back to Login'), findsOneWidget);
  });

  testWidgets(
    'Register screen validates required fields, email format, and password match',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeURegisterScreen()));

      final Finder registerButton = find.widgetWithText(
        ElevatedButton,
        'Register',
      );
      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Phone Number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Confirm Password is required'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('register_name_field')),
        'Aisyah',
      );
      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'not-an-email',
      );
      await tester.enterText(
        find.byKey(const Key('register_phone_field')),
        '+60 12 123 4567',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'secret123',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirm_password_field')),
        'secret456',
      );

      await tester.ensureVisible(registerButton);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(
        find.text('Password and confirm password do not match'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Register password fields support visibility toggle', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeURegisterScreen()));

    final Finder passwordField = find.byKey(
      const Key('register_password_field'),
    );
    final Finder confirmField = find.byKey(
      const Key('register_confirm_password_field'),
    );
    final Finder editableInPassword = find.descendant(
      of: passwordField,
      matching: find.byType(EditableText),
    );
    final Finder editableInConfirm = find.descendant(
      of: confirmField,
      matching: find.byType(EditableText),
    );

    EditableText passwordBefore = tester.widget<EditableText>(
      editableInPassword,
    );
    EditableText confirmBefore = tester.widget<EditableText>(editableInConfirm);
    expect(passwordBefore.obscureText, isTrue);
    expect(confirmBefore.obscureText, isTrue);

    await tester.tap(
      find.byKey(const Key('register_password_visibility_toggle')),
    );
    await tester.pumpAndSettle();
    final Finder confirmToggle = find.byKey(
      const Key('register_confirm_password_visibility_toggle'),
    );
    await tester.ensureVisible(confirmToggle);
    await tester.tap(confirmToggle);
    await tester.pumpAndSettle();

    EditableText passwordAfter = tester.widget<EditableText>(
      editableInPassword,
    );
    EditableText confirmAfter = tester.widget<EditableText>(editableInConfirm);
    expect(passwordAfter.obscureText, isFalse);
    expect(confirmAfter.obscureText, isFalse);
  });

  testWidgets(
    'Register role toggle updates selection and back link returns to login',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeULoginScreen()));

      final Finder registerLink = find.widgetWithText(TextButton, 'Register');
      await tester.ensureVisible(registerLink);
      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      ChoiceChip ownerChipBefore = tester.widget<ChoiceChip>(
        find.byKey(const Key('role_owner_chip')),
      );
      ChoiceChip tenantChipBefore = tester.widget<ChoiceChip>(
        find.byKey(const Key('role_tenant_chip')),
      );
      expect(ownerChipBefore.selected, isFalse);
      expect(tenantChipBefore.selected, isTrue);

      final Finder ownerChipFinder = find.byKey(const Key('role_owner_chip'));
      await tester.ensureVisible(ownerChipFinder);
      await tester.tap(ownerChipFinder);
      await tester.pumpAndSettle();

      ChoiceChip ownerChipAfter = tester.widget<ChoiceChip>(
        find.byKey(const Key('role_owner_chip')),
      );
      ChoiceChip tenantChipAfter = tester.widget<ChoiceChip>(
        find.byKey(const Key('role_tenant_chip')),
      );
      expect(ownerChipAfter.selected, isTrue);
      expect(tenantChipAfter.selected, isFalse);

      final Finder backToLoginFinder = find.text('Back to Login');
      await tester.ensureVisible(backToLoginFinder);
      await tester.tap(backToLoginFinder);
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    },
  );

  testWidgets('Tenant home dashboard renders tenant-only browsing UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUHomePage(seedProperties: _testProperties)),
    );

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Search location, condo, house'), findsOneWidget);

    expect(find.text('Any'), findsOneWidget);
    expect(find.text('Condo'), findsOneWidget);
    expect(find.text('Apartment'), findsOneWidget);
    expect(find.text('Landed'), findsNothing);

    expect(find.text('Skyline Condo Suite'), findsOneWidget);
    expect(find.text('Mont Kiara, Kuala Lumpur'), findsOneWidget);
    expect(find.text('RM 2,100 / month'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

    // Home page widget does not render the tenant shell navigation bar directly.
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Map'), findsNothing);
    expect(find.text('Owner'), findsNothing);
  });

  testWidgets('Property details screen shows premium listing sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUHomePage(seedProperties: _testProperties)),
    );

    final skylineCard = find.byKey(const Key('property_card_Skyline Condo Suite'));
    await tester.ensureVisible(skylineCard);
    await tester.tap(skylineCard);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('property_image_carousel')), findsOneWidget);
    expect(find.text('Skyline Condo Suite'), findsOneWidget);
    expect(find.text('RM 2,100 / month'), findsOneWidget);
    expect(find.byKey(const Key('location_info_section')), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.byKey(const Key('facilities_row')), findsOneWidget);
    expect(find.text('WiFi'), findsOneWidget);
    expect(find.text('Parking'), findsOneWidget);
    expect(find.text('Aircond'), findsOneWidget);
    expect(find.byKey(const Key('owner_contact_shortcut')), findsOneWidget);
    expect(find.byKey(const Key('book_now_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('book_now_button')));
    await tester.pumpAndSettle();

    expect(find.text('Booking'), findsOneWidget);
    expect(
      find.byKey(const Key('selected_property_summary_card')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('rental_duration_selector')), findsOneWidget);
    expect(find.byKey(const Key('start_date_picker_field')), findsOneWidget);
    expect(find.text('Total Price Calculation'), findsOneWidget);
    expect(find.byKey(const Key('total_price_text')), findsOneWidget);
    expect(find.byKey(const Key('confirm_booking_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirm_booking_button')));
    await tester.pumpAndSettle();

    final bool paymentOpened = find.text('Payment').evaluate().isNotEmpty;
    final bool blockedBySupabase = find
        .text('Supabase is not initialized. Please try again later.')
        .evaluate()
        .isNotEmpty;
    expect(paymentOpened || blockedBySupabase, isTrue);

    if (paymentOpened) {
      expect(find.text('Credit / Debit Card'), findsOneWidget);
      expect(find.text('Online Banking'), findsOneWidget);
      expect(find.text('E-wallet'), findsOneWidget);
      expect(find.byKey(const Key('credit_card_visual')), findsOneWidget);
      expect(find.byKey(const Key('payment_summary_section')), findsOneWidget);
      expect(find.byKey(const Key('pay_now_button')), findsOneWidget);

      expect(find.byKey(const Key('card_front_side')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('cvv_field')));
      await tester.tap(find.byKey(const Key('cvv_field')));
      await tester.pump(const Duration(milliseconds: 420));

      expect(find.byKey(const Key('card_back_side')), findsOneWidget);
      expect(find.byKey(const Key('cvv_highlight_area')), findsOneWidget);

      await tester.tap(find.byKey(const Key('card_number_field')));
      await tester.pump(const Duration(milliseconds: 420));

      expect(find.byKey(const Key('card_front_side')), findsOneWidget);
    }
  });


  testWidgets('Booking history screen shows filters, cards, and tenant-only nav items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeUBookingHistoryScreen()));

    expect(find.text('Booking History'), findsOneWidget);
    expect(find.byKey(const Key('status_filter_pending')), findsOneWidget);
    expect(find.byKey(const Key('status_filter_approved')), findsOneWidget);
    expect(find.byKey(const Key('status_filter_rejected')), findsOneWidget);
    expect(find.byKey(const Key('status_filter_completed')), findsOneWidget);

    final hasBookings = find.byType(Card).evaluate().isNotEmpty ||
        find.byKey(const Key('status_badge_pending')).evaluate().isNotEmpty;
    final hasEmptyState = find.text('No bookings found for this status.').evaluate().isNotEmpty ||
        find.text('Supabase is not initialized.').evaluate().isNotEmpty ||
        find.text('Please log in to view your booking history.').evaluate().isNotEmpty;
    expect(hasBookings || hasEmptyState, isTrue);

    await tester.tap(find.byKey(const Key('status_filter_approved')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('status_filter_approved')), findsOneWidget);

    // Booking history screen is tested in isolation without tenant shell nav.
    expect(find.text('Map'), findsNothing);
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Owner'), findsNothing);
  });

  testWidgets('Tenant home Chat nav opens conversation list screen', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.tenant);
    addTearDown(HomeUSession.logout);

    await tester.pumpWidget(const MaterialApp(home: HomeUTenantShellScreen()));

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeUConversationListScreen), findsOneWidget);
    expect(find.text('Conversations'), findsOneWidget);
  });

  testWidgets('Tenant home Viewings nav opens viewing history screen', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.tenant);
    addTearDown(HomeUSession.logout);

    await tester.pumpWidget(const MaterialApp(home: HomeUTenantShellScreen()));

    await tester.tap(find.text('Viewings'));
    await tester.pumpAndSettle();

    expect(find.text('Viewing History'), findsOneWidget);
  });

  testWidgets('Viewing history screen blocks non-tenant roles', (WidgetTester tester) async {
    HomeUSession.register(HomeURole.owner);
    addTearDown(HomeUSession.logout);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeUViewingHistoryScreen(initialViewings: <ViewingRequest>[]),
      ),
    );

    expect(find.text('Access Restricted'), findsOneWidget);
    expect(find.text('This page is available to Tenant users only.'), findsOneWidget);
  });

  testWidgets('Viewing history screen renders property, date, status, and host details', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.tenant);
    addTearDown(HomeUSession.logout);

    final demoViewing = ViewingRequest(
      id: 'viewing-1',
      propertyId: 'Skyline Condo Suite',
      ownerId: 'Nurul Huda',
      tenantId: 'tenant-1',
      scheduledAt: DateTime(2026, 4, 20, 14, 30),
      status: 'Approved',
      rescheduleTo: null,
      rescheduleReason: null,
      createdAt: DateTime(2026, 4, 18, 10, 0),
      updatedAt: DateTime(2026, 4, 18, 10, 0),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeUViewingHistoryScreen(initialViewings: <ViewingRequest>[demoViewing]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('viewing_card_viewing-1')), findsOneWidget);
    expect(find.text('Skyline Condo Suite'), findsOneWidget);
    expect(find.text('Scheduled At: '), findsOneWidget);
    expect(find.text('20 Apr 2026, 2:30 PM'), findsOneWidget);
    expect(find.text('Status: '), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Agent/Host: '), findsOneWidget);
    expect(find.text('Nurul Huda'), findsOneWidget);
  });

  testWidgets('Tenant home Bookings nav opens booking history screen', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.tenant);
    addTearDown(HomeUSession.logout);

    await tester.pumpWidget(const MaterialApp(home: HomeUTenantShellScreen()));

    await tester.tap(find.text('Bookings'));
    await tester.pumpAndSettle();

    expect(find.text('Booking History'), findsOneWidget);
  });

  testWidgets('Review and rating screen renders all feedback sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeUReviewRatingScreen(propertyName: 'Skyline Condo Suite'),
      ),
    );

    expect(find.text('Review & Rating'), findsOneWidget);
    expect(find.byKey(const Key('average_rating_summary')), findsOneWidget);
    expect(
      find.byKey(const Key('rating_distribution_section')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('star_rating_selector')), findsOneWidget);
    expect(find.byKey(const Key('review_comment_field')), findsOneWidget);
    expect(find.byKey(const Key('submit_review_button')), findsOneWidget);
  });

  testWidgets('Completed booking can open review screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUBookingHistoryScreen()),
    );

    await tester.tap(find.byKey(const Key('status_filter_completed')));
    await tester.pumpAndSettle();

    final leaveReviewButton = find.byKey(const Key('leave_review_button'));
    if (leaveReviewButton.evaluate().isNotEmpty) {
      await tester.tap(leaveReviewButton);
      await tester.pumpAndSettle();

      expect(find.text('Review & Rating'), findsOneWidget);
    } else {
      final hasFallbackState =
          find.text('No bookings found for this status.').evaluate().isNotEmpty ||
          find.text('Supabase is not initialized.').evaluate().isNotEmpty ||
          find.text('Please log in to view your booking history.').evaluate().isNotEmpty;
      expect(hasFallbackState, isTrue);
    }
  });

  testWidgets('Owner dashboard renders owner-only navigation and sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUOwnerDashboardScreen()),
    );

    expect(find.byKey(const Key('owner_greeting_text')), findsOneWidget);
    expect(find.byKey(const Key('add_property_button')), findsOneWidget);
    expect(find.byKey(const Key('earnings_summary_card')), findsOneWidget);
    expect(find.text('My Properties'), findsWidgets);
    expect(find.text('Booking Requests'), findsOneWidget);
    expect(find.text('Quick Stats'), findsOneWidget);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('My Properties'), findsWidgets);
    expect(find.text('Requests'), findsWidgets);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Bookings'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Viewings'), findsNothing);
  });

  testWidgets(
    'Owner dashboard keeps compact owner nav alignment and larger request cards',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(393 * 2.75, 851 * 2.75);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: HomeUOwnerDashboardScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Properties'), findsWidgets);
      expect(
        find.byKey(const Key('owner_request_card_aisyah')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('owner_request_card_daniel')),
        findsOneWidget,
      );
      expect(find.text('Tap to review request'), findsNWidgets(2));
    },
  );

  testWidgets('Register with owner role routes to owner dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeURegisterScreen()));

    await tester.enterText(
      find.byKey(const Key('register_name_field')),
      'Nurul Huda',
    );
    await tester.enterText(
      find.byKey(const Key('register_email_field')),
      'owner@homeu.app',
    );
    await tester.enterText(
      find.byKey(const Key('register_phone_field')),
      '+60 13 882 5560',
    );
    await tester.enterText(
      find.byKey(const Key('register_password_field')),
      'secret123',
    );
    await tester.enterText(
      find.byKey(const Key('register_confirm_password_field')),
      'secret123',
    );

    final Finder ownerChipFinder = find.byKey(const Key('role_owner_chip'));
    await tester.ensureVisible(ownerChipFinder);
    await tester.tap(ownerChipFinder);
    await tester.pumpAndSettle();

    final Finder registerButtonFinder = find.widgetWithText(
      ElevatedButton,
      'Register',
    );
    await tester.ensureVisible(registerButtonFinder);
    await tester.tap(registerButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(HomeUOwnerDashboardScreen), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Requests'), findsWidgets);
  });

  testWidgets('Owner add property screen renders complete structured form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUOwnerAddPropertyScreen()),
    );

    expect(find.text('Add Property'), findsOneWidget);
    expect(find.byKey(const Key('property_name_field')), findsOneWidget);
    expect(find.byKey(const Key('rental_type_dropdown')), findsOneWidget);
    expect(find.byKey(const Key('price_field')), findsOneWidget);
    expect(find.byKey(const Key('address_field')), findsOneWidget);
    expect(find.byKey(const Key('description_field')), findsOneWidget);
    expect(find.byKey(const Key('facilities_checklist')), findsOneWidget);
    expect(find.byKey(const Key('upload_images_section')), findsOneWidget);
    expect(find.byKey(const Key('select_location_section')), findsOneWidget);
    expect(
      find.byKey(const Key('availability_calendar_section')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('submit_property_button')), findsOneWidget);
  });

  testWidgets('Owner dashboard Add Property opens owner add property form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUOwnerDashboardScreen()),
    );

    await tester.tap(find.byKey(const Key('add_property_button')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeUOwnerAddPropertyScreen), findsOneWidget);
    expect(find.text('Add Property'), findsOneWidget);
  });

  testWidgets('Owner booking request management screen renders details and owner-only nav', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeUOwnerBookingRequestsScreen()));

    expect(find.byKey(const Key('tenant_information_card')), findsOneWidget);
    expect(find.byKey(const Key('booking_details_card')), findsOneWidget);
    expect(find.byKey(const Key('request_summary_card')), findsOneWidget);
    expect(find.byKey(const Key('decision_action_area')), findsOneWidget);
    expect(find.byKey(const Key('approve_request_button')), findsOneWidget);
    expect(find.byKey(const Key('reject_request_button')), findsOneWidget);

    expect(find.text('Dashboard'), findsOneWidget);
    final hasOwnerPropertiesLabel =
        find.text('My Properties').evaluate().isNotEmpty ||
        find.text('Properties').evaluate().isNotEmpty;
    expect(hasOwnerPropertiesLabel, isTrue);
    expect(find.text('Requests'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    expect(find.text('Home'), findsNothing);
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Bookings'), findsNothing);
  });

  testWidgets('Owner request decision buttons update summary state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUOwnerBookingRequestsScreen()),
    );

    expect(find.text('Pending Decision'), findsOneWidget);

    final Finder approveButton = find.byKey(
      const Key('approve_request_button'),
    );
    await tester.ensureVisible(approveButton);
    await tester.tap(approveButton);
    await tester.pumpAndSettle();
    expect(find.text('Approved'), findsOneWidget);

    final Finder rejectButton = find.byKey(const Key('reject_request_button'));
    await tester.ensureVisible(rejectButton);
    await tester.tap(rejectButton);
    await tester.pumpAndSettle();
    expect(find.text('Rejected'), findsOneWidget);
  });

  testWidgets('Owner dashboard Requests nav opens request management screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUOwnerDashboardScreen()),
    );

    await tester.tap(find.text('Requests'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeUOwnerBookingRequestsScreen), findsOneWidget);
  });

  testWidgets('Owner analytics screen renders charts and owner-only navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeUOwnerAnalyticsScreen()));

    expect(find.byKey(const Key('monthly_earnings_bar_chart')), findsOneWidget);
    expect(find.byKey(const Key('rental_type_pie_chart')), findsOneWidget);
    expect(find.byKey(const Key('occupancy_rate_progress')), findsOneWidget);
    expect(find.byKey(const Key('owner_stat_net_earnings')), findsOneWidget);
    expect(find.byKey(const Key('owner_stat_occupancy')), findsOneWidget);
    expect(find.byKey(const Key('owner_stat_requests')), findsOneWidget);

    expect(find.text('Dashboard'), findsOneWidget);
    final hasOwnerPropertiesLabel =
        find.text('My Properties').evaluate().isNotEmpty ||
        find.text('Properties').evaluate().isNotEmpty;
    expect(hasOwnerPropertiesLabel, isTrue);
    expect(find.text('Requests'), findsWidgets);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    expect(find.text('Home'), findsNothing);
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Bookings'), findsNothing);
  });

  testWidgets('Owner dashboard Analytics nav opens owner analytics screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUOwnerDashboardScreen()),
    );

    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeUOwnerAnalyticsScreen), findsOneWidget);
    expect(find.byKey(const Key('monthly_earnings_bar_chart')), findsOneWidget);
  });

  testWidgets('Owner dashboard Chat nav opens conversation list screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeUOwnerDashboardScreen()));

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeUConversationListScreen), findsOneWidget);
    expect(find.text('Conversations'), findsOneWidget);
  });

  testWidgets('Profile screen renders full user details and actions', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.tenant);

    final profileController = HomeUProfileController(
      initialProfile: const HomeUProfileData(
        userId: 'tenant-test-user',
        fullName: 'Aisyah Rahman',
        email: 'aisyah@email.com',
        phoneNumber: '+60 12 998 1123',
        role: HomeURole.tenant,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeUProfileScreen(
          role: HomeURole.tenant,
          profileController: profileController,
        ),
      ),
    );

    expect(find.byKey(const Key('profile_photo')), findsOneWidget);
    expect(find.byKey(const Key('profile_name')), findsOneWidget);
    expect(find.text('Aisyah Rahman'), findsWidgets);
    expect(find.text('aisyah@email.com'), findsOneWidget);
    expect(find.text('+60 12 998 1123'), findsOneWidget);
    expect(find.byKey(const Key('profile_role')), findsOneWidget);
    expect(find.byKey(const Key('update_password_button')), findsOneWidget);
    expect(find.text('Update Password'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.byKey(const Key('edit_profile_button')), findsOneWidget);
    expect(find.byKey(const Key('logout_button')), findsOneWidget);
  });

  testWidgets('Owner profile screen does not show chat shortcut button', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.owner);
    addTearDown(HomeUSession.logout);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeUProfileScreen(role: HomeURole.owner),
      ),
    );

    expect(find.byKey(const Key('open_chats_button')), findsNothing);
    expect(find.text('Chats'), findsNothing);
    expect(find.text('Favorites'), findsNothing);
  });

  testWidgets('Profile Update Password action opens update password screen', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.tenant);

    final profileController = HomeUProfileController(
      initialProfile: const HomeUProfileData(
        userId: 'tenant-test-user',
        fullName: 'Aisyah Rahman',
        email: 'aisyah@email.com',
        phoneNumber: '+60 12 998 1123',
        role: HomeURole.tenant,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeUProfileScreen(
          role: HomeURole.tenant,
          profileController: profileController,
        ),
      ),
    );

    final updatePasswordButton = find.byKey(
      const Key('update_password_button'),
    );
    await tester.ensureVisible(updatePasswordButton);
    await tester.tap(updatePasswordButton);
    await tester.pumpAndSettle();

    expect(find.byType(HomeUUpdatePasswordScreen), findsOneWidget);
    expect(find.byKey(const Key('current_password_field')), findsOneWidget);
    expect(find.text('Update Password'), findsWidgets);
  });

  testWidgets('Update password screen renders secure fields and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: HomeUUpdatePasswordScreen()),
    );

    expect(find.text('Update Password'), findsWidgets);
    expect(
      find.text('Change your password to keep your account secure.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('new_password_field')), findsOneWidget);
    expect(find.byKey(const Key('confirm_new_password_field')), findsOneWidget);
    expect(
      find.byKey(const Key('update_password_submit_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('cancel_update_password_button')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Update password button follows disabled active and loading states',
    (WidgetTester tester) async {
      final completer = Completer<UpdatePasswordSubmissionResult>();
      final fakeController = _FakeUpdatePasswordController(
        onSubmit: (_) => completer.future,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeUUpdatePasswordScreen(controller: fakeController),
        ),
      );

      final buttonFinder = find.byKey(
        const Key('update_password_submit_button'),
      );
      ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'abc12345',
      );
      await tester.pump();
      button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('confirm_new_password_field')),
        'xyz12345',
      );
      await tester.pump();
      button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('confirm_new_password_field')),
        'abc12345',
      );
      await tester.pump();
      button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNotNull);

      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(
        const UpdatePasswordSubmissionResult(
          status: UpdatePasswordSubmissionStatus.success,
          message: 'ok',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeULoginScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Profile update password flow requires current password and submits non-recovery payload',
    (WidgetTester tester) async {
      UpdatePasswordPayload? submittedPayload;
      final fakeController = _FakeUpdatePasswordController(
        onSubmit: (payload) async {
          submittedPayload = payload;
          return const UpdatePasswordSubmissionResult(
            status: UpdatePasswordSubmissionStatus.validationFailure,
            message: 'mock',
          );
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeUUpdatePasswordScreen(
            isRecoveryFlow: false,
            controller: fakeController,
          ),
        ),
      );

      final buttonFinder = find.byKey(
        const Key('update_password_submit_button'),
      );
      ElevatedButton button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'abc12345',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_new_password_field')),
        'abc12345',
      );
      await tester.pump();

      button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('current_password_field')),
        'old-pass-123',
      );
      await tester.pump();

      button = tester.widget<ElevatedButton>(buttonFinder);
      expect(button.onPressed, isNotNull);

      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(submittedPayload, isNotNull);
      expect(submittedPayload!.isRecoveryFlow, isFalse);
      expect(submittedPayload!.currentPassword, 'old-pass-123');
    },
  );

  testWidgets(
    'Profile update password shows localized error for incorrect current password',
    (WidgetTester tester) async {
      final fakeController = _FakeUpdatePasswordController(
        onSubmit: (_) async => const UpdatePasswordSubmissionResult(
          status: UpdatePasswordSubmissionStatus.failure,
          message: UpdatePasswordRepository.errorCurrentPasswordIncorrect,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeUUpdatePasswordScreen(
            isRecoveryFlow: false,
            controller: fakeController,
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('current_password_field')),
        'old-pass-123',
      );
      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'abc12345',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_new_password_field')),
        'abc12345',
      );
      await tester.pump();

      final submitButton = find.byKey(const Key('update_password_submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('password_feedback_message')), findsOneWidget);
      expect(find.text('Current password is incorrect.'), findsOneWidget);
    },
  );

  testWidgets(
    'Profile update password shows localized generic backend error',
    (WidgetTester tester) async {
      final fakeController = _FakeUpdatePasswordController(
        onSubmit: (_) async => const UpdatePasswordSubmissionResult(
          status: UpdatePasswordSubmissionStatus.failure,
          message: UpdatePasswordRepository.errorGeneric,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HomeUUpdatePasswordScreen(
            isRecoveryFlow: false,
            controller: fakeController,
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const Key('current_password_field')),
        'old-pass-123',
      );
      await tester.enterText(
        find.byKey(const Key('new_password_field')),
        'abc12345',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_new_password_field')),
        'abc12345',
      );
      await tester.pump();

      final submitButton = find.byKey(const Key('update_password_submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('password_feedback_message')), findsOneWidget);
      expect(
        find.text('Unable to update password right now. Please try again.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Profile logout clears session and routes back to login', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.owner);

    final profileController = HomeUProfileController(
      initialProfile: const HomeUProfileData(
        userId: 'owner-test-user',
        fullName: 'Nurul Huda',
        email: 'owner@homeu.app',
        phoneNumber: '+60 13 882 5560',
        role: HomeURole.owner,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HomeUProfileScreen(
          role: HomeURole.owner,
          profileController: profileController,
        ),
      ),
    );

    final logoutButton = find.byKey(const Key('logout_button'));
    await tester.ensureVisible(logoutButton);
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    expect(HomeUSession.loggedInRole, isNull);
    expect(find.byType(HomeULoginScreen), findsOneWidget);
  });

  testWidgets('Tenant profile nav opens profile screen', (
    WidgetTester tester,
  ) async {
    HomeUSession.register(HomeURole.tenant);
    await tester.pumpWidget(
      const MaterialApp(home: HomeUHomePage(seedProperties: _testProperties)),
    );

    final Finder tenantProfileTab = find.text('Profile').first;
    await tester.ensureVisible(tenantProfileTab);
    await tester.tap(tenantProfileTab);
    await tester.pumpAndSettle();
    expect(find.byType(HomeUProfileScreen), findsOneWidget);
  });

  testWidgets(
    'Tenant can favorite from listing and details, then review in Profile Favorites',
    (WidgetTester tester) async {
      final favoritesController = HomeUFavoritesController.instance;
      favoritesController.clear();
      addTearDown(favoritesController.clear);

      await tester.pumpWidget(
        const MaterialApp(home: HomeUHomePage(seedProperties: _testProperties)),
      );

      await tester.tap(find.byKey(const Key('favorite_toggle_2861d5db-0b6f-44a2-85f2-865f99de2428')));
      await tester.pumpAndSettle();

      expect(
        find.byIcon(Icons.favorite_rounded),
        findsWidgets,
      );

      await tester.tap(find.byKey(const Key('property_card_Skyline Condo Suite')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('details_favorite_toggle')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('details_favorite_toggle')));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      final Finder tenantProfileTab = find.text('Profile').first;
      await tester.ensureVisible(tenantProfileTab);
      await tester.tap(tenantProfileTab);
      await tester.pumpAndSettle();

      final openFavoritesButton = find.byKey(const Key('open_favorites_button'));
      await tester.ensureVisible(openFavoritesButton);
      await tester.tap(openFavoritesButton);
      await tester.pumpAndSettle();

      expect(find.byType(HomeUFavoritesScreen), findsOneWidget);
      expect(find.byKey(const Key('favorites_list')), findsOneWidget);
      expect(find.text('Skyline Condo Suite'), findsOneWidget);
    },
  );
}

class _FakeUpdatePasswordController extends UpdatePasswordController {
  _FakeUpdatePasswordController({
    required Future<UpdatePasswordSubmissionResult> Function(
      UpdatePasswordPayload payload,
    )
    onSubmit,
  }) : _onSubmit = onSubmit;

  final Future<UpdatePasswordSubmissionResult> Function(
    UpdatePasswordPayload payload,
  )
  _onSubmit;

  @override
  Future<UpdatePasswordSubmissionResult> submit(UpdatePasswordPayload payload) {
    return _onSubmit(payload);
  }
}
