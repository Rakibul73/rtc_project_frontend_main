import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:rtc_project_fronend/api_service.dart';

class UserManagementOverviewScreen extends StatefulWidget {
  const UserManagementOverviewScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementOverviewScreen> createState() => _UserManagementOverviewScreenState();
}

class _UserManagementOverviewScreenState extends State<UserManagementOverviewScreen> {
  final _dataTableHorizontalScrollController = ScrollController();
  late Future<Map<String, dynamic>> _summaryDataFuture;

  Future<Map<String, dynamic>> _fetchProjectSummaryData() async {
    final data = await ApiService.getUserManagementOverview();

    if (data['statuscode'] == 200) {
      // Handle successful response
      final totalTeacher = await data['total_teacher'];
      final totalResearcher = await data['total_researcher'];
      final totalAdmin = await data['total_admin'];
      final totalStudent = await data['total_student'];
      final totalReviewer = await data['total_reviewer'];
      final totalPendingUsers = await data['total_pending_users'];
      final totalUsers = await data['total_users'];

      final Map<String, dynamic> summaryData = {
        'total_teacher': await totalTeacher,
        'total_researcher': await totalResearcher,
        'total_admin': await totalAdmin,
        'total_student': await totalStudent,
        'total_reviewer': await totalReviewer,
        'total_pending_users': await totalPendingUsers,
        'total_users': await totalUsers,
      };
      return summaryData;
    } else if (data['statuscode'] == 401) {
      // Handle token expiration
      // ignore: use_build_context_synchronously
      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        desc: "Token expired. Please login again.",
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {
          GoRouter.of(context).go(RouteUri.logout);
        },
      );

      dialog.show();
      final Map<String, dynamic> summaryData = {
        'total_teacher': 0,
        'total_researcher': 0,
        'total_admin': 0,
        'total_student': 0,
        'total_reviewer': 0,
        'total_pending_users': 0,
        'total_users': 0,
      };
      return summaryData;
    } else {
      // Handle other error cases
      final Map<String, dynamic> summaryData = {
        'total_teacher': 'x',
        'total_researcher': 'x',
        'total_admin': 'x',
        'total_student': 'x',
        'total_reviewer': 'x',
        'total_pending_users': 'x',
        'total_users': 'x',
      };
      return summaryData;
    }
  }

  @override
  void initState() {
    super.initState();
    _summaryDataFuture = _fetchProjectSummaryData();
  }

  @override
  void dispose() {
    _dataTableHorizontalScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appColorScheme = Theme.of(context).extension<AppColorScheme>()!;
    // final appDataTableTheme = Theme.of(context).extension<AppDataTableTheme>()!;
    final appButtonTheme = themeData.extension<AppButtonTheme>()!;
    final size = MediaQuery.of(context).size;
    final summaryCardCrossAxisCount = (size.width >= kScreenWidthLg ? 4 : 2);

    return PortalMasterLayout(
        body: FutureBuilder<Map<String, dynamic>>(
      future: _summaryDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return ListView(
            padding: const EdgeInsets.all(kDefaultPadding),
            children: [
              Text(
                "User Management Overview",
                style: themeData.textTheme.headlineMedium,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final summaryCardWidth = ((constraints.maxWidth - (kDefaultPadding * (summaryCardCrossAxisCount - 1))) / summaryCardCrossAxisCount);
                    return Wrap(
                      direction: Axis.horizontal,
                      spacing: kDefaultPadding,
                      runSpacing: kDefaultPadding,
                      children: [
                        // SizedBox(height: 120, width: summaryCardWidth,),
                        SummaryCard(
                          title: "Total Verified Users",
                          value: snapshot.data!['total_users'].toString(),
                          icon: Icons.verified_user_rounded,
                          backgroundColor: appColorScheme.success,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Pending Users",
                          value: snapshot.data!['total_pending_users'].toString(),
                          icon: Icons.person_add_alt_1,
                          backgroundColor: appColorScheme.warning,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Admins",
                          value: snapshot.data!['total_admin'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: const Color.fromARGB(255, 173, 91, 241),
                          textColor: appColorScheme.buttonTextBlack,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        // SummaryCard(
                        //   title: "Rejected Projects",
                        //   value: snapshot.data!['total_project_report'].toString(),
                        //   icon: Icons.attach_file_rounded,
                        //   backgroundColor: appColorScheme.error,
                        //   textColor: themeData.colorScheme.onPrimary,
                        //   iconColor: Colors.black12,
                        //   width: summaryCardWidth,
                        // ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final summaryCardWidth = ((constraints.maxWidth - (kDefaultPadding * (summaryCardCrossAxisCount - 1))) / summaryCardCrossAxisCount);
                    return Wrap(
                      direction: Axis.horizontal,
                      spacing: kDefaultPadding,
                      runSpacing: kDefaultPadding,
                      children: [
                        SummaryCard(
                          title: "Total Teachers",
                          value: snapshot.data!['total_teacher'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: const Color.fromARGB(255, 235, 62, 143),
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Researchers",
                          value: snapshot.data!['total_researcher'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: appColorScheme.info,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Reviewers",
                          value: snapshot.data!['total_reviewer'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: appColorScheme.secondary,
                          textColor: appColorScheme.buttonTextBlack,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Students",
                          value: snapshot.data!['total_student'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: const Color.fromARGB(255, 116, 43, 218),
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardBody(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => GoRouter.of(context).go(RouteUri.verifiedusers),
                                style: appButtonTheme.successText,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.people_outline_rounded),
                                    ),
                                    Text('Verified Users List'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => GoRouter.of(context).go(RouteUri.pendingusers),
                                style: appButtonTheme.warningText,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.person_add_alt_1_outlined),
                                    ),
                                    Text('Pending Users List'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      },
    ));
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final double width;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 120.0,
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: backgroundColor,
        child: Stack(
          children: [
            Positioned(
              top: kDefaultPadding * 0.5,
              right: kDefaultPadding * 0.5,
              child: Icon(
                icon,
                size: 80.0,
                color: iconColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                    child: Text(
                      value,
                      style: textTheme.headlineMedium!.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    title,
                    style: textTheme.labelLarge!.copyWith(
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
