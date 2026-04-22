// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'HomeU';

  @override
  String get navHome => '首页';

  @override
  String get navFavorites => '收藏';

  @override
  String get navBookings => '预订';

  @override
  String get navProfile => '个人资料';

  @override
  String get homeGreetingAnonymous => '你好';

  @override
  String homeGreetingWithName(Object name) {
    return '你好，$name';
  }

  @override
  String get homeQuickSearchSubtitle => '快速搜索，找到你的下一间租房。';

  @override
  String get homeSearchHint => '搜索位置、公寓、房屋';

  @override
  String get homeCategories => '分类';

  @override
  String get homeRecommendedProperties => '推荐房源';

  @override
  String get homeScanQr => '扫码';

  @override
  String get bookingHistoryTitle => '预订记录';

  @override
  String get bookingHistorySubtitle => '快速跟踪你最新的租房预订状态。';

  @override
  String get bookingDateLabel => '预订日期';

  @override
  String get rentalPeriodLabel => '租期';

  @override
  String get statusPending => '待处理';

  @override
  String get statusApproved => '已批准';

  @override
  String get statusRejected => '已拒绝';

  @override
  String get statusCompleted => '已完成';

  @override
  String get leaveReview => '留下评价';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileRoleOwner => '房东';

  @override
  String get profileRoleTenant => '租客';

  @override
  String get profileThemeTitle => '主题';

  @override
  String get profileThemeSubtitle => '选择浅色、深色或系统默认。';

  @override
  String get profileLanguageTitle => '语言';

  @override
  String get profileLanguageSubtitle => '选择你偏好的应用语言。';

  @override
  String get profileUpdatePasswordTitle => '更新密码';

  @override
  String get profileUpdatePasswordSubtitle => '修改密码以保障账号安全。';

  @override
  String get profileEditButton => '编辑资料';

  @override
  String get profileLogoutButton => '退出登录';

  @override
  String get profileAccountDetails => '账号详情';

  @override
  String get profileFieldName => '姓名';

  @override
  String get profileFieldEmail => '邮箱';

  @override
  String get profileFieldPhone => '电话号码';

  @override
  String get profileFieldRole => '角色';

  @override
  String get profileEditSheetTitle => '编辑资料';

  @override
  String get profileEditSheetPhotoHint => '可通过上方头像按钮更换头像。';

  @override
  String get profileEditFieldFullName => '姓名';

  @override
  String get profileEditFieldFullNameHint => '输入姓名';

  @override
  String get profileEditFieldEmailReadonly => '邮箱（不可编辑）';

  @override
  String get profileEditFieldPhone => '电话号码';

  @override
  String get profileEditFieldPhoneHint => '输入电话号码';

  @override
  String get profileEditSaveChanges => '保存更改';

  @override
  String get profileNamePhoneRequired => '姓名和电话号码为必填项。';

  @override
  String get profileUpdatedSuccess => '个人资料更新成功。';

  @override
  String get profileErrorRefresh => '暂时无法刷新资料，正在显示可用数据。';

  @override
  String get profileErrorUpdate => '暂时无法更新资料，请稍后再试。';

  @override
  String get profileErrorUpload => '暂时无法上传头像，请稍后再试。';

  @override
  String get profileErrorLanguageSave => '暂时无法保存语言偏好，请稍后再试。';

  @override
  String get profilePhotoChooseGallery => '从相册选择';

  @override
  String get profilePhotoChooseGallerySubtitle => '从你的设备中选择一张照片。';

  @override
  String get profilePhotoTakeCamera => '拍照';

  @override
  String get profilePhotoTakeCameraSubtitle => '使用相机拍摄新头像。';

  @override
  String get profilePhotoUpdatedSuccess => '头像更新成功。';

  @override
  String get profilePhotoAccessError => '暂时无法访问照片，请稍后再试。';

  @override
  String get profileThemeSaved => '主题偏好已保存。';

  @override
  String get profileLanguageSaved => '语言偏好已保存。';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageMalay => '马来语';

  @override
  String get languageChinese => '中文';

  @override
  String get themeSystem => '系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get ownerNavDashboard => '仪表盘';

  @override
  String get ownerNavMyProperties => '我的房源';

  @override
  String get ownerNavRequests => '请求';

  @override
  String get ownerNavAnalytics => '分析';

  @override
  String get ownerDashboardSubtitle => '在一个页面管理房源、请求和表现。';

  @override
  String get ownerAddProperty => '添加房源';

  @override
  String get ownerMonthlyEarnings => '月收入';

  @override
  String get ownerQuickStats => '快速统计';

  @override
  String get ownerActiveListings => '在租房源';

  @override
  String get ownerPendingRequests => '待处理请求';

  @override
  String get ownerOccupancy => '入住率';

  @override
  String get ownerMyProperties => '我的房源';

  @override
  String get ownerBookingRequests => '预订请求';

  @override
  String get ownerOccupancyOccupied => '已入住';

  @override
  String get ownerOccupancyVacant => '空置';

  @override
  String get ownerRequestStatusAwaitingResponse => '待响应';

  @override
  String get ownerRequestStatusNewRequest => '新请求';

  @override
  String get ownerPropertyLabel => '房源';

  @override
  String get ownerTapToReviewRequest => '点击查看请求';

  @override
  String get ownerBookingRequestTitle => '预订请求';

  @override
  String get ownerBookingRequestSubtitle => '快速查看租客信息并确认你的决定。';

  @override
  String get ownerTenantInformation => '租客信息';

  @override
  String get ownerBookingDetails => '预订详情';

  @override
  String get ownerCheckInLabel => '入住日期';

  @override
  String get ownerDurationLabel => '时长';

  @override
  String get ownerMonthlyRentLabel => '月租';

  @override
  String get ownerRequestSummary => '请求摘要';

  @override
  String get ownerRequestDecisionPending => '待决策';

  @override
  String get ownerRequestDecisionApproved => '已批准';

  @override
  String get ownerRequestDecisionRejected => '已拒绝';

  @override
  String get ownerDecision => '决策';

  @override
  String get ownerReject => '拒绝';

  @override
  String get ownerApprove => '批准';

  @override
  String get ownerAnalyticsTitle => '房东分析';

  @override
  String get ownerAnalyticsSubtitle => '本月你的租赁业务表现概览。';

  @override
  String get ownerStatNetEarnings => '净收入';

  @override
  String get ownerRentalTypeDistribution => '租赁类型分布';

  @override
  String get ownerOccupancyRate => '入住率';

  @override
  String get ownerOccupancyRateDescription => '你上架的房源中有 91% 当前已入住。';

  @override
  String get monthShortJan => '1月';

  @override
  String get monthShortFeb => '2月';

  @override
  String get monthShortMar => '3月';

  @override
  String get monthShortApr => '4月';

  @override
  String get monthShortMay => '5月';

  @override
  String get monthShortJun => '6月';

  @override
  String get rentalTypeCondo => '公寓';

  @override
  String get rentalTypeApartment => '单元房';

  @override
  String get rentalTypeRoom => '房间';

  @override
  String get rentalTypeLanded => '独立屋';

  @override
  String formFieldRequired(Object fieldName) {
    return '$fieldName为必填项';
  }

  @override
  String get formEmailInvalid => '请输入有效的邮箱地址';

  @override
  String get formPasswordMinLength => '密码至少需要6个字符';

  @override
  String get formPasswordMismatch => '密码与确认密码不一致';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPassword => '密码';

  @override
  String get authLogin => '登录';

  @override
  String get authRegister => '注册';

  @override
  String get authShowPassword => '显示密码';

  @override
  String get authHidePassword => '隐藏密码';

  @override
  String get loginTitle => '欢迎回来';

  @override
  String get loginSubtitle => '登录以继续你的 HomeU 旅程。';

  @override
  String get loginPasswordHint => '输入你的密码';

  @override
  String get loginForgotPassword => '忘记密码？';

  @override
  String get loginNewHere => '新用户？';

  @override
  String get loginSuccess => '登录成功。';

  @override
  String get loginErrorBackendNotInitialized => '后端尚未初始化，请检查 Supabase 配置。';

  @override
  String get loginErrorIncomplete => '暂时无法完成登录，请稍后重试。';

  @override
  String get loginErrorProfileRoleMissing => '你的资料角色缺失，请联系支持团队。';

  @override
  String get loginErrorNetwork => '网络错误，请检查网络连接后重试。';

  @override
  String get loginErrorProfileRead => '暂时无法读取你的资料，请稍后重试。';

  @override
  String get loginErrorUnexpected => '登录时发生未知错误，请稍后重试。';

  @override
  String get loginErrorInvalidCredentials => '邮箱或密码不正确。';

  @override
  String get loginErrorGeneric => '暂时无法登录，请稍后重试。';

  @override
  String get registerTitle => '创建你的账号';

  @override
  String get registerSubtitle => '加入 HomeU，开启你的租房之旅。';

  @override
  String get registerNameHint => '你的姓名';

  @override
  String get registerPasswordHint => '创建密码';

  @override
  String get registerConfirmPassword => '确认密码';

  @override
  String get registerConfirmPasswordHint => '再次输入密码';

  @override
  String get registerSelectRole => '选择账号角色';

  @override
  String get registerRoleInfo => '所选角色将决定可用功能与导航。若需切换角色，请退出后重新注册。';

  @override
  String get registerAlreadyHaveAccount => '已有账号？';

  @override
  String get registerBackToLogin => '返回登录';

  @override
  String get registerSuccessLocalMode => '已在本地模式下注册。连接 Supabase 后可创建真实账号。';

  @override
  String get registerSuccessAccountCreated => '账号创建成功。';

  @override
  String get registerErrorSignUpIncomplete => '暂时无法完成注册，请稍后重试。';

  @override
  String get registerErrorDuplicateEmail => '该邮箱已被使用。';

  @override
  String get registerErrorProfileUnavailable => '账号已创建，但资料暂时不可用，请稍后重试。';

  @override
  String get registerErrorUnexpected => '注册时发生未知错误，请稍后重试。';

  @override
  String get registerErrorNetwork => '网络错误，请检查网络连接后重试。';

  @override
  String get registerErrorGeneric => '暂时无法注册，请稍后重试。';

  @override
  String get forgotPasswordTitle => '忘记密码';

  @override
  String get forgotPasswordSubtitle => '请输入你的注册邮箱，我们会发送重置密码链接。';

  @override
  String get forgotPasswordEmailNote => '请使用真实邮箱，重置链接将发送到你的收件箱。';

  @override
  String get forgotPasswordEmailAddress => '邮箱地址';

  @override
  String get forgotPasswordSendResetLink => '发送重置链接';

  @override
  String get forgotPasswordCheckEmail => '请检查邮箱';

  @override
  String get forgotPasswordNoEmailHint => '没收到邮件？请检查垃圾邮箱或稍后重试。';

  @override
  String get forgotPasswordSuccessDefault => '重置密码链接已发送到你的邮箱。';

  @override
  String get forgotPasswordErrorRateLimit => '尝试次数过多，请稍后再试。';

  @override
  String get forgotPasswordErrorNetwork => '网络错误，请检查网络连接后重试。';

  @override
  String get forgotPasswordErrorGeneric => '暂时无法发送重置链接，请稍后重试。';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingGetStarted => '开始使用';

  @override
  String onboardingStepProgress(int current, int total) {
    return '第$current步，共$total步';
  }

  @override
  String get onboardingStep1Title => '浏览租赁房源';

  @override
  String get onboardingStep1Subtitle => '发现符合你生活方式和预算的房间、房屋、公寓和单元房。';

  @override
  String get onboardingFilters => '筛选';

  @override
  String get onboardingExampleListing1Title => '城市公寓';

  @override
  String get onboardingExampleListing1Subtitle => '2居室 • 市中心';

  @override
  String get onboardingExampleListing1Price => '\$1,250/月';

  @override
  String get onboardingExampleListing2Title => '舒适单间';

  @override
  String get onboardingExampleListing2Subtitle => '1居室 • 近校园';

  @override
  String get onboardingExampleListing2Price => '\$780/月';

  @override
  String get onboardingStep2Title => '轻松发布你的房源';

  @override
  String get onboardingStep2Subtitle => '添加房源、上传照片，并在一个页面管理租赁请求。';

  @override
  String get ownerNewListing => '新房源';

  @override
  String get ownerPropertyType => '房源类型';

  @override
  String get ownerUploadPhotos => '上传照片';

  @override
  String get ownerLocationAndPrice => '位置与价格';

  @override
  String get ownerNewRentalRequests => '3 条新租赁请求';

  @override
  String get onboardingStep3Title => '安全预订与支付';

  @override
  String get onboardingStep3Subtitle => '通过安全简洁的流程完成看房预约、租赁确认与支付。';

  @override
  String get onboardingViewingConfirmed => '看房已确认';

  @override
  String get onboardingSecurePayment => '安全支付';

  @override
  String get onboardingProtected => '已保护';

  @override
  String get updatePasswordSuccessMessage => '你的密码已成功更新。';

  @override
  String get updatePasswordStrongPasswordTip => '请使用包含字母、数字和符号的高强度密码。';

  @override
  String get updatePasswordCurrentPasswordLabel => '当前密码';

  @override
  String get updatePasswordCurrentPasswordHint => '输入当前密码';

  @override
  String get updatePasswordNewPasswordLabel => '新密码';

  @override
  String get updatePasswordNewPasswordHint => '输入新密码';

  @override
  String get updatePasswordConfirmPasswordLabel => '确认新密码';

  @override
  String get updatePasswordConfirmPasswordHint => '再次输入新密码';

  @override
  String get updatePasswordValidationCurrentRequired => '当前密码为必填项';

  @override
  String get updatePasswordValidationNewRequired => '新密码为必填项';

  @override
  String get updatePasswordValidationMinLength => '新密码至少需要6个字符';

  @override
  String get updatePasswordValidationConfirmRequired => '确认新密码为必填项';

  @override
  String get updatePasswordValidationMismatch => '新密码与确认密码不一致';

  @override
  String get updatePasswordErrorCurrentPasswordIncorrect => '当前密码不正确。';

  @override
  String get updatePasswordErrorBackendNotInitialized =>
      '后端尚未初始化。请检查 Supabase 配置。';

  @override
  String get updatePasswordErrorVerifyCurrentPasswordUnavailable =>
      '暂时无法验证当前密码，请重新登录后再试。';

  @override
  String get updatePasswordErrorSessionExpired => '重置链接无效或已过期，请重新申请密码重置邮件。';

  @override
  String get updatePasswordErrorNewPasswordMustDiffer => '新密码必须与当前密码不同。';

  @override
  String get updatePasswordErrorWeakPassword => '请设置更强的密码，至少包含 6 个字符。';

  @override
  String get updatePasswordErrorNetwork => '网络错误，请检查网络连接后重试。';

  @override
  String get updatePasswordErrorGeneric => '暂时无法更新密码，请稍后再试。';
}
