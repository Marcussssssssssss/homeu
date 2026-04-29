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
  String get splashTagline => '找到你的理想居所';

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
  String get profileRoleAdmin => '管理员';

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
  String get profileFieldAccountStatus => '账号状态';

  @override
  String get profileFieldRiskStatus => '风险状态';

  @override
  String get profileAccountStatusActive => '正常';

  @override
  String get profileAccountStatusSuspended => '已停用';

  @override
  String get profileAccountStatusRemoved => '已移除';

  @override
  String get profileRiskStatusNormal => '正常';

  @override
  String get profileRiskStatusSuspicious => '可疑';

  @override
  String get profileRiskStatusHigh => '高风险';

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
  String get loginDividerOr => '或';

  @override
  String get loginBiometricReason => '验证以访问 HomeU';

  @override
  String get loginSessionExpired => '会话已过期，请使用邮箱和密码登录。';

  @override
  String get loginBiometricFailed => '生物识别验证失败或已取消。';

  @override
  String loginContinueAs(Object name) {
    return '以 $name 继续';
  }

  @override
  String get loginUseBiometrics => '使用生物识别';

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
  String get registerPhoneHint => '+60 12 345 6789';

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
  String get registerErrorGeneric => '暂时无法注册，请稍后再试。';

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
  String get forgotPasswordNoEmailHint => '没收到邮件？请检查垃圾邮箱或稍后再试。';

  @override
  String get forgotPasswordSuccessDefault => '重置密码链接已发送到你的邮箱。';

  @override
  String get forgotPasswordErrorRateLimit => '尝试次数过多，请稍后再试。';

  @override
  String get forgotPasswordErrorNetwork => '网络错误，请检查网络连接后重试。';

  @override
  String get forgotPasswordErrorGeneric => '暂时无法发送重置链接，请稍后再试。';

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
  String get viewingScheduleTitle => '预约看房';

  @override
  String get viewingSelectSlotTitle => '选择可用时段';

  @override
  String get viewingSelectSlotSubtitle => '房东只展示可用时段。请选择一个继续。';

  @override
  String get viewingNoSlotsTitle => '暂无可用时段';

  @override
  String get viewingNoSlotsSubtitle => '房东尚未为该房源设置可用时间。请稍后再试或联系房东。';

  @override
  String get viewingGoBack => '返回';

  @override
  String get viewingConfirmRequest => '确认预约';

  @override
  String get viewingAlreadyScheduled => '你已为该时段预约过看房。请查看你的请求。';

  @override
  String get viewingRequestSent => '请求已发送！';

  @override
  String viewingErrorWithMessage(Object message) {
    return '错误：$message';
  }

  @override
  String get bookingDetailsTitle => '预订详情';

  @override
  String get bookingPaymentScheduleTitle => '付款计划';

  @override
  String get bookingPaymentScheduleEmpty => '暂无生成付款计划。';

  @override
  String bookingMonthLabel(Object number) {
    return '第 $number 个月';
  }

  @override
  String bookingMonthWithFee(Object number) {
    return '第 $number 个月（预订费）';
  }

  @override
  String bookingDueLabel(Object date) {
    return '到期：$date';
  }

  @override
  String get bookingViewReceipt => '查看收据';

  @override
  String bookingAmountRm(Object amount) {
    return 'RM $amount';
  }

  @override
  String get bookingPaid => '已支付';

  @override
  String get bookingUpcoming => '即将到期';

  @override
  String get bookingPayNow => '立即支付';

  @override
  String get bookingReceiptNotFound => '未找到该付款的收据。';

  @override
  String bookingReceiptError(Object message) {
    return '加载收据出错：$message';
  }

  @override
  String get reviewRatingTitle => '评价与评分';

  @override
  String get reviewRatingSubtitle => '分享你的体验，帮助未来的租客做出更好的决定。';

  @override
  String get reviewAverageLabel => '平均评分';

  @override
  String get reviewYourRatingLabel => '你的评分';

  @override
  String get reviewCommentLabel => '评论';

  @override
  String get reviewCommentHint => '告诉我们有关清洁度、房东沟通以及整体体验。';

  @override
  String get reviewSubmitLabel => '提交';

  @override
  String get reviewSubmitSuccess => '谢谢，你的评价已提交。';

  @override
  String reviewStarLabel(Object count) {
    return '$count 星';
  }

  @override
  String get compareTitle => '对比房源';

  @override
  String get compareClear => '清除';

  @override
  String get compareEmptyTitle => '未选择房源';

  @override
  String get compareEmptySubtitle => '返回并选择 2 个房源\n开始对比';

  @override
  String get compareBackToListings => '返回列表';

  @override
  String get comparePriceRangeLabel => '价格区间';

  @override
  String comparePriceRangeValue(Object min, Object max) {
    return 'RM $min - RM $max';
  }

  @override
  String compareSaveAmount(Object amount) {
    return '节省 RM $amount';
  }

  @override
  String get compareLabelAddress => '地址';

  @override
  String get compareLabelType => '类型';

  @override
  String get compareLabelRooms => '房间';

  @override
  String get compareLabelFurnishing => '家具';

  @override
  String get compareLabelOwner => '房东';

  @override
  String get compareLabelAvailability => '可用性';

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

  @override
  String get chatTitle => '消息';

  @override
  String get chatSearchHint => '搜索消息...';

  @override
  String get chatFilterAll => '全部';

  @override
  String get chatFilterUnread => '未读';

  @override
  String get chatFilterProperty => '房源';

  @override
  String get chatFilterArchived => '已归档';

  @override
  String get chatYesterday => '昨天';

  @override
  String get chatOnline => '在线';

  @override
  String get chatOffline => '离线';

  @override
  String get chatTypeMessageHint => '输入消息...';

  @override
  String get chatAttachmentTitle => '发送附件';

  @override
  String get chatAttachImage => '图片';

  @override
  String get chatAttachCamera => '拍照';

  @override
  String get chatAttachDocument => '文档';

  @override
  String get receiptTitle => '付款收据';

  @override
  String get receiptSuccess => '付款成功';

  @override
  String get receiptTransactionId => '交易 ID';

  @override
  String get receiptProperty => '房源';

  @override
  String get receiptLocation => '位置';

  @override
  String get receiptPaymentDate => '付款日期';

  @override
  String get receiptPaymentMethod => '付款方式';

  @override
  String get receiptInstallment => '分期';

  @override
  String receiptMonth(Object number) {
    return '第 $number 个月';
  }

  @override
  String get receiptTotalAmount => '总金额';

  @override
  String get receiptDownload => '下载';

  @override
  String get receiptShare => '分享';

  @override
  String get receiptFooter => '感谢您使用 HomeU！';

  @override
  String paymentAmountRm(Object amount) {
    return 'RM $amount';
  }

  @override
  String get bookingTitle => '预订';

  @override
  String get bookingConflictDetected => '检测到与现有预订冲突。';

  @override
  String get bookingFeeNotice => '支付预订费会锁定该房源，剩余款项需在房东批准后支付。';

  @override
  String bookingPayFee(Object amount) {
    return '支付预订费（RM $amount）';
  }

  @override
  String get bookingSelectedProperty => '已选房源';

  @override
  String bookingConflictDetails(Object date) {
    return '该房源从 $date 起已被预订。请缩短租期或选择其他开始日期。';
  }

  @override
  String get bookingDurationTitle => '租期';

  @override
  String bookingDurationMonths(Object count) {
    return '$count 个月';
  }

  @override
  String get bookingStartDateTitle => '开始日期';

  @override
  String bookingOccupiedUntil(Object date) {
    return '房源已被占用至 $date';
  }

  @override
  String get bookingTotalPriceTitle => '总价计算';

  @override
  String get bookingMonthlyPriceLabel => '月租';

  @override
  String bookingDurationSummary(Object months) {
    return '时长（$months 个月）';
  }

  @override
  String get bookingEstimatedTotalLabel => '预计总价';

  @override
  String get paymentSupabaseUnavailable => 'Supabase 未初始化，请稍后再试。';

  @override
  String get bookingLoginRequired => '请先登录以继续预订。';

  @override
  String get bookingDurationJustBooked => '抱歉，该时长刚被其他租客预订。';

  @override
  String get bookingCreateFailed => '无法创建预订，请稍后再试。';

  @override
  String bookingCreateError(Object error) {
    return '创建预订失败：$error';
  }

  @override
  String get statusAll => '全部';

  @override
  String get ownerRequestsTitle => '请求';

  @override
  String get ownerRequestsBookingsTab => '预订';

  @override
  String get ownerRequestsViewingsTab => '看房';

  @override
  String get ownerRequestsRetry => '重试';

  @override
  String ownerRequestsEmpty(Object filter) {
    return '没有“$filter”请求。';
  }

  @override
  String ownerRequestsMoveIn(Object date, Object months) {
    return '入住：$date  •  $months 个月';
  }

  @override
  String ownerRequestsFlexibleDuration(Object months) {
    return '灵活  •  $months 个月';
  }

  @override
  String ownerRequestsMonthlyPrice(Object price) {
    return 'RM $price / 月';
  }

  @override
  String get ownerRequestsReview => '查看';

  @override
  String ownerRequestsViewingsEmpty(Object filter) {
    return '没有“$filter”看房请求。';
  }

  @override
  String ownerRequestsViewingTime(Object date, Object time) {
    return '$date  •  $time';
  }

  @override
  String get ownerRequestsDecline => '拒绝';

  @override
  String get ownerRequestsApprove => '批准';

  @override
  String get ownerRequestsMarkCompleted => '标记为已完成';

  @override
  String ownerGreeting(Object name) {
    return '你好，$name';
  }

  @override
  String get ownerRecentProperties => '最新房源';

  @override
  String get ownerNoProperties => '尚未发布房源';

  @override
  String get ownerAddFirstProperty => '添加你的第一套房源';

  @override
  String get ownerUntitledProperty => '未命名';

  @override
  String get ownerRecentBookingRequests => '最新预订请求';

  @override
  String get ownerNoBookingRequests => '暂无活跃的预订请求';

  @override
  String get ownerUnknownProperty => '未知房源';

  @override
  String get ownerUnknownTenant => '未知租客';

  @override
  String get ownerRecentViewingRequests => '最新看房请求';

  @override
  String get ownerNoViewingRequests => '暂无活跃的看房请求';

  @override
  String get ownerTapToReviewViewing => '点击查看看房';

  @override
  String get ownerProjected30Days => '预计（30 天）';

  @override
  String get ownerOverduePayments => '逾期款项';

  @override
  String get ownerInvoiceCollectionRate => '发票收款率';

  @override
  String get monthShortJul => '7月';

  @override
  String get monthShortAug => '8月';

  @override
  String get monthShortSep => '9月';

  @override
  String get monthShortOct => '10月';

  @override
  String get monthShortNov => '11月';

  @override
  String get monthShortDec => '12月';

  @override
  String get profileBiometricUnavailable => '该设备未启用或不支持生物识别认证。';

  @override
  String get profileBiometricReason => '请验证以启用生物识别登录';

  @override
  String get profileBiometricEnabled => '生物识别登录已启用。';

  @override
  String get profileBiometricSaveFailed => '无法更新生物识别偏好。';

  @override
  String get profileBiometricDisabled => '生物识别登录已关闭。';

  @override
  String get profileErrorSaveBiometric => '无法保存生物识别偏好。';

  @override
  String get profileLogoutTitle => '退出登录？';

  @override
  String get profileLogoutMessage => '确定要退出你的 HomeU 账号吗？';

  @override
  String get profileLogoutCancel => '取消';

  @override
  String get profileLogoutConfirm => '退出登录';

  @override
  String get profileFavoritesSubtitle => '查看你保存的房源';

  @override
  String get profileBiometricTitle => '生物识别登录';

  @override
  String get profileBiometricSubtitle => '使用生物识别解锁 HomeU';

  @override
  String get adminDashboardLoadError => '无法加载系统概览，请检查网络连接。';

  @override
  String get adminDashboardTitle => '管理员仪表盘';

  @override
  String get adminDashboardWelcome => '欢迎，管理员';

  @override
  String get adminDashboardOverview => '系统概览';

  @override
  String get adminTotalUsers => '用户总数';

  @override
  String get adminTotalOwners => '房东';

  @override
  String get adminTotalTenants => '租客';

  @override
  String get adminPendingReports => '待处理举报';

  @override
  String get adminManagementTitle => '管理';

  @override
  String get adminReportsReview => '举报审核';

  @override
  String adminReportsSummary(Object pending, Object total) {
    return '$pending 条待处理 / 共 $total 条举报';
  }

  @override
  String get adminManagementTile => '管理员管理';

  @override
  String get adminManagementSubtitle => '管理系统管理员';

  @override
  String get adminAuditLogsTitle => '审计日志';

  @override
  String get adminAuditLogsSubtitle => '查看全系统活动日志';

  @override
  String get adminCreatedSuccess => '管理员账号创建成功。';

  @override
  String get adminUpdateDetailsTitle => '更新管理员信息';

  @override
  String get adminUpdateDetailsConfirm => '更新';

  @override
  String get adminDetailsUpdated => '管理员信息已更新。';

  @override
  String adminUpdateError(Object error) {
    return '错误：$error';
  }

  @override
  String get adminCannotRemoveSelf => '安全提示：你不能移除自己的管理员权限。';

  @override
  String get adminRemoveTitle => '移除管理员？';

  @override
  String adminRemoveMessage(Object name) {
    return '要移除 $name 的管理员权限吗？他们将恢复为租客角色。';
  }

  @override
  String get adminRemoveConfirm => '移除';

  @override
  String get adminRemovedSuccess => '管理员权限已移除。';

  @override
  String adminRemoveError(Object error) {
    return '错误：$error';
  }

  @override
  String get adminAddButton => '添加管理员';

  @override
  String get adminNoAdminsFound => '未找到管理员。';

  @override
  String get adminNavDashboard => '仪表盘';

  @override
  String get adminNavReports => '举报';

  @override
  String get adminNavChat => '聊天';

  @override
  String get adminNavLogs => '日志';

  @override
  String get adminNavProfile => '个人资料';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonRefreshTooltip => '刷新';

  @override
  String get statusReviewed => '已审核';

  @override
  String get statusDismissed => '已驳回';

  @override
  String get adminReportsTitle => '举报审核';

  @override
  String get adminReportsSearchHint => '搜索举报、房东、租客、房源...';

  @override
  String get adminReportsFilterTooltip => '筛选举报';

  @override
  String get adminReportsActiveFilterLabel => '当前筛选：';

  @override
  String get adminReportsNoMatches => '没有举报符合当前筛选条件。';

  @override
  String get adminReportsFilterTitle => '筛选举报';

  @override
  String get adminReportsFilterSectionStatus => '举报状态';

  @override
  String get adminReportsFilterClear => '清除筛选';

  @override
  String get adminReportsFilterApply => '应用筛选';

  @override
  String get adminReportsUnknownListing => '未知房源';

  @override
  String get adminReportsUnknownReportId => '未知';

  @override
  String adminReportsPropertyIdFallback(Object propertyId) {
    return '房源 #$propertyId';
  }

  @override
  String get adminReportsNotAvailable => '暂无';

  @override
  String get adminReportsUnknownOwner => '未知房东';

  @override
  String get adminReportsUnknownReporter => '未知举报人';

  @override
  String get adminReportsUnknownEmail => '-';

  @override
  String adminReportsLoadError(Object error) {
    return '加载举报失败：$error';
  }

  @override
  String get adminReportsMissingOwnerOrPropertyChat => '缺少房东或房源信息，无法发起聊天。';

  @override
  String get adminReportsMissingTenantOrPropertyChat => '缺少租客或房源信息，无法发起聊天。';

  @override
  String get adminReportsAuditContactOwnerReason => '已打开与房东的聊天以跟进举报。';

  @override
  String get adminReportsAuditContactTenantReason => '已打开与租客的聊天以跟进举报。';

  @override
  String adminReportsChatOpenError(Object error) {
    return '无法打开聊天：$error';
  }

  @override
  String get adminReportsRecordRiskLevelAction => '记录风险等级';

  @override
  String get adminReportsRiskRecorded => '风险等级已记录。';

  @override
  String adminReportsRiskRecordError(Object error) {
    return '风险评估失败：$error';
  }

  @override
  String adminReportsActionCompleted(Object actionLabel) {
    return '$actionLabel 已完成。';
  }

  @override
  String adminReportsUpdateError(Object error) {
    return '更新举报失败：$error';
  }

  @override
  String adminReportsReportTitle(Object reportId) {
    return '举报 #$reportId';
  }

  @override
  String adminReportsSubmittedOn(Object date) {
    return '提交于 $date';
  }

  @override
  String get adminReportsSectionProperty => '房源';

  @override
  String get adminReportsSectionOwner => '房东';

  @override
  String get adminReportsSectionReporter => '举报人';

  @override
  String get adminReportsSectionComplaint => '投诉';

  @override
  String get adminReportsFieldPropertyId => '房源 ID';

  @override
  String get adminReportsFieldTitle => '标题';

  @override
  String get adminReportsFieldName => '姓名';

  @override
  String get adminReportsFieldEmail => '邮箱';

  @override
  String get adminReportsFieldTotalReports => '举报总数';

  @override
  String get adminReportsFieldReason => '原因';

  @override
  String get adminReportsFieldDescription => '说明';

  @override
  String get adminReportsFieldStatus => '状态';

  @override
  String get adminReportsRiskSectionTitle => '风险评估';

  @override
  String get adminReportsRiskSectionHint => '仅用于内部审核，不会影响房源展示或账号状态。';

  @override
  String get adminReportsReviewedConfirmTitle => '我已审核该投诉。';

  @override
  String get adminReportsReviewedConfirmSubtitle => '确认后可进行风险评估和状态更新。';

  @override
  String get adminReportsActionsTitle => '操作';

  @override
  String get adminReportsActionsHint => '先通过聊天跟进，然后记录内部风险等级或更新举报状态。';

  @override
  String get adminReportsContactOwner => '联系房东';

  @override
  String get adminReportsContactReporter => '联系举报人';

  @override
  String get adminReportsSaveRisk => '保存风险等级';

  @override
  String get adminReportsMarkReviewed => '标记已审核';

  @override
  String get adminReportsDismissReport => '驳回举报';

  @override
  String adminReportsOwnerLabel(Object name) {
    return '房东：$name';
  }

  @override
  String adminReportsReporterLabel(Object name) {
    return '举报人：$name';
  }

  @override
  String adminReportsReasonLabel(Object reason) {
    return '原因：$reason';
  }

  @override
  String get adminReportsReasonDialogPrompt => '请提供原因并确认此审核操作。';

  @override
  String get adminReportsReasonDialogLabel => '管理员原因';

  @override
  String get adminReportsReasonDialogHint => '添加清晰的审核说明';

  @override
  String get adminReportsReasonDialogConfirm => '我确认此操作。';

  @override
  String get adminReportsRiskLow => '低';

  @override
  String get adminReportsRiskMedium => '中';

  @override
  String get adminReportsRiskHigh => '高';

  @override
  String get adminReportsRiskInvalid => '无效';

  @override
  String get adminAuditTitle => '系统审计日志';

  @override
  String get adminAuditClearFiltersTooltip => '清除筛选';

  @override
  String get adminAuditSearchHint => '搜索描述...';

  @override
  String get adminAuditAllDates => '所有日期';

  @override
  String adminAuditDateRange(Object start, Object end) {
    return '$start - $end';
  }

  @override
  String get adminAuditTableFilterHint => '表';

  @override
  String get adminAuditActionFilterHint => '操作';

  @override
  String get adminAuditEmptyState => '没有符合条件的审计日志。';

  @override
  String get adminAuditClearAllFilters => '清除所有筛选';

  @override
  String get adminAuditUnknownTime => '时间未知';

  @override
  String get adminAuditNoDetails => '暂无详情';

  @override
  String get adminAuditSystemActor => '系统 / 匿名';

  @override
  String get adminAuditUnknownRole => '未知';

  @override
  String get adminAuditNotAvailable => '暂无';

  @override
  String get adminAuditActorLabel => '操作者';

  @override
  String get adminAuditTargetTableLabel => '目标表';

  @override
  String get adminAuditTargetIdLabel => '目标 ID';

  @override
  String get adminAuditTableProfiles => '用户资料';

  @override
  String get adminAuditTableProperties => '房源';

  @override
  String get adminAuditTableBookings => '预订';

  @override
  String get adminAuditTablePropertyReports => '房源举报';

  @override
  String get adminAuditTableReports => '举报';

  @override
  String get adminAuditTableAuditLogs => '审计日志';

  @override
  String get adminAuditActionAdminCreated => '管理员已创建';

  @override
  String get adminAuditActionAdminUpdated => '管理员已更新';

  @override
  String get adminAuditActionAdminRemoved => '管理员已移除';

  @override
  String get adminAuditActionReportContactOwner => '举报：联系房东';

  @override
  String get adminAuditActionReportContactTenant => '举报：联系租客';

  @override
  String get adminAuditActionReportRiskLow => '举报：低风险';

  @override
  String get adminAuditActionReportRiskMedium => '举报：中风险';

  @override
  String get adminAuditActionReportRiskHigh => '举报：高风险';

  @override
  String get adminAuditActionReportRiskInvalid => '举报：无效风险';

  @override
  String get adminAuditActionReportReviewed => '举报：已审核';

  @override
  String get adminAuditActionReportDismissed => '举报：已驳回';

  @override
  String get adminAuditActionPropertyApproved => '房源已批准';

  @override
  String get adminAuditActionPropertyRejected => '房源已拒绝';

  @override
  String get adminAuditActionProfileUpdate => '资料已更新';

  @override
  String adminAuditLoadError(Object error) {
    return '加载日志失败：$error';
  }

  @override
  String get propertyReportTitle => '举报房源';

  @override
  String get propertyReportSubtitle => '请选择举报该房源的原因。我们的团队将尽快审核。';

  @override
  String get propertyReportReasonFake => '虚假房源 / 诈骗';

  @override
  String get propertyReportReasonSuspicious => '可疑活动';

  @override
  String get propertyReportReasonWrongDetails => '房源信息错误';

  @override
  String get propertyReportReasonInappropriate => '不当内容';

  @override
  String get propertyReportReasonOther => '其他原因';

  @override
  String get propertyReportDescriptionHint => '提供更多详情（可选）';

  @override
  String get propertyReportCancel => '取消';

  @override
  String get propertyReportSubmit => '提交举报';

  @override
  String get propertyReportSubmitted => '举报已提交，谢谢。';

  @override
  String get propertyReportSubmitFailed => '提交举报失败，请稍后重试。';

  @override
  String get propertyReportServiceUnavailable => '举报服务暂时不可用，请检查网络连接。';

  @override
  String get propertyReportLoginRequired => '请先登录以提交举报。';

  @override
  String get propertyReportTenantOnly => '只有租客可以提交房源举报。';

  @override
  String get propertyReportOwnProperty => '你不能举报自己的房源。';

  @override
  String get propertyReportInvalidMetadata => '房源元数据无效，无法举报。';

  @override
  String get propertyFacilitiesTitle => '设施';

  @override
  String get propertyNoFacilities => '暂无设施信息。';

  @override
  String get propertyOwnerInfoTitle => '房东信息';

  @override
  String get propertyOwnerHighRisk => '高风险';

  @override
  String get propertyOwnerSuspicious => '可疑房东';

  @override
  String get propertyOwnerSuspended => '已停用';

  @override
  String get propertyOwnerRemoved => '已移除';

  @override
  String get propertyAvailabilityTitle => '房源状态';

  @override
  String get propertyAvailabilityLabel => '房源状态：';

  @override
  String get propertyStatusActive => '出租中';

  @override
  String get propertyStatusOccupied => '已出租';

  @override
  String get propertyStatusInactive => '已下架';

  @override
  String get propertyReportErrorPermission => '由于权限限制，无法提交举报。请联系支持团队。';

  @override
  String get propertyReportErrorInvalidListing => '由于房源引用无效，无法提交举报。';

  @override
  String get propertyReportErrorInvalidData => '由于举报数据无效，无法提交举报。';

  @override
  String propertyNearbyLabel(Object landmarks) {
    return '周边：$landmarks';
  }

  @override
  String get propertyDetailsTitle => '房源详情';

  @override
  String get propertyUnavailableAdmin => '该房源目前因审核中而无法查看。';

  @override
  String get propertyUnavailableBooking => '该房源目前已出租，暂时无法预订。';

  @override
  String get propertyFavoriteLoginRequired => '请先登录以添加至收藏。';

  @override
  String get propertyFavoriteTenantOnly => '只有租客可以收藏房源。';

  @override
  String get propertyFavoritePolicyBlocked => '由于安全策略，无法更新收藏状态。';

  @override
  String get propertyFavoriteUpdateFailed => '更新收藏失败，请稍后再试。';

  @override
  String get propertyHighRiskTag => '高风险';

  @override
  String get propertyLocationTitle => '位置信息';

  @override
  String get propertyDescriptionTitle => '房源描述';

  @override
  String get bookingBookNow => '立即预订';

  @override
  String get bookingHistoryEmpty => '没有符合条件的预订记录。';

  @override
  String get ownerAvailabilityEndAfterStart => '结束时间必须晚于开始时间。';

  @override
  String get ownerAvailabilityPastDate => '不能为过去日期添加时段。';

  @override
  String get ownerAvailabilityOverlap => '该时段与已有时段重叠。';

  @override
  String get ownerAvailabilitySlotAdded => '看房时段已成功添加。';

  @override
  String get ownerAvailabilityAddFailed => '添加时段失败，请重试。';

  @override
  String get ownerAvailabilityDeleteFailed => '删除时段失败，请重试。';

  @override
  String ownerAvailabilityDateTime(Object date, Object time) {
    return '$date 于 $time';
  }

  @override
  String get ownerAvailabilityCreateSlot => '创建新的看房时段';

  @override
  String get ownerAvailabilitySelectDate => '选择日期';

  @override
  String get ownerAvailabilityStartTime => '开始时间';

  @override
  String get ownerAvailabilityEndTime => '结束时间';

  @override
  String get ownerAvailabilityActiveSlots => '你的可用时段';

  @override
  String get ownerAvailabilityStatusAvailable => '可用';

  @override
  String get ownerAvailabilityStatusBooked => '已预订';

  @override
  String get ownerAvailabilityStatusApproved => '已批准';

  @override
  String get ownerAvailabilityDeleteConfirmTitle => '删除时段？';

  @override
  String get ownerAvailabilityDeleteConfirmMessage => '确定要删除这个可用时段吗？';

  @override
  String get ownerAvailabilityEmpty => '尚未添加可用时段。';

  @override
  String get ownerAvailabilityAddSlot => '添加时段';

  @override
  String get ownerAvailabilityBooked => '已预订';

  @override
  String get ownerAvailabilityAvailable => '可用';

  @override
  String get ownerAvailabilityTitle => '看房可用时间';

  @override
  String get paymentCardIncomplete => '请输入完整的到期日期。';

  @override
  String get paymentCardInvalidMonth => '月份无效（01-12）。';

  @override
  String get paymentCardExpired => '卡已过期。';

  @override
  String get paymentCardInvalidFormat => '到期日期格式无效（MM/YY）。';

  @override
  String get paymentTitle => '付款';

  @override
  String get paymentCompletedLabel => '付款已完成';

  @override
  String get paymentPayNow => '立即支付';

  @override
  String get paymentMethodTitle => '支付方式';

  @override
  String get paymentMethodCard => '信用卡/借记卡';

  @override
  String get paymentMethodBanking => '网上银行';

  @override
  String get paymentSelectBank => '选择银行';

  @override
  String get paymentCardNumberLabel => '卡号';

  @override
  String get paymentCardNumberHint => 'XXXX XXXX XXXX XXXX';

  @override
  String get paymentExpiryLabel => '到期日期';

  @override
  String get paymentExpiryHint => 'MM/YY';

  @override
  String get paymentCvvLabel => 'CVV';

  @override
  String get paymentCvvHint => 'XXX';

  @override
  String get paymentAmountLabel => '需支付金额';

  @override
  String get paymentTotalLabel => '总价';

  @override
  String get paymentProcessing => '付款处理中...';

  @override
  String get paymentSuccess => '付款成功！';

  @override
  String paymentSuccessSubtitle(Object amount) {
    return '你已支付 RM $amount。';
  }

  @override
  String get paymentBackToHome => '返回首页';

  @override
  String paymentError(Object message) {
    return '付款错误：$message';
  }

  @override
  String get paymentMethodEwallet => '电子钱包';

  @override
  String get paymentSelectEwallet => '选择电子钱包';

  @override
  String get paymentSelectEwalletError => '请选择电子钱包。';

  @override
  String get paymentCardNumberInvalid => '卡号无效。';

  @override
  String get paymentCvvInvalid => 'CVV 无效。';

  @override
  String get paymentSummaryTitle => '付款摘要';

  @override
  String get paymentSummaryProperty => '房源';

  @override
  String get paymentSummaryStartDate => '开始日期';

  @override
  String get paymentSummaryDuration => '时长';

  @override
  String get paymentSummaryMonthlyRent => '月租';

  @override
  String paymentDurationMonths(Object count) {
    return '$count 个月';
  }

  @override
  String get paymentSummaryMethod => '方式';

  @override
  String paymentMethodWithBank(Object bank) {
    return '网上银行（$bank）';
  }

  @override
  String paymentMethodWithEwallet(Object wallet) {
    return '电子钱包（$wallet）';
  }

  @override
  String get paymentSummaryStatus => '状态';

  @override
  String paymentRentMonth(Object number) {
    return '第 $number 个月租金';
  }

  @override
  String get paymentBookingFeeOneMonth => '预订费（1 个月）';

  @override
  String get paymentSelectBankError => '请选择银行。';

  @override
  String get paymentConfirmTitle => '确认付款';

  @override
  String get paymentConfirmMessage => '确定要继续付款吗？';

  @override
  String get paymentSummaryAmount => '金额';

  @override
  String get paymentSummaryMethodLabel => '支付方式';

  @override
  String get paymentCancel => '取消';

  @override
  String get paymentConfirmPay => '确认并支付';

  @override
  String get paymentFailed => '付款失败，请重试。';

  @override
  String get paymentSuccessMessage => '付款已成功处理。';

  @override
  String paymentFailedWithMessage(Object message) {
    return '付款失败：$message';
  }

  @override
  String get paymentErrorDetailsAction => '详情';

  @override
  String get paymentErrorDetailsTitle => '错误详情';

  @override
  String get paymentOk => '确定';

  @override
  String get paymentSuccessTitle => '付款成功';

  @override
  String get paymentViewReceipt => '查看收据';

  @override
  String get paymentDismiss => '关闭';

  @override
  String get paymentMethodCardShort => '卡';

  @override
  String get paymentLoginRequired => '请登录后再付款。';

  @override
  String get viewingHistoryPleaseLogin => '请登录查看你的看房记录。';

  @override
  String get viewingHistoryTitle => '看房记录';

  @override
  String viewingHistoryErrorWithMessage(Object message) {
    return '错误：$message';
  }

  @override
  String get viewingHistoryCancelTitle => '取消看房';

  @override
  String get viewingHistoryCancelMessage => '确定要取消该看房预约吗？';

  @override
  String get viewingHistoryKeepAppointment => '保留预约';

  @override
  String get viewingHistoryConfirmCancellation => '确认取消';

  @override
  String get viewingHistoryCancelledSuccess => '看房预约已取消';

  @override
  String viewingHistoryCancelFailed(Object error) {
    return '取消看房失败：$error';
  }

  @override
  String get viewingHistoryEmptyAll => '暂无看房请求。';

  @override
  String get viewingHistoryEmptyForStatus => '该状态暂无看房请求。';

  @override
  String get viewingHistoryFallbackLocation => '位置不可用';

  @override
  String get viewingHistoryFallbackPrice => '价格不可用';

  @override
  String get viewingHistoryFallbackDescription => '房源详情暂不可用。';

  @override
  String get viewingHistoryFallbackHostRole => '房东';

  @override
  String get viewingHistoryDateLabel => '看房日期';

  @override
  String get viewingHistoryTimeLabel => '看房时间';

  @override
  String get viewingHistoryScheduledLabel => '已预约';

  @override
  String get viewingHistoryCancelAction => '取消';

  @override
  String get statusCancelled => '已取消';

  @override
  String get statusRescheduled => '已改期';

  @override
  String get statusSlotTaken => '时段已占用';

  @override
  String get statusPropertyRented => '房源已出租';
}
