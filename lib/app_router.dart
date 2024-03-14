import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/views/screens/BillInformationScreen.dart';
import 'package:rtc_project_fronend/views/screens/ChangePasswordScreen.dart';
import 'package:rtc_project_fronend/views/screens/CreateProject.dart';
import 'package:rtc_project_fronend/views/screens/DeleteUserScreen.dart';
import 'package:rtc_project_fronend/views/screens/MyProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/PendingUsersScreen.dart';
import 'package:rtc_project_fronend/views/screens/ProjectDashboardScreen.dart';
import 'package:rtc_project_fronend/views/screens/ProjectProgressReportScreen.dart';
import 'package:rtc_project_fronend/views/screens/ProjectTrackingScreen.dart';
import 'package:rtc_project_fronend/views/screens/SearchProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/UserManagementOverviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/VerifyUserScreen.dart';
import 'package:rtc_project_fronend/views/screens/ViewAllUsersScreen.dart';
import 'package:rtc_project_fronend/views/screens/EditProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/ViewProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/dashboard_screen.dart';
import 'package:rtc_project_fronend/views/screens/error_screen.dart';
import 'package:rtc_project_fronend/views/screens/forgot_pass.dart';
import 'package:rtc_project_fronend/views/screens/login_screen.dart';
import 'package:rtc_project_fronend/views/screens/logout_screen.dart';
import 'package:rtc_project_fronend/views/screens/my_profile_screen.dart';
import 'package:rtc_project_fronend/views/screens/register_screen.dart';
import 'package:rtc_project_fronend/views/screens/reset_pass_screen.dart';

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
  static const String viewproject = '/viewproject';
  static const String editproject = '/editproject';
  static const String projecttracking = '/projecttracking';
  static const String projectdashboard = '/projectdashboard';
  static const String billinformation = '/billinformation';
  static const String projectprogressreport = '/projectprogressreport';
  static const String usermanagementoverview = '/usermanagementoverview';
  static const String viewallusers = '/viewallusers';
  static const String pendingusers = '/pendingusers';
  static const String verifyuser = '/verifyuser';
  static const String deleteuser = '/deleteuser';
  static const String changepassword = '/changepassword';
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
        path: RouteUri.myprojects,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyProjectScreen(),
        ),
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
        path: RouteUri.verifyuser,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: VerifyUserScreen(userID: state.queryParameters['pendinguserid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.projectprogressreport,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectProgressReportScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.billinformation,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const BillInformationScreen(),
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
        path: RouteUri.projecttracking,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectTrackingScreen(),
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
        path: RouteUri.viewallusers,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ViewAllUsersScreen(),
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
