// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'HomeU';

  @override
  String get navHome => 'Laman Utama';

  @override
  String get navFavorites => 'Kegemaran';

  @override
  String get navBookings => 'Tempahan';

  @override
  String get navProfile => 'Profil';

  @override
  String get homeGreetingAnonymous => 'Hai';

  @override
  String homeGreetingWithName(Object name) {
    return 'Hai, $name';
  }

  @override
  String get homeQuickSearchSubtitle =>
      'Cari sewaan seterusnya dengan carian pantas.';

  @override
  String get homeSearchHint => 'Cari lokasi, kondo, rumah';

  @override
  String get homeCategories => 'Kategori';

  @override
  String get homeRecommendedProperties => 'Hartanah Disyorkan';

  @override
  String get homeScanQr => 'Imbas QR';

  @override
  String get bookingHistoryTitle => 'Sejarah Tempahan';

  @override
  String get bookingHistorySubtitle =>
      'Jejaki kemas kini tempahan sewaan terkini dengan cepat.';

  @override
  String get bookingDateLabel => 'Tarikh Tempahan';

  @override
  String get rentalPeriodLabel => 'Tempoh Sewa';

  @override
  String get statusPending => 'Menunggu';

  @override
  String get statusApproved => 'Diluluskan';

  @override
  String get statusRejected => 'Ditolak';

  @override
  String get statusCompleted => 'Selesai';

  @override
  String get leaveReview => 'Beri Ulasan';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileRoleOwner => 'Pemilik';

  @override
  String get profileRoleAdmin => 'Pentadbir';

  @override
  String get profileRoleTenant => 'Penyewa';

  @override
  String get profileThemeTitle => 'Tema';

  @override
  String get profileThemeSubtitle => 'Pilih Terang, Gelap, atau Sistem lalai.';

  @override
  String get profileLanguageTitle => 'Bahasa';

  @override
  String get profileLanguageSubtitle => 'Pilih bahasa aplikasi pilihan anda.';

  @override
  String get profileUpdatePasswordTitle => 'Kemas Kini Kata Laluan';

  @override
  String get profileUpdatePasswordSubtitle =>
      'Tukar kata laluan untuk memastikan akaun anda selamat.';

  @override
  String get profileEditButton => 'Edit Profil';

  @override
  String get profileLogoutButton => 'Log Keluar';

  @override
  String get profileAccountDetails => 'Butiran Akaun';

  @override
  String get profileFieldName => 'Nama';

  @override
  String get profileFieldEmail => 'E-mel';

  @override
  String get profileFieldPhone => 'Nombor Telefon';

  @override
  String get profileFieldRole => 'Peranan';

  @override
  String get profileFieldAccountStatus => 'Status Akaun';

  @override
  String get profileFieldRiskStatus => 'Status Risiko';

  @override
  String get profileAccountStatusActive => 'Aktif';

  @override
  String get profileAccountStatusSuspended => 'Digantung';

  @override
  String get profileAccountStatusRemoved => 'Dibuang';

  @override
  String get profileRiskStatusNormal => 'Normal';

  @override
  String get profileRiskStatusSuspicious => 'Mencurigakan';

  @override
  String get profileRiskStatusHigh => 'Risiko Tinggi';

  @override
  String get profileEditSheetTitle => 'Edit Profil';

  @override
  String get profileEditSheetPhotoHint =>
      'Foto profil boleh ditukar melalui butang avatar di atas.';

  @override
  String get profileEditFieldFullName => 'Nama Penuh';

  @override
  String get profileEditFieldFullNameHint => 'Masukkan nama penuh';

  @override
  String get profileEditFieldEmailReadonly => 'E-mel (tidak boleh diedit)';

  @override
  String get profileEditFieldPhone => 'Nombor Telefon';

  @override
  String get profileEditFieldPhoneHint => 'Masukkan nombor telefon';

  @override
  String get profileEditSaveChanges => 'Simpan Perubahan';

  @override
  String get profileNamePhoneRequired => 'Nama dan nombor telefon diperlukan.';

  @override
  String get profileUpdatedSuccess => 'Profil berjaya dikemas kini.';

  @override
  String get profileErrorRefresh =>
      'Tidak dapat memuat semula profil sekarang. Memaparkan data yang tersedia.';

  @override
  String get profileErrorUpdate =>
      'Tidak dapat mengemas kini profil sekarang. Sila cuba lagi.';

  @override
  String get profileErrorUpload =>
      'Tidak dapat memuat naik foto profil sekarang. Sila cuba lagi.';

  @override
  String get profileErrorLanguageSave =>
      'Tidak dapat menyimpan pilihan bahasa sekarang. Sila cuba lagi.';

  @override
  String get profilePhotoChooseGallery => 'Pilih dari galeri';

  @override
  String get profilePhotoChooseGallerySubtitle =>
      'Pilih foto dari peranti anda.';

  @override
  String get profilePhotoTakeCamera => 'Ambil foto';

  @override
  String get profilePhotoTakeCameraSubtitle =>
      'Gunakan kamera anda untuk mengambil avatar baharu.';

  @override
  String get profilePhotoUpdatedSuccess => 'Foto profil berjaya dikemas kini.';

  @override
  String get profilePhotoAccessError =>
      'Tidak dapat mengakses foto sekarang. Sila cuba lagi.';

  @override
  String get profileThemeSaved => 'Pilihan tema disimpan.';

  @override
  String get profileLanguageSaved => 'Pilihan bahasa disimpan.';

  @override
  String get languageEnglish => 'Inggeris';

  @override
  String get languageMalay => 'Melayu';

  @override
  String get languageChinese => 'Cina';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get ownerNavDashboard => 'Papan Pemuka';

  @override
  String get ownerNavMyProperties => 'Hartanah Saya';

  @override
  String get ownerNavRequests => 'Permintaan';

  @override
  String get ownerNavAnalytics => 'Analitik';

  @override
  String get ownerDashboardSubtitle =>
      'Urus senarai, permintaan, dan prestasi di satu tempat.';

  @override
  String get ownerAddProperty => 'Tambah Hartanah';

  @override
  String get ownerMonthlyEarnings => 'Pendapatan Bulanan';

  @override
  String get ownerQuickStats => 'Statistik Ringkas';

  @override
  String get ownerActiveListings => 'Senarai Aktif';

  @override
  String get ownerPendingRequests => 'Permintaan Menunggu';

  @override
  String get ownerOccupancy => 'Penghunian';

  @override
  String get ownerMyProperties => 'Hartanah Saya';

  @override
  String get ownerBookingRequests => 'Permintaan Tempahan';

  @override
  String get ownerOccupancyOccupied => 'Diduduki';

  @override
  String get ownerOccupancyVacant => 'Kosong';

  @override
  String get ownerRequestStatusAwaitingResponse => 'Menunggu Respons';

  @override
  String get ownerRequestStatusNewRequest => 'Permintaan Baharu';

  @override
  String get ownerPropertyLabel => 'Hartanah';

  @override
  String get ownerTapToReviewRequest => 'Ketik untuk semak permintaan';

  @override
  String get ownerBookingRequestTitle => 'Permintaan Tempahan';

  @override
  String get ownerBookingRequestSubtitle =>
      'Semak butiran penyewa dan sahkan keputusan anda dengan cepat.';

  @override
  String get ownerTenantInformation => 'Maklumat Penyewa';

  @override
  String get ownerBookingDetails => 'Butiran Tempahan';

  @override
  String get ownerCheckInLabel => 'Daftar masuk';

  @override
  String get ownerDurationLabel => 'Tempoh';

  @override
  String get ownerMonthlyRentLabel => 'Sewa Bulanan';

  @override
  String get ownerRequestSummary => 'Ringkasan Permintaan';

  @override
  String get ownerRequestDecisionPending => 'Keputusan Menunggu';

  @override
  String get ownerRequestDecisionApproved => 'Diluluskan';

  @override
  String get ownerRequestDecisionRejected => 'Ditolak';

  @override
  String get ownerDecision => 'Keputusan';

  @override
  String get ownerReject => 'Tolak';

  @override
  String get ownerApprove => 'Lulus';

  @override
  String get ownerAnalyticsTitle => 'Analitik Pemilik';

  @override
  String get ownerAnalyticsSubtitle =>
      'Gambaran prestasi perniagaan sewa anda bulan ini.';

  @override
  String get ownerStatNetEarnings => 'Pendapatan Bersih';

  @override
  String get ownerRentalTypeDistribution => 'Taburan Jenis Sewa';

  @override
  String get ownerOccupancyRate => 'Kadar Penghunian';

  @override
  String get ownerOccupancyRateDescription => '91% unit anda sedang diduduki.';

  @override
  String get monthShortJan => 'Jan';

  @override
  String get monthShortFeb => 'Feb';

  @override
  String get monthShortMar => 'Mac';

  @override
  String get monthShortApr => 'Apr';

  @override
  String get monthShortMay => 'Mei';

  @override
  String get monthShortJun => 'Jun';

  @override
  String get rentalTypeCondo => 'Kondo';

  @override
  String get rentalTypeApartment => 'Apartmen';

  @override
  String get rentalTypeRoom => 'Bilik';

  @override
  String get rentalTypeLanded => 'Bertanah';

  @override
  String formFieldRequired(Object fieldName) {
    return '$fieldName diperlukan';
  }

  @override
  String get formEmailInvalid => 'Sila masukkan alamat e-mel yang sah';

  @override
  String get formPasswordMinLength =>
      'Kata laluan mesti sekurang-kurangnya 6 aksara';

  @override
  String get formPasswordMismatch => 'Kata laluan dan pengesahan tidak sepadan';

  @override
  String get authEmailHint => 'anda@contoh.com';

  @override
  String get authPassword => 'Kata Laluan';

  @override
  String get authLogin => 'Log Masuk';

  @override
  String get authRegister => 'Daftar';

  @override
  String get authShowPassword => 'Tunjuk kata laluan';

  @override
  String get authHidePassword => 'Sembunyi kata laluan';

  @override
  String get loginTitle => 'Selamat Kembali';

  @override
  String get loginSubtitle =>
      'Log masuk untuk meneruskan perjalanan HomeU anda.';

  @override
  String get loginPasswordHint => 'Masukkan kata laluan anda';

  @override
  String get loginForgotPassword => 'Lupa kata laluan?';

  @override
  String get loginNewHere => 'Baru di sini?';

  @override
  String get loginSuccess => 'Log masuk berjaya.';

  @override
  String get loginErrorBackendNotInitialized =>
      'Backend belum dimulakan. Sila semak konfigurasi Supabase anda.';

  @override
  String get loginErrorIncomplete =>
      'Log masuk tidak dapat diselesaikan. Sila cuba lagi.';

  @override
  String get loginErrorProfileRoleMissing =>
      'Peranan profil anda tiada. Sila hubungi sokongan.';

  @override
  String get loginErrorNetwork =>
      'Ralat rangkaian. Sila semak sambungan internet anda dan cuba lagi.';

  @override
  String get loginErrorProfileRead =>
      'Tidak dapat membaca profil anda sekarang. Sila cuba lagi.';

  @override
  String get loginErrorUnexpected =>
      'Ralat tidak dijangka semasa log masuk. Sila cuba lagi.';

  @override
  String get loginErrorInvalidCredentials =>
      'E-mel atau kata laluan tidak sah.';

  @override
  String get loginErrorGeneric =>
      'Tidak dapat log masuk sekarang. Sila cuba lagi.';

  @override
  String get registerTitle => 'Cipta Akaun Anda';

  @override
  String get registerSubtitle =>
      'Sertai HomeU and mulakan perjalanan sewaan anda.';

  @override
  String get registerNameHint => 'Nama penuh anda';

  @override
  String get registerPasswordHint => 'Cipta kata laluan';

  @override
  String get registerConfirmPassword => 'Sahkan Kata Laluan';

  @override
  String get registerConfirmPasswordHint => 'Masukkan semula kata laluan';

  @override
  String get registerSelectRole => 'Pilih Peranan Akaun';

  @override
  String get registerRoleInfo =>
      'Peranan yang dipilih menentukan ciri dan navigasi yang boleh diakses. Untuk tukar peranan, log keluar dan daftar semula.';

  @override
  String get registerAlreadyHaveAccount => 'Sudah mempunyai akaun?';

  @override
  String get registerBackToLogin => 'Kembali ke Log Masuk';

  @override
  String get registerSuccessLocalMode =>
      'Daftar dalam mod setempat. Sambungkan Supabase untuk penciptaan akaun sebenar.';

  @override
  String get registerSuccessAccountCreated => 'Akaun berjaya dicipta.';

  @override
  String get registerErrorSignUpIncomplete =>
      'Tidak dapat melengkapkan pendaftaran sekarang. Sila cuba lagi.';

  @override
  String get registerErrorDuplicateEmail => 'E-mel ini sudah digunakan.';

  @override
  String get registerErrorProfileUnavailable =>
      'Akaun berjaya dicipta, tetapi profil tidak tersedia sekarang. Sila cuba lagi.';

  @override
  String get registerErrorUnexpected =>
      'Ralat tidak dijangka semasa pendaftaran. Sila cuba lagi.';

  @override
  String get registerErrorNetwork =>
      'Ralat rangkaian. Sila semak sambungan internet anda dan cuba lagi.';

  @override
  String get registerErrorGeneric =>
      'Tidak dapat mendaftar sekarang. Sila cuba lagi.';

  @override
  String get forgotPasswordTitle => 'Lupa Kata Laluan';

  @override
  String get forgotPasswordSubtitle =>
      'Masukkan alamat e-mel berdaftar anda dan kami akan menghantar pautan tetapan semula kata laluan.';

  @override
  String get forgotPasswordEmailNote =>
      'Sila gunakan e-mel sebenar kerana pautan tetapan semula akan dihantar ke peti masuk anda.';

  @override
  String get forgotPasswordEmailAddress => 'Alamat E-mel';

  @override
  String get forgotPasswordSendResetLink => 'Hantar Pautan Tetapan Semula';

  @override
  String get forgotPasswordCheckEmail => 'Semak E-mel Anda';

  @override
  String get forgotPasswordNoEmailHint =>
      'Tidak menerima e-mel? Semak spam atau cuba lagi.';

  @override
  String get forgotPasswordSuccessDefault =>
      'Pautan tetapan semula kata laluan telah dihantar ke e-mel anda.';

  @override
  String get forgotPasswordErrorRateLimit =>
      'Terlalu banyak percubaan. Sila tunggu sebentar dan cuba lagi.';

  @override
  String get forgotPasswordErrorNetwork =>
      'Ralat rangkaian. Sila semak sambungan internet anda dan cuba lagi.';

  @override
  String get forgotPasswordErrorGeneric =>
      'Tidak dapat menghantar pautan tetapan semula sekarang. Sila cuba lagi.';

  @override
  String get onboardingSkip => 'Langkau';

  @override
  String get onboardingNext => 'Seterusnya';

  @override
  String get onboardingGetStarted => 'Mula';

  @override
  String onboardingStepProgress(int current, int total) {
    return '$current daripada $total';
  }

  @override
  String get onboardingStep1Title => 'Semak Imbas Hartanah Sewa';

  @override
  String get onboardingStep1Subtitle =>
      'Temui bilik, rumah, kondo, dan apartmen yang sepadan dengan gaya hidup dan bajet anda.';

  @override
  String get onboardingFilters => 'Penapis';

  @override
  String get onboardingExampleListing1Title => 'Kondo Bandar';

  @override
  String get onboardingExampleListing1Subtitle => '2 Bilik • Pusat Bandar';

  @override
  String get onboardingExampleListing1Price => '\$1,250/bln';

  @override
  String get onboardingExampleListing2Title => 'Studio Selesa';

  @override
  String get onboardingExampleListing2Subtitle => '1 Bilik • Dekat Kampus';

  @override
  String get onboardingExampleListing2Price => '\$780/bln';

  @override
  String get onboardingStep2Title => 'Senaraikan Hartanah Anda Dengan Mudah';

  @override
  String get onboardingStep2Subtitle =>
      'Tambah hartanah, muat naik foto, dan urus permintaan sewa di satu tempat.';

  @override
  String get ownerNewListing => 'Senarai Baharu';

  @override
  String get ownerPropertyType => 'Jenis Hartanah';

  @override
  String get ownerUploadPhotos => 'Muat Naik Foto';

  @override
  String get ownerLocationAndPrice => 'Lokasi & Harga';

  @override
  String get ownerNewRentalRequests => '3 Permintaan Sewa Baharu';

  @override
  String get onboardingStep3Title => 'Tempahan & Bayaran Selamat';

  @override
  String get onboardingStep3Subtitle =>
      'Tempah lawatan, sahkan sewaan, dan buat bayaran melalui proses yang selamat dan mudah.';

  @override
  String get onboardingViewingConfirmed => 'Lawatan Disahkan';

  @override
  String get onboardingSecurePayment => 'Bayaran Selamat';

  @override
  String get onboardingProtected => 'Dilindungi';

  @override
  String get updatePasswordSuccessMessage =>
      'Kata laluan anda berjaya dikemas kini.';

  @override
  String get updatePasswordStrongPasswordTip =>
      'Gunakan kata laluan yang kuat dengan huruf, nombor dan simbol.';

  @override
  String get updatePasswordCurrentPasswordLabel => 'Kata Laluan Semasa';

  @override
  String get updatePasswordCurrentPasswordHint => 'Masukkan kata laluan semasa';

  @override
  String get updatePasswordNewPasswordLabel => 'Kata Laluan Baharu';

  @override
  String get updatePasswordNewPasswordHint => 'Masukkan kata laluan baharu';

  @override
  String get updatePasswordConfirmPasswordLabel => 'Sahkan Kata Laluan Baharu';

  @override
  String get updatePasswordConfirmPasswordHint =>
      'Masukkan semula kata laluan baharu';

  @override
  String get updatePasswordValidationCurrentRequired =>
      'Kata laluan semasa diperlukan';

  @override
  String get updatePasswordValidationNewRequired =>
      'Kata laluan baharu diperlukan';

  @override
  String get updatePasswordValidationMinLength =>
      'Kata laluan baharu mesti sekurang-kurangnya 6 aksara';

  @override
  String get updatePasswordValidationConfirmRequired =>
      'Sahkan kata laluan baharu diperlukan';

  @override
  String get updatePasswordValidationMismatch =>
      'Kata laluan baharu dan pengesahan tidak sepadan';

  @override
  String get updatePasswordErrorCurrentPasswordIncorrect =>
      'Kata laluan semasa tidak betul.';

  @override
  String get updatePasswordErrorBackendNotInitialized =>
      'Backend belum dimulakan. Sila semak konfigurasi Supabase.';

  @override
  String get updatePasswordErrorVerifyCurrentPasswordUnavailable =>
      'Tidak dapat mengesahkan kata laluan semasa anda sekarang. Sila log masuk semula.';

  @override
  String get updatePasswordErrorSessionExpired =>
      'Pautan tetapan semula tidak sah atau telah tamat tempoh. Sila minta e-mel tetapan semula kata laluan baharu.';

  @override
  String get updatePasswordErrorNewPasswordMustDiffer =>
      'Kata laluan baharu mesti berbeza daripada kata laluan semasa anda.';

  @override
  String get updatePasswordErrorWeakPassword =>
      'Sila pilih kata laluan yang lebih kuat dengan sekurang-kurangnya 6 aksara.';

  @override
  String get updatePasswordErrorNetwork =>
      'Ralat rangkaian. Sila semak sambungan internet anda dan cuba lagi.';

  @override
  String get updatePasswordErrorGeneric =>
      'Tidak dapat mengemas kini kata laluan sekarang. Sila cuba lagi.';

  @override
  String get chatTitle => 'Mesej';

  @override
  String get chatSearchHint => 'Cari mesej...';

  @override
  String get chatFilterAll => 'Semua';

  @override
  String get chatFilterUnread => 'Belum dibaca';

  @override
  String get chatFilterProperty => 'Hartanah';

  @override
  String get chatFilterArchived => 'Diarkibkan';

  @override
  String get chatYesterday => 'Semalam';

  @override
  String get chatOnline => 'Dalam Talian';

  @override
  String get chatOffline => 'Luar Talian';

  @override
  String get chatTypeMessageHint => 'Taip mesej...';

  @override
  String get chatAttachmentTitle => 'Hantar Lampiran';

  @override
  String get chatAttachImage => 'Imej';

  @override
  String get chatAttachCamera => 'Kamera';

  @override
  String get chatAttachDocument => 'Dokumen';
}
