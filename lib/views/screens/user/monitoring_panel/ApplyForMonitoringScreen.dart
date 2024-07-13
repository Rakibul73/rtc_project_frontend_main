// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/views/screens/pdf_generate/pdf_generator.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class ApplyForMonitoringScreen extends StatefulWidget {
  final String projectID;

  const ApplyForMonitoringScreen({
    Key? key,
    required this.projectID,
  }) : super(key: key);

  @override
  State<ApplyForMonitoringScreen> createState() => _ApplyForMonitoringScreenState();
}

class _ApplyForMonitoringScreenState extends State<ApplyForMonitoringScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  late List<dynamic> initialProjectBudget = [];
  late List<dynamic> initialProjectBudgetOriginal = [];
  late List<dynamic> initialProjectGantts = [];
  late List<dynamic> initialProjectGanttsOriginal = [];
  late List<dynamic> ganttFormDataForUpload = [];
  late List<dynamic> budgetFormDataForUpload = [];
  Future<bool>? _future;

  Future<bool> _getDataAsync() async {
    if (widget.projectID.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.projectID = widget.projectID;

        int projectID = int.parse(widget.projectID);
        final projectDetailForFundSelf = await ApiService.getSpecificProjectForFundSelf(
          projectID,
        );

        if (projectDetailForFundSelf['statuscode'] == 401) {
          // Handle token expiration
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
        }

        _formData.rtcCode = projectDetailForFundSelf['project']['CodeByRTC'].toString();
        _formData.projectTitle = projectDetailForFundSelf['project']['ProjectTitle'];

        final budgetDetailsOriginal = await ApiService.fetchAllBudgetOfAProjectOriginal(
          int.parse(_formData.projectID),
        );
        if (budgetDetailsOriginal.isNotEmpty) {
          initialProjectBudgetOriginal = budgetDetailsOriginal;
        }

        final budgetDetails = await ApiService.fetchAllBudgetOfAProject(
          int.parse(_formData.projectID),
        );
        if (budgetDetails.isNotEmpty) {
          initialProjectBudget = budgetDetails;
        }

        final ganttDetails = await ApiService.fetchAllGanttOfAProject(
          int.parse(_formData.projectID),
        );
        if (ganttDetails.isNotEmpty) {
          initialProjectGantts = ganttDetails;
        }

        final ganttDetailsOriginal = await ApiService.fetchAllGanttOfAProjectOriginal(
          int.parse(_formData.projectID),
        );
        if (ganttDetailsOriginal.isNotEmpty) {
          initialProjectGanttsOriginal = ganttDetailsOriginal;
        }

        final userId = await storage.read(key: 'user_id');
        int userid = int.parse(userId!);

        final userDetailsForFundApply = await ApiService.getSpecificUserDetailsForFundApply(
          userid,
        );

        _formData.piInstituteName = userDetailsForFundApply['user']['InstituteName'] ?? '';
        _formData.piInstituteAddress = userDetailsForFundApply['user']['InstituteLocation'] ?? '';
        _formData.piName = userDetailsForFundApply['user']['FirstName'] + ' ' + userDetailsForFundApply['user']['LastName'] ?? '';
      });
    }

    return true;
  }

  void _goSubmitMonitoringReport(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    _formKey.currentState!.validate();
    _formKey.currentState!.save();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Are you sure you want to submit this monitoring report?",
      desc: "Note: This will save your modified activity plan & budget into our database.",
      width: kDialogWidth,
      btnOkText: "Yes",
      btnOkOnPress: () async {
        // here should make a api request to submit review
        _formKey.currentState!.save();
        try {
          // get current date time
          final DateTime now = DateTime.now();
          final String datePublished = DateFormat('E, dd MMM yyyy hh:mm a').format(now);
          final monitoringRequestData = {
            'ProjectID': int.parse(_formData.projectID),
            'ReportDate': datePublished,
          };

          final responseBody = await ApiService.createMonitoringRequestForSpecificProject(monitoringRequestData);
          int projectMonitoringReportID = 0;
          if (responseBody['statuscode'] == 201) {
            projectMonitoringReportID = responseBody['projectMonitoringReportID'];
          }

          // Iterate through the list of initialProjectGantts and update ganttData

          for (int i = 0; i < initialProjectGantts.length; i++) {
            Map<String, dynamic> ganttData = initialProjectGantts[i];
            // Get the corresponding FormBuilderState using GlobalKey
            final formState = GlobalKey<FormBuilderState>().currentState;
            if (formState != null && formState.saveAndValidate()) {
              // Update ganttData with the updated form values
              ganttData['Activity'] = formState.value['work_activity'];
              ganttData['ActivityStatus'] = formState.value['activity_status'];
              // Save the updated date values (StartDate and EndDate) in the desired format
              final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
              final DateTimeRange dateRange = formState.value['duration'];
              ganttData['StartDate'] = formatter.format(dateRange.start);
              ganttData['EndDate'] = formatter.format(dateRange.end);
            }

            ganttFormDataForUpload.add(ganttData);
          }

          final responseBodyGantt = await ApiService.updateProjectGanttDetailsForMonitoring(ganttFormDataForUpload, projectMonitoringReportID);

          // Iterate through the list of initialProjectBudget and update budgetData

          for (int i = 0; i < initialProjectBudget.length; i++) {
            Map<String, dynamic> budgetData = initialProjectBudget[i];
            // Get the corresponding FormBuilderState using GlobalKey
            final formState = GlobalKey<FormBuilderState>().currentState;
            if (formState != null && formState.saveAndValidate()) {
              // Update budgetData with the updated form values
              budgetData['SerialNo'] = formState.value['sl_no'];
              budgetData['Item'] = formState.value['item'];
              budgetData['Quantity'] = formState.value['quantity'];
              budgetData['UnitPrice'] = formState.value['unit_price'];
              budgetData['TotalCost'] = formState.value['total_cost_tk'];
            }

            budgetFormDataForUpload.add(budgetData);
          }

          final responseBodyBudget = await ApiService.updateProjectBudgetDetailsForMonitoring(budgetFormDataForUpload, projectMonitoringReportID);

          final zzzz =
              generateMonitoringReportPDF(_formData, context, initialProjectBudgetOriginal, budgetFormDataForUpload, initialProjectGanttsOriginal, ganttFormDataForUpload, projectMonitoringReportID);

          Uint8List zzzzz = await zzzz;

          final responseBodyuploadPdfFile =
              await ApiService.uploadPdfFile("monitoring_report", "MonitoringReportID_${projectMonitoringReportID}_PI_Name_${_formData.piName}.pdf", zzzzz, projectMonitoringReportID);

          if (responseBody['statuscode'] == 201 && responseBodyGantt['statuscode'] == 200 && responseBodyBudget['statuscode'] == 200) {
            // Handle successrr
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: "Project monitoring report submitted successfully",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () => GoRouter.of(context).go(RouteUri.projectineedtosendmonitoringreport),
            );
            dialog.show();
          } else if (responseBody['msg'] == "Token has expired") {
            // Handle error

            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Token has expired , please login again",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () {},
            );
            dialog.show();
          } else {
            // Handle error

            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Error submitting request: ${responseBody['message']}",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () {},
            );
            dialog.show();
          }
        } catch (e) {
          // Handle error

          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: "Error submitting request: $e",
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () {},
          );
          dialog.show();
        }
      },
      btnCancelText: "No",
      btnCancelOnPress: () {},
    );
    dialog.show();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.projectmonitoringreport,
      body: FutureBuilder<bool>(
        initialData: null,
        future: (_future ??= _getDataAsync()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            if (snapshot.hasData && snapshot.data!) {
              return _content(context);
            }
          } else if (snapshot.hasData && snapshot.data!) {
            return _content(context);
          }
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: SizedBox(
              height: 40.0,
              width: 40.0,
              child: CircularProgressIndicator(
                backgroundColor: themeData.scaffoldBackgroundColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context) {
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;
    final currentYear = DateTime.now().year;
    final previousYear = DateTime.now().year - 1;
    var pageTitle = 'Monitoring Format: FY $previousYear-$currentYear';

    return FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        clearValueOnUnregister: false,
        autoFocusOnValidationFailure: true,
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              pageTitle,
              style: themeData.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(title: "Part-A (For PI)", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Project ID :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.projectID,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Research/RTC Code :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.rtcCode,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Title of the Project :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.projectTitle,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Name of the PI :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.piName,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Office Address of the PI :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.piInstituteAddress,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(title: "Activity proposed in original proposal", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardBody(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding * 5.0,
                                  runSpacing: kDefaultPadding * 2.0,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 40.0,
                                        child: Text('Activity Plan/Gantt Chart (Annual Basis)', style: Theme.of(context).textTheme.titleMedium),
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
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true, // Ensure the ListView takes only the necessary space
                                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
                                    itemCount: initialProjectGanttsOriginal.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> ganttData = initialProjectGanttsOriginal[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                                        child: FormBuilder(
                                          // Use a unique key for each form to manage state separately
                                          key: GlobalKey<FormBuilderState>(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: ganttData['Activity'],
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.2)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title:
                                                            "${DateFormat("d MMM yyyy").format(DateFormat("E, d MMM yyyy HH:mm:ss 'GMT'").parseUTC(ganttData['StartDate']))}  To  ${DateFormat("d MMM yyyy").format(DateFormat("E, d MMM yyyy HH:mm:ss 'GMT'").parseUTC(ganttData['EndDate']))}",
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.1)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: ganttData['ActivityStatus'],
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(title: "Activity Progress (Completed/ongoing)", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardBody(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding * 5.0,
                                  runSpacing: kDefaultPadding * 2.0,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 40.0,
                                        child: Text('Activity Plan/Gantt Chart (Annual Basis)', style: Theme.of(context).textTheme.titleMedium),
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
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true, // Ensure the ListView takes only the necessary space
                                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
                                    itemCount: initialProjectGantts.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> ganttData = initialProjectGantts[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                                        child: FormBuilder(
                                          // Use a unique key for each form to manage state separately
                                          key: GlobalKey<FormBuilderState>(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                                child: FormBuilderTextField(
                                                  initialValue: ganttData['Activity'], // Use ganttData instead of _formData
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: null, // Allow unlimited lines
                                                  name: 'work_activity',
                                                  decoration: const InputDecoration(
                                                    labelText: 'Work/Activity',
                                                    hintText: 'Work/Activity',
                                                    border: OutlineInputBorder(),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  ),
                                                  onChanged: (value) => (ganttData['Activity'] = value ?? ''), // Update ganttData
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.2)),
                                                child: FormBuilderDateRangePicker(
                                                    initialValue: DateTimeRange(
                                                      start: DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(ganttData['StartDate']),
                                                      end: DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(ganttData['EndDate']),
                                                    ),
                                                    name: 'duration',
                                                    firstDate: DateTime(1970),
                                                    lastDate: DateTime(2030),
                                                    format: DateFormat('MMMM d, yyyy'),
                                                    decoration: const InputDecoration(
                                                      labelText: 'Duration',
                                                      hintText: 'Duration',
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
                                                          ganttData['StartDate'] = formatter.format(value.start);
                                                          ganttData['EndDate'] = formatter.format(value.end);
                                                        });
                                                      }
                                                    }),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.1)),
                                                child: FormBuilderChoiceChip(
                                                  initialValue: ganttData['ActivityStatus'],
                                                  name: 'activity_status',
                                                  spacing: kDefaultPadding * 0.5,
                                                  runSpacing: kDefaultPadding * 0.2,
                                                  selectedColor: appColorScheme.warning,
                                                  decoration: const InputDecoration(
                                                    labelText: 'Activity Status',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                  options: const [
                                                    FormBuilderChipOption(value: 'Completed', child: Text('Completed')),
                                                    FormBuilderChipOption(value: 'Ongoing', child: Text('Ongoing')),
                                                  ],
                                                  onChanged: (value) => (ganttData['ActivityStatus'] = value ?? ''), // Update ganttData
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(title: "Proposed goods and services in original proposal", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardBody(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding * 5.0,
                                  runSpacing: kDefaultPadding * 2.0,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 40.0,
                                        child: Text('Budget Summary (Annual Basis)', style: Theme.of(context).textTheme.titleMedium),
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
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                  child: const Text('Sl. No.'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: const Text('Item'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                  child: const Text('Quantity'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('Unit Price'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('Total cost (Tk)'),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true, // Ensure the ListView takes only the necessary space
                                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
                                    itemCount: initialProjectBudgetOriginal.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> budgetData = initialProjectBudgetOriginal[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                                        child: FormBuilder(
                                          // Use a unique key for each form to manage state separately
                                          key: GlobalKey<FormBuilderState>(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['SerialNo'].toString(),
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['Item'],
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['Quantity'].toString(),
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['UnitPrice'].toString(),
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['TotalCost'].toString(),
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(title: "Procured goods and services", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardBody(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding * 5.0,
                                  runSpacing: kDefaultPadding * 2.0,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 40.0,
                                        child: Text('Budget Summary (Annual Basis)', style: Theme.of(context).textTheme.titleMedium),
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
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                  child: const Text('Sl. No.'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: const Text('Item'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                  child: const Text('Quantity'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('Unit Price'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('Total cost (Tk)'),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true, // Ensure the ListView takes only the necessary space
                                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
                                    itemCount: initialProjectBudget.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> budgetData = initialProjectBudget[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                                        child: FormBuilder(
                                          // Use a unique key for each form to manage state separately
                                          key: GlobalKey<FormBuilderState>(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['SerialNo'].toString(),
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: null, // Allow unlimited lines
                                                  name: 'sl_no',
                                                  decoration: const InputDecoration(
                                                    labelText: 'Sl. No.',
                                                    hintText: 'Sl. No.',
                                                    border: OutlineInputBorder(),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  ),
                                                  validator: FormBuilderValidators.required(),
                                                  onChanged: (value) => (budgetData['SerialNo'] = value ?? 0),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['Item'],
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: null, // Allow unlimited lines
                                                  name: 'item',
                                                  decoration: const InputDecoration(
                                                    labelText: 'Item',
                                                    hintText: 'Item',
                                                    border: OutlineInputBorder(),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  ),
                                                  validator: FormBuilderValidators.required(),
                                                  onChanged: (value) => (budgetData['Item'] = value ?? ''),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['Quantity'].toString(),
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: null, // Allow unlimited lines
                                                  name: 'quantity',
                                                  decoration: const InputDecoration(
                                                    labelText: 'Quantity',
                                                    hintText: 'Quantity',
                                                    border: OutlineInputBorder(),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  ),
                                                  validator: FormBuilderValidators.required(),
                                                  onChanged: (value) => (budgetData['Quantity'] = value ?? 0),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['UnitPrice'].toString(),
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: null, // Allow unlimited lines
                                                  name: 'unit_price',
                                                  decoration: const InputDecoration(
                                                    labelText: 'Unit Price',
                                                    hintText: '(Taka)',
                                                    border: OutlineInputBorder(),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  ),
                                                  validator: FormBuilderValidators.required(),
                                                  onChanged: (value) => (budgetData['UnitPrice'] = value ?? 0.0),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['TotalCost'].toString(),
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: null, // Allow unlimited lines
                                                  name: 'total_cost_tk',
                                                  decoration: const InputDecoration(
                                                    labelText: 'Total cost (Tk)',
                                                    hintText: '(Taka)',
                                                    border: OutlineInputBorder(),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  ),
                                                  validator: FormBuilderValidators.required(),
                                                  onChanged: (value) => (budgetData['TotalCost'] = value ?? 0.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ])),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40.0,
                                child: ElevatedButton(
                                  style: themeData.extension<AppButtonTheme>()!.secondaryElevated,
                                  onPressed: () => GoRouter.of(context).go(RouteUri.projectineedtosendmonitoringreport),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                        child: Icon(
                                          Icons.arrow_circle_left_outlined,
                                          size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                        ),
                                      ),
                                      const Text("Back"),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: kDefaultPadding),
                                child: SizedBox(
                                  height: 40.0,
                                  child: ElevatedButton(
                                    style: themeData.extension<AppButtonTheme>()!.primaryOutlined,
                                    onPressed: () => _goSubmitMonitoringReport(context),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                          child: Icon(
                                            Icons.arrow_circle_right_outlined,
                                            size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                          ),
                                        ),
                                        const Text("Submit Monitoring Report"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

class FormData {
  String projectID = '';
  String piInstituteName = '';
  String piInstituteAddress = '';
  String piName = '';
  String projectTitle = '';
  String rtcCode = '';
}
