// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:html' as html; // Import the 'html' library for web-specific functionalities
import 'dart:math';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_data_table_theme.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class ViewMonitoringHistoryScreen extends StatefulWidget {
  final String projectID;
  final Map<String, dynamic> additionalValue;

  const ViewMonitoringHistoryScreen({
    Key? key,
    required this.projectID,
    required this.additionalValue,
  }) : super(key: key);

  @override
  State<ViewMonitoringHistoryScreen> createState() => _ViewMonitoringHistoryScreenState();
}

class _ViewMonitoringHistoryScreenState extends State<ViewMonitoringHistoryScreen> {
  final _scrollController = ScrollController();

  late DataSource _dataSource;
  late List<dynamic> _initialProjects = []; // Updated projects list to hold all projects
  String _projectTitle = '';
  late int _projectID;
  Uint8List? _downloadProjectFileBytes;

  void viewAllMonitoringHistoryForSingleProject(int projectID) async {
    try {
      _initialProjects = await ApiService.fetchMonitoringHistoryForSingleProject(projectID);
      if (_initialProjects[0]['statuscode'] == 401) {
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
        _dataSource.data = _initialProjects; // Update the  list with fetched data
      });
    } catch (e) {
      print('Failed to fetch projects: $e');
      // Handle error if needed
    }
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

  Future<String> getProjectTitle(int projectID) async {
    final projectTitle = await ApiService.getProjectTitle(projectID);
    if (projectTitle == "401") {
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
    return projectTitle;
  }

  @override
  void initState() {
    super.initState();
    _projectID = int.parse(widget.projectID);
    if (widget.additionalValue['projectTitle'] == null || widget.additionalValue['projectTitle'] == '') {
      getProjectTitle(_projectID).then((projectTitle) {
        setState(() {
          _projectTitle = projectTitle;
        });
      });
    } else {
      _projectTitle = widget.additionalValue['projectTitle'];
    }

    // Fetch monitoring history for the project
    viewAllMonitoringHistoryForSingleProject(_projectID);

    _dataSource = DataSource(
      onViewMonitoringReportPressed: (data) => GoRouter.of(context).go('${RouteUri.viewmonitoringreport}?monitoringreportid=${data['ProjectMonitoringReportID']}'),
      onPDFPressed: (data) {
        if (data['ReportFileLocation'] == null || data['ReportFileLocation'].isEmpty) {
          final notFoundPDF = AwesomeDialog(
            context: context,
            dialogType: DialogType.infoReverse,
            title: "Monitoring Report Not Found",
            desc: "PDF file not found in server. Please contact administrator with (Project Monitoring Report-ID). Thank you.",
            width: kDialogWidth,
            headerAnimationLoop: true,
          );
          notFoundPDF.show();
        } else {
          _pdfHandleButtonPress(data['ReportFileLocation']);
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
              'Project ID: $_projectID | Monitoring Report History',
              style: themeData.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Text(
                              'Title: $_projectTitle',
                              style: themeData.textTheme.bodyLarge,
                              textAlign: TextAlign.center,
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
                                              rowsPerPage: 10,
                                              showCheckboxColumn: false,
                                              showFirstLastButtons: true,
                                              columns: const [
                                                DataColumn(label: Text('ProjectMonitoringReportID')),
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
  final void Function(Map<String, dynamic> data) onViewMonitoringReportPressed;
  final void Function(Map<String, dynamic> data) onPDFPressed;
  List<dynamic> data;

  DataSource({
    required this.onViewMonitoringReportPressed,
    required this.onPDFPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['ProjectMonitoringReportID'].toString())),
      DataCell(Text(data['ReportDate'].toString())),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: ElevatedButton(
                  onPressed: () => onViewMonitoringReportPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.primaryOutlined,
                  child: const Text(
                    "View Monitoring Report",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
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
            ],
          );
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
}
