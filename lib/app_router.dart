import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/views/screens/admin/AllFundConfirmListScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/AllFundRequestQueueListScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/CreateCircularNoticeScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/EditNoticeAdminScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/FundMonitoringPanelScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/ProjectReviewerHasGivenReviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/ProjectYouHaveToAssignReviewerScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/ReviewPanelOverviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/UserProfileScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/VerifiedUsersScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/ViewReviewOfTheProjectAdminScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/CircularNoticeScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/MyProjectRecievedFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ProjectFundManagementScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/ChangePasswordScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/CreateProject.dart';
import 'package:rtc_project_fronend/views/screens/admin/DeleteUserScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/MyProjectReviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/MyProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/NotificationScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/PendingUsersScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ProjectDashboardScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/ProjectOverviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ProjectHaveToReviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ProjectICanApplyForFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ProjectMonitoringReportScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ProjectReviewTrackingScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/SearchProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/UserManagementOverviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/VerifyUserScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/ViewAllNotificationScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/EditProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/EditProjectScreenAdmin.dart';
import 'package:rtc_project_fronend/views/screens/general/ViewIndividualNotificationScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/ViewProjectScreenAdmin.dart';
import 'package:rtc_project_fronend/views/screens/general/dashboard_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/error_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/forgot_pass.dart';
import 'package:rtc_project_fronend/views/screens/general/login_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/logout_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/MyProfileScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/register_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/reset_pass_screen.dart';
import 'package:rtc_project_fronend/views/screens/user/RequestForAProjectFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ReviewIndividualProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/ViewRequestForAProjectFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ViewProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/ViewReviewOfTheProjectScreen.dart';

class RouteUri {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String myProfile = '/my-profile';
  static const String logout = '/logout';
  static const String error404 = '/404';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotpass = '/forgotpass';
  static const String resetpassscreen = '/resetpassscreen';
  static const String createproject = '/createproject';
  static const String searchproject = '/searchproject';
  static const String myprojects = '/myprojects';
  static const String viewprojectadmin = '/viewprojectadmin';
  static const String viewproject = '/viewproject';
  static const String editproject = '/editproject';
  static const String editprojectadmin = '/editprojectadmin';
  static const String projectreviewtracking = '/projectreviewtracking';
  static const String projectdashboard = '/projectdashboard';
  static const String projectfundmanagement = '/projectfundmanagement';
  static const String projectmonitoringreport = '/projectmonitoringreport';
  static const String usermanagementoverview = '/usermanagementoverview';
  static const String pendingusers = '/pendingusers';
  static const String verifiedusers = '/verifiedusers';
  static const String verifyuser = '/verifyuser';
  static const String userprofile = '/userprofile';
  static const String projectoverview = '/projectoverview';
  static const String deleteuser = '/deleteuser';
  static const String notification = '/notification';
  static const String viewallnotifications = '/viewallnotifications';
  static const String viewindividualnotification = '/viewindividualnotification';
  static const String changepassword = '/changepassword';
  static const String myprojectreview = '/myprojectreview';
  static const String projecthavetoreview = '/projecthavetoreview';
  static const String reviewprojectscreen = '/reviewprojectscreen';
  static const String reviewpaneloverview = '/reviewpaneloverview';
  static const String projectyouhavetoassignreviewer = '/projectyouhavetoassignreviewer';
  static const String projectreviewerhasgivenreview = '/projectreviewerhasgivenreview';
  static const String viewreviewoftheproject = '/viewreviewoftheproject';
  static const String viewreviewoftheprojectadmin = '/viewreviewoftheprojectadmin';
  static const String projecticanapplyforfund = '/projecticanapplyforfund';
  static const String requestforaprojectfund = '/requestforaprojectfund';
  static const String viewrequestforaprojectfund = '/viewrequestforaprojectfund';
  static const String myprojectrecievedfund = '/myprojectrecievedfund';
  static const String fundmonitoringpanel = '/fundmonitoringpanel';
  static const String allfundrequestqueuelist = '/allfundrequestqueuelist';
  static const String allfundconfirmlist = '/allfundconfirmlist';
  static const String circularnotice = '/circularnotice';
  static const String createcircularnotice = '/createcircularnotice';
  static const String editnoticeadmin = '/editnoticeadmin';
}

const List<String> unrestrictedRoutes = [
  RouteUri.error404,
  RouteUri.logout,
  // RouteUri.login, // Remove this line for actual authentication flow.
  // RouteUri.register, // Remove this line for actual authentication flow.
];

const List<String> publicRoutes = [
  RouteUri.login, // Enable this line for actual authentication flow.
  RouteUri.register, // Enable this line for actual authentication flow.
  RouteUri.forgotpass,
  RouteUri.resetpassscreen,
];

GoRouter appRouter(UserDataProvider userDataProvider) {
  return GoRouter(
    initialLocation: RouteUri.home,
    errorPageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const ErrorScreen(),
    ),
    routes: [
      GoRoute(
        path: RouteUri.home,
        redirect: (context, state) => RouteUri.dashboard,
      ),
      GoRoute(
        path: RouteUri.dashboard,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.myProfile,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyProfileScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.createproject,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const CreateProjectScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.searchproject,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const SearchProjectScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projecthavetoreview,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectHaveToReviewScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.myprojectreview,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyProjectReviewScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.myprojects,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyProjectScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.viewprojectadmin,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewProjectScreenAdmin(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewproject,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewProjectScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.editproject,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: EditProjectScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.editprojectadmin,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: EditProjectScreenAdmin(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.verifyuser,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: VerifyUserScreen(pendingUserID: state.queryParameters['pendinguserid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.userprofile,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: UserProfileScreen(userID: state.queryParameters['userid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.reviewprojectscreen,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ReviewIndividualProjectScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewreviewoftheprojectadmin,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewReviewOfTheProjectAdminScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.editnoticeadmin,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: EditNoticeAdminScreen(noticeID: state.queryParameters['noticeid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.requestforaprojectfund,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: RequestForAProjectFundScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewrequestforaprojectfund,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewRequestForAProjectFundScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewreviewoftheproject,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewReviewOfTheProjectScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewindividualnotification,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewIndividualNotificationScreen(notificationID: state.queryParameters['notification_id'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.projectmonitoringreport,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectMonitoringReportScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projecticanapplyforfund,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectICanApplyForFundScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.fundmonitoringpanel,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const FundMonitoringPanelScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.myprojectrecievedfund,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyProjectRecievedFundScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.circularnotice,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const CircularNoticeScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.createcircularnotice,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const CreateCircularNoticeScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projectfundmanagement,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectFundManagementScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projectdashboard,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectDashboardScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.allfundconfirmlist,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AllFundConfirmListScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.allfundrequestqueuelist,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AllFundRequestQueueListScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projectreviewtracking,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectReviewTrackingScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.notification,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const NotificationScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.viewallnotifications,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ViewAllNotificationScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projectyouhavetoassignreviewer,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectYouHaveToAssignReviewerScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projectreviewerhasgivenreview,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectReviewerHasGivenReviewScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.reviewpaneloverview,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ReviewPanelOverviewScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.deleteuser,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const DeleteUserScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projectoverview,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectOverviewScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.usermanagementoverview,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const UserManagementOverviewScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.pendingusers,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const PendingUsersScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.verifiedusers,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const VerifiedUsersScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.changepassword,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ChangePasswordScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.logout,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LogoutScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.login,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.forgotpass,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ForgotPass(),
        ),
      ),
      GoRoute(
        path: RouteUri.resetpassscreen,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ResetPassScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.register,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const RegisterScreen(),
          );
        },
      ),
    ],
    redirect: (context, state) {
      if (unrestrictedRoutes.contains(state.matchedLocation)) {
        return null;
      } else if (publicRoutes.contains(state.matchedLocation)) {
        // Is public route.
        if (userDataProvider.isUserLoggedIn()) {
          // User is logged in, redirect to home page.
          return RouteUri.home;
        }
      } else {
        // Not public route.
        if (!userDataProvider.isUserLoggedIn()) {
          // User is not logged in, redirect to login page.
          return RouteUri.login;
        }
      }

      return null;
    },
  );
}
