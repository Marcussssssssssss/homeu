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
  String get splashTagline => 'Find Your Perfect Home';

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
  String get loginDividerOr => 'OR';

  @override
  String get loginBiometricReason => 'Authenticate to access HomeU';

  @override
  String get loginSessionExpired =>
      'Session expired. Please login with email and password.';

  @override
  String get loginBiometricFailed =>
      'Biometric authentication failed or cancelled.';

  @override
  String loginContinueAs(Object name) {
    return 'Continue as $name';
  }

  @override
  String get loginUseBiometrics => 'Use Biometrics';

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
  String get registerPhoneHint => '+60 12 345 6789';

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
  String get viewingScheduleTitle => 'Schedule Viewing';

  @override
  String get viewingSelectSlotTitle => 'Select an Available Slot';

  @override
  String get viewingSelectSlotSubtitle =>
      'Owners only display slots they are available for. Select one to proceed.';

  @override
  String get viewingNoSlotsTitle => 'No Available Slots';

  @override
  String get viewingNoSlotsSubtitle =>
      'The owner has not listed any availability for this property yet. Please check back later or contact the owner.';

  @override
  String get viewingGoBack => 'Go Back';

  @override
  String get viewingConfirmRequest => 'Confirm Request';

  @override
  String get viewingAlreadyScheduled =>
      'You have already scheduled a viewing for this time slot. Please check your Requests.';

  @override
  String get viewingRequestSent => 'Request Sent!';

  @override
  String viewingErrorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get bookingDetailsTitle => 'Booking Details';

  @override
  String get bookingPaymentScheduleTitle => 'Payment Schedule';

  @override
  String get bookingPaymentScheduleEmpty =>
      'No payment schedule generated yet.';

  @override
  String bookingMonthLabel(Object number) {
    return 'Month $number';
  }

  @override
  String bookingMonthWithFee(Object number) {
    return 'Month $number (Booking Fee)';
  }

  @override
  String bookingDueLabel(Object date) {
    return 'Due: $date';
  }

  @override
  String get bookingViewReceipt => 'View Receipt';

  @override
  String bookingAmountRm(Object amount) {
    return 'RM $amount';
  }

  @override
  String get bookingPaid => 'PAID';

  @override
  String get bookingUpcoming => 'UPCOMING';

  @override
  String get bookingPayNow => 'Pay Now';

  @override
  String get bookingReceiptNotFound => 'No receipt found for this payment.';

  @override
  String bookingReceiptError(Object message) {
    return 'Error loading receipt: $message';
  }

  @override
  String get reviewRatingTitle => 'Review & Rating';

  @override
  String get reviewRatingSubtitle =>
      'Share your experience to help future tenants make better decisions.';

  @override
  String get reviewAverageLabel => 'Average Rating';

  @override
  String get reviewYourRatingLabel => 'Your Rating';

  @override
  String get reviewCommentLabel => 'Comment';

  @override
  String get reviewCommentHint =>
      'Tell us about cleanliness, owner communication, and your overall experience.';

  @override
  String get reviewSubmitLabel => 'Submit';

  @override
  String get reviewSubmitSuccess =>
      'Thank you. Your review has been submitted.';

  @override
  String reviewStarLabel(Object count) {
    return '$count star';
  }

  @override
  String get compareTitle => 'Compare Properties';

  @override
  String get compareClear => 'Clear';

  @override
  String get compareEmptyTitle => 'No Properties Selected';

  @override
  String get compareEmptySubtitle =>
      'Go back and select 2 properties\nto start comparing';

  @override
  String get compareBackToListings => 'Back to Listings';

  @override
  String get comparePriceRangeLabel => 'Price Range';

  @override
  String comparePriceRangeValue(Object min, Object max) {
    return 'RM $min - RM $max';
  }

  @override
  String compareSaveAmount(Object amount) {
    return 'Save RM $amount';
  }

  @override
  String get compareLabelAddress => 'Address';

  @override
  String get compareLabelType => 'Type';

  @override
  String get compareLabelRooms => 'Rooms';

  @override
  String get compareLabelFurnishing => 'Furnishing';

  @override
  String get compareLabelOwner => 'Owner';

  @override
  String get compareLabelAvailability => 'Availability';

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

  @override
  String get receiptTitle => 'Payment Receipt';

  @override
  String get receiptSuccess => 'Payment Successful';

  @override
  String get receiptTransactionId => 'Transaction ID';

  @override
  String get receiptProperty => 'Property';

  @override
  String get receiptLocation => 'Location';

  @override
  String get receiptPaymentDate => 'Payment Date';

  @override
  String get receiptPaymentMethod => 'Payment Method';

  @override
  String get receiptInstallment => 'Installment';

  @override
  String receiptMonth(Object number) {
    return 'Month $number';
  }

  @override
  String get receiptTotalAmount => 'Total Amount';

  @override
  String get receiptDownload => 'Download';

  @override
  String get receiptShare => 'Share';

  @override
  String get receiptFooter => 'Thank you for using HomeU!';

  @override
  String paymentAmountRm(Object amount) {
    return 'RM $amount';
  }

  @override
  String get bookingTitle => 'Booking';

  @override
  String get bookingConflictDetected =>
      'Conflict detected with an existing booking.';

  @override
  String get bookingFeeNotice =>
      'Paying the booking fee locks this property. The remaining balance is due after owner approval.';

  @override
  String bookingPayFee(Object amount) {
    return 'Pay Booking Fee (RM $amount)';
  }

  @override
  String get bookingSelectedProperty => 'Selected Property';

  @override
  String bookingConflictDetails(Object date) {
    return 'Property is already booked starting from $date. Please choose a shorter duration or different start date.';
  }

  @override
  String get bookingDurationTitle => 'Rental Duration';

  @override
  String bookingDurationMonths(Object count) {
    return '$count months';
  }

  @override
  String get bookingStartDateTitle => 'Start Date';

  @override
  String bookingOccupiedUntil(Object date) {
    return 'Property is occupied until $date';
  }

  @override
  String get bookingTotalPriceTitle => 'Total Price Calculation';

  @override
  String get bookingMonthlyPriceLabel => 'Monthly Price';

  @override
  String bookingDurationSummary(Object months) {
    return 'Duration ($months months)';
  }

  @override
  String get bookingEstimatedTotalLabel => 'Estimated Total';

  @override
  String get paymentSupabaseUnavailable =>
      'Supabase is not initialized. Please try again later.';

  @override
  String get bookingLoginRequired => 'Please log in to continue booking.';

  @override
  String get bookingDurationJustBooked =>
      'Sorry, this duration was just booked by another tenant.';

  @override
  String get bookingCreateFailed =>
      'Unable to create booking. Please try again.';

  @override
  String bookingCreateError(Object error) {
    return 'Create booking failed: $error';
  }

  @override
  String get statusAll => 'All';

  @override
  String get ownerRequestsTitle => 'Requests';

  @override
  String get ownerRequestsBookingsTab => 'Bookings';

  @override
  String get ownerRequestsViewingsTab => 'Viewings';

  @override
  String get ownerRequestsRetry => 'Retry';

  @override
  String ownerRequestsEmpty(Object filter) {
    return 'No \"$filter\" requests.';
  }

  @override
  String ownerRequestsMoveIn(Object date, Object months) {
    return 'Moves in: $date  •  $months months';
  }

  @override
  String ownerRequestsFlexibleDuration(Object months) {
    return 'Flexible  •  $months months';
  }

  @override
  String ownerRequestsMonthlyPrice(Object price) {
    return 'RM $price / mo';
  }

  @override
  String get ownerRequestsReview => 'Review';

  @override
  String ownerRequestsViewingsEmpty(Object filter) {
    return 'No \"$filter\" viewing requests.';
  }

  @override
  String ownerRequestsViewingTime(Object date, Object time) {
    return '$date  •  $time';
  }

  @override
  String get ownerRequestsDecline => 'Decline';

  @override
  String get ownerRequestsApprove => 'Approve';

  @override
  String get ownerRequestsMarkCompleted => 'Mark as Completed';

  @override
  String ownerGreeting(Object name) {
    return 'Hello, $name';
  }

  @override
  String get ownerRecentProperties => 'Recent Properties';

  @override
  String get ownerNoProperties => 'No properties listed yet';

  @override
  String get ownerAddFirstProperty => 'Add your first property';

  @override
  String get ownerUntitledProperty => 'Untitled';

  @override
  String get ownerRecentBookingRequests => 'Recent Booking Requests';

  @override
  String get ownerNoBookingRequests => 'No active booking requests';

  @override
  String get ownerUnknownProperty => 'Unknown Property';

  @override
  String get ownerUnknownTenant => 'Unknown Tenant';

  @override
  String get ownerRecentViewingRequests => 'Recent Viewing Requests';

  @override
  String get ownerNoViewingRequests => 'No active viewing requests';

  @override
  String get ownerTapToReviewViewing => 'Tap to review viewing';

  @override
  String get ownerProjected30Days => 'Projected (30 Days)';

  @override
  String get ownerOverduePayments => 'Overdue Payments';

  @override
  String get ownerInvoiceCollectionRate => 'Invoice Collection Rate';

  @override
  String get monthShortJul => 'Jul';

  @override
  String get monthShortAug => 'Aug';

  @override
  String get monthShortSep => 'Sep';

  @override
  String get monthShortOct => 'Oct';

  @override
  String get monthShortNov => 'Nov';

  @override
  String get monthShortDec => 'Dec';

  @override
  String get profileBiometricUnavailable =>
      'Biometric authentication is not available or not set up on this device.';

  @override
  String get profileBiometricReason =>
      'Please authenticate to enable biometric login';

  @override
  String get profileBiometricEnabled => 'Biometric login enabled successfully.';

  @override
  String get profileBiometricSaveFailed =>
      'Failed to update biometric preference.';

  @override
  String get profileBiometricDisabled => 'Biometric login disabled.';

  @override
  String get profileErrorSaveBiometric =>
      'Failed to save biometric preference.';

  @override
  String get profileLogoutTitle => 'Log out?';

  @override
  String get profileLogoutMessage =>
      'Are you sure you want to log out of your HomeU account?';

  @override
  String get profileLogoutCancel => 'Cancel';

  @override
  String get profileLogoutConfirm => 'Log Out';

  @override
  String get profileFavoritesSubtitle => 'View your saved properties';

  @override
  String get profileBiometricTitle => 'Biometric Login';

  @override
  String get profileBiometricSubtitle => 'Unlock HomeU with biometrics';

  @override
  String get adminDashboardLoadError =>
      'Failed to load system overview. Please check your connection.';

  @override
  String get adminDashboardTitle => 'Admin Dashboard';

  @override
  String get adminDashboardWelcome => 'Welcome, Admin';

  @override
  String get adminDashboardOverview => 'System Overview';

  @override
  String get adminTotalUsers => 'Total Users';

  @override
  String get adminTotalOwners => 'Owners';

  @override
  String get adminTotalTenants => 'Tenants';

  @override
  String get adminPendingReports => 'Pending Reports';

  @override
  String get adminManagementTitle => 'Management';

  @override
  String get adminReportsReview => 'Reports Review';

  @override
  String adminReportsSummary(Object pending, Object total) {
    return '$pending pending of $total total reports';
  }

  @override
  String get adminManagementTile => 'Admin Management';

  @override
  String get adminManagementSubtitle => 'Manage system administrators';

  @override
  String get adminAuditLogsTitle => 'Audit Logs';

  @override
  String get adminAuditLogsSubtitle => 'View system-wide activity logs';

  @override
  String get adminCreatedSuccess => 'Admin account created successfully.';

  @override
  String get adminUpdateDetailsTitle => 'Update Admin Details';

  @override
  String get adminUpdateDetailsConfirm => 'Update';

  @override
  String get adminDetailsUpdated => 'Admin details updated.';

  @override
  String adminUpdateError(Object error) {
    return 'Error: $error';
  }

  @override
  String get adminCannotRemoveSelf =>
      'Security: You cannot remove your own admin access.';

  @override
  String get adminRemoveTitle => 'Remove Admin?';

  @override
  String adminRemoveMessage(Object name) {
    return 'Remove admin privileges from $name? They will revert to a Tenant role.';
  }

  @override
  String get adminRemoveConfirm => 'Remove';

  @override
  String get adminRemovedSuccess => 'Admin privileges removed.';

  @override
  String adminRemoveError(Object error) {
    return 'Error: $error';
  }

  @override
  String get adminAddButton => 'Add Admin';

  @override
  String get adminNoAdminsFound => 'No admins found.';

  @override
  String get adminNavDashboard => 'Dashboard';

  @override
  String get adminNavReports => 'Reports';

  @override
  String get adminNavChat => 'Chat';

  @override
  String get adminNavLogs => 'Logs';

  @override
  String get adminNavProfile => 'Profile';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonRefreshTooltip => 'Refresh';

  @override
  String get statusReviewed => 'Reviewed';

  @override
  String get statusDismissed => 'Dismissed';

  @override
  String get adminReportsTitle => 'Reports Review';

  @override
  String get adminReportsSearchHint =>
      'Search report, owner, tenant, listing...';

  @override
  String get adminReportsFilterTooltip => 'Filter reports';

  @override
  String get adminReportsActiveFilterLabel => 'Active filter:';

  @override
  String get adminReportsNoMatches => 'No reports match the current filters.';

  @override
  String get adminReportsFilterTitle => 'Filter Reports';

  @override
  String get adminReportsFilterSectionStatus => 'Report Status';

  @override
  String get adminReportsFilterClear => 'Clear Filter';

  @override
  String get adminReportsFilterApply => 'Apply Filter';

  @override
  String get adminReportsUnknownListing => 'Unknown listing';

  @override
  String get adminReportsUnknownReportId => 'Unknown';

  @override
  String adminReportsPropertyIdFallback(Object propertyId) {
    return 'Property #$propertyId';
  }

  @override
  String get adminReportsNotAvailable => 'N/A';

  @override
  String get adminReportsUnknownOwner => 'Unknown owner';

  @override
  String get adminReportsUnknownReporter => 'Unknown reporter';

  @override
  String get adminReportsUnknownEmail => '-';

  @override
  String adminReportsLoadError(Object error) {
    return 'Failed to load reports: $error';
  }

  @override
  String get adminReportsMissingOwnerOrPropertyChat =>
      'Missing owner or property context for chat.';

  @override
  String get adminReportsMissingTenantOrPropertyChat =>
      'Missing tenant or property context for chat.';

  @override
  String get adminReportsAuditContactOwnerReason =>
      'Opened owner chat for report follow-up.';

  @override
  String get adminReportsAuditContactTenantReason =>
      'Opened tenant chat for report follow-up.';

  @override
  String adminReportsChatOpenError(Object error) {
    return 'Unable to open chat: $error';
  }

  @override
  String get adminReportsRecordRiskLevelAction => 'Record Risk Level';

  @override
  String get adminReportsRiskRecorded => 'Risk level recorded.';

  @override
  String adminReportsRiskRecordError(Object error) {
    return 'Risk evaluation failed: $error';
  }

  @override
  String adminReportsActionCompleted(Object actionLabel) {
    return '$actionLabel completed.';
  }

  @override
  String adminReportsUpdateError(Object error) {
    return 'Report update failed: $error';
  }

  @override
  String adminReportsReportTitle(Object reportId) {
    return 'Report #$reportId';
  }

  @override
  String adminReportsSubmittedOn(Object date) {
    return 'Submitted on $date';
  }

  @override
  String get adminReportsSectionProperty => 'Property';

  @override
  String get adminReportsSectionOwner => 'Owner';

  @override
  String get adminReportsSectionReporter => 'Reporter';

  @override
  String get adminReportsSectionComplaint => 'Complaint';

  @override
  String get adminReportsFieldPropertyId => 'Property ID';

  @override
  String get adminReportsFieldTitle => 'Title';

  @override
  String get adminReportsFieldName => 'Name';

  @override
  String get adminReportsFieldEmail => 'Email';

  @override
  String get adminReportsFieldTotalReports => 'Total reports';

  @override
  String get adminReportsFieldReason => 'Reason';

  @override
  String get adminReportsFieldDescription => 'Description';

  @override
  String get adminReportsFieldStatus => 'Status';

  @override
  String get adminReportsRiskSectionTitle => 'Risk evaluation';

  @override
  String get adminReportsRiskSectionHint =>
      'Internal review only. This does not change listing visibility or account status.';

  @override
  String get adminReportsReviewedConfirmTitle =>
      'I have reviewed this complaint.';

  @override
  String get adminReportsReviewedConfirmSubtitle =>
      'Risk evaluation and status updates unlock after this confirmation.';

  @override
  String get adminReportsActionsTitle => 'Actions';

  @override
  String get adminReportsActionsHint =>
      'Use chat for follow-up, then record the internal risk level or update the report status.';

  @override
  String get adminReportsContactOwner => 'Contact Owner';

  @override
  String get adminReportsContactReporter => 'Contact Reporter';

  @override
  String get adminReportsSaveRisk => 'Save Risk Level';

  @override
  String get adminReportsMarkReviewed => 'Mark Reviewed';

  @override
  String get adminReportsDismissReport => 'Dismiss Report';

  @override
  String adminReportsOwnerLabel(Object name) {
    return 'Owner: $name';
  }

  @override
  String adminReportsReporterLabel(Object name) {
    return 'Reporter: $name';
  }

  @override
  String adminReportsReasonLabel(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get adminReportsReasonDialogPrompt =>
      'Provide a reason and confirm this moderation action.';

  @override
  String get adminReportsReasonDialogLabel => 'Admin reason';

  @override
  String get adminReportsReasonDialogHint => 'Add clear moderation context';

  @override
  String get adminReportsReasonDialogConfirm => 'I confirm this action.';

  @override
  String get adminReportsRiskLow => 'Low';

  @override
  String get adminReportsRiskMedium => 'Medium';

  @override
  String get adminReportsRiskHigh => 'High';

  @override
  String get adminReportsRiskInvalid => 'Invalid';

  @override
  String get adminAuditTitle => 'System Audit Logs';

  @override
  String get adminAuditClearFiltersTooltip => 'Clear Filters';

  @override
  String get adminAuditSearchHint => 'Search descriptions...';

  @override
  String get adminAuditAllDates => 'All Dates';

  @override
  String adminAuditDateRange(Object start, Object end) {
    return '$start - $end';
  }

  @override
  String get adminAuditTableFilterHint => 'Table';

  @override
  String get adminAuditActionFilterHint => 'Action';

  @override
  String get adminAuditEmptyState =>
      'No audit logs found matching your criteria.';

  @override
  String get adminAuditClearAllFilters => 'Clear all filters';

  @override
  String get adminAuditUnknownTime => 'Unknown Time';

  @override
  String get adminAuditNoDetails => 'No details available';

  @override
  String get adminAuditSystemActor => 'System / Anonymous';

  @override
  String get adminAuditUnknownRole => 'unknown';

  @override
  String get adminAuditNotAvailable => 'N/A';

  @override
  String get adminAuditActorLabel => 'Actor';

  @override
  String get adminAuditTargetTableLabel => 'Target Table';

  @override
  String get adminAuditTargetIdLabel => 'Target ID';

  @override
  String get adminAuditTableProfiles => 'Profiles';

  @override
  String get adminAuditTableProperties => 'Properties';

  @override
  String get adminAuditTableBookings => 'Bookings';

  @override
  String get adminAuditTablePropertyReports => 'Property Reports';

  @override
  String get adminAuditTableReports => 'Reports';

  @override
  String get adminAuditTableAuditLogs => 'Audit Logs';

  @override
  String get adminAuditActionAdminCreated => 'Admin Created';

  @override
  String get adminAuditActionAdminUpdated => 'Admin Updated';

  @override
  String get adminAuditActionAdminRemoved => 'Admin Removed';

  @override
  String get adminAuditActionReportContactOwner => 'Report: Contact Owner';

  @override
  String get adminAuditActionReportContactTenant => 'Report: Contact Tenant';

  @override
  String get adminAuditActionReportRiskLow => 'Report: Risk Low';

  @override
  String get adminAuditActionReportRiskMedium => 'Report: Risk Medium';

  @override
  String get adminAuditActionReportRiskHigh => 'Report: Risk High';

  @override
  String get adminAuditActionReportRiskInvalid => 'Report: Risk Invalid';

  @override
  String get adminAuditActionReportReviewed => 'Report: Reviewed';

  @override
  String get adminAuditActionReportDismissed => 'Report: Dismissed';

  @override
  String get adminAuditActionPropertyApproved => 'Property Approved';

  @override
  String get adminAuditActionPropertyRejected => 'Property Rejected';

  @override
  String get adminAuditActionProfileUpdate => 'Profile Updated';

  @override
  String adminAuditLoadError(Object error) {
    return 'Failed to load logs: $error';
  }

  @override
  String get propertyReportTitle => 'Report Property';

  @override
  String get propertyReportSubtitle =>
      'Please select a reason for reporting this property. Our team will review it shortly.';

  @override
  String get propertyReportReasonFake => 'Fake listing / Scam';

  @override
  String get propertyReportReasonSuspicious => 'Suspicious activity';

  @override
  String get propertyReportReasonWrongDetails => 'Incorrect property details';

  @override
  String get propertyReportReasonInappropriate => 'Inappropriate content';

  @override
  String get propertyReportReasonOther => 'Other';

  @override
  String get propertyReportDescriptionHint =>
      'Provide additional details (optional)';

  @override
  String get propertyReportCancel => 'Cancel';

  @override
  String get propertyReportSubmit => 'Submit Report';

  @override
  String get propertyReportSubmitted =>
      'Report submitted successfully. Thank you.';

  @override
  String get propertyReportSubmitFailed =>
      'Failed to submit report. Please try again.';

  @override
  String get propertyReportServiceUnavailable =>
      'Report service is currently unavailable. Please check your connection.';

  @override
  String get propertyReportLoginRequired => 'Please log in to submit a report.';

  @override
  String get propertyReportTenantOnly =>
      'Only tenants can submit property reports.';

  @override
  String get propertyReportOwnProperty =>
      'You cannot report your own property.';

  @override
  String get propertyReportInvalidMetadata =>
      'Invalid property metadata. Unable to report.';

  @override
  String get propertyFacilitiesTitle => 'Facilities';

  @override
  String get propertyNoFacilities => 'No facilities listed.';

  @override
  String get propertyOwnerInfoTitle => 'Owner Information';

  @override
  String get propertyOwnerHighRisk => 'High Risk';

  @override
  String get propertyOwnerSuspicious => 'Suspicious Owner';

  @override
  String get propertyOwnerSuspended => 'Suspended';

  @override
  String get propertyOwnerRemoved => 'Removed';

  @override
  String get propertyAvailabilityTitle => 'Availability';

  @override
  String get propertyAvailabilityLabel => 'Availability:';

  @override
  String get propertyStatusActive => 'Active';

  @override
  String get propertyStatusOccupied => 'Occupied';

  @override
  String get propertyStatusInactive => 'Inactive';

  @override
  String get propertyReportErrorPermission =>
      'Unable to submit report due to permission policy. Please contact support.';

  @override
  String get propertyReportErrorInvalidListing =>
      'Unable to submit report because the listing reference is invalid.';

  @override
  String get propertyReportErrorInvalidData =>
      'Unable to submit report because the listing data is invalid.';

  @override
  String propertyNearbyLabel(Object landmarks) {
    return 'Nearby: $landmarks';
  }

  @override
  String get propertyDetailsTitle => 'Property Details';

  @override
  String get propertyUnavailableAdmin =>
      'This property is currently unavailable due to moderation.';

  @override
  String get propertyUnavailableBooking =>
      'This property is currently occupied and not available for booking.';

  @override
  String get propertyFavoriteLoginRequired =>
      'Please login to add to favorites.';

  @override
  String get propertyFavoriteTenantOnly => 'Only tenants can save favorites.';

  @override
  String get propertyFavoritePolicyBlocked =>
      'Unable to update favorite due to security policy.';

  @override
  String get propertyFavoriteUpdateFailed =>
      'Failed to update favorite. Please try again.';

  @override
  String get propertyHighRiskTag => 'High Risk';

  @override
  String get propertyLocationTitle => 'Location';

  @override
  String get propertyDescriptionTitle => 'Description';

  @override
  String get bookingBookNow => 'Book Now';

  @override
  String get bookingHistoryEmpty => 'No bookings found matching your criteria.';

  @override
  String get ownerAvailabilityEndAfterStart =>
      'End time must be after start time.';

  @override
  String get ownerAvailabilityPastDate => 'Cannot add slots for past dates.';

  @override
  String get ownerAvailabilityOverlap =>
      'This slot overlaps with an existing one.';

  @override
  String get ownerAvailabilitySlotAdded =>
      'Availability slot added successfully.';

  @override
  String get ownerAvailabilityAddFailed =>
      'Failed to add availability slot. Please try again.';

  @override
  String get ownerAvailabilityDeleteFailed =>
      'Failed to delete slot. Please try again.';

  @override
  String ownerAvailabilityDateTime(Object date, Object time) {
    return '$date at $time';
  }

  @override
  String get ownerAvailabilityCreateSlot => 'Create New Availability Slot';

  @override
  String get ownerAvailabilitySelectDate => 'Select Date';

  @override
  String get ownerAvailabilityStartTime => 'Start Time';

  @override
  String get ownerAvailabilityEndTime => 'End Time';

  @override
  String get ownerAvailabilityActiveSlots => 'Your Available Slots';

  @override
  String get ownerAvailabilityStatusAvailable => 'Available';

  @override
  String get ownerAvailabilityStatusBooked => 'Booked';

  @override
  String get ownerAvailabilityStatusApproved => 'Approved';

  @override
  String get ownerAvailabilityDeleteConfirmTitle => 'Delete Slot?';

  @override
  String get ownerAvailabilityDeleteConfirmMessage =>
      'Are you sure you want to delete this availability slot?';

  @override
  String get ownerAvailabilityEmpty => 'No availability slots added yet.';

  @override
  String get ownerAvailabilityAddSlot => 'Add Slot';

  @override
  String get ownerAvailabilityBooked => 'Booked';

  @override
  String get ownerAvailabilityAvailable => 'Available';

  @override
  String get ownerAvailabilityTitle => 'Viewing Availability';

  @override
  String get paymentCardIncomplete => 'Please enter a full card expiry date.';

  @override
  String get paymentCardInvalidMonth => 'Invalid month (01-12).';

  @override
  String get paymentCardExpired => 'Card has expired.';

  @override
  String get paymentCardInvalidFormat => 'Invalid expiry format (MM/YY).';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentCompletedLabel => 'Payment Completed';

  @override
  String get paymentPayNow => 'Pay Now';

  @override
  String get paymentMethodTitle => 'Payment Method';

  @override
  String get paymentMethodCard => 'Credit/Debit Card';

  @override
  String get paymentMethodBanking => 'Online Banking';

  @override
  String get paymentSelectBank => 'Select Bank';

  @override
  String get paymentCardNumberLabel => 'Card Number';

  @override
  String get paymentCardNumberHint => 'XXXX XXXX XXXX XXXX';

  @override
  String get paymentExpiryLabel => 'Expiry Date';

  @override
  String get paymentExpiryHint => 'MM/YY';

  @override
  String get paymentCvvLabel => 'CVV';

  @override
  String get paymentCvvHint => 'XXX';

  @override
  String get paymentAmountLabel => 'Amount to Pay';

  @override
  String get paymentTotalLabel => 'Total Price';

  @override
  String get paymentProcessing => 'Processing Payment...';

  @override
  String get paymentSuccess => 'Payment Successful!';

  @override
  String paymentSuccessSubtitle(Object amount) {
    return 'You have paid RM $amount.';
  }

  @override
  String get paymentBackToHome => 'Back to Home';

  @override
  String paymentError(Object message) {
    return 'Payment Error: $message';
  }

  @override
  String get paymentMethodEwallet => 'E-Wallet';

  @override
  String get paymentSelectEwallet => 'Select E-Wallet';

  @override
  String get paymentSelectEwalletError => 'Please select an E-Wallet.';

  @override
  String get paymentCardNumberInvalid => 'Invalid card number.';

  @override
  String get paymentCvvInvalid => 'Invalid CVV.';

  @override
  String get paymentSummaryTitle => 'Payment Summary';

  @override
  String get paymentSummaryProperty => 'Property';

  @override
  String get paymentSummaryStartDate => 'Start Date';

  @override
  String get paymentSummaryDuration => 'Duration';

  @override
  String get paymentSummaryMonthlyRent => 'Monthly Rent';

  @override
  String paymentDurationMonths(Object count) {
    return '$count months';
  }

  @override
  String get paymentSummaryMethod => 'Method';

  @override
  String paymentMethodWithBank(Object bank) {
    return 'Online Banking ($bank)';
  }

  @override
  String paymentMethodWithEwallet(Object wallet) {
    return 'E-Wallet ($wallet)';
  }

  @override
  String get paymentSummaryStatus => 'Status';

  @override
  String paymentRentMonth(Object number) {
    return 'Rent for Month $number';
  }

  @override
  String get paymentBookingFeeOneMonth => 'Booking Fee (1 Month)';

  @override
  String get paymentSelectBankError => 'Please select a bank.';

  @override
  String get paymentConfirmTitle => 'Confirm Payment';

  @override
  String get paymentConfirmMessage =>
      'Are you sure you want to proceed with the payment?';

  @override
  String get paymentSummaryAmount => 'Amount';

  @override
  String get paymentSummaryMethodLabel => 'Payment Method';

  @override
  String get paymentCancel => 'Cancel';

  @override
  String get paymentConfirmPay => 'Confirm & Pay';

  @override
  String get paymentFailed => 'Payment failed. Please try again.';

  @override
  String get paymentSuccessMessage => 'Payment processed successfully.';

  @override
  String paymentFailedWithMessage(Object message) {
    return 'Payment failed: $message';
  }

  @override
  String get paymentErrorDetailsAction => 'Details';

  @override
  String get paymentErrorDetailsTitle => 'Error Details';

  @override
  String get paymentOk => 'OK';

  @override
  String get paymentSuccessTitle => 'Payment Successful';

  @override
  String get paymentViewReceipt => 'View Receipt';

  @override
  String get paymentDismiss => 'Dismiss';

  @override
  String get paymentMethodCardShort => 'Card';

  @override
  String get paymentLoginRequired => 'Please log in to make a payment.';

  @override
  String get viewingHistoryPleaseLogin =>
      'Please log in to view your viewing history.';

  @override
  String get viewingHistoryTitle => 'Viewing History';

  @override
  String viewingHistoryErrorWithMessage(Object message) {
    return 'Error: $message';
  }

  @override
  String get viewingHistoryCancelTitle => 'Cancel Viewing';

  @override
  String get viewingHistoryCancelMessage =>
      'Are you sure you want to cancel this viewing appointment?';

  @override
  String get viewingHistoryKeepAppointment => 'Keep Appointment';

  @override
  String get viewingHistoryConfirmCancellation => 'Confirm Cancellation';

  @override
  String get viewingHistoryCancelledSuccess => 'Viewing appointment cancelled';

  @override
  String viewingHistoryCancelFailed(Object error) {
    return 'Failed to cancel viewing: $error';
  }

  @override
  String get viewingHistoryEmptyAll => 'No viewing requests yet.';

  @override
  String get viewingHistoryEmptyForStatus =>
      'No viewing requests found for this status.';

  @override
  String get viewingHistoryFallbackLocation => 'Location unavailable';

  @override
  String get viewingHistoryFallbackPrice => 'Price unavailable';

  @override
  String get viewingHistoryFallbackDescription =>
      'Property details are currently unavailable.';

  @override
  String get viewingHistoryFallbackHostRole => 'Host';

  @override
  String get viewingHistoryDateLabel => 'Viewing Date';

  @override
  String get viewingHistoryTimeLabel => 'Viewing Time';

  @override
  String get viewingHistoryScheduledLabel => 'Scheduled';

  @override
  String get viewingHistoryCancelAction => 'Cancel';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusRescheduled => 'Rescheduled';

  @override
  String get statusSlotTaken => 'Slot Taken';

  @override
  String get statusPropertyRented => 'Property Rented';
}
