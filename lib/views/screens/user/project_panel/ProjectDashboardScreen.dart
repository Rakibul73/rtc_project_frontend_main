// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';

class ProjectDashboardScreen extends StatefulWidget {
  const ProjectDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  final _dataTableHorizontalScrollController = ScrollController();
  late Future<Map<String, dynamic>> _summaryDataFuture;

  Future<Map<String, dynamic>> _fetchProjectSummaryData() async {
    final data = await ApiService.getSelfProjectDashboard();

    if (data['statuscode'] == 200) {
      // Handle successful response
      final runningProjects = data['running_projects'];
      final rejectedProjects = await data['rejected_projects'];
      final approvedProjects = await data['approved_projects'];
      final pendingProjects = await data['pending_projects'];
      final finalReportSubmitted = await data['final_report_submitted'];
      final completedProjects = await data['completed_projects'];
      final totalProjects = await data['total_projects'];

      final Map<String, dynamic> summaryData = {
        'running_projects': await runningProjects,
        'rejected_projects': await rejectedProjects,
        'approved_projects': await approvedProjects,
        'pending_projects': await pendingProjects,
        'final_report_submitted': await finalReportSubmitted,
        'completed_projects': await completedProjects,
        'total_projects': await totalProjects,
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
        'running_projects': 0,
        'rejected_projects': 0,
        'approved_projects': 0,
        'pending_projects': 0,
        'final_report_submitted': 0,
        'completed_projects': 0,
        'total_projects': 0,
      };
      return summaryData;
    } else {
      // Handle other error cases
      final Map<String, dynamic> summaryData = {
        'running_projects': 'x',
        'rejected_projects': 'x',
        'approved_projects': 'x',
        'pending_projects': 'x',
        'final_report_submitted': 'x',
        'completed_projects': 'x',
        'total_projects': 'x',
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
    final size = MediaQuery.of(context).size;
    final summaryCardCrossAxisCount = (size.width >= kScreenWidthLg ? 4 : 2);
    var isAdmin = Provider.of<UserDataProvider>(context).roleId;

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
                "Project Dashboard",
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
                        SummaryCard(
                          title: "Total Projects",
                          value: snapshot.data!['total_projects'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: appColorScheme.success,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Completed Projects",
                          value: snapshot.data!['completed_projects'].toString(),
                          icon: Icons.article_outlined,
                          backgroundColor: const Color.fromARGB(255, 255, 162, 68),
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Final Report Submitted",
                          value: snapshot.data!['final_report_submitted'].toString(),
                          icon: Icons.group_add_rounded,
                          backgroundColor: appColorScheme.warning,
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
                          title: "Pending Projects",
                          value: snapshot.data!['pending_projects'].toString(),
                          icon: Icons.article_outlined,
                          backgroundColor: appColorScheme.warning,
                          textColor: appColorScheme.buttonTextBlack,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Approved Projects",
                          value: snapshot.data!['approved_projects'].toString(),
                          icon: Icons.group_add_rounded,
                          backgroundColor: appColorScheme.success,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Rejected Projects",
                          value: snapshot.data!['rejected_projects'].toString(),
                          icon: Icons.attach_file_rounded,
                          backgroundColor: appColorScheme.error,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Running Projects",
                          value: snapshot.data!['running_projects'].toString(),
                          icon: Icons.attach_file_rounded,
                          backgroundColor: const Color.fromARGB(255, 43, 215, 218),
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Visibility(
                visible: isAdmin != 1,
                child: Padding(
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.circularnotice),
                                  style: themeData.extension<AppButtonTheme>()!.warningText,
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: kTextPadding),
                                        child: Icon(Icons.notifications_active_outlined),
                                      ),
                                      Text('Notice Board'),
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
