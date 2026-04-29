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

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect Home'**
  String get splashTagline;

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

  /// No description provided for @profileRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get profileRoleAdmin;

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

  /// No description provided for @profileFieldAccountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get profileFieldAccountStatus;

  /// No description provided for @profileFieldRiskStatus.
  ///
  /// In en, this message translates to:
  /// **'Risk Status'**
  String get profileFieldRiskStatus;

  /// No description provided for @profileAccountStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get profileAccountStatusActive;

  /// No description provided for @profileAccountStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get profileAccountStatusSuspended;

  /// No description provided for @profileAccountStatusRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get profileAccountStatusRemoved;

  /// No description provided for @profileRiskStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get profileRiskStatusNormal;

  /// No description provided for @profileRiskStatusSuspicious.
  ///
  /// In en, this message translates to:
  /// **'Suspicious'**
  String get profileRiskStatusSuspicious;

  /// No description provided for @profileRiskStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get profileRiskStatusHigh;

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

  /// No description provided for @loginDividerOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get loginDividerOr;

  /// No description provided for @loginBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access HomeU'**
  String get loginBiometricReason;

  /// No description provided for @loginSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login with email and password.'**
  String get loginSessionExpired;

  /// No description provided for @loginBiometricFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed or cancelled.'**
  String get loginBiometricFailed;

  /// No description provided for @loginContinueAs.
  ///
  /// In en, this message translates to:
  /// **'Continue as {name}'**
  String loginContinueAs(Object name);

  /// No description provided for @loginUseBiometrics.
  ///
  /// In en, this message translates to:
  /// **'Use Biometrics'**
  String get loginUseBiometrics;

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

  /// No description provided for @registerPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+60 12 345 6789'**
  String get registerPhoneHint;

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

  /// No description provided for @viewingScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Viewing'**
  String get viewingScheduleTitle;

  /// No description provided for @viewingSelectSlotTitle.
  ///
  /// In en, this message translates to:
  /// **'Select an Available Slot'**
  String get viewingSelectSlotTitle;

  /// No description provided for @viewingSelectSlotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Owners only display slots they are available for. Select one to proceed.'**
  String get viewingSelectSlotSubtitle;

  /// No description provided for @viewingNoSlotsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Available Slots'**
  String get viewingNoSlotsTitle;

  /// No description provided for @viewingNoSlotsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The owner has not listed any availability for this property yet. Please check back later or contact the owner.'**
  String get viewingNoSlotsSubtitle;

  /// No description provided for @viewingGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get viewingGoBack;

  /// No description provided for @viewingConfirmRequest.
  ///
  /// In en, this message translates to:
  /// **'Confirm Request'**
  String get viewingConfirmRequest;

  /// No description provided for @viewingAlreadyScheduled.
  ///
  /// In en, this message translates to:
  /// **'You have already scheduled a viewing for this time slot. Please check your Requests.'**
  String get viewingAlreadyScheduled;

  /// No description provided for @viewingRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request Sent!'**
  String get viewingRequestSent;

  /// No description provided for @viewingErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String viewingErrorWithMessage(Object message);

  /// No description provided for @bookingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetailsTitle;

  /// No description provided for @bookingPaymentScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Schedule'**
  String get bookingPaymentScheduleTitle;

  /// No description provided for @bookingPaymentScheduleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No payment schedule generated yet.'**
  String get bookingPaymentScheduleEmpty;

  /// No description provided for @bookingMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month {number}'**
  String bookingMonthLabel(Object number);

  /// No description provided for @bookingMonthWithFee.
  ///
  /// In en, this message translates to:
  /// **'Month {number} (Booking Fee)'**
  String bookingMonthWithFee(Object number);

  /// No description provided for @bookingDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String bookingDueLabel(Object date);

  /// No description provided for @bookingViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get bookingViewReceipt;

  /// No description provided for @bookingAmountRm.
  ///
  /// In en, this message translates to:
  /// **'RM {amount}'**
  String bookingAmountRm(Object amount);

  /// No description provided for @bookingPaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get bookingPaid;

  /// No description provided for @bookingUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get bookingUpcoming;

  /// No description provided for @bookingPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get bookingPayNow;

  /// No description provided for @bookingReceiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'No receipt found for this payment.'**
  String get bookingReceiptNotFound;

  /// No description provided for @bookingReceiptError.
  ///
  /// In en, this message translates to:
  /// **'Error loading receipt: {message}'**
  String bookingReceiptError(Object message);

  /// No description provided for @reviewRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Review & Rating'**
  String get reviewRatingTitle;

  /// No description provided for @reviewRatingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your experience to help future tenants make better decisions.'**
  String get reviewRatingSubtitle;

  /// No description provided for @reviewAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get reviewAverageLabel;

  /// No description provided for @reviewYourRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get reviewYourRatingLabel;

  /// No description provided for @reviewCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get reviewCommentLabel;

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about cleanliness, owner communication, and your overall experience.'**
  String get reviewCommentHint;

  /// No description provided for @reviewSubmitLabel.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get reviewSubmitLabel;

  /// No description provided for @reviewSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you. Your review has been submitted.'**
  String get reviewSubmitSuccess;

  /// No description provided for @reviewStarLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} star'**
  String reviewStarLabel(Object count);

  /// No description provided for @compareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare Properties'**
  String get compareTitle;

  /// No description provided for @compareClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get compareClear;

  /// No description provided for @compareEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Properties Selected'**
  String get compareEmptyTitle;

  /// No description provided for @compareEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go back and select 2 properties\nto start comparing'**
  String get compareEmptySubtitle;

  /// No description provided for @compareBackToListings.
  ///
  /// In en, this message translates to:
  /// **'Back to Listings'**
  String get compareBackToListings;

  /// No description provided for @comparePriceRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get comparePriceRangeLabel;

  /// No description provided for @comparePriceRangeValue.
  ///
  /// In en, this message translates to:
  /// **'RM {min} - RM {max}'**
  String comparePriceRangeValue(Object min, Object max);

  /// No description provided for @compareSaveAmount.
  ///
  /// In en, this message translates to:
  /// **'Save RM {amount}'**
  String compareSaveAmount(Object amount);

  /// No description provided for @compareLabelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get compareLabelAddress;

  /// No description provided for @compareLabelType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get compareLabelType;

  /// No description provided for @compareLabelRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get compareLabelRooms;

  /// No description provided for @compareLabelFurnishing.
  ///
  /// In en, this message translates to:
  /// **'Furnishing'**
  String get compareLabelFurnishing;

  /// No description provided for @compareLabelOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get compareLabelOwner;

  /// No description provided for @compareLabelAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get compareLabelAvailability;

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

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatTitle;

  /// No description provided for @chatSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search messages...'**
  String get chatSearchHint;

  /// No description provided for @chatFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chatFilterAll;

  /// No description provided for @chatFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get chatFilterUnread;

  /// No description provided for @chatFilterProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get chatFilterProperty;

  /// No description provided for @chatFilterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get chatFilterArchived;

  /// No description provided for @chatYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatYesterday;

  /// No description provided for @chatOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get chatOnline;

  /// No description provided for @chatOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get chatOffline;

  /// No description provided for @chatTypeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get chatTypeMessageHint;

  /// No description provided for @chatAttachmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Attachment'**
  String get chatAttachmentTitle;

  /// No description provided for @chatAttachImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get chatAttachImage;

  /// No description provided for @chatAttachCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get chatAttachCamera;

  /// No description provided for @chatAttachDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get chatAttachDocument;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Receipt'**
  String get receiptTitle;

  /// No description provided for @receiptSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get receiptSuccess;

  /// No description provided for @receiptTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get receiptTransactionId;

  /// No description provided for @receiptProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get receiptProperty;

  /// No description provided for @receiptLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get receiptLocation;

  /// No description provided for @receiptPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get receiptPaymentDate;

  /// No description provided for @receiptPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get receiptPaymentMethod;

  /// No description provided for @receiptInstallment.
  ///
  /// In en, this message translates to:
  /// **'Installment'**
  String get receiptInstallment;

  /// No description provided for @receiptMonth.
  ///
  /// In en, this message translates to:
  /// **'Month {number}'**
  String receiptMonth(Object number);

  /// No description provided for @receiptTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get receiptTotalAmount;

  /// No description provided for @receiptDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get receiptDownload;

  /// No description provided for @receiptShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get receiptShare;

  /// No description provided for @receiptFooter.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using HomeU!'**
  String get receiptFooter;

  /// No description provided for @paymentAmountRm.
  ///
  /// In en, this message translates to:
  /// **'RM {amount}'**
  String paymentAmountRm(Object amount);

  /// No description provided for @bookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookingTitle;

  /// No description provided for @bookingConflictDetected.
  ///
  /// In en, this message translates to:
  /// **'Conflict detected with an existing booking.'**
  String get bookingConflictDetected;

  /// No description provided for @bookingFeeNotice.
  ///
  /// In en, this message translates to:
  /// **'Paying the booking fee locks this property. The remaining balance is due after owner approval.'**
  String get bookingFeeNotice;

  /// No description provided for @bookingPayFee.
  ///
  /// In en, this message translates to:
  /// **'Pay Booking Fee (RM {amount})'**
  String bookingPayFee(Object amount);

  /// No description provided for @bookingSelectedProperty.
  ///
  /// In en, this message translates to:
  /// **'Selected Property'**
  String get bookingSelectedProperty;

  /// No description provided for @bookingConflictDetails.
  ///
  /// In en, this message translates to:
  /// **'Property is already booked starting from {date}. Please choose a shorter duration or different start date.'**
  String bookingConflictDetails(Object date);

  /// No description provided for @bookingDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rental Duration'**
  String get bookingDurationTitle;

  /// No description provided for @bookingDurationMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String bookingDurationMonths(Object count);

  /// No description provided for @bookingStartDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get bookingStartDateTitle;

  /// No description provided for @bookingOccupiedUntil.
  ///
  /// In en, this message translates to:
  /// **'Property is occupied until {date}'**
  String bookingOccupiedUntil(Object date);

  /// No description provided for @bookingTotalPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Price Calculation'**
  String get bookingTotalPriceTitle;

  /// No description provided for @bookingMonthlyPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Price'**
  String get bookingMonthlyPriceLabel;

  /// No description provided for @bookingDurationSummary.
  ///
  /// In en, this message translates to:
  /// **'Duration ({months} months)'**
  String bookingDurationSummary(Object months);

  /// No description provided for @bookingEstimatedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated Total'**
  String get bookingEstimatedTotalLabel;

  /// No description provided for @paymentSupabaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Supabase is not initialized. Please try again later.'**
  String get paymentSupabaseUnavailable;

  /// No description provided for @bookingLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to continue booking.'**
  String get bookingLoginRequired;

  /// No description provided for @bookingDurationJustBooked.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this duration was just booked by another tenant.'**
  String get bookingDurationJustBooked;

  /// No description provided for @bookingCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to create booking. Please try again.'**
  String get bookingCreateFailed;

  /// No description provided for @bookingCreateError.
  ///
  /// In en, this message translates to:
  /// **'Create booking failed: {error}'**
  String bookingCreateError(Object error);

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @ownerRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get ownerRequestsTitle;

  /// No description provided for @ownerRequestsBookingsTab.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get ownerRequestsBookingsTab;

  /// No description provided for @ownerRequestsViewingsTab.
  ///
  /// In en, this message translates to:
  /// **'Viewings'**
  String get ownerRequestsViewingsTab;

  /// No description provided for @ownerRequestsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get ownerRequestsRetry;

  /// No description provided for @ownerRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No \"{filter}\" requests.'**
  String ownerRequestsEmpty(Object filter);

  /// No description provided for @ownerRequestsMoveIn.
  ///
  /// In en, this message translates to:
  /// **'Moves in: {date}  •  {months} months'**
  String ownerRequestsMoveIn(Object date, Object months);

  /// No description provided for @ownerRequestsFlexibleDuration.
  ///
  /// In en, this message translates to:
  /// **'Flexible  •  {months} months'**
  String ownerRequestsFlexibleDuration(Object months);

  /// No description provided for @ownerRequestsMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'RM {price} / mo'**
  String ownerRequestsMonthlyPrice(Object price);

  /// No description provided for @ownerRequestsReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get ownerRequestsReview;

  /// No description provided for @ownerRequestsViewingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No \"{filter}\" viewing requests.'**
  String ownerRequestsViewingsEmpty(Object filter);

  /// No description provided for @ownerRequestsViewingTime.
  ///
  /// In en, this message translates to:
  /// **'{date}  •  {time}'**
  String ownerRequestsViewingTime(Object date, Object time);

  /// No description provided for @ownerRequestsDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get ownerRequestsDecline;

  /// No description provided for @ownerRequestsApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get ownerRequestsApprove;

  /// No description provided for @ownerRequestsMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get ownerRequestsMarkCompleted;

  /// No description provided for @ownerGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String ownerGreeting(Object name);

  /// No description provided for @ownerRecentProperties.
  ///
  /// In en, this message translates to:
  /// **'Recent Properties'**
  String get ownerRecentProperties;

  /// No description provided for @ownerNoProperties.
  ///
  /// In en, this message translates to:
  /// **'No properties listed yet'**
  String get ownerNoProperties;

  /// No description provided for @ownerAddFirstProperty.
  ///
  /// In en, this message translates to:
  /// **'Add your first property'**
  String get ownerAddFirstProperty;

  /// No description provided for @ownerUntitledProperty.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get ownerUntitledProperty;

  /// No description provided for @ownerRecentBookingRequests.
  ///
  /// In en, this message translates to:
  /// **'Recent Booking Requests'**
  String get ownerRecentBookingRequests;

  /// No description provided for @ownerNoBookingRequests.
  ///
  /// In en, this message translates to:
  /// **'No active booking requests'**
  String get ownerNoBookingRequests;

  /// No description provided for @ownerUnknownProperty.
  ///
  /// In en, this message translates to:
  /// **'Unknown Property'**
  String get ownerUnknownProperty;

  /// No description provided for @ownerUnknownTenant.
  ///
  /// In en, this message translates to:
  /// **'Unknown Tenant'**
  String get ownerUnknownTenant;

  /// No description provided for @ownerRecentViewingRequests.
  ///
  /// In en, this message translates to:
  /// **'Recent Viewing Requests'**
  String get ownerRecentViewingRequests;

  /// No description provided for @ownerNoViewingRequests.
  ///
  /// In en, this message translates to:
  /// **'No active viewing requests'**
  String get ownerNoViewingRequests;

  /// No description provided for @ownerTapToReviewViewing.
  ///
  /// In en, this message translates to:
  /// **'Tap to review viewing'**
  String get ownerTapToReviewViewing;

  /// No description provided for @ownerProjected30Days.
  ///
  /// In en, this message translates to:
  /// **'Projected (30 Days)'**
  String get ownerProjected30Days;

  /// No description provided for @ownerOverduePayments.
  ///
  /// In en, this message translates to:
  /// **'Overdue Payments'**
  String get ownerOverduePayments;

  /// No description provided for @ownerInvoiceCollectionRate.
  ///
  /// In en, this message translates to:
  /// **'Invoice Collection Rate'**
  String get ownerInvoiceCollectionRate;

  /// No description provided for @monthShortJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthShortJul;

  /// No description provided for @monthShortAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthShortAug;

  /// No description provided for @monthShortSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthShortSep;

  /// No description provided for @monthShortOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthShortOct;

  /// No description provided for @monthShortNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthShortNov;

  /// No description provided for @monthShortDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthShortDec;

  /// No description provided for @profileBiometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available or not set up on this device.'**
  String get profileBiometricUnavailable;

  /// No description provided for @profileBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to enable biometric login'**
  String get profileBiometricReason;

  /// No description provided for @profileBiometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login enabled successfully.'**
  String get profileBiometricEnabled;

  /// No description provided for @profileBiometricSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update biometric preference.'**
  String get profileBiometricSaveFailed;

  /// No description provided for @profileBiometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login disabled.'**
  String get profileBiometricDisabled;

  /// No description provided for @profileErrorSaveBiometric.
  ///
  /// In en, this message translates to:
  /// **'Failed to save biometric preference.'**
  String get profileErrorSaveBiometric;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your HomeU account?'**
  String get profileLogoutMessage;

  /// No description provided for @profileLogoutCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileLogoutCancel;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogoutConfirm;

  /// No description provided for @profileFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View your saved properties'**
  String get profileFavoritesSubtitle;

  /// No description provided for @profileBiometricTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get profileBiometricTitle;

  /// No description provided for @profileBiometricSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock HomeU with biometrics'**
  String get profileBiometricSubtitle;

  /// No description provided for @adminDashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load system overview. Please check your connection.'**
  String get adminDashboardLoadError;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminDashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Admin'**
  String get adminDashboardWelcome;

  /// No description provided for @adminDashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'System Overview'**
  String get adminDashboardOverview;

  /// No description provided for @adminTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get adminTotalUsers;

  /// No description provided for @adminTotalOwners.
  ///
  /// In en, this message translates to:
  /// **'Owners'**
  String get adminTotalOwners;

  /// No description provided for @adminTotalTenants.
  ///
  /// In en, this message translates to:
  /// **'Tenants'**
  String get adminTotalTenants;

  /// No description provided for @adminPendingReports.
  ///
  /// In en, this message translates to:
  /// **'Pending Reports'**
  String get adminPendingReports;

  /// No description provided for @adminManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get adminManagementTitle;

  /// No description provided for @adminReportsReview.
  ///
  /// In en, this message translates to:
  /// **'Reports Review'**
  String get adminReportsReview;

  /// No description provided for @adminReportsSummary.
  ///
  /// In en, this message translates to:
  /// **'{pending} pending of {total} total reports'**
  String adminReportsSummary(Object pending, Object total);

  /// No description provided for @adminManagementTile.
  ///
  /// In en, this message translates to:
  /// **'Admin Management'**
  String get adminManagementTile;

  /// No description provided for @adminManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage system administrators'**
  String get adminManagementSubtitle;

  /// No description provided for @adminAuditLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get adminAuditLogsTitle;

  /// No description provided for @adminAuditLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View system-wide activity logs'**
  String get adminAuditLogsSubtitle;

  /// No description provided for @adminCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Admin account created successfully.'**
  String get adminCreatedSuccess;

  /// No description provided for @adminUpdateDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Update Admin Details'**
  String get adminUpdateDetailsTitle;

  /// No description provided for @adminUpdateDetailsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get adminUpdateDetailsConfirm;

  /// No description provided for @adminDetailsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Admin details updated.'**
  String get adminDetailsUpdated;

  /// No description provided for @adminUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String adminUpdateError(Object error);

  /// No description provided for @adminCannotRemoveSelf.
  ///
  /// In en, this message translates to:
  /// **'Security: You cannot remove your own admin access.'**
  String get adminCannotRemoveSelf;

  /// No description provided for @adminRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Admin?'**
  String get adminRemoveTitle;

  /// No description provided for @adminRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove admin privileges from {name}? They will revert to a Tenant role.'**
  String adminRemoveMessage(Object name);

  /// No description provided for @adminRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminRemoveConfirm;

  /// No description provided for @adminRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Admin privileges removed.'**
  String get adminRemovedSuccess;

  /// No description provided for @adminRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String adminRemoveError(Object error);

  /// No description provided for @adminAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Admin'**
  String get adminAddButton;

  /// No description provided for @adminNoAdminsFound.
  ///
  /// In en, this message translates to:
  /// **'No admins found.'**
  String get adminNoAdminsFound;

  /// No description provided for @adminNavDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get adminNavDashboard;

  /// No description provided for @adminNavReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminNavReports;

  /// No description provided for @adminNavChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get adminNavChat;

  /// No description provided for @adminNavLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get adminNavLogs;

  /// No description provided for @adminNavProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get adminNavProfile;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefreshTooltip;

  /// No description provided for @statusReviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get statusReviewed;

  /// No description provided for @statusDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get statusDismissed;

  /// No description provided for @adminReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports Review'**
  String get adminReportsTitle;

  /// No description provided for @adminReportsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search report, owner, tenant, listing...'**
  String get adminReportsSearchHint;

  /// No description provided for @adminReportsFilterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter reports'**
  String get adminReportsFilterTooltip;

  /// No description provided for @adminReportsActiveFilterLabel.
  ///
  /// In en, this message translates to:
  /// **'Active filter:'**
  String get adminReportsActiveFilterLabel;

  /// No description provided for @adminReportsNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No reports match the current filters.'**
  String get adminReportsNoMatches;

  /// No description provided for @adminReportsFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter Reports'**
  String get adminReportsFilterTitle;

  /// No description provided for @adminReportsFilterSectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Report Status'**
  String get adminReportsFilterSectionStatus;

  /// No description provided for @adminReportsFilterClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get adminReportsFilterClear;

  /// No description provided for @adminReportsFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get adminReportsFilterApply;

  /// No description provided for @adminReportsUnknownListing.
  ///
  /// In en, this message translates to:
  /// **'Unknown listing'**
  String get adminReportsUnknownListing;

  /// No description provided for @adminReportsUnknownReportId.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get adminReportsUnknownReportId;

  /// No description provided for @adminReportsPropertyIdFallback.
  ///
  /// In en, this message translates to:
  /// **'Property #{propertyId}'**
  String adminReportsPropertyIdFallback(Object propertyId);

  /// No description provided for @adminReportsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get adminReportsNotAvailable;

  /// No description provided for @adminReportsUnknownOwner.
  ///
  /// In en, this message translates to:
  /// **'Unknown owner'**
  String get adminReportsUnknownOwner;

  /// No description provided for @adminReportsUnknownReporter.
  ///
  /// In en, this message translates to:
  /// **'Unknown reporter'**
  String get adminReportsUnknownReporter;

  /// No description provided for @adminReportsUnknownEmail.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get adminReportsUnknownEmail;

  /// No description provided for @adminReportsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reports: {error}'**
  String adminReportsLoadError(Object error);

  /// No description provided for @adminReportsMissingOwnerOrPropertyChat.
  ///
  /// In en, this message translates to:
  /// **'Missing owner or property context for chat.'**
  String get adminReportsMissingOwnerOrPropertyChat;

  /// No description provided for @adminReportsMissingTenantOrPropertyChat.
  ///
  /// In en, this message translates to:
  /// **'Missing tenant or property context for chat.'**
  String get adminReportsMissingTenantOrPropertyChat;

  /// No description provided for @adminReportsAuditContactOwnerReason.
  ///
  /// In en, this message translates to:
  /// **'Opened owner chat for report follow-up.'**
  String get adminReportsAuditContactOwnerReason;

  /// No description provided for @adminReportsAuditContactTenantReason.
  ///
  /// In en, this message translates to:
  /// **'Opened tenant chat for report follow-up.'**
  String get adminReportsAuditContactTenantReason;

  /// No description provided for @adminReportsChatOpenError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open chat: {error}'**
  String adminReportsChatOpenError(Object error);

  /// No description provided for @adminReportsRecordRiskLevelAction.
  ///
  /// In en, this message translates to:
  /// **'Record Risk Level'**
  String get adminReportsRecordRiskLevelAction;

  /// No description provided for @adminReportsRiskRecorded.
  ///
  /// In en, this message translates to:
  /// **'Risk level recorded.'**
  String get adminReportsRiskRecorded;

  /// No description provided for @adminReportsRiskRecordError.
  ///
  /// In en, this message translates to:
  /// **'Risk evaluation failed: {error}'**
  String adminReportsRiskRecordError(Object error);

  /// No description provided for @adminReportsActionCompleted.
  ///
  /// In en, this message translates to:
  /// **'{actionLabel} completed.'**
  String adminReportsActionCompleted(Object actionLabel);

  /// No description provided for @adminReportsUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Report update failed: {error}'**
  String adminReportsUpdateError(Object error);

  /// No description provided for @adminReportsReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report #{reportId}'**
  String adminReportsReportTitle(Object reportId);

  /// No description provided for @adminReportsSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on {date}'**
  String adminReportsSubmittedOn(Object date);

  /// No description provided for @adminReportsSectionProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get adminReportsSectionProperty;

  /// No description provided for @adminReportsSectionOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get adminReportsSectionOwner;

  /// No description provided for @adminReportsSectionReporter.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get adminReportsSectionReporter;

  /// No description provided for @adminReportsSectionComplaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get adminReportsSectionComplaint;

  /// No description provided for @adminReportsFieldPropertyId.
  ///
  /// In en, this message translates to:
  /// **'Property ID'**
  String get adminReportsFieldPropertyId;

  /// No description provided for @adminReportsFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get adminReportsFieldTitle;

  /// No description provided for @adminReportsFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminReportsFieldName;

  /// No description provided for @adminReportsFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminReportsFieldEmail;

  /// No description provided for @adminReportsFieldTotalReports.
  ///
  /// In en, this message translates to:
  /// **'Total reports'**
  String get adminReportsFieldTotalReports;

  /// No description provided for @adminReportsFieldReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get adminReportsFieldReason;

  /// No description provided for @adminReportsFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminReportsFieldDescription;

  /// No description provided for @adminReportsFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminReportsFieldStatus;

  /// No description provided for @adminReportsRiskSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk evaluation'**
  String get adminReportsRiskSectionTitle;

  /// No description provided for @adminReportsRiskSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Internal review only. This does not change listing visibility or account status.'**
  String get adminReportsRiskSectionHint;

  /// No description provided for @adminReportsReviewedConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'I have reviewed this complaint.'**
  String get adminReportsReviewedConfirmTitle;

  /// No description provided for @adminReportsReviewedConfirmSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Risk evaluation and status updates unlock after this confirmation.'**
  String get adminReportsReviewedConfirmSubtitle;

  /// No description provided for @adminReportsActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get adminReportsActionsTitle;

  /// No description provided for @adminReportsActionsHint.
  ///
  /// In en, this message translates to:
  /// **'Use chat for follow-up, then record the internal risk level or update the report status.'**
  String get adminReportsActionsHint;

  /// No description provided for @adminReportsContactOwner.
  ///
  /// In en, this message translates to:
  /// **'Contact Owner'**
  String get adminReportsContactOwner;

  /// No description provided for @adminReportsContactReporter.
  ///
  /// In en, this message translates to:
  /// **'Contact Reporter'**
  String get adminReportsContactReporter;

  /// No description provided for @adminReportsSaveRisk.
  ///
  /// In en, this message translates to:
  /// **'Save Risk Level'**
  String get adminReportsSaveRisk;

  /// No description provided for @adminReportsMarkReviewed.
  ///
  /// In en, this message translates to:
  /// **'Mark Reviewed'**
  String get adminReportsMarkReviewed;

  /// No description provided for @adminReportsDismissReport.
  ///
  /// In en, this message translates to:
  /// **'Dismiss Report'**
  String get adminReportsDismissReport;

  /// No description provided for @adminReportsOwnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner: {name}'**
  String adminReportsOwnerLabel(Object name);

  /// No description provided for @adminReportsReporterLabel.
  ///
  /// In en, this message translates to:
  /// **'Reporter: {name}'**
  String adminReportsReporterLabel(Object name);

  /// No description provided for @adminReportsReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String adminReportsReasonLabel(Object reason);

  /// No description provided for @adminReportsReasonDialogPrompt.
  ///
  /// In en, this message translates to:
  /// **'Provide a reason and confirm this moderation action.'**
  String get adminReportsReasonDialogPrompt;

  /// No description provided for @adminReportsReasonDialogLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin reason'**
  String get adminReportsReasonDialogLabel;

  /// No description provided for @adminReportsReasonDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Add clear moderation context'**
  String get adminReportsReasonDialogHint;

  /// No description provided for @adminReportsReasonDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm this action.'**
  String get adminReportsReasonDialogConfirm;

  /// No description provided for @adminReportsRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get adminReportsRiskLow;

  /// No description provided for @adminReportsRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get adminReportsRiskMedium;

  /// No description provided for @adminReportsRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get adminReportsRiskHigh;

  /// No description provided for @adminReportsRiskInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get adminReportsRiskInvalid;

  /// No description provided for @adminAuditTitle.
  ///
  /// In en, this message translates to:
  /// **'System Audit Logs'**
  String get adminAuditTitle;

  /// No description provided for @adminAuditClearFiltersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get adminAuditClearFiltersTooltip;

  /// No description provided for @adminAuditSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search descriptions...'**
  String get adminAuditSearchHint;

  /// No description provided for @adminAuditAllDates.
  ///
  /// In en, this message translates to:
  /// **'All Dates'**
  String get adminAuditAllDates;

  /// No description provided for @adminAuditDateRange.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String adminAuditDateRange(Object start, Object end);

  /// No description provided for @adminAuditTableFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get adminAuditTableFilterHint;

  /// No description provided for @adminAuditActionFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get adminAuditActionFilterHint;

  /// No description provided for @adminAuditEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No audit logs found matching your criteria.'**
  String get adminAuditEmptyState;

  /// No description provided for @adminAuditClearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get adminAuditClearAllFilters;

  /// No description provided for @adminAuditUnknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown Time'**
  String get adminAuditUnknownTime;

  /// No description provided for @adminAuditNoDetails.
  ///
  /// In en, this message translates to:
  /// **'No details available'**
  String get adminAuditNoDetails;

  /// No description provided for @adminAuditSystemActor.
  ///
  /// In en, this message translates to:
  /// **'System / Anonymous'**
  String get adminAuditSystemActor;

  /// No description provided for @adminAuditUnknownRole.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get adminAuditUnknownRole;

  /// No description provided for @adminAuditNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get adminAuditNotAvailable;

  /// No description provided for @adminAuditActorLabel.
  ///
  /// In en, this message translates to:
  /// **'Actor'**
  String get adminAuditActorLabel;

  /// No description provided for @adminAuditTargetTableLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Table'**
  String get adminAuditTargetTableLabel;

  /// No description provided for @adminAuditTargetIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Target ID'**
  String get adminAuditTargetIdLabel;

  /// No description provided for @adminAuditTableProfiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get adminAuditTableProfiles;

  /// No description provided for @adminAuditTableProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get adminAuditTableProperties;

  /// No description provided for @adminAuditTableBookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get adminAuditTableBookings;

  /// No description provided for @adminAuditTablePropertyReports.
  ///
  /// In en, this message translates to:
  /// **'Property Reports'**
  String get adminAuditTablePropertyReports;

  /// No description provided for @adminAuditTableReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminAuditTableReports;

  /// No description provided for @adminAuditTableAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get adminAuditTableAuditLogs;

  /// No description provided for @adminAuditActionAdminCreated.
  ///
  /// In en, this message translates to:
  /// **'Admin Created'**
  String get adminAuditActionAdminCreated;

  /// No description provided for @adminAuditActionAdminUpdated.
  ///
  /// In en, this message translates to:
  /// **'Admin Updated'**
  String get adminAuditActionAdminUpdated;

  /// No description provided for @adminAuditActionAdminRemoved.
  ///
  /// In en, this message translates to:
  /// **'Admin Removed'**
  String get adminAuditActionAdminRemoved;

  /// No description provided for @adminAuditActionReportContactOwner.
  ///
  /// In en, this message translates to:
  /// **'Report: Contact Owner'**
  String get adminAuditActionReportContactOwner;

  /// No description provided for @adminAuditActionReportContactTenant.
  ///
  /// In en, this message translates to:
  /// **'Report: Contact Tenant'**
  String get adminAuditActionReportContactTenant;

  /// No description provided for @adminAuditActionReportRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Report: Risk Low'**
  String get adminAuditActionReportRiskLow;

  /// No description provided for @adminAuditActionReportRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'Report: Risk Medium'**
  String get adminAuditActionReportRiskMedium;

  /// No description provided for @adminAuditActionReportRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'Report: Risk High'**
  String get adminAuditActionReportRiskHigh;

  /// No description provided for @adminAuditActionReportRiskInvalid.
  ///
  /// In en, this message translates to:
  /// **'Report: Risk Invalid'**
  String get adminAuditActionReportRiskInvalid;

  /// No description provided for @adminAuditActionReportReviewed.
  ///
  /// In en, this message translates to:
  /// **'Report: Reviewed'**
  String get adminAuditActionReportReviewed;

  /// No description provided for @adminAuditActionReportDismissed.
  ///
  /// In en, this message translates to:
  /// **'Report: Dismissed'**
  String get adminAuditActionReportDismissed;

  /// No description provided for @adminAuditActionPropertyApproved.
  ///
  /// In en, this message translates to:
  /// **'Property Approved'**
  String get adminAuditActionPropertyApproved;

  /// No description provided for @adminAuditActionPropertyRejected.
  ///
  /// In en, this message translates to:
  /// **'Property Rejected'**
  String get adminAuditActionPropertyRejected;

  /// No description provided for @adminAuditActionProfileUpdate.
  ///
  /// In en, this message translates to:
  /// **'Profile Updated'**
  String get adminAuditActionProfileUpdate;

  /// No description provided for @adminAuditLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load logs: {error}'**
  String adminAuditLoadError(Object error);

  /// No description provided for @propertyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Property'**
  String get propertyReportTitle;

  /// No description provided for @propertyReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason for reporting this property. Our team will review it shortly.'**
  String get propertyReportSubtitle;

  /// No description provided for @propertyReportReasonFake.
  ///
  /// In en, this message translates to:
  /// **'Fake listing / Scam'**
  String get propertyReportReasonFake;

  /// No description provided for @propertyReportReasonSuspicious.
  ///
  /// In en, this message translates to:
  /// **'Suspicious activity'**
  String get propertyReportReasonSuspicious;

  /// No description provided for @propertyReportReasonWrongDetails.
  ///
  /// In en, this message translates to:
  /// **'Incorrect property details'**
  String get propertyReportReasonWrongDetails;

  /// No description provided for @propertyReportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get propertyReportReasonInappropriate;

  /// No description provided for @propertyReportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get propertyReportReasonOther;

  /// No description provided for @propertyReportDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Provide additional details (optional)'**
  String get propertyReportDescriptionHint;

  /// No description provided for @propertyReportCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get propertyReportCancel;

  /// No description provided for @propertyReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get propertyReportSubmit;

  /// No description provided for @propertyReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully. Thank you.'**
  String get propertyReportSubmitted;

  /// No description provided for @propertyReportSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report. Please try again.'**
  String get propertyReportSubmitFailed;

  /// No description provided for @propertyReportServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Report service is currently unavailable. Please check your connection.'**
  String get propertyReportServiceUnavailable;

  /// No description provided for @propertyReportLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to submit a report.'**
  String get propertyReportLoginRequired;

  /// No description provided for @propertyReportTenantOnly.
  ///
  /// In en, this message translates to:
  /// **'Only tenants can submit property reports.'**
  String get propertyReportTenantOnly;

  /// No description provided for @propertyReportOwnProperty.
  ///
  /// In en, this message translates to:
  /// **'You cannot report your own property.'**
  String get propertyReportOwnProperty;

  /// No description provided for @propertyReportInvalidMetadata.
  ///
  /// In en, this message translates to:
  /// **'Invalid property metadata. Unable to report.'**
  String get propertyReportInvalidMetadata;

  /// No description provided for @propertyFacilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Facilities'**
  String get propertyFacilitiesTitle;

  /// No description provided for @propertyNoFacilities.
  ///
  /// In en, this message translates to:
  /// **'No facilities listed.'**
  String get propertyNoFacilities;

  /// No description provided for @propertyOwnerInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Owner Information'**
  String get propertyOwnerInfoTitle;

  /// No description provided for @propertyOwnerHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get propertyOwnerHighRisk;

  /// No description provided for @propertyOwnerSuspicious.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Owner'**
  String get propertyOwnerSuspicious;

  /// No description provided for @propertyOwnerSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get propertyOwnerSuspended;

  /// No description provided for @propertyOwnerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get propertyOwnerRemoved;

  /// No description provided for @propertyAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get propertyAvailabilityTitle;

  /// No description provided for @propertyAvailabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Availability:'**
  String get propertyAvailabilityLabel;

  /// No description provided for @propertyStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get propertyStatusActive;

  /// No description provided for @propertyStatusOccupied.
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get propertyStatusOccupied;

  /// No description provided for @propertyStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get propertyStatusInactive;

  /// No description provided for @propertyReportErrorPermission.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit report due to permission policy. Please contact support.'**
  String get propertyReportErrorPermission;

  /// No description provided for @propertyReportErrorInvalidListing.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit report because the listing reference is invalid.'**
  String get propertyReportErrorInvalidListing;

  /// No description provided for @propertyReportErrorInvalidData.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit report because the listing data is invalid.'**
  String get propertyReportErrorInvalidData;

  /// No description provided for @propertyNearbyLabel.
  ///
  /// In en, this message translates to:
  /// **'Nearby: {landmarks}'**
  String propertyNearbyLabel(Object landmarks);

  /// No description provided for @propertyDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get propertyDetailsTitle;

  /// No description provided for @propertyUnavailableAdmin.
  ///
  /// In en, this message translates to:
  /// **'This property is currently unavailable due to moderation.'**
  String get propertyUnavailableAdmin;

  /// No description provided for @propertyUnavailableBooking.
  ///
  /// In en, this message translates to:
  /// **'This property is currently occupied and not available for booking.'**
  String get propertyUnavailableBooking;

  /// No description provided for @propertyFavoriteLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please login to add to favorites.'**
  String get propertyFavoriteLoginRequired;

  /// No description provided for @propertyFavoriteTenantOnly.
  ///
  /// In en, this message translates to:
  /// **'Only tenants can save favorites.'**
  String get propertyFavoriteTenantOnly;

  /// No description provided for @propertyFavoritePolicyBlocked.
  ///
  /// In en, this message translates to:
  /// **'Unable to update favorite due to security policy.'**
  String get propertyFavoritePolicyBlocked;

  /// No description provided for @propertyFavoriteUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite. Please try again.'**
  String get propertyFavoriteUpdateFailed;

  /// No description provided for @propertyHighRiskTag.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get propertyHighRiskTag;

  /// No description provided for @propertyLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get propertyLocationTitle;

  /// No description provided for @propertyDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get propertyDescriptionTitle;

  /// No description provided for @bookingBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookingBookNow;

  /// No description provided for @bookingHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookings found matching your criteria.'**
  String get bookingHistoryEmpty;

  /// No description provided for @ownerAvailabilityEndAfterStart.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get ownerAvailabilityEndAfterStart;

  /// No description provided for @ownerAvailabilityPastDate.
  ///
  /// In en, this message translates to:
  /// **'Cannot add slots for past dates.'**
  String get ownerAvailabilityPastDate;

  /// No description provided for @ownerAvailabilityOverlap.
  ///
  /// In en, this message translates to:
  /// **'This slot overlaps with an existing one.'**
  String get ownerAvailabilityOverlap;

  /// No description provided for @ownerAvailabilitySlotAdded.
  ///
  /// In en, this message translates to:
  /// **'Availability slot added successfully.'**
  String get ownerAvailabilitySlotAdded;

  /// No description provided for @ownerAvailabilityAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add availability slot. Please try again.'**
  String get ownerAvailabilityAddFailed;

  /// No description provided for @ownerAvailabilityDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete slot. Please try again.'**
  String get ownerAvailabilityDeleteFailed;

  /// No description provided for @ownerAvailabilityDateTime.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String ownerAvailabilityDateTime(Object date, Object time);

  /// No description provided for @ownerAvailabilityCreateSlot.
  ///
  /// In en, this message translates to:
  /// **'Create New Availability Slot'**
  String get ownerAvailabilityCreateSlot;

  /// No description provided for @ownerAvailabilitySelectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get ownerAvailabilitySelectDate;

  /// No description provided for @ownerAvailabilityStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get ownerAvailabilityStartTime;

  /// No description provided for @ownerAvailabilityEndTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get ownerAvailabilityEndTime;

  /// No description provided for @ownerAvailabilityActiveSlots.
  ///
  /// In en, this message translates to:
  /// **'Your Available Slots'**
  String get ownerAvailabilityActiveSlots;

  /// No description provided for @ownerAvailabilityStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get ownerAvailabilityStatusAvailable;

  /// No description provided for @ownerAvailabilityStatusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get ownerAvailabilityStatusBooked;

  /// No description provided for @ownerAvailabilityStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get ownerAvailabilityStatusApproved;

  /// No description provided for @ownerAvailabilityDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Slot?'**
  String get ownerAvailabilityDeleteConfirmTitle;

  /// No description provided for @ownerAvailabilityDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this availability slot?'**
  String get ownerAvailabilityDeleteConfirmMessage;

  /// No description provided for @ownerAvailabilityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No availability slots added yet.'**
  String get ownerAvailabilityEmpty;

  /// No description provided for @ownerAvailabilityAddSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Slot'**
  String get ownerAvailabilityAddSlot;

  /// No description provided for @ownerAvailabilityBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get ownerAvailabilityBooked;

  /// No description provided for @ownerAvailabilityAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get ownerAvailabilityAvailable;

  /// No description provided for @ownerAvailabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Viewing Availability'**
  String get ownerAvailabilityTitle;

  /// No description provided for @paymentCardIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Please enter a full card expiry date.'**
  String get paymentCardIncomplete;

  /// No description provided for @paymentCardInvalidMonth.
  ///
  /// In en, this message translates to:
  /// **'Invalid month (01-12).'**
  String get paymentCardInvalidMonth;

  /// No description provided for @paymentCardExpired.
  ///
  /// In en, this message translates to:
  /// **'Card has expired.'**
  String get paymentCardExpired;

  /// No description provided for @paymentCardInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid expiry format (MM/YY).'**
  String get paymentCardInvalidFormat;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Completed'**
  String get paymentCompletedLabel;

  /// No description provided for @paymentPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get paymentPayNow;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodTitle;

  /// No description provided for @paymentMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Credit/Debit Card'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodBanking.
  ///
  /// In en, this message translates to:
  /// **'Online Banking'**
  String get paymentMethodBanking;

  /// No description provided for @paymentSelectBank.
  ///
  /// In en, this message translates to:
  /// **'Select Bank'**
  String get paymentSelectBank;

  /// No description provided for @paymentCardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get paymentCardNumberLabel;

  /// No description provided for @paymentCardNumberHint.
  ///
  /// In en, this message translates to:
  /// **'XXXX XXXX XXXX XXXX'**
  String get paymentCardNumberHint;

  /// No description provided for @paymentExpiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get paymentExpiryLabel;

  /// No description provided for @paymentExpiryHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get paymentExpiryHint;

  /// No description provided for @paymentCvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get paymentCvvLabel;

  /// No description provided for @paymentCvvHint.
  ///
  /// In en, this message translates to:
  /// **'XXX'**
  String get paymentCvvHint;

  /// No description provided for @paymentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount to Pay'**
  String get paymentAmountLabel;

  /// No description provided for @paymentTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get paymentTotalLabel;

  /// No description provided for @paymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment...'**
  String get paymentProcessing;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccess;

  /// No description provided for @paymentSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have paid RM {amount}.'**
  String paymentSuccessSubtitle(Object amount);

  /// No description provided for @paymentBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get paymentBackToHome;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment Error: {message}'**
  String paymentError(Object message);

  /// No description provided for @paymentMethodEwallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get paymentMethodEwallet;

  /// No description provided for @paymentSelectEwallet.
  ///
  /// In en, this message translates to:
  /// **'Select E-Wallet'**
  String get paymentSelectEwallet;

  /// No description provided for @paymentSelectEwalletError.
  ///
  /// In en, this message translates to:
  /// **'Please select an E-Wallet.'**
  String get paymentSelectEwalletError;

  /// No description provided for @paymentCardNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid card number.'**
  String get paymentCardNumberInvalid;

  /// No description provided for @paymentCvvInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid CVV.'**
  String get paymentCvvInvalid;

  /// No description provided for @paymentSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummaryTitle;

  /// No description provided for @paymentSummaryProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get paymentSummaryProperty;

  /// No description provided for @paymentSummaryStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get paymentSummaryStartDate;

  /// No description provided for @paymentSummaryDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get paymentSummaryDuration;

  /// No description provided for @paymentSummaryMonthlyRent.
  ///
  /// In en, this message translates to:
  /// **'Monthly Rent'**
  String get paymentSummaryMonthlyRent;

  /// No description provided for @paymentDurationMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String paymentDurationMonths(Object count);

  /// No description provided for @paymentSummaryMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get paymentSummaryMethod;

  /// No description provided for @paymentMethodWithBank.
  ///
  /// In en, this message translates to:
  /// **'Online Banking ({bank})'**
  String paymentMethodWithBank(Object bank);

  /// No description provided for @paymentMethodWithEwallet.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet ({wallet})'**
  String paymentMethodWithEwallet(Object wallet);

  /// No description provided for @paymentSummaryStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get paymentSummaryStatus;

  /// No description provided for @paymentRentMonth.
  ///
  /// In en, this message translates to:
  /// **'Rent for Month {number}'**
  String paymentRentMonth(Object number);

  /// No description provided for @paymentBookingFeeOneMonth.
  ///
  /// In en, this message translates to:
  /// **'Booking Fee (1 Month)'**
  String get paymentBookingFeeOneMonth;

  /// No description provided for @paymentSelectBankError.
  ///
  /// In en, this message translates to:
  /// **'Please select a bank.'**
  String get paymentSelectBankError;

  /// No description provided for @paymentConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get paymentConfirmTitle;

  /// No description provided for @paymentConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed with the payment?'**
  String get paymentConfirmMessage;

  /// No description provided for @paymentSummaryAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentSummaryAmount;

  /// No description provided for @paymentSummaryMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentSummaryMethodLabel;

  /// No description provided for @paymentCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get paymentCancel;

  /// No description provided for @paymentConfirmPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get paymentConfirmPay;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailed;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment processed successfully.'**
  String get paymentSuccessMessage;

  /// No description provided for @paymentFailedWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {message}'**
  String paymentFailedWithMessage(Object message);

  /// No description provided for @paymentErrorDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get paymentErrorDetailsAction;

  /// No description provided for @paymentErrorDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Error Details'**
  String get paymentErrorDetailsTitle;

  /// No description provided for @paymentOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get paymentOk;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentViewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get paymentViewReceipt;

  /// No description provided for @paymentDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get paymentDismiss;

  /// No description provided for @paymentMethodCardShort.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentMethodCardShort;

  /// No description provided for @paymentLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please log in to make a payment.'**
  String get paymentLoginRequired;

  /// No description provided for @viewingHistoryPleaseLogin.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your viewing history.'**
  String get viewingHistoryPleaseLogin;

  /// No description provided for @viewingHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Viewing History'**
  String get viewingHistoryTitle;

  /// No description provided for @viewingHistoryErrorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String viewingHistoryErrorWithMessage(Object message);

  /// No description provided for @viewingHistoryCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Viewing'**
  String get viewingHistoryCancelTitle;

  /// No description provided for @viewingHistoryCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this viewing appointment?'**
  String get viewingHistoryCancelMessage;

  /// No description provided for @viewingHistoryKeepAppointment.
  ///
  /// In en, this message translates to:
  /// **'Keep Appointment'**
  String get viewingHistoryKeepAppointment;

  /// No description provided for @viewingHistoryConfirmCancellation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cancellation'**
  String get viewingHistoryConfirmCancellation;

  /// No description provided for @viewingHistoryCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Viewing appointment cancelled'**
  String get viewingHistoryCancelledSuccess;

  /// No description provided for @viewingHistoryCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel viewing: {error}'**
  String viewingHistoryCancelFailed(Object error);

  /// No description provided for @viewingHistoryEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'No viewing requests yet.'**
  String get viewingHistoryEmptyAll;

  /// No description provided for @viewingHistoryEmptyForStatus.
  ///
  /// In en, this message translates to:
  /// **'No viewing requests found for this status.'**
  String get viewingHistoryEmptyForStatus;

  /// No description provided for @viewingHistoryFallbackLocation.
  ///
  /// In en, this message translates to:
  /// **'Location unavailable'**
  String get viewingHistoryFallbackLocation;

  /// No description provided for @viewingHistoryFallbackPrice.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get viewingHistoryFallbackPrice;

  /// No description provided for @viewingHistoryFallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Property details are currently unavailable.'**
  String get viewingHistoryFallbackDescription;

  /// No description provided for @viewingHistoryFallbackHostRole.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get viewingHistoryFallbackHostRole;

  /// No description provided for @viewingHistoryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Viewing Date'**
  String get viewingHistoryDateLabel;

  /// No description provided for @viewingHistoryTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Viewing Time'**
  String get viewingHistoryTimeLabel;

  /// No description provided for @viewingHistoryScheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get viewingHistoryScheduledLabel;

  /// No description provided for @viewingHistoryCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get viewingHistoryCancelAction;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get statusRescheduled;

  /// No description provided for @statusSlotTaken.
  ///
  /// In en, this message translates to:
  /// **'Slot Taken'**
  String get statusSlotTaken;

  /// No description provided for @statusPropertyRented.
  ///
  /// In en, this message translates to:
  /// **'Property Rented'**
  String get statusPropertyRented;
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
