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

class ProjectMonitoringReportScreen extends StatefulWidget {
  const ProjectMonitoringReportScreen({Key? key}) : super(key: key);

  @override
  State<ProjectMonitoringReportScreen> createState() => _ProjectMonitoringReportScreenState();
}

class _ProjectMonitoringReportScreenState extends State<ProjectMonitoringReportScreen> {
  final _dataTableHorizontalScrollController = ScrollController();
  late Future<Map<String, dynamic>> _summaryDataFuture;

  Future<Map<String, dynamic>> _fetchProjectSummaryData() async {
    final data = await ApiService.getMyMonitoringDashboard();
    print("_fetchProjectSummaryData = data: $data");
    print(data['statuscode']);
    if (data['statuscode'] == 200) {
      // Handle successful response
      final feedbackFromCommittee = await data['feedback_from_committee'];
      final sendForMonitoring = await data['send_for_monitoring'];
      final canSendMonitoringReport = await data['can_send_monitoring_report'];
      final noOfReportAssignedToMe = await data['no_of_report_assigned_to_me'];
      final feedbackSent = await data['feedback_sent'];

      final Map<String, dynamic> summaryData = {
        'feedback_from_committee': await feedbackFromCommittee,
        'send_for_monitoring': await sendForMonitoring,
        'can_send_monitoring_report': await canSendMonitoringReport,
        'feedback_sent': await feedbackSent,
        'no_of_report_assigned_to_me': await noOfReportAssignedToMe,
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
        btnOkOnPress: () {},
      );

      dialog.show();
      final Map<String, dynamic> summaryData = {
        'feedback_from_committee': 0,
        'send_for_monitoring': 0,
        'can_send_monitoring_report': 0,
        'feedback_sent': 0,
        'no_of_report_assigned_to_me': 0,
      };
      return summaryData;
    } else {
      // Handle other error cases
      final Map<String, dynamic> summaryData = {
        'feedback_from_committee': 'x',
        'send_for_monitoring': 'x',
        'can_send_monitoring_report': 'x',
        'feedback_sent': 'x',
        'no_of_report_assigned_to_me': 'x',
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
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: themeData.textTheme.headlineMedium,
                  children: const [
                    // TextSpan(
                    //   text: '',
                    // ),
                    TextSpan(
                      text: 'As Monitoring Committee',
                      style: TextStyle(
                        color: Color.fromARGB(183, 228, 229, 229), // Change color to your desired color
                      ),
                    ),
                  ],
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
                        // SizedBox(
                        //   height: 120.0,
                        //   width: summaryCardWidth,
                        // ),
                        SummaryCard(
                          title: "No. of Report Assigned To Me",
                          value: snapshot.data!['no_of_report_assigned_to_me'].toString(),
                          icon: Icons.add_task_outlined,
                          backgroundColor: appColorScheme.tia,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Feedback Sent",
                          value: snapshot.data!['feedback_sent'].toString(),
                          icon: Icons.add_task_outlined,
                          backgroundColor: appColorScheme.violet,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                      ],
                    );
                  },
                ),
              ),
              RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  style: themeData.textTheme.headlineMedium,
                  children: const [
                    // TextSpan(
                    //   text: '',
                    // ),
                    TextSpan(
                      text: 'My Project Monitoring Hub',
                      style: TextStyle(
                        color: Color.fromARGB(183, 228, 229, 229), // Change color to your desired color
                      ),
                    ),
                  ],
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
                        SizedBox(
                          height: 120.0,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Can Send Monitoring Report",
                          value: snapshot.data!['can_send_monitoring_report'].toString(),
                          icon: Icons.add_task_outlined,
                          backgroundColor: appColorScheme.primary,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Monitoring Report Sent",
                          value: snapshot.data!['send_for_monitoring'].toString(),
                          icon: Icons.add_task_outlined,
                          backgroundColor: appColorScheme.secondary,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Received Feedback From Committee",
                          value: snapshot.data!['feedback_from_committee'].toString(),
                          icon: Icons.feedback_rounded,
                          backgroundColor: appColorScheme.info,
                          textColor: appColorScheme.buttonTextBlack,
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
                                onPressed: () => GoRouter.of(context).go(RouteUri.monitorthereportasmonitoringcommittee),
                                style: appButtonTheme.tiaOutlined,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.reviews_rounded),
                                    ),
                                    Text('Monitor The Report As Monitoring Committee'),
                                  ],
                                ),
                              ),
                            ),
                            // const SizedBox(width: 20),
                            // Expanded(
                            //   child: ElevatedButton(
                            //     onPressed: () => GoRouter.of(context).go(RouteUri.myrecievedfeedbackfrommonitoringcommittee),
                            //     style: appButtonTheme.infoOutlined,
                            //     child: const Row(
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         Padding(
                            //           padding: EdgeInsets.only(right: kTextPadding),
                            //           child: Icon(Icons.reviews_outlined),
                            //         ),
                            //         Text('Recieved feedback from monitoring committee'),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                                onPressed: () => GoRouter.of(context).go(RouteUri.projectineedtosendmonitoringreport),
                                style: appButtonTheme.successOutlined,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.reviews_rounded),
                                    ),
                                    Text('Projects I need to send monitoring report'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => GoRouter.of(context).go(RouteUri.myrecievedfeedbackfrommonitoringcommittee),
                                style: appButtonTheme.infoOutlined,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.reviews_outlined),
                                    ),
                                    Text('Recieved feedback from monitoring committee'),
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
                                onPressed: () => GoRouter.of(context).go(RouteUri.viewallofmymonitoringreporthistory),
                                style: appButtonTheme.secondaryOutlined,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.history_rounded),
                                    ),
                                    Text('View All of My Monitoring Report History'),
                                  ],
                                ),
                              ),
                            ),
                            // const SizedBox(width: 20),
                            // Expanded(
                            //   child: ElevatedButton(
                            //     onPressed: () => GoRouter.of(context).go(RouteUri.myrecievedfeedbackfrommonitoringcommittee),
                            //     style: appButtonTheme.infoOutlined,
                            //     child: const Row(
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         Padding(
                            //           padding: EdgeInsets.only(right: kTextPadding),
                            //           child: Icon(Icons.reviews_outlined),
                            //         ),
                            //         Text('Recieved feedback from monitoring committee'),
                            //       ],
                            //     ),
                            //   ),
                            // ),
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
