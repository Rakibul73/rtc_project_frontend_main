// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class ViewMonitoringReportAdminScreen extends StatefulWidget {
  final String monitoringReportID;

  const ViewMonitoringReportAdminScreen({
    Key? key,
    required this.monitoringReportID,
  }) : super(key: key);

  @override
  State<ViewMonitoringReportAdminScreen> createState() => _ViewMonitoringReportAdminScreenState();
}

class _ViewMonitoringReportAdminScreenState extends State<ViewMonitoringReportAdminScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  late List<dynamic> initialProjectBudget = [];
  late List<dynamic> initialProjectBudgetOriginal = [];
  late List<dynamic> initialProjectGantts = [];
  late List<dynamic> initialProjectGanttsOriginal = [];
  late List<dynamic> ganttFormDataForUpload = [];
  late List<dynamic> budgetFormDataForUpload = [];
  Future<bool>? _future;

  void _setCommittee(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Assign these committee to this monitoring report id = ${widget.monitoringReportID}?",
      desc: "Note: This action cannot be undone.",
      width: kDialogWidth,
      btnOkText: "Yes",
      btnOkOnPress: () async {
        _formKey.currentState!.save();
        try {
          final committee1 = {
            'ProjectMonitoringReportID': _formData.monitoringReportID,
            'MonitoringCommitteeUserID': _formData.committeeUserId1,
          };
          final committee2 = {
            'ProjectMonitoringReportID': _formData.monitoringReportID,
            'MonitoringCommitteeUserID': _formData.committeeUserId2,
          };
          final committee3 = {
            'ProjectMonitoringReportID': _formData.monitoringReportID,
            'MonitoringCommitteeUserID': _formData.committeeUserId3,
          };
          final responseBody = await ApiService.setMonitoringCommittee(committee1, committee2, committee3);
          if (responseBody['statuscode'] == 201) {
            // Handle success
            print('Monitoring Committee set successfully');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: "Monitoring Committee set successfully",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () => GoRouter.of(context).go(RouteUri.monitoringpanelneedtoassignmonitoringcommittee),
            );
            dialog.show();
          } else if (responseBody['msg'] == "Token has expired") {
            // Handle error
            print('Token has expired');
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
            print('Error seting monitoring committee: ${responseBody['message']}');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Error seting monitoring committee: ${responseBody['message']}",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () {},
            );
            dialog.show();
          }
        } catch (e) {
          // Handle error
          print('Error seting monitoring committee: $e');
          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: "Error seting monitoring committee: $e",
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

  Future<bool> _getDataAsync() async {
    if (widget.monitoringReportID.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.monitoringReportID = widget.monitoringReportID;
        int monitoringReportID = int.parse(_formData.monitoringReportID);
        final projectMonitoringReportDetails = await ApiService.getSpecificProjectMonitoringReport(
          monitoringReportID,
        );

        if (projectMonitoringReportDetails['statuscode'] == 401) {
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
        }

        _formData.projectID = projectMonitoringReportDetails['monitoring_report_data']['ProjectID'].toString();

        _formData.reportDate = projectMonitoringReportDetails['monitoring_report_data']['ReportDate'];
        print("=========deb=========");

        _formData.reportFileLocation = projectMonitoringReportDetails['monitoring_report_data']['ReportFileLocation'] ?? '';

        final projectRTCCodeAndTitleOnly = await ApiService.getSpecificProjectRTCCodeAndTitleOnly(
          int.parse(_formData.projectID),
        );
        if (projectRTCCodeAndTitleOnly.isNotEmpty) {
          _formData.projectTitle = projectRTCCodeAndTitleOnly['project']['ProjectTitle'] ?? '';
          _formData.rtcCode = projectRTCCodeAndTitleOnly['project']['CodeByRTC'].toString();
        }

        final budgetDetailsOriginal = await ApiService.fetchAllBudgetOfAProjectOriginal(
          int.parse(_formData.projectID),
        );
        if (budgetDetailsOriginal.isNotEmpty) {
          initialProjectBudgetOriginal = budgetDetailsOriginal;
        }

        final budgetDetails = await ApiService.fetchAllBudgetOfAProjectHistory(
          monitoringReportID,
        );
        if (budgetDetails.isNotEmpty) {
          initialProjectBudget = budgetDetails;
        }
        print("initialProjectBudget: $initialProjectBudget");

        final ganttDetails = await ApiService.fetchAllGanttOfAProjectHistory(
          monitoringReportID,
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

        final userDetails = await ApiService.getSpecificProjectCreatorUserIDOnly(
          int.parse(_formData.projectID),
        );
        print("==========**S      T      A      R**===========");
        print(userDetails);

        _formData.piUserID = userDetails['project']['CreatorUserID'].toString();

        final piDetailForMonitoringReport = await ApiService.getSpecificUserDetailsForFundApply(
          int.parse(_formData.piUserID),
        );

        _formData.piInstituteName = piDetailForMonitoringReport['user']['InstituteName'] ?? '';
        _formData.piInstituteAddress = piDetailForMonitoringReport['user']['InstituteLocation'] ?? '';
        _formData.piName = piDetailForMonitoringReport['user']['FirstName'] + ' ' + piDetailForMonitoringReport['user']['LastName'] ?? '';

        print("==========**E      N      D*****===========");

        final committeeUserId = await ApiService.getMonitoringCommitteeUserId(monitoringReportID);
        if (committeeUserId['statuscode'] == 401) {
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
        }

        print(committeeUserId);
        print(committeeUserId['committeeuserid'].length);

        if (committeeUserId['committeeuserid'].length != 0) {
          _formData.fetchCommitteeUserId1 = committeeUserId['committeeuserid'][0]['MonitoringCommitteeUserID'];
          _formData.fetchCommitteeUserId2 = committeeUserId['committeeuserid'][1]['MonitoringCommitteeUserID'];
          _formData.fetchCommitteeUserId3 = committeeUserId['committeeuserid'][2]['MonitoringCommitteeUserID'];

          final fetchCommitteeUserDetail1 = await ApiService.getSpecificUser(
            _formData.fetchCommitteeUserId1,
          );
          final fetchCommitteeUserDetail2 = await ApiService.getSpecificUser(
            _formData.fetchCommitteeUserId2,
          );
          final fetchCommitteeUserDetail3 = await ApiService.getSpecificUser(
            _formData.fetchCommitteeUserId3,
          );
          _formData.profilePicLocation1 = fetchCommitteeUserDetail1['user']['ProfilePicLocation'] ?? '';
          _formData.profilePicLocation2 = fetchCommitteeUserDetail2['user']['ProfilePicLocation'] ?? '';
          _formData.profilePicLocation3 = fetchCommitteeUserDetail3['user']['ProfilePicLocation'] ?? '';
          _formData.reviewerFullname1 = fetchCommitteeUserDetail1['user']['FirstName'] + ' ' + fetchCommitteeUserDetail1['user']['LastName'];
          _formData.reviewerFullname2 = fetchCommitteeUserDetail2['user']['FirstName'] + ' ' + fetchCommitteeUserDetail2['user']['LastName'];
          _formData.reviewerFullname3 = fetchCommitteeUserDetail3['user']['FirstName'] + ' ' + fetchCommitteeUserDetail3['user']['LastName'];
          _formData.reviewerUsername1 = fetchCommitteeUserDetail1['user']['Username'] ?? '';
          _formData.reviewerUsername2 = fetchCommitteeUserDetail2['user']['Username'] ?? '';
          _formData.reviewerUsername3 = fetchCommitteeUserDetail3['user']['Username'] ?? '';
        }
      });
    }

    return true;
  }


  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.monitoringpaneloverview,
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
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommitteeSelection1(formData: _formData),
                          CommitteeSelection2(formData: _formData),
                          CommitteeSelection3(formData: _formData),
                          Visibility(
                            visible: _formData.fetchCommitteeUserId1 == 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
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
                                              child: ElevatedButton(
                                                style: themeData.extension<AppButtonTheme>()!.successOutlined,
                                                onPressed: () => _setCommittee(context),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                      child: Icon(
                                                        Icons.save_outlined,
                                                        size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Save Changes",
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.assignedmonitoringcommittee),
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
                              // const Spacer(),
                              // Padding(
                              //   padding: const EdgeInsets.only(right: kDefaultPadding),
                              //   child: SizedBox(
                              //     height: 40.0,
                              //     child: ElevatedButton(
                              //       style: themeData.extension<AppButtonTheme>()!.primaryOutlined,
                              //       onPressed: () => _goSubmitMonitoringReport(context),
                              //       child: Row(
                              //         mainAxisSize: MainAxisSize.min,
                              //         crossAxisAlignment: CrossAxisAlignment.center,
                              //         children: [
                              //           Padding(
                              //             padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                              //             child: Icon(
                              //               Icons.arrow_circle_right_outlined,
                              //               size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                              //             ),
                              //           ),
                              //           const Text("Submit Monitoring Report"),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
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
  String monitoringReportID = '';
  String reportDate = '';
  String reportFileLocation = '';
  String piInstituteName = '';
  String piInstituteAddress = '';
  String piName = '';
  String piUserID = '';
  String projectTitle = '';
  String rtcCode = '';

  String profilePicLocation1 = '';
  String profilePicLocation2 = '';
  String profilePicLocation3 = '';
  String reviewerUsername1 = '';
  String reviewerUsername2 = '';
  String reviewerUsername3 = '';
  String reviewerFullname1 = '';
  String reviewerFullname2 = '';
  String reviewerFullname3 = '';
  int committeeUserId1 = 0;
  int committeeUserId2 = 0;
  int committeeUserId3 = 0;
  int fetchCommitteeUserId1 = 0;
  int fetchCommitteeUserId2 = 0;
  int fetchCommitteeUserId3 = 0;
}


class CommitteeSelection1 extends StatefulWidget {
  final FormData formData;

  const CommitteeSelection1({required this.formData, Key? key}) : super(key: key);

  @override
  _CommitteeSelection1State createState() => _CommitteeSelection1State();
}

class _CommitteeSelection1State extends State<CommitteeSelection1> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      onChanged: () {
        _formKey.currentState!.save();
      },
      clearValueOnUnregister: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: ((constraints.maxWidth * 0.22) - (kDefaultPadding * 0.22)),
                ),
                const SizedBox(width: kDefaultPadding),
                Visibility(
                  visible: widget.formData.fetchCommitteeUserId1 == 0,
                  child: SizedBox(
                    width: ((constraints.maxWidth * 0.50) - (kDefaultPadding * 0.50)),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardBody(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                                  child: FutureBuilder<List<User>>(
                                    future: ApiService.getAllUsersExceptStudents(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator(); // Show loading indicator while fetching data
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return FormBuilderDropdown<User>(
                                          name: 'committee_1',
                                          decoration: const InputDecoration(
                                            labelText: 'Committee 1',
                                            hintText: 'Select Committee 1',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          // validator: FormBuilderValidators.required(),
                                          items: snapshot.data!
                                              .map((user) => DropdownMenuItem<User>(
                                                    value: user,
                                                    child: Text(user.getDisplayName()),
                                                  ))
                                              .toList(),
                                          onChanged: (User? user) {
                                            if (user != null) {
                                              setState(() {
                                                widget.formData.profilePicLocation1 = user.profilePicLocation;
                                                widget.formData.committeeUserId1 = user.userId;
                                              });

                                              _formKey.currentState?.save();
                                            }
                                          },
                                        );
                                      }
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
                ),
                Visibility(
                  visible: widget.formData.fetchCommitteeUserId1 != 0,
                  child: SizedBox(
                    width: ((constraints.maxWidth * 0.50) - (kDefaultPadding * 0.50)),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardHeader(
                            title: "Name: ${widget.formData.reviewerFullname1}     | Username: ${widget.formData.reviewerUsername1}",
                            backgroundColor: const Color.fromARGB(255, 74, 89, 96),
                            titleColor: const Color.fromARGB(255, 151, 204, 197),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                SizedBox(
                  width: ((constraints.maxWidth * 0.25) - (kDefaultPadding * 0.25)),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                    child: Stack(
                      children: [
                        FutureBuilder<String>(
                          future: widget.formData.profilePicLocation1.isNotEmpty
                              ? ApiService.downloadFile('profile-pic/download', widget.formData.profilePicLocation1)
                              : ApiService.downloadFile('profile-pic/download', "defaultprofilepic.png"), // Check if value is not empty before making the API call
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Image.memory(
                                base64Decode(snapshot.data!), // Convert base64 string to image bytes
                                fit: BoxFit.cover, // Adjust image to cover the entire space
                                // width: 120, // Adjust width as needed
                                height: 60, // Adjust height as needed
                              );
                            }
                          },
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
    );
  }
}

class CommitteeSelection2 extends StatefulWidget {
  final FormData formData;

  const CommitteeSelection2({required this.formData, Key? key}) : super(key: key);

  @override
  _CommitteeSelection2State createState() => _CommitteeSelection2State();
}

class _CommitteeSelection2State extends State<CommitteeSelection2> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      clearValueOnUnregister: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: ((constraints.maxWidth * 0.22) - (kDefaultPadding * 0.22)),
                  child: const Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CardHeader(
                          title: 'Committee Selection :',
                          backgroundColor: Color.fromARGB(255, 74, 89, 96),
                          titleColor: Color.fromARGB(255, 151, 204, 197),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                Visibility(
                  visible: widget.formData.fetchCommitteeUserId2 == 0,
                  child: SizedBox(
                    width: ((constraints.maxWidth * 0.50) - (kDefaultPadding * 0.50)),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardBody(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                                  child: FutureBuilder<List<User>>(
                                    future: ApiService.getAllUsersExceptStudents(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator(); // Show loading indicator while fetching data
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return FormBuilderDropdown<User>(
                                          name: 'committee_user_id2',
                                          decoration: const InputDecoration(
                                            labelText: 'Committee 2',
                                            hintText: 'Select Committee 2',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          // validator: FormBuilderValidators.required(),
                                          items: snapshot.data!
                                              .map((user) => DropdownMenuItem<User>(
                                                    value: user,
                                                    child: Text(user.getDisplayName()),
                                                  ))
                                              .toList(),
                                          onChanged: (User? user) {
                                            if (user != null) {
                                              setState(() {
                                                widget.formData.profilePicLocation2 = user.profilePicLocation;
                                                widget.formData.committeeUserId2 = user.userId;
                                              });

                                              _formKey.currentState!.save();
                                            }
                                          },
                                        );
                                      }
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
                ),
                Visibility(
                  visible: widget.formData.fetchCommitteeUserId2 != 0,
                  child: SizedBox(
                    width: ((constraints.maxWidth * 0.50) - (kDefaultPadding * 0.50)),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardHeader(
                            title: "Name: ${widget.formData.reviewerFullname2}     | Username: ${widget.formData.reviewerUsername2}",
                            backgroundColor: const Color.fromARGB(255, 74, 89, 96),
                            titleColor: const Color.fromARGB(255, 151, 204, 197),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                SizedBox(
                  width: ((constraints.maxWidth * 0.25) - (kDefaultPadding * 0.25)),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                    child: Stack(
                      children: [
                        FutureBuilder<String>(
                          future: widget.formData.profilePicLocation2.isNotEmpty
                              ? ApiService.downloadFile('profile-pic/download', widget.formData.profilePicLocation2)
                              : ApiService.downloadFile('profile-pic/download', "defaultprofilepic.png"), // Check if value is not empty before making the API call
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Image.memory(
                                base64Decode(snapshot.data!), // Convert base64 string to image bytes
                                fit: BoxFit.cover, // Adjust image to cover the entire space
                                // width: 120, // Adjust width as needed
                                height: 60, // Adjust height as needed
                              );
                            }
                          },
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
    );
  }
}

class CommitteeSelection3 extends StatefulWidget {
  final FormData formData;

  const CommitteeSelection3({required this.formData, Key? key}) : super(key: key);

  @override
  _CommitteeSelection3State createState() => _CommitteeSelection3State();
}

class _CommitteeSelection3State extends State<CommitteeSelection3> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.always,
      clearValueOnUnregister: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: ((constraints.maxWidth * 0.22) - (kDefaultPadding * 0.22)),
                ),
                const SizedBox(width: kDefaultPadding),
                Visibility(
                  visible: widget.formData.fetchCommitteeUserId3 == 0,
                  child: SizedBox(
                    width: ((constraints.maxWidth * 0.50) - (kDefaultPadding * 0.50)),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardBody(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                                  child: FutureBuilder<List<User>>(
                                    future: ApiService.getAllUsersExceptStudents(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator(); // Show loading indicator while fetching data
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        return FormBuilderDropdown<User>(
                                          name: 'committee_3',
                                          decoration: const InputDecoration(
                                            labelText: 'Committee 3',
                                            hintText: 'Select Committee 3',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          // validator: FormBuilderValidators.required(),
                                          items: snapshot.data!
                                              .map((user) => DropdownMenuItem<User>(
                                                    value: user,
                                                    child: Text(user.getDisplayName()),
                                                  ))
                                              .toList(),
                                          onChanged: (User? user) {
                                            if (user != null) {
                                              setState(() {
                                                widget.formData.profilePicLocation3 = user.profilePicLocation;
                                                widget.formData.committeeUserId3 = user.userId;
                                              });

                                              _formKey.currentState?.save();
                                            }
                                          },
                                        );
                                      }
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
                ),
                Visibility(
                  visible: widget.formData.fetchCommitteeUserId3 != 0,
                  child: SizedBox(
                    width: ((constraints.maxWidth * 0.50) - (kDefaultPadding * 0.50)),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CardHeader(
                            title: "Name: ${widget.formData.reviewerFullname3}     | Username: ${widget.formData.reviewerUsername3}",
                            backgroundColor: const Color.fromARGB(255, 74, 89, 96),
                            titleColor: const Color.fromARGB(255, 151, 204, 197),
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: kDefaultPadding),
                SizedBox(
                  width: ((constraints.maxWidth * 0.25) - (kDefaultPadding * 0.25)),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                    child: Stack(
                      children: [
                        FutureBuilder<String>(
                          future: widget.formData.profilePicLocation3.isNotEmpty
                              ? ApiService.downloadFile('profile-pic/download', widget.formData.profilePicLocation3)
                              : ApiService.downloadFile('profile-pic/download', "defaultprofilepic.png"), // Check if value is not empty before making the API call
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Image.memory(
                                base64Decode(snapshot.data!), // Convert base64 string to image bytes
                                fit: BoxFit.cover, // Adjust image to cover the entire space
                                // width: 120, // Adjust width as needed
                                height: 60, // Adjust height as needed
                              );
                            }
                          },
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
    );
  }
}
