// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/constants/values.dart';
import 'package:rtc_project_fronend/generated/l10n.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dataTableHorizontalScrollController = ScrollController();
  late Future<Map<String, dynamic>> _summaryDataFuture;
  late int isAdmin;

  Future<int> getRoleID() async {
    final sharedPref = await SharedPreferences.getInstance();
    int? roleId = sharedPref.getInt(StorageKeys.roleId);
    return roleId ?? 0;
  }

  Future<Map<String, dynamic>> _fetchSummaryData() async {
    isAdmin = await getRoleID();

    final data = await ApiService.getTotalNumberOfAllDashboard();
    print("_fetchSummaryData = data: $data");
    print(data['statuscode']);
    if (data['statuscode'] == 200) {
      // Handle successful response
      final totalUsers = data['total_users'];
      final totalProjects = await data['total_projects'];
      final totalProjectReport = await data['total_project_report'];
      final totalTeacher = await data['total_teacher'];
      final totalResearcher = await data['total_researcher'];
      final totalAdmin = await data['total_admin'];
      final totalStudent = await data['total_student'];
      final totalReviewer = await data['total_reviewer'];

      final Map<String, dynamic> summaryData = {
        'total_users': await totalUsers,
        'total_projects': await totalProjects,
        'total_project_report': await totalProjectReport,
        'total_teacher': await totalTeacher,
        'total_researcher': await totalResearcher,
        'total_admin': await totalAdmin,
        'total_student': await totalStudent,
        'total_reviewer': await totalReviewer,
      };

      return summaryData;
    } else if (data['statuscode'] == 401) {
      // Handle token expiration
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
        'total_users': 0,
        'total_projects': 0,
        'total_project_report': 0,
        'total_teacher': 0,
        'total_researcher': 0,
        'total_admin': 0,
        'total_student': 0,
        'total_reviewer': 0,
      };

      return summaryData;
    } else {
      // Handle other error cases
      final Map<String, dynamic> summaryData = {
        'total_users': 'x',
        'total_projects': 'x',
        'total_project_report': 'x',
        'total_teacher': 'x',
        'total_researcher': 'x',
        'total_admin': 'x',
        'total_student': 'x',
        'total_reviewer': 'x',
      };

      return summaryData;
    }
  }

  @override
  void initState() {
    super.initState();
    _summaryDataFuture = _fetchSummaryData();
  }

  @override
  void dispose() {
    _dataTableHorizontalScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appColorScheme = Theme.of(context).extension<AppColorScheme>()!;
    // final appDataTableTheme = Theme.of(context).extension<AppDataTableTheme>()!;
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
                lang.dashboard,
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
                          title: "Total Users",
                          value: snapshot.data!['total_users'].toString(),
                          icon: Icons.verified_user_rounded,
                          backgroundColor: const Color.fromARGB(255, 255, 162, 68),
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Projects",
                          value: snapshot.data!['total_projects'].toString(),
                          icon: Icons.article_outlined,
                          backgroundColor: appColorScheme.success,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Admins",
                          value: snapshot.data!['total_admin'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: appColorScheme.warning,
                          textColor: appColorScheme.buttonTextBlack,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Total Project Reports",
                          value: snapshot.data!['total_project_report'].toString(),
                          icon: Icons.attach_file_rounded,
                          backgroundColor: appColorScheme.error,
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
              // Padding(
              //   padding: const EdgeInsets.only(bottom: kDefaultPadding),
              //   child: Card(
              //     clipBehavior: Clip.antiAlias,
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         CardHeader(
              //           title: lang.recentOrders(2),
              //           showDivider: false,
              //         ),
              //         SizedBox(
              //           width: double.infinity,
              //           child: LayoutBuilder(
              //             builder: (context, constraints) {
              //               final double dataTableWidth = max(kScreenWidthMd, constraints.maxWidth);

              //               return Scrollbar(
              //                 controller: _dataTableHorizontalScrollController,
              //                 thumbVisibility: true,
              //                 trackVisibility: true,
              //                 child: SingleChildScrollView(
              //                   scrollDirection: Axis.horizontal,
              //                   controller: _dataTableHorizontalScrollController,
              //                   child: SizedBox(
              //                     width: dataTableWidth,
              //                     child: Theme(
              //                       data: themeData.copyWith(
              //                         cardTheme: appDataTableTheme.cardTheme,
              //                         dataTableTheme: appDataTableTheme.dataTableThemeData,
              //                       ),
              //                       child: DataTable(
              //                         showCheckboxColumn: false,
              //                         showBottomBorder: true,
              //                         columns: const [
              //                           DataColumn(label: Text('No.'), numeric: true),
              //                           DataColumn(label: Text('Date')),
              //                           DataColumn(label: Text('Item')),
              //                           DataColumn(label: Text('Price'), numeric: true),
              //                         ],
              //                         rows: List.generate(5, (index) {
              //                           return DataRow.byIndex(
              //                             index: index,
              //                             cells: [
              //                               DataCell(Text('#${index + 1}')),
              //                               const DataCell(Text('2022-06-30')),
              //                               DataCell(Text('Item ${index + 1}')),
              //                               DataCell(Text('${Random().nextInt(10000)}')),
              //                             ],
              //                           );
              //                         }),
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //               );
              //             },
              //           ),
              //         ),
              //         Align(
              //           alignment: Alignment.center,
              //           child: Padding(
              //             padding: const EdgeInsets.all(kDefaultPadding),
              //             child: SizedBox(
              //               height: 40.0,
              //               width: 120.0,
              //               child: ElevatedButton(
              //                 onPressed: () {},
              //                 style: themeData.extension<AppButtonTheme>()!.infoElevated,
              //                 child: Row(
              //                   mainAxisSize: MainAxisSize.min,
              //                   crossAxisAlignment: CrossAxisAlignment.start,
              //                   children: [
              //                     Padding(
              //                       padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
              //                       child: Icon(
              //                         Icons.visibility_rounded,
              //                         size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
              //                       ),
              //                     ),
              //                     const Text('View All'),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
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
