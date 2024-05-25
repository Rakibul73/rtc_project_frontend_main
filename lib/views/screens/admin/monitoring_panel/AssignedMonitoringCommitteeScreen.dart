// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'dart:math';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_data_table_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class AssignedMonitoringCommitteeScreen extends StatefulWidget {
  const AssignedMonitoringCommitteeScreen({Key? key}) : super(key: key);

  @override
  State<AssignedMonitoringCommitteeScreen> createState() => _AssignedMonitoringCommitteeScreenState();
}

class _AssignedMonitoringCommitteeScreenState extends State<AssignedMonitoringCommitteeScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialProjects = [];

  // Function to filter projects based on search text
  void filterProjects(String searchText) {
    List<dynamic> updatedProjects = [];
    if (searchText.isEmpty) {
      setState(() {
        // Update the data source with all projects
        _dataSource.data = List<dynamic>.from(_initialProjects);
      });
    } else {
      updatedProjects = _initialProjects.where((project) {
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

  void viewAssignedMonitoringCommittee() async {
    try {
      _initialProjects = await ApiService.fetchAssignedMonitoringCommittee();
      setState(() {
        _dataSource.data = _initialProjects; // Update the projects list with fetched data
      });
    } catch (e) {
      print('Failed to fetch projects: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    viewAssignedMonitoringCommittee();

    _dataSource = DataSource(
      onViewAssignedCommitteeButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewmonitoringreportadmin}?monitoringreportid=${data['ProjectMonitoringReportID']}'),
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
        selectedMenuUri: RouteUri.monitoringpaneloverview,
        body: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            RichText(
              text: TextSpan(
                style: themeData.textTheme.headlineMedium,
                children: const [
                  TextSpan(
                    text: 'View ',
                  ),
                  TextSpan(
                    text: 'Assigned Committee',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange, // Change color to your desired color
                    ),
                  ),
                  TextSpan(
                    text: ' for Monitoring Reports',
                  ),
                ],
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
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: kDefaultPadding),
                                          child: SizedBox(
                                            height: 40.0,
                                            child: ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.orangeOutlined,
                                              onPressed: () => viewAssignedMonitoringCommittee(),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                    child: Icon(
                                                      Icons.search,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  const Text("Refresh"),
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
                                                DataColumn(label: Text('ProjectMonitoringReportID'), numeric: true),
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
  final void Function(Map<String, dynamic> data) onViewAssignedCommitteeButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onViewAssignedCommitteeButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['ProjectMonitoringReportID'].toString())),
      DataCell(Text(data['ProjectID'].toString())),
      DataCell(Text(data['ReportDate'].toString())),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onViewAssignedCommitteeButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.orangeOutlined,
                  child: const Text("View Monitoring Committee"),
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
