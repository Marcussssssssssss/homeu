import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ms'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HomeU'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get navFavorites;

  /// No description provided for @navBookings.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @homeGreetingAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeGreetingAnonymous;

  /// No description provided for @homeGreetingWithName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreetingWithName(Object name);

  /// No description provided for @homeQuickSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next rental with a quick search.'**
  String get homeQuickSearchSubtitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search location, condo, house'**
  String get homeSearchHint;

  /// No description provided for @homeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategories;

  /// No description provided for @homeRecommendedProperties.
  ///
  /// In en, this message translates to:
  /// **'Recommended Properties'**
  String get homeRecommendedProperties;

  /// No description provided for @homeScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get homeScanQr;

  /// No description provided for @bookingHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking History'**
  String get bookingHistoryTitle;

  /// No description provided for @bookingHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your latest rental booking updates quickly.'**
  String get bookingHistorySubtitle;

  /// No description provided for @bookingDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Booking Date'**
  String get bookingDateLabel;

  /// No description provided for @rentalPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Rental Period'**
  String get rentalPeriodLabel;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave Review'**
  String get leaveReview;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get profileRoleOwner;

  /// No description provided for @profileRoleTenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get profileRoleTenant;

  /// No description provided for @profileThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileThemeTitle;

  /// No description provided for @profileThemeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Light, Dark, or System default.'**
  String get profileThemeSubtitle;

  /// No description provided for @profileLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguageTitle;

  /// No description provided for @profileLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred app language.'**
  String get profileLanguageSubtitle;

  /// No description provided for @profileUpdatePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get profileUpdatePasswordTitle;

  /// No description provided for @profileUpdatePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change your password to keep your account secure.'**
  String get profileUpdatePasswordSubtitle;

  /// No description provided for @profileEditButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditButton;

  /// No description provided for @profileLogoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogoutButton;

  /// No description provided for @profileAccountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get profileAccountDetails;

  /// No description provided for @profileFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileFieldName;

  /// No description provided for @profileFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileFieldEmail;

  /// No description provided for @profileFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profileFieldPhone;

  /// No description provided for @profileFieldRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileFieldRole;

  /// No description provided for @profileEditSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditSheetTitle;

  /// No description provided for @profileEditSheetPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Profile photo can be changed from the avatar button above.'**
  String get profileEditSheetPhotoHint;

  /// No description provided for @profileEditFieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileEditFieldFullName;

  /// No description provided for @profileEditFieldFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get profileEditFieldFullNameHint;

  /// No description provided for @profileEditFieldEmailReadonly.
  ///
  /// In en, this message translates to:
  /// **'Email (not editable)'**
  String get profileEditFieldEmailReadonly;

  /// No description provided for @profileEditFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profileEditFieldPhone;

  /// No description provided for @profileEditFieldPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get profileEditFieldPhoneHint;

  /// No description provided for @profileEditSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileEditSaveChanges;

  /// No description provided for @profileNamePhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Name and phone number are required.'**
  String get profileNamePhoneRequired;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully.'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileErrorRefresh.
  ///
  /// In en, this message translates to:
  /// **'Unable to refresh profile now. Showing available data.'**
  String get profileErrorRefresh;

  /// No description provided for @profileErrorUpdate.
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile right now. Please try again.'**
  String get profileErrorUpdate;

  /// No description provided for @profileErrorUpload.
  ///
  /// In en, this message translates to:
  /// **'Unable to upload profile photo right now. Please try again.'**
  String get profileErrorUpload;

  /// No description provided for @profileErrorLanguageSave.
  ///
  /// In en, this message translates to:
  /// **'Unable to save language preference right now. Please try again.'**
  String get profileErrorLanguageSave;

  /// No description provided for @profilePhotoChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get profilePhotoChooseGallery;

  /// No description provided for @profilePhotoChooseGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a photo from your device.'**
  String get profilePhotoChooseGallerySubtitle;

  /// No description provided for @profilePhotoTakeCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get profilePhotoTakeCamera;

  /// No description provided for @profilePhotoTakeCameraSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your camera to capture a new avatar.'**
  String get profilePhotoTakeCameraSubtitle;

  /// No description provided for @profilePhotoUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully.'**
  String get profilePhotoUpdatedSuccess;

  /// No description provided for @profilePhotoAccessError.
  ///
  /// In en, this message translates to:
  /// **'Unable to access photos right now. Please try again.'**
  String get profilePhotoAccessError;

  /// No description provided for @profileThemeSaved.
  ///
  /// In en, this message translates to:
  /// **'Theme preference saved.'**
  String get profileThemeSaved;

  /// No description provided for @profileLanguageSaved.
  ///
  /// In en, this message translates to:
  /// **'Language preference saved.'**
  String get profileLanguageSaved;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageMalay.
  ///
  /// In en, this message translates to:
  /// **'Malay'**
  String get languageMalay;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @ownerNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get ownerNavDashboard;

  /// No description provided for @ownerNavMyProperties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get ownerNavMyProperties;

  /// No description provided for @ownerNavRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get ownerNavRequests;

  /// No description provided for @ownerNavAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get ownerNavAnalytics;

  /// No description provided for @ownerDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage listings, requests, and performance from one place.'**
  String get ownerDashboardSubtitle;

  /// No description provided for @ownerAddProperty.
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get ownerAddProperty;

  /// No description provided for @ownerMonthlyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Monthly Earnings'**
  String get ownerMonthlyEarnings;

  /// No description provided for @ownerQuickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get ownerQuickStats;

  /// No description provided for @ownerActiveListings.
  ///
  /// In en, this message translates to:
  /// **'Active Listings'**
  String get ownerActiveListings;

  /// No description provided for @ownerPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending Requests'**
  String get ownerPendingRequests;

  /// No description provided for @ownerOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Occupancy'**
  String get ownerOccupancy;

  /// No description provided for @ownerMyProperties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get ownerMyProperties;

  /// No description provided for @ownerBookingRequests.
  ///
  /// In en, this message translates to:
  /// **'Booking Requests'**
  String get ownerBookingRequests;

  /// No description provided for @ownerOccupancyOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get ownerOccupancyOccupied;

  /// No description provided for @ownerOccupancyVacant.
  ///
  /// In en, this message translates to:
  /// **'Vacant'**
  String get ownerOccupancyVacant;

  /// No description provided for @ownerRequestStatusAwaitingResponse.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Response'**
  String get ownerRequestStatusAwaitingResponse;

  /// No description provided for @ownerRequestStatusNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get ownerRequestStatusNewRequest;

  /// No description provided for @ownerPropertyLabel.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get ownerPropertyLabel;

  /// No description provided for @ownerTapToReviewRequest.
  ///
  /// In en, this message translates to:
  /// **'Tap to review request'**
  String get ownerTapToReviewRequest;

  /// No description provided for @ownerBookingRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Request'**
  String get ownerBookingRequestTitle;

  /// No description provided for @ownerBookingRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review tenant details and confirm your decision quickly.'**
  String get ownerBookingRequestSubtitle;

  /// No description provided for @ownerTenantInformation.
  ///
  /// In en, this message translates to:
  /// **'Tenant Information'**
  String get ownerTenantInformation;

  /// No description provided for @ownerBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get ownerBookingDetails;

  /// No description provided for @ownerCheckInLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get ownerCheckInLabel;

  /// No description provided for @ownerDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get ownerDurationLabel;

  /// No description provided for @ownerMonthlyRentLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Rent'**
  String get ownerMonthlyRentLabel;

  /// No description provided for @ownerRequestSummary.
  ///
  /// In en, this message translates to:
  /// **'Request Summary'**
  String get ownerRequestSummary;

  /// No description provided for @ownerRequestDecisionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Decision'**
  String get ownerRequestDecisionPending;

  /// No description provided for @ownerRequestDecisionApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get ownerRequestDecisionApproved;

  /// No description provided for @ownerRequestDecisionRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get ownerRequestDecisionRejected;

  /// No description provided for @ownerDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get ownerDecision;

  /// No description provided for @ownerReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get ownerReject;

  /// No description provided for @ownerApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get ownerApprove;

  /// No description provided for @ownerAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner Analytics'**
  String get ownerAnalyticsTitle;

  /// No description provided for @ownerAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Performance overview for your rental business this month.'**
  String get ownerAnalyticsSubtitle;

  /// No description provided for @ownerStatNetEarnings.
  ///
  /// In en, this message translates to:
  /// **'Net Earnings'**
  String get ownerStatNetEarnings;

  /// No description provided for @ownerRentalTypeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Rental Type Distribution'**
  String get ownerRentalTypeDistribution;

  /// No description provided for @ownerOccupancyRate.
  ///
  /// In en, this message translates to:
  /// **'Occupancy Rate'**
  String get ownerOccupancyRate;

  /// No description provided for @ownerOccupancyRateDescription.
  ///
  /// In en, this message translates to:
  /// **'91% of your listed units are currently occupied.'**
  String get ownerOccupancyRateDescription;

  /// No description provided for @monthShortJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthShortJan;

  /// No description provided for @monthShortFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthShortFeb;

  /// No description provided for @monthShortMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthShortMar;

  /// No description provided for @monthShortApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthShortApr;

  /// No description provided for @monthShortMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthShortMay;

  /// No description provided for @monthShortJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthShortJun;

  /// No description provided for @rentalTypeCondo.
  ///
  /// In en, this message translates to:
  /// **'Condo'**
  String get rentalTypeCondo;

  /// No description provided for @rentalTypeApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get rentalTypeApartment;

  /// No description provided for @rentalTypeRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get rentalTypeRoom;

  /// No description provided for @rentalTypeLanded.
  ///
  /// In en, this message translates to:
  /// **'Landed'**
  String get rentalTypeLanded;

  /// No description provided for @formFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{fieldName} is required'**
  String formFieldRequired(Object fieldName);

  /// No description provided for @formEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get formEmailInvalid;

  /// No description provided for @formPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get formPasswordMinLength;

  /// No description provided for @formPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password and confirm password do not match'**
  String get formPasswordMismatch;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to continue your HomeU journey.'**
  String get loginSubtitle;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNewHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get loginNewHere;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful.'**
  String get loginSuccess;

  /// No description provided for @loginErrorBackendNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Backend is not initialized. Please check your Supabase configuration.'**
  String get loginErrorBackendNotInitialized;

  /// No description provided for @loginErrorIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Login could not be completed. Please try again.'**
  String get loginErrorIncomplete;

  /// No description provided for @loginErrorProfileRoleMissing.
  ///
  /// In en, this message translates to:
  /// **'Your profile role is missing. Please contact support.'**
  String get loginErrorProfileRoleMissing;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorProfileRead.
  ///
  /// In en, this message translates to:
  /// **'Unable to read your profile right now. Please try again.'**
  String get loginErrorProfileRead;

  /// No description provided for @loginErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error during login. Please try again.'**
  String get loginErrorUnexpected;

  /// No description provided for @loginErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get loginErrorInvalidCredentials;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to login right now. Please try again.'**
  String get loginErrorGeneric;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join HomeU and start your rental journey.'**
  String get registerSubtitle;

  /// No description provided for @registerNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get registerNameHint;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get registerPasswordHint;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Select Account Role'**
  String get registerSelectRole;

  /// No description provided for @registerRoleInfo.
  ///
  /// In en, this message translates to:
  /// **'Your selected role controls accessible features and navigation. To switch roles later, log out and register again under the other role.'**
  String get registerRoleInfo;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get registerBackToLogin;

  /// No description provided for @registerSuccessLocalMode.
  ///
  /// In en, this message translates to:
  /// **'Registered in local mode. Connect Supabase for real account creation.'**
  String get registerSuccessLocalMode;

  /// No description provided for @registerSuccessAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully.'**
  String get registerSuccessAccountCreated;

  /// No description provided for @registerErrorSignUpIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete sign up right now. Please try again.'**
  String get registerErrorSignUpIncomplete;

  /// No description provided for @registerErrorDuplicateEmail.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get registerErrorDuplicateEmail;

  /// No description provided for @registerErrorProfileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Account created, but profile is unavailable right now. Please try again.'**
  String get registerErrorProfileUnavailable;

  /// No description provided for @registerErrorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error during registration. Please try again.'**
  String get registerErrorUnexpected;

  /// No description provided for @registerErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again.'**
  String get registerErrorNetwork;

  /// No description provided for @registerErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign up right now. Please try again.'**
  String get registerErrorGeneric;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address and we will send you a password reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailNote.
  ///
  /// In en, this message translates to:
  /// **'Please use your real email address because the password reset link will be sent to your inbox.'**
  String get forgotPasswordEmailNote;

  /// No description provided for @forgotPasswordEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get forgotPasswordEmailAddress;

  /// No description provided for @forgotPasswordSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotPasswordSendResetLink;

  /// No description provided for @forgotPasswordCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get forgotPasswordCheckEmail;

  /// No description provided for @forgotPasswordNoEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? Check your spam folder or try again.'**
  String get forgotPasswordNoEmailHint;

  /// No description provided for @forgotPasswordSuccessDefault.
  ///
  /// In en, this message translates to:
  /// **'A password reset link has been sent to your email.'**
  String get forgotPasswordSuccessDefault;

  /// No description provided for @forgotPasswordErrorRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a while and try again.'**
  String get forgotPasswordErrorRateLimit;

  /// No description provided for @forgotPasswordErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again.'**
  String get forgotPasswordErrorNetwork;

  /// No description provided for @forgotPasswordErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset link right now. Please try again.'**
  String get forgotPasswordErrorGeneric;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingStepProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String onboardingStepProgress(int current, int total);

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Browse Rental Properties'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover rooms, houses, condos, and apartments that match your lifestyle and budget.'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get onboardingFilters;

  /// No description provided for @onboardingExampleListing1Title.
  ///
  /// In en, this message translates to:
  /// **'City Condo'**
  String get onboardingExampleListing1Title;

  /// No description provided for @onboardingExampleListing1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'2 Beds • Downtown'**
  String get onboardingExampleListing1Subtitle;

  /// No description provided for @onboardingExampleListing1Price.
  ///
  /// In en, this message translates to:
  /// **'\$1,250/mo'**
  String get onboardingExampleListing1Price;

  /// No description provided for @onboardingExampleListing2Title.
  ///
  /// In en, this message translates to:
  /// **'Cozy Studio'**
  String get onboardingExampleListing2Title;

  /// No description provided for @onboardingExampleListing2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'1 Bed • Near Campus'**
  String get onboardingExampleListing2Subtitle;

  /// No description provided for @onboardingExampleListing2Price.
  ///
  /// In en, this message translates to:
  /// **'\$780/mo'**
  String get onboardingExampleListing2Price;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'List Your Property Easily'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your property, upload photos, and manage rental requests in one place.'**
  String get onboardingStep2Subtitle;

  /// No description provided for @ownerNewListing.
  ///
  /// In en, this message translates to:
  /// **'New Listing'**
  String get ownerNewListing;

  /// No description provided for @ownerPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get ownerPropertyType;

  /// No description provided for @ownerUploadPhotos.
  ///
  /// In en, this message translates to:
  /// **'Upload Photos'**
  String get ownerUploadPhotos;

  /// No description provided for @ownerLocationAndPrice.
  ///
  /// In en, this message translates to:
  /// **'Location & Price'**
  String get ownerLocationAndPrice;

  /// No description provided for @ownerNewRentalRequests.
  ///
  /// In en, this message translates to:
  /// **'3 New Rental Requests'**
  String get ownerNewRentalRequests;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Secure Booking & Payment'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Book viewings, confirm rentals, and complete payment through a safe and simple process.'**
  String get onboardingStep3Subtitle;

  /// No description provided for @onboardingViewingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Viewing Confirmed'**
  String get onboardingViewingConfirmed;

  /// No description provided for @onboardingSecurePayment.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get onboardingSecurePayment;

  /// No description provided for @onboardingProtected.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get onboardingProtected;

  /// No description provided for @updatePasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been updated successfully.'**
  String get updatePasswordSuccessMessage;

  /// No description provided for @updatePasswordStrongPasswordTip.
  ///
  /// In en, this message translates to:
  /// **'Use a strong password with letters, numbers, and symbols.'**
  String get updatePasswordStrongPasswordTip;

  /// No description provided for @updatePasswordCurrentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get updatePasswordCurrentPasswordLabel;

  /// No description provided for @updatePasswordCurrentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get updatePasswordCurrentPasswordHint;

  /// No description provided for @updatePasswordNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get updatePasswordNewPasswordLabel;

  /// No description provided for @updatePasswordNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get updatePasswordNewPasswordHint;

  /// No description provided for @updatePasswordConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get updatePasswordConfirmPasswordLabel;

  /// No description provided for @updatePasswordConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get updatePasswordConfirmPasswordHint;

  /// No description provided for @updatePasswordValidationCurrentRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get updatePasswordValidationCurrentRequired;

  /// No description provided for @updatePasswordValidationNewRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get updatePasswordValidationNewRequired;

  /// No description provided for @updatePasswordValidationMinLength.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 6 characters'**
  String get updatePasswordValidationMinLength;

  /// No description provided for @updatePasswordValidationConfirmRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password is required'**
  String get updatePasswordValidationConfirmRequired;

  /// No description provided for @updatePasswordValidationMismatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation do not match'**
  String get updatePasswordValidationMismatch;

  /// No description provided for @updatePasswordErrorCurrentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get updatePasswordErrorCurrentPasswordIncorrect;

  /// No description provided for @updatePasswordErrorBackendNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Backend is not initialized. Please check Supabase configuration.'**
  String get updatePasswordErrorBackendNotInitialized;

  /// No description provided for @updatePasswordErrorVerifyCurrentPasswordUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify your current password right now. Please sign in again.'**
  String get updatePasswordErrorVerifyCurrentPasswordUnavailable;

  /// No description provided for @updatePasswordErrorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Reset link is invalid or expired. Please request a new password reset email.'**
  String get updatePasswordErrorSessionExpired;

  /// No description provided for @updatePasswordErrorNewPasswordMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from your current password.'**
  String get updatePasswordErrorNewPasswordMustDiffer;

  /// No description provided for @updatePasswordErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Please choose a stronger password with at least 6 characters.'**
  String get updatePasswordErrorWeakPassword;

  /// No description provided for @updatePasswordErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again.'**
  String get updatePasswordErrorNetwork;

  /// No description provided for @updatePasswordErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to update password right now. Please try again.'**
  String get updatePasswordErrorGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
