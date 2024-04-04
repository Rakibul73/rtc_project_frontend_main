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

class FundMonitoringPanelScreen extends StatefulWidget {
  const FundMonitoringPanelScreen({Key? key}) : super(key: key);

  @override
  State<FundMonitoringPanelScreen> createState() => _FundMonitoringPanelScreenState();
}

class _FundMonitoringPanelScreenState extends State<FundMonitoringPanelScreen> {
  final _dataTableHorizontalScrollController = ScrollController();
  late Future<Map<String, dynamic>> _summaryDataFuture;

  Future<Map<String, dynamic>> _fetchProjectSummaryData() async {
    final data = await ApiService.getAdminFundDashboard();
    print("_fetchProjectSummaryData = data: $data");
    print(data['statuscode']);
    if (data['statuscode'] == 200) {
      // Handle successful response
      final fundConfirmationRecieved = await data['fund_confirmation_recieved'];
      final fundedProjects = await data['funded_projects'];
      final fundRequestQueue = await data['fund_request_queue'];

      final Map<String, dynamic> summaryData = {
        'fund_confirmation_recieved': await fundConfirmationRecieved,
        'funded_projects': await fundedProjects,
        'fund_request_queue': await fundRequestQueue,
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
        'fund_confirmation_recieved': 0,
        'funded_projects': 0,
        'fund_request_queue': 0,
      };
      return summaryData;
    } else {
      // Handle other error cases
      final Map<String, dynamic> summaryData = {
        'fund_confirmation_recieved': 'x',
        'funded_projects': 'x',
        'fund_request_queue': 'x',
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
                text: TextSpan(
                  style: themeData.textTheme.headlineMedium,
                  children: const [
                    TextSpan(
                      text: 'All Project Fund Hub ',
                    ),
                    TextSpan(
                      text: '(No of Projects:)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(183, 59, 255, 248), // Change color to your desired color
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
                        SummaryCard(
                          title: "Fund Request Queue",
                          value: snapshot.data!['fund_request_queue'].toString(),
                          icon: Icons.people_rounded,
                          backgroundColor: appColorScheme.success,
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Funded Projects",
                          value: snapshot.data!['funded_projects'].toString(),
                          icon: Icons.article_outlined,
                          backgroundColor: const Color.fromARGB(255, 255, 162, 68),
                          textColor: themeData.colorScheme.onPrimary,
                          iconColor: Colors.black12,
                          width: summaryCardWidth,
                        ),
                        SummaryCard(
                          title: "Fund Confirmation Recieved",
                          value: snapshot.data!['fund_confirmation_recieved'].toString(),
                          icon: Icons.article_outlined,
                          backgroundColor: const Color.fromARGB(255, 68, 202, 255),
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
                                onPressed: () => GoRouter.of(context).go(RouteUri.allfundrequestqueuelist),
                                style: appButtonTheme.successOutlined,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.reviews_rounded),
                                    ),
                                    Text('Queue List'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => GoRouter.of(context).go(RouteUri.allfundconfirmlist),
                                style: appButtonTheme.infoOutlined,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: kTextPadding),
                                      child: Icon(Icons.reviews_outlined),
                                    ),
                                    Text('Fund Confirm List'),
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
