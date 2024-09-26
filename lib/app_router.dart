import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/home/screens/home/home.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/views/screens/admin/fund_panel/AllAdvanceFundConfirmListScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/fund_panel/AllAdvanceFundRequestQueueListScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/fund_panel/AllFundConfirmListScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/fund_panel/AllFundRequestQueueListScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/monitoring_panel/AssignedMonitoringCommitteeScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/monitoring_panel/MonitoringCommitteeHasGivenFeedbackScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/monitoring_panel/ViewFeedbackAdminScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/notice_board/CreateCircularNoticeScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/notice_board/EditNoticeAdminScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/fund_panel/FundMonitoringPanelScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/monitoring_panel/MonitoringPanelNeedToAssignMonitoringCommitteeScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/review_panel/ProjectReviewerHasGivenReviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/review_panel/ProjectYouHaveToAssignReviewerScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/monitoring_panel/MonitoringPanelOverviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/review_panel/ReviewPanelOverviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/user_management/UserProfileScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/user_management/VerifiedUsersScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/monitoring_panel/ViewMonitoringReportAdminScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/review_panel/ViewReviewOfTheProjectAdminScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/notice_board/CircularNoticeScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/notice_board/ViewNoticeScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/fund_panel/ViewRequestForAProjectAdvanceFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ApplyForMonitoringScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/MonitorTheReportAsMonitoringCommitteeScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/fund_panel/MyProjectRecievedAdvanceFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/fund_panel/MyProjectRecievedFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/MyRecievedFeedbackFromMonitoringCommitteeScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/fund_panel/ProjectFundManagementScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/auth/ChangePasswordScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ViewAllOfMyMonitoringReportHistoryScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ViewFeedbacksScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/project_panel/CreateProject.dart';
import 'package:rtc_project_fronend/views/screens/admin/user_management/DeleteUserScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/review_panel/MyProjectReviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/project_panel/MyProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/notification_panel/NotificationScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/user_management/PendingUsersScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/project_panel/ProjectDashboardScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/project_overview/ProjectOverviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/review_panel/ProjectHaveToReviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/fund_panel/ProjectICanApplyForFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/fund_panel/ProjectICanApplyForRequestForAdvanceScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ProjectINeedToSendMonitoringReportScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ProjectMonitoringReportScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/review_panel/ProjectReviewTrackingScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/project_overview/SearchProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/user_management/UserManagementOverviewScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/user_management/VerifyUserScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/notification_panel/ViewAllNotificationScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/project_panel/EditProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/project_overview/EditProjectScreenAdmin.dart';
import 'package:rtc_project_fronend/views/screens/general/notification_panel/ViewIndividualNotificationScreen.dart';
import 'package:rtc_project_fronend/views/screens/admin/project_overview/ViewProjectScreenAdmin.dart';
import 'package:rtc_project_fronend/views/screens/admin/DashboardScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/profile/error_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/auth/forgot_pass.dart';
import 'package:rtc_project_fronend/views/screens/general/auth/login_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/auth/logout_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/profile/MyProfileScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/auth/register_screen.dart';
import 'package:rtc_project_fronend/views/screens/general/auth/reset_pass_screen.dart';
import 'package:rtc_project_fronend/views/screens/user/fund_panel/RequestForAProjectFundAdvanceScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/fund_panel/RequestForAProjectFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/FeedbackMonitoringReportScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/review_panel/ReviewIndividualProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/general/fund_panel/ViewRequestForAProjectFundScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ViewMonitoringFeedbackScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ViewMonitoringHistoryScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/monitoring_panel/ViewMonitoringReportScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/project_panel/ViewProjectScreen.dart';
import 'package:rtc_project_fronend/views/screens/user/review_panel/ViewReviewOfTheProjectScreen.dart';

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
  static const String viewmonitoringreportadmin = '/viewmonitoringreportadmin';
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
  static const String monitorthereportasmonitoringcommittee = '/monitorthereportasmonitoringcommittee';
  static const String viewallofmymonitoringreporthistory = '/viewallofmymonitoringreporthistory';
  static const String reviewprojectscreen = '/reviewprojectscreen';
  static const String feedbackmonitoringreport = '/feedbackmonitoringreport';
  static const String reviewpaneloverview = '/reviewpaneloverview';
  static const String monitoringpaneloverview = '/monitoringpaneloverview';
  static const String projectyouhavetoassignreviewer = '/projectyouhavetoassignreviewer';
  static const String monitoringpanelneedtoassignmonitoringcommittee = '/monitoringpanelneedtoassignmonitoringcommittee';
  static const String assignedmonitoringcommittee = '/assignedmonitoringcommittee';
  static const String projectreviewerhasgivenreview = '/projectreviewerhasgivenreview';
  static const String monitoringcommitteehasgivenfeedback = '/monitoringcommitteehasgivenfeedback';
  static const String viewreviewoftheproject = '/viewreviewoftheproject';
  static const String viewreviewoftheprojectadmin = '/viewreviewoftheprojectadmin';
  static const String viewfeedbackadmin = '/viewfeedbackadmin';
  static const String viewfeedbacks = '/viewfeedbacks';
  static const String projecticanapplyforfund = '/projecticanapplyforfund';
  static const String requestforaprojectfund = '/requestforaprojectfund';
  static const String viewrequestforaprojectfund = '/viewrequestforaprojectfund';
  static const String viewrequestforaprojectadvancefund = '/viewrequestforaprojectadvancefund';
  static const String myprojectrecievedfund = '/myprojectrecievedfund';
  static const String myprojectrecievedadvancefund = '/myprojectrecievedadvancefund';
  static const String fundmonitoringpanel = '/fundmonitoringpanel';
  static const String allfundrequestqueuelist = '/allfundrequestqueuelist';
  static const String alladvancefundrequestqueuelist = '/alladvancefundrequestqueuelist';
  static const String allfundconfirmlist = '/allfundconfirmlist';
  static const String alladvancefundconfirmlist = '/alladvancefundconfirmlist';
  static const String circularnotice = '/circularnotice';
  static const String createcircularnotice = '/createcircularnotice';
  static const String editnoticeadmin = '/editnoticeadmin';
  static const String viewnotice = '/viewnotice';
  static const String projecticanapplyforrequestforadvance = '/projecticanapplyforrequestforadvance';
  static const String requestforaprojectfundadvance = '/requestforaprojectfundadvance';
  static const String applyformonitoring = '/applyformonitoring';
  static const String viewmonitoringfeedback = '/viewmonitoringfeedback';
  static const String viewmonitoringreport = '/viewmonitoringreport';
  static const String viewmonitoringhistory = '/viewmonitoringhistory';
  static const String projectineedtosendmonitoringreport = '/projectineedtosendmonitoringreport';
  static const String myrecievedfeedbackfrommonitoringcommittee = '/myrecievedfeedbackfrommonitoringcommittee';
}

const List<String> unrestrictedRoutes = [
  RouteUri.error404,
  RouteUri.logout,
];

const List<String> publicRoutes = [
  RouteUri.home,
  RouteUri.login,
  RouteUri.register,
  RouteUri.forgotpass,
  RouteUri.resetpassscreen,
  RouteUri.resetpassscreen,
];

GoRouter appRouter(UserDataProvider userDataProvider) {
  return GoRouter(
    initialLocation: RouteUri.dashboard,
    errorPageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const ErrorScreen(),
    ),
    routes: [
      GoRoute(
        path: RouteUri.home,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: HomeScreen(),
        ),
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
        path: RouteUri.monitorthereportasmonitoringcommittee,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MonitorTheReportAsMonitoringCommitteeScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.viewallofmymonitoringreporthistory,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ViewAllOfMyMonitoringReportHistoryScreen(),
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
        path: RouteUri.feedbackmonitoringreport,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: FeedbackMonitoringReportScreen(monitoringReportID: state.queryParameters['monitoringreportid'] ?? ''),
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
        path: RouteUri.viewfeedbackadmin,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewFeedbackAdminScreen(monitoringReportID: state.queryParameters['monitoringreportid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewfeedbacks,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewFeedbacksScreen(monitoringReportID: state.queryParameters['monitoringreportid'] ?? ''),
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
        path: RouteUri.requestforaprojectfundadvance,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: RequestForAProjectFundAdvanceScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.applyformonitoring,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ApplyForMonitoringScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewmonitoringfeedback,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewMonitoringFeedbackScreen(projectMonitoringFeedbackID: state.queryParameters['projectmonitoringfeedbackid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewmonitoringreport,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewMonitoringReportScreen(monitoringReportID: state.queryParameters['monitoringreportid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewmonitoringreportadmin,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewMonitoringReportAdminScreen(monitoringReportID: state.queryParameters['monitoringreportid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewmonitoringhistory,
        pageBuilder: (context, state) {
          final data = state.extra != null ? state.extra as Map<String, dynamic> : {};
          final additionalValue = data.cast<String, dynamic>(); // Add this line

          // final data = state.extra! as Map<String, dynamic>;
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewMonitoringHistoryScreen(
              projectID: state.queryParameters['projectid'] ?? '',
              additionalValue: additionalValue,
            ),
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
        path: RouteUri.viewrequestforaprojectadvancefund,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewRequestForAProjectAdvanceFundScreen(projectID: state.queryParameters['projectid'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.viewnotice,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ViewNoticeScreen(noticeID: state.queryParameters['noticeid'] ?? ''),
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
        path: RouteUri.projecticanapplyforrequestforadvance,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectICanApplyForRequestForAdvanceScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.projectineedtosendmonitoringreport,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ProjectINeedToSendMonitoringReportScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.myrecievedfeedbackfrommonitoringcommittee,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyRecievedFeedbackFromMonitoringCommitteeScreen(),
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
        path: RouteUri.myprojectrecievedadvancefund,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyProjectRecievedAdvanceFundScreen(),
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
        path: RouteUri.alladvancefundconfirmlist,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AllAdvanceFundConfirmListScreen(),
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
        path: RouteUri.alladvancefundrequestqueuelist,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AllAdvanceFundRequestQueueListScreen(),
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
        path: RouteUri.monitoringpanelneedtoassignmonitoringcommittee,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MonitoringPanelNeedToAssignMonitoringCommitteeScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.assignedmonitoringcommittee,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const AssignedMonitoringCommitteeScreen(),
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
        path: RouteUri.monitoringcommitteehasgivenfeedback,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MonitoringCommitteeHasGivenFeedbackScreen(),
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
        path: RouteUri.monitoringpaneloverview,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MonitoringPanelOverviewScreen(),
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
        if (userDataProvider.isUserLoggedIn()) {
          // User is logged in, redirect to dashboard.
          return RouteUri.dashboard;
        } else {
          // User is not logged in, stay on current URL.
          return null;
        }
      } else {
        // Not public route.
        if (!userDataProvider.isUserLoggedIn()) {
          // User is not logged in, redirect to login page.
          return RouteUri.home;
        }
      }

      return null;
    },
  );
}
