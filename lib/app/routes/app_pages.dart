import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/start_live/bindings/start_live_binding.dart';
import '../modules/start_live/views/start_live_view.dart';
import '../modules/live_streaming/bindings/live_streaming_binding.dart';
import '../modules/live_streaming/views/live_streaming_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/kyc/bindings/kyc_binding.dart';
import '../modules/kyc/views/kyc_view.dart';
import '../modules/notifications/bindings/notification_binding.dart';
import '../modules/notifications/views/notification_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/otp_view.dart';
import '../modules/auth/views/forgot_password_view.dart';
import '../modules/auth/views/reset_password_view.dart';
import '../modules/explore/bindings/explore_binding.dart';
import '../modules/explore/views/explore_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';

import '../modules/chat/views/active_users_view.dart';
import '../modules/finance/bindings/finance_binding.dart';
import '../modules/finance/views/withdraw_to_view.dart';
import '../modules/finance/views/link_account_view.dart';
import '../modules/finance/views/withdraw_amount_view.dart';
import '../modules/finance/views/payout_success_view.dart';
import '../modules/profile/bindings/edit_profile_binding.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/call/bindings/call_binding.dart';
import '../modules/call/views/call_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.START_LIVE,
      page: () => const StartLiveView(),
      binding: StartLiveBinding(),
    ),
    GetPage(
      name: _Paths.LIVE_STREAMING,
      page: () => const LiveStreamingView(),
      binding: LiveStreamingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.ACTIVE_USERS,
      page: () => const ActiveUsersView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.KYC,
      page: () => const KYCView(),
      binding: KYCBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.RESET_PASSWORD,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.EXPLORE,
      page: () => const ExploreView(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.WITHDRAW_TO,
      page: () => const WithdrawToView(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.LINK_ACCOUNT,
      page: () => const LinkAccountView(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.WITHDRAW_AMOUNT,
      page: () => const WithdrawAmountView(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: _Paths.PAYOUT_SUCCESS,
      page: () => const PayoutSuccessView(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: '/call',
      page: () => const CallView(),
      binding: CallBinding(),
    ),
  ];
}
