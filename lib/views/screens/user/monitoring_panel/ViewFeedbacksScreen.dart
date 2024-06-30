import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // Import the 'html' library for web-specific functionalities
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:rtc_project_fronend/api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class ViewFeedbacksScreen extends StatefulWidget {
  final String monitoringReportID;

  const ViewFeedbacksScreen({
    Key? key,
    required this.monitoringReportID,
  }) : super(key: key);

  @override
  State<ViewFeedbacksScreen> createState() => _ViewFeedbacksScreenState();
}

class _ViewFeedbacksScreenState extends State<ViewFeedbacksScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  bool editusername = false;
  bool editemail = false;
  bool editfirstname = false;
  bool editlastname = false;
  bool editphone = false;
  bool editrole = false;
  bool initialPendingUserDataChange = false;
  Uint8List? _downloadProjectFileBytes;

  Future<bool>? _future;

  void _pdfHandleButtonPress(String feedbackFileLocation) {
    final d = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: "PDF Downloading.....",
      desc: "Please wait...5 seconds",
      width: kDialogWidth,
      headerAnimationLoop: true,
    );
    Future.wait([
      d.show(),
      Future.delayed(const Duration(seconds: 5), () => d.dismiss()),
      downloadMonitoringReport(feedbackFileLocation),
    ]).then((_) {
      d.dismiss();
    });
  }

  Future<void> downloadMonitoringReport(String fileName) async {
    String downloadProjectReport = await ApiService.downloadFile('monitoringreportfile/download', fileName);
    if (downloadProjectReport.isNotEmpty) {
      Uint8List fileBytes = base64Decode(downloadProjectReport);
      _downloadProjectFileBytes = fileBytes;
    }
    final blob = html.Blob([_downloadProjectFileBytes], 'application/octet-stream');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final html.AnchorElement anchor = html.AnchorElement(href: url);
    anchor.download = fileName; // Specify the filename for the downloaded file
    anchor.click(); // Trigger the download
  }

  Future<bool> _getDataAsync() async {
    print('monitoringReportID: ${widget.monitoringReportID}');
    if (widget.monitoringReportID.isNotEmpty) {
      print('monitoringReportID: ${widget.monitoringReportID}');
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.monitoringReportID = widget.monitoringReportID;

        int monitoringReportID = int.parse(widget.monitoringReportID);
        final feedbackDetails = await ApiService.fetchAllFeedbackForSpecificMonitoringReport(
          monitoringReportID,
        );
        if (feedbackDetails[0]['statuscode'] == 401) {
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

        if (feedbackDetails.isNotEmpty) {
          _formData.projectID = feedbackDetails[0]['ProjectID'].toString();
          _formData.suggestions1 = feedbackDetails[0]['Suggestions'] ?? '';
          _formData.suggestions2 = feedbackDetails[1]['Suggestions'] ?? '';
          _formData.suggestions3 = feedbackDetails[2]['Suggestions'] ?? '';
          _formData.observation1 = feedbackDetails[0]['Observation'] ?? '';
          _formData.observation2 = feedbackDetails[1]['Observation'] ?? '';
          _formData.observation3 = feedbackDetails[2]['Observation'] ?? '';
          _formData.recommendations1 = feedbackDetails[0]['Recommendations'] ?? '';
          _formData.recommendations2 = feedbackDetails[1]['Recommendations'] ?? '';
          _formData.recommendations3 = feedbackDetails[2]['Recommendations'] ?? '';
          _formData.endorsement1 = feedbackDetails[0]['Endorsement'] ?? '';
          _formData.endorsement2 = feedbackDetails[1]['Endorsement'] ?? '';
          _formData.endorsement3 = feedbackDetails[2]['Endorsement'] ?? '';
          _formData.monitoringFeedbackFileLocation1 = feedbackDetails[0]['MonitoringFeedbackFileLocation'] ?? '';
          _formData.monitoringFeedbackFileLocation2 = feedbackDetails[1]['MonitoringFeedbackFileLocation'] ?? '';
          _formData.monitoringFeedbackFileLocation3 = feedbackDetails[2]['MonitoringFeedbackFileLocation'] ?? '';
          _formData.projectMonitoringFeedbackId1 = feedbackDetails[0]['ProjectMonitoringFeedbackID'];
          _formData.projectMonitoringFeedbackId2 = feedbackDetails[1]['ProjectMonitoringFeedbackID'];
          _formData.projectMonitoringFeedbackId3 = feedbackDetails[2]['ProjectMonitoringFeedbackID'];
        }
      });
    }

    return true;
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
    final pageTitle = 'Feedback for Monitoring Report - ID: ${widget.monitoringReportID.isEmpty ? 'Invalid Monitoring Report-ID' : widget.monitoringReportID}';

    return FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
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
            const SizedBox(height: kDefaultPadding),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                        child: const Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: 'Committee 1:',
                                                backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                                titleColor: Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.17) - (kDefaultPadding * 0.17)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Observation:  ${_formData.observation1}%',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.58) - (kDefaultPadding * 0.58)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                style: themeData.extension<AppButtonTheme>()!.warningText,
                                                onPressed: () {
                                                  _pdfHandleButtonPress(_formData.monitoringFeedbackFileLocation1);
                                                },
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                      child: Icon(
                                                        Icons.file_download_outlined,
                                                        size: (themeData.textTheme.labelLarge!.fontSize! + 5.0),
                                                      ),
                                                    ),
                                                    const Text("Monitoring Report Feedback", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: "Suggestions:  ${_formData.suggestions1}",
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: 'Recommendations:  ${_formData.recommendations1}',
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: "Endorsement:  ${_formData.endorsement1}",
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
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
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                        child: const Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: 'Committee 2:',
                                                backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                                titleColor: Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.17) - (kDefaultPadding * 0.17)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Observation:  ${_formData.observation2}%',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.58) - (kDefaultPadding * 0.58)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                style: themeData.extension<AppButtonTheme>()!.warningText,
                                                onPressed: () {
                                                  _pdfHandleButtonPress(_formData.monitoringFeedbackFileLocation2);
                                                },
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                      child: Icon(
                                                        Icons.file_download_outlined,
                                                        size: (themeData.textTheme.labelLarge!.fontSize! + 5.0),
                                                      ),
                                                    ),
                                                    const Text("Monitoring Report Feedback", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: "Suggestions:  ${_formData.suggestions2}",
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: 'Recommendations:  ${_formData.recommendations2}',
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: "Endorsement:  ${_formData.endorsement2}",
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
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
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                        child: const Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: 'Committee 3:',
                                                backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                                titleColor: Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.17) - (kDefaultPadding * 0.17)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Observation:  ${_formData.observation3}%',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.58) - (kDefaultPadding * 0.58)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                style: themeData.extension<AppButtonTheme>()!.warningText,
                                                onPressed: () {
                                                  _pdfHandleButtonPress(_formData.monitoringFeedbackFileLocation3);
                                                },
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                      child: Icon(
                                                        Icons.file_download_outlined,
                                                        size: (themeData.textTheme.labelLarge!.fontSize! + 5.0),
                                                      ),
                                                    ),
                                                    const Text("Monitoring Report Feedback", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: "Suggestions:  ${_formData.suggestions3}",
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: 'Recommendations:  ${_formData.recommendations3}',
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.75) - (kDefaultPadding * 0.75)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: "Endorsement:  ${_formData.endorsement3}",
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.myrecievedfeedbackfrommonitoringcommittee),
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

  int projectMonitoringFeedbackId1 = 0;
  int projectMonitoringFeedbackId2 = 0;
  int projectMonitoringFeedbackId3 = 0;

  String suggestions1 = '';
  String suggestions2 = '';
  String suggestions3 = '';
  String monitoringFeedbackFileLocation1 = '';
  String monitoringFeedbackFileLocation2 = '';
  String monitoringFeedbackFileLocation3 = '';
  String endorsement1 = '';
  String endorsement2 = '';
  String endorsement3 = '';
  String recommendations1 = '';
  String recommendations2 = '';
  String recommendations3 = '';
  String observation1 = '';
  String observation2 = '';
  String observation3 = '';
}
