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

class ReviewPanelOverviewScreen extends StatefulWidget {
  const ReviewPanelOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewPanelOverviewScreen> createState() => _ReviewPanelOverviewScreenState();
}

class _ReviewPanelOverviewScreenState extends State<ReviewPanelOverviewScreen> {
  final _dataTableHorizontalScrollController = ScrollController();
  late Future<Map<String, dynamic>> _summaryDataFuture;

  Future<Map<String, dynamic>> _fetchProjectSummaryData() async {
    final data = await ApiService.getReviewPanelOverview();

    if (data['statuscode'] == 200) {
      // Handle successful response
      final reviewerGaveReview = await data['reviewer_gave_review'];
      final assignedReviewer = await data['assigned_reviewer'];
      final needToAssignReviewer = await data['need_to_assign_reviewer'];

      final Map<String, dynamic> summaryData = {
        'reviewer_gave_review': await reviewerGaveReview,
        'assigned_reviewer': await assignedReviewer,
        'need_to_assign_reviewer': await needToAssignReviewer,
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
        'reviewer_gave_review': 0,
        'assigned_reviewer': 0,
        'need_to_assign_reviewer': 0,
      };
      return summaryData;
    } else {
      // Handle other error cases
      final Map<String, dynamic> summaryData = {
        'reviewer_gave_review': 'x',
        'assigned_reviewer': 'x',
        'need_to_assign_reviewer': 'x',
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
                "No of Projects = ",
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
                          title: "Need to Assign Reviewer",
                          value: snapshot.data!['need_to_assign_reviewer'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: appColorScheme.success,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Assigned Reviewer",
                          value: snapshot.data!['assigned_reviewer'].toString(),
                          icon: Icons.article_outlined,
                          backgroundColor: const Color.fromARGB(255, 255, 162, 68),
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Reviewer Gave Review",
                          value: snapshot.data!['reviewer_gave_review'].toString(),
                          icon: Icons.group_add_rounded,
                          backgroundColor: appColorScheme.warning,
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
                                onPressed: () => GoRouter.of(context).go(RouteUri.projectyouhavetoassignreviewer),
                                style: appButtonTheme.successOutlined,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.reviews_rounded),
                                    ),
                                    Text('Projects you have to Assign Reviewer'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => GoRouter.of(context).go(RouteUri.projectreviewerhasgivenreview),
                                style: appButtonTheme.warningOutlined,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.reviews_outlined),
                                    ),
                                    Text('Projects that Reviewer has given Review'),
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
