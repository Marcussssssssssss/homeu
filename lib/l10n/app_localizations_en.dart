// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HomeU';

  @override
  String get navHome => 'Home';

  @override
  String get navFavorites => 'Favourite';

  @override
  String get navBookings => 'Booking';

  @override
  String get navProfile => 'Profile';

  @override
  String get homeGreetingAnonymous => 'Hello';

  @override
  String homeGreetingWithName(Object name) {
    return 'Hello, $name';
  }

  @override
  String get homeQuickSearchSubtitle =>
      'Find your next rental with a quick search.';

  @override
  String get homeSearchHint => 'Search location, condo, house';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeRecommendedProperties => 'Recommended Properties';

  @override
  String get homeScanQr => 'Scan QR';

  @override
  String get bookingHistoryTitle => 'Booking History';

  @override
  String get bookingHistorySubtitle =>
      'Track your latest rental booking updates quickly.';

  @override
  String get bookingDateLabel => 'Booking Date';

  @override
  String get rentalPeriodLabel => 'Rental Period';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get leaveReview => 'Leave Review';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileRoleOwner => 'Owner';

  @override
  String get profileRoleAdmin => 'Admin';

  @override
  String get profileRoleTenant => 'Tenant';

  @override
  String get profileThemeTitle => 'Theme';

  @override
  String get profileThemeSubtitle => 'Choose Light, Dark, or System default.';

  @override
  String get profileLanguageTitle => 'Language';

  @override
  String get profileLanguageSubtitle => 'Choose your preferred app language.';

  @override
  String get profileUpdatePasswordTitle => 'Update Password';

  @override
  String get profileUpdatePasswordSubtitle =>
      'Change your password to keep your account secure.';

  @override
  String get profileEditButton => 'Edit Profile';

  @override
  String get profileLogoutButton => 'Logout';

  @override
  String get profileAccountDetails => 'Account Details';

  @override
  String get profileFieldName => 'Name';

  @override
  String get profileFieldEmail => 'Email';

  @override
  String get profileFieldPhone => 'Phone Number';

  @override
  String get profileFieldRole => 'Role';

  @override
  String get profileFieldAccountStatus => 'Account Status';

  @override
  String get profileFieldRiskStatus => 'Risk Status';

  @override
  String get profileAccountStatusActive => 'Active';

  @override
  String get profileAccountStatusSuspended => 'Suspended';

  @override
  String get profileAccountStatusRemoved => 'Removed';

  @override
  String get profileRiskStatusNormal => 'Normal';

  @override
  String get profileRiskStatusSuspicious => 'Suspicious';

  @override
  String get profileRiskStatusHigh => 'High Risk';

  @override
  String get profileEditSheetTitle => 'Edit Profile';

  @override
  String get profileEditSheetPhotoHint =>
      'Profile photo can be changed from the avatar button above.';

  @override
  String get profileEditFieldFullName => 'Full Name';

  @override
  String get profileEditFieldFullNameHint => 'Enter full name';

  @override
  String get profileEditFieldEmailReadonly => 'Email (not editable)';

  @override
  String get profileEditFieldPhone => 'Phone Number';

  @override
  String get profileEditFieldPhoneHint => 'Enter phone number';

  @override
  String get profileEditSaveChanges => 'Save Changes';

  @override
  String get profileNamePhoneRequired => 'Name and phone number are required.';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully.';

  @override
  String get profileErrorRefresh =>
      'Unable to refresh profile now. Showing available data.';

  @override
  String get profileErrorUpdate =>
      'Unable to update profile right now. Please try again.';

  @override
  String get profileErrorUpload =>
      'Unable to upload profile photo right now. Please try again.';

  @override
  String get profileErrorLanguageSave =>
      'Unable to save language preference right now. Please try again.';

  @override
  String get profilePhotoChooseGallery => 'Choose from gallery';

  @override
  String get profilePhotoChooseGallerySubtitle =>
      'Select a photo from your device.';

  @override
  String get profilePhotoTakeCamera => 'Take a photo';

  @override
  String get profilePhotoTakeCameraSubtitle =>
      'Use your camera to capture a new avatar.';

  @override
  String get profilePhotoUpdatedSuccess =>
      'Profile photo updated successfully.';

  @override
  String get profilePhotoAccessError =>
      'Unable to access photos right now. Please try again.';

  @override
  String get profileThemeSaved => 'Theme preference saved.';

  @override
  String get profileLanguageSaved => 'Language preference saved.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageMalay => 'Malay';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get ownerNavDashboard => 'Dashboard';

  @override
  String get ownerNavMyProperties => 'My Properties';

  @override
  String get ownerNavRequests => 'Requests';

  @override
  String get ownerNavAnalytics => 'Analytics';

  @override
  String get ownerDashboardSubtitle =>
      'Manage listings, requests, and performance from one place.';

  @override
  String get ownerAddProperty => 'Add Property';

  @override
  String get ownerMonthlyEarnings => 'Monthly Earnings';

  @override
  String get ownerQuickStats => 'Quick Stats';

  @override
  String get ownerActiveListings => 'Active Listings';

  @override
  String get ownerPendingRequests => 'Pending Requests';

  @override
  String get ownerOccupancy => 'Occupancy';

  @override
  String get ownerMyProperties => 'My Properties';

  @override
  String get ownerBookingRequests => 'Booking Requests';

  @override
  String get ownerOccupancyOccupied => 'Occupied';

  @override
  String get ownerOccupancyVacant => 'Vacant';

  @override
  String get ownerRequestStatusAwaitingResponse => 'Awaiting Response';

  @override
  String get ownerRequestStatusNewRequest => 'New Request';

  @override
  String get ownerPropertyLabel => 'Property';

  @override
  String get ownerTapToReviewRequest => 'Tap to review request';

  @override
  String get ownerBookingRequestTitle => 'Booking Request';

  @override
  String get ownerBookingRequestSubtitle =>
      'Review tenant details and confirm your decision quickly.';

  @override
  String get ownerTenantInformation => 'Tenant Information';

  @override
  String get ownerBookingDetails => 'Booking Details';

  @override
  String get ownerCheckInLabel => 'Check-in';

  @override
  String get ownerDurationLabel => 'Duration';

  @override
  String get ownerMonthlyRentLabel => 'Monthly Rent';

  @override
  String get ownerRequestSummary => 'Request Summary';

  @override
  String get ownerRequestDecisionPending => 'Pending Decision';

  @override
  String get ownerRequestDecisionApproved => 'Approved';

  @override
  String get ownerRequestDecisionRejected => 'Rejected';

  @override
  String get ownerDecision => 'Decision';

  @override
  String get ownerReject => 'Reject';

  @override
  String get ownerApprove => 'Approve';

  @override
  String get ownerAnalyticsTitle => 'Owner Analytics';

  @override
  String get ownerAnalyticsSubtitle =>
      'Performance overview for your rental business this month.';

  @override
  String get ownerStatNetEarnings => 'Net Earnings';

  @override
  String get ownerRentalTypeDistribution => 'Rental Type Distribution';

  @override
  String get ownerOccupancyRate => 'Occupancy Rate';

  @override
  String get ownerOccupancyRateDescription =>
      '91% of your listed units are currently occupied.';

  @override
  String get monthShortJan => 'Jan';

  @override
  String get monthShortFeb => 'Feb';

  @override
  String get monthShortMar => 'Mar';

  @override
  String get monthShortApr => 'Apr';

  @override
  String get monthShortMay => 'May';

  @override
  String get monthShortJun => 'Jun';

  @override
  String get rentalTypeCondo => 'Condo';

  @override
  String get rentalTypeApartment => 'Apartment';

  @override
  String get rentalTypeRoom => 'Room';

  @override
  String get rentalTypeLanded => 'Landed';

  @override
  String formFieldRequired(Object fieldName) {
    return '$fieldName is required';
  }

  @override
  String get formEmailInvalid => 'Please enter a valid email address';

  @override
  String get formPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get formPasswordMismatch =>
      'Password and confirm password do not match';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPassword => 'Password';

  @override
  String get authLogin => 'Login';

  @override
  String get authRegister => 'Register';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Login to continue your HomeU journey.';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNewHere => 'New here?';

  @override
  String get loginSuccess => 'Login successful.';

  @override
  String get loginErrorBackendNotInitialized =>
      'Backend is not initialized. Please check your Supabase configuration.';

  @override
  String get loginErrorIncomplete =>
      'Login could not be completed. Please try again.';

  @override
  String get loginErrorProfileRoleMissing =>
      'Your profile role is missing. Please contact support.';

  @override
  String get loginErrorNetwork =>
      'Network error. Please check your internet connection and try again.';

  @override
  String get loginErrorProfileRead =>
      'Unable to read your profile right now. Please try again.';

  @override
  String get loginErrorUnexpected =>
      'Unexpected error during login. Please try again.';

  @override
  String get loginErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get loginErrorGeneric =>
      'Unable to login right now. Please try again.';

  @override
  String get registerTitle => 'Create Your Account';

  @override
  String get registerSubtitle => 'Join HomeU and start your rental journey.';

  @override
  String get registerNameHint => 'Your full name';

  @override
  String get registerPasswordHint => 'Create a password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerConfirmPasswordHint => 'Re-enter your password';

  @override
  String get registerSelectRole => 'Select Account Role';

  @override
  String get registerRoleInfo =>
      'Your selected role controls accessible features and navigation. To switch roles later, log out and register again under the other role.';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account?';

  @override
  String get registerBackToLogin => 'Back to Login';

  @override
  String get registerSuccessLocalMode =>
      'Registered in local mode. Connect Supabase for real account creation.';

  @override
  String get registerSuccessAccountCreated => 'Account created successfully.';

  @override
  String get registerErrorSignUpIncomplete =>
      'Unable to complete sign up right now. Please try again.';

  @override
  String get registerErrorDuplicateEmail => 'This email is already in use.';

  @override
  String get registerErrorProfileUnavailable =>
      'Account created, but profile is unavailable right now. Please try again.';

  @override
  String get registerErrorUnexpected =>
      'Unexpected error during registration. Please try again.';

  @override
  String get registerErrorNetwork =>
      'Network error. Please check your internet connection and try again.';

  @override
  String get registerErrorGeneric =>
      'Unable to sign up right now. Please try again.';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your registered email address and we will send you a password reset link.';

  @override
  String get forgotPasswordEmailNote =>
      'Please use your real email address because the password reset link will be sent to your inbox.';

  @override
  String get forgotPasswordEmailAddress => 'Email Address';

  @override
  String get forgotPasswordSendResetLink => 'Send Reset Link';

  @override
  String get forgotPasswordCheckEmail => 'Check Your Email';

  @override
  String get forgotPasswordNoEmailHint =>
      'Didn\'t receive the email? Check your spam folder or try again.';

  @override
  String get forgotPasswordSuccessDefault =>
      'A password reset link has been sent to your email.';

  @override
  String get forgotPasswordErrorRateLimit =>
      'Too many attempts. Please wait a while and try again.';

  @override
  String get forgotPasswordErrorNetwork =>
      'Network error. Please check your internet connection and try again.';

  @override
  String get forgotPasswordErrorGeneric =>
      'Unable to send reset link right now. Please try again.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String onboardingStepProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get onboardingStep1Title => 'Browse Rental Properties';

  @override
  String get onboardingStep1Subtitle =>
      'Discover rooms, houses, condos, and apartments that match your lifestyle and budget.';

  @override
  String get onboardingFilters => 'Filters';

  @override
  String get onboardingExampleListing1Title => 'City Condo';

  @override
  String get onboardingExampleListing1Subtitle => '2 Beds • Downtown';

  @override
  String get onboardingExampleListing1Price => '\$1,250/mo';

  @override
  String get onboardingExampleListing2Title => 'Cozy Studio';

  @override
  String get onboardingExampleListing2Subtitle => '1 Bed • Near Campus';

  @override
  String get onboardingExampleListing2Price => '\$780/mo';

  @override
  String get onboardingStep2Title => 'List Your Property Easily';

  @override
  String get onboardingStep2Subtitle =>
      'Add your property, upload photos, and manage rental requests in one place.';

  @override
  String get ownerNewListing => 'New Listing';

  @override
  String get ownerPropertyType => 'Property Type';

  @override
  String get ownerUploadPhotos => 'Upload Photos';

  @override
  String get ownerLocationAndPrice => 'Location & Price';

  @override
  String get ownerNewRentalRequests => '3 New Rental Requests';

  @override
  String get onboardingStep3Title => 'Secure Booking & Payment';

  @override
  String get onboardingStep3Subtitle =>
      'Book viewings, confirm rentals, and complete payment through a safe and simple process.';

  @override
  String get onboardingViewingConfirmed => 'Viewing Confirmed';

  @override
  String get onboardingSecurePayment => 'Secure Payment';

  @override
  String get onboardingProtected => 'Protected';

  @override
  String get updatePasswordSuccessMessage =>
      'Your password has been updated successfully.';

  @override
  String get updatePasswordStrongPasswordTip =>
      'Use a strong password with letters, numbers, and symbols.';

  @override
  String get updatePasswordCurrentPasswordLabel => 'Current Password';

  @override
  String get updatePasswordCurrentPasswordHint => 'Enter current password';

  @override
  String get updatePasswordNewPasswordLabel => 'New Password';

  @override
  String get updatePasswordNewPasswordHint => 'Enter new password';

  @override
  String get updatePasswordConfirmPasswordLabel => 'Confirm New Password';

  @override
  String get updatePasswordConfirmPasswordHint => 'Re-enter new password';

  @override
  String get updatePasswordValidationCurrentRequired =>
      'Current password is required';

  @override
  String get updatePasswordValidationNewRequired => 'New password is required';

  @override
  String get updatePasswordValidationMinLength =>
      'New password must be at least 6 characters';

  @override
  String get updatePasswordValidationConfirmRequired =>
      'Confirm new password is required';

  @override
  String get updatePasswordValidationMismatch =>
      'New password and confirmation do not match';

  @override
  String get updatePasswordErrorCurrentPasswordIncorrect =>
      'Current password is incorrect.';

  @override
  String get updatePasswordErrorBackendNotInitialized =>
      'Backend is not initialized. Please check Supabase configuration.';

  @override
  String get updatePasswordErrorVerifyCurrentPasswordUnavailable =>
      'Unable to verify your current password right now. Please sign in again.';

  @override
  String get updatePasswordErrorSessionExpired =>
      'Reset link is invalid or expired. Please request a new password reset email.';

  @override
  String get updatePasswordErrorNewPasswordMustDiffer =>
      'New password must be different from your current password.';

  @override
  String get updatePasswordErrorWeakPassword =>
      'Please choose a stronger password with at least 6 characters.';

  @override
  String get updatePasswordErrorNetwork =>
      'Network error. Please check your internet connection and try again.';

  @override
  String get updatePasswordErrorGeneric =>
      'Unable to update password right now. Please try again.';

  @override
  String get chatTitle => 'Messages';

  @override
  String get chatSearchHint => 'Search messages...';

  @override
  String get chatFilterAll => 'All';

  @override
  String get chatFilterUnread => 'Unread';

  @override
  String get chatFilterProperty => 'Property';

  @override
  String get chatFilterArchived => 'Archived';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get chatOnline => 'Online';

  @override
  String get chatOffline => 'Offline';

  @override
  String get chatTypeMessageHint => 'Type a message...';

  @override
  String get chatAttachmentTitle => 'Send Attachment';

  @override
  String get chatAttachImage => 'Image';

  @override
  String get chatAttachCamera => 'Camera';

  @override
  String get chatAttachDocument => 'Document';
}
