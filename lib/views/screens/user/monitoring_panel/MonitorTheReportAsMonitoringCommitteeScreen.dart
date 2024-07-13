import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html; // Import the 'html' library for web-specific functionalities
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:rtc_project_fronend/api_service.dart';
import 'dart:math';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_data_table_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class MonitorTheReportAsMonitoringCommitteeScreen extends StatefulWidget {
  const MonitorTheReportAsMonitoringCommitteeScreen({Key? key}) : super(key: key);

  @override
  State<MonitorTheReportAsMonitoringCommitteeScreen> createState() => _MonitorTheReportAsMonitoringCommitteeScreenState();
}

class _MonitorTheReportAsMonitoringCommitteeScreenState extends State<MonitorTheReportAsMonitoringCommitteeScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialProjectHaveToGiveFeedbackList = [];
  Uint8List? _downloadProjectFileBytes;

// Function to filter projects based on search text
  void filterProjects(String searchText) {
    List<dynamic> updatedProjects = [];
    if (searchText.isEmpty) {
      setState(() {
        // Update the data source with all projects
        _dataSource.data = List<dynamic>.from(_initialProjectHaveToGiveFeedbackList);
      });
    } else {
      updatedProjects = _initialProjectHaveToGiveFeedbackList.where((project) {
        final projectTitle = project['ProjectID'].toString().toLowerCase();
        final searchLowerCase = searchText.toLowerCase();
        return projectTitle.contains(searchLowerCase);
      }).toList();
      setState(() {
        // Update the data source with filtered projects
        _dataSource.data = updatedProjects;
      });
    }
  }

  void viewAllProjectHaveToMonitorList() async {
    try {
      _initialProjectHaveToGiveFeedbackList = await ApiService.fetchAllProjectHaveToMonitorList();
      if (_initialProjectHaveToGiveFeedbackList[0]['statuscode'] == 401) {
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
      setState(() {
        _dataSource.data = _initialProjectHaveToGiveFeedbackList;
      });
    } catch (e) {}
  }

  void _pdfHandleButtonPress(String fileName) {
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
      downloadMonitoringReport(fileName),
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

  @override
  void initState() {
    super.initState();
    // Fetch all pending users
    viewAllProjectHaveToMonitorList();

    _dataSource = DataSource(
      onGiveFeedbackButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.feedbackmonitoringreport}?monitoringreportid=${data['ProjectMonitoringReportID']}'),
      onViewFeedbackAndReportButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.feedbackmonitoringreport}?monitoringreportid=${data['ProjectMonitoringReportID']}'),
      onPDFPressed: (data) {
        if (data['MonitoringFeedbackFileLocation'] == null || data['MonitoringFeedbackFileLocation'].isEmpty) {
          final notFoundPDF = AwesomeDialog(
            context: context,
            dialogType: DialogType.infoReverse,
            title: "Monitoring Feedback Not Found",
            desc: "PDF file not found in server. Please contact administrator with (Project Monitoring Feedback-ID). Thank you.",
            width: kDialogWidth,
            headerAnimationLoop: true,
          );
          notFoundPDF.show();
        } else {
          _pdfHandleButtonPress(data['MonitoringFeedbackFileLocation']);
        }
      },
      data: [],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appDataTableTheme = themeData.extension<AppDataTableTheme>()!;

    return PortalMasterLayout(
        selectedMenuUri: RouteUri.projectmonitoringreport,
        body: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              'Viewing as a Monitoring Committee',
              style: themeData.textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(
                      title: 'Monitoring Report Lists',
                    ),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilder(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.disabled,
                              child: SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding,
                                  runSpacing: kDefaultPadding,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: kDefaultPadding),
                                          child: SizedBox(
                                            width: 300.0,
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                              child: FormBuilderTextField(
                                                name: 'search_project_ID',
                                                decoration: const InputDecoration(
                                                  labelText: 'Search by Project ID',
                                                  hintText: 'Enter project ID',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  isDense: true,
                                                ),
                                                onChanged: (value) {
                                                  filterProjects(value!);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double dataTableWidth = max(kScreenWidthMd, constraints.maxWidth);
                                return Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    controller: _scrollController,
                                    child: SizedBox(
                                      width: dataTableWidth,
                                      child: Theme(
                                        data: themeData.copyWith(
                                          cardTheme: appDataTableTheme.cardTheme,
                                          dataTableTheme: appDataTableTheme.dataTableThemeData,
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            // Return the PaginatedDataTable with _dataSource
                                            return PaginatedDataTable(
                                              key: UniqueKey(), // Use UniqueKey to force rebuild when _dataSource changes
                                              source: _dataSource,
                                              rowsPerPage: 20,
                                              showCheckboxColumn: false,
                                              showFirstLastButtons: true,
                                              columns: const [
                                                DataColumn(label: Text('ProjectMonitoringReportID')),
                                                DataColumn(label: Text('ProjectID')),
                                                DataColumn(label: Text('ReportDate')),
                                                DataColumn(label: Text('Actions')),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
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
          ],
        ));
  }
}

class DataSource extends DataTableSource {
  final void Function(Map<String, dynamic> data) onGiveFeedbackButtonPressed;
  final void Function(Map<String, dynamic> data) onViewFeedbackAndReportButtonPressed;
  final void Function(Map<String, dynamic> data) onPDFPressed;
  List<dynamic> data;

  DataSource({
    required this.onGiveFeedbackButtonPressed,
    required this.onViewFeedbackAndReportButtonPressed,
    required this.onPDFPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['ProjectMonitoringReportID'].toString())),
      DataCell(Text(data['ProjectID'].toString())),
      DataCell(Text(data['ReportDate'].toString())),
      DataCell(FutureBuilder<String>(
        future: getTheProjectReviewedOrNot(data['ProjectMonitoringReportID']),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: snapshot.data == "No",
                  child: Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: OutlinedButton(
                      onPressed: () => onGiveFeedbackButtonPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                      child: const Text("Give Feedback"),
                    ),
                  ),
                ),
                Visibility(
                  visible: snapshot.data == "Yes",
                  child: Padding(
                      padding: const EdgeInsets.only(right: kDefaultPadding),
                      child: Tooltip(
                        message: 'Already Given Feedback',
                        child: OutlinedButton(
                          onPressed: null,
                          style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
                          child: const Text("Give Feedback"),
                        ),
                      )),
                ),
                Visibility(
                  visible: snapshot.data == "Yes",
                  child: Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: OutlinedButton(
                      onPressed: () => onViewFeedbackAndReportButtonPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.warningOutlined,
                      child: const Text("View Feedback & Report"),
                    ),
                  ),
                ),
                Visibility(
                  visible: snapshot.data == "Yes",
                  child: Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: ElevatedButton(
                      onPressed: () => onPDFPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.secondaryOutlined,
                      child: const Text(
                        "PDF",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Text('Loading...'); // Show a loading indicator while fetching data
          }
        },
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  Future<String> getTheProjectReviewedOrNot(int projectMonitoringReportID) async {
    // read user id
    final userId = await storage.read(key: 'user_id');
    int userid = int.parse(userId!);
    final responseBody = await ApiService.checkMonitoringReportFeedbackGivenOrNot(projectMonitoringReportID, userid);
    String projectReviewCheck = responseBody['MonitoringReportFeedbackCheck'];
    return projectReviewCheck;
  }
}
