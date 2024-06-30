// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
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

class ProjectReviewerHasGivenReviewScreen extends StatefulWidget {
  const ProjectReviewerHasGivenReviewScreen({Key? key}) : super(key: key);

  @override
  State<ProjectReviewerHasGivenReviewScreen> createState() => _ProjectReviewerHasGivenReviewScreenState();
}

class _ProjectReviewerHasGivenReviewScreenState extends State<ProjectReviewerHasGivenReviewScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialProjects = []; // Updated projects list to hold all projects

// Function to filter projects based on search text
  void filterProjectsStatus(String searchText) {
    List<dynamic> updatedProjects = [];
    if (searchText.isEmpty) {
      setState(() {
        // Update the data source with all projects
        _dataSource.data = List<dynamic>.from(_initialProjects);
      });
    } else {
      updatedProjects = _initialProjects.where((project) {
        final projectTitle = project['ProjectStatus'].toString().toLowerCase();
        final searchLowerCase = searchText.toLowerCase();
        return projectTitle.contains(searchLowerCase);
      }).toList();
      setState(() {
        // Update the data source with filtered projects
        _dataSource.data = updatedProjects;
      });
    }
  }

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
        final projectTitle = project['ProjectTitle'].toString().toLowerCase();
        final searchLowerCase = searchText.toLowerCase();
        return projectTitle.contains(searchLowerCase);
      }).toList();
      setState(() {
        // Update the data source with filtered projects
        _dataSource.data = updatedProjects;
      });
    }
  }

  void viewAllProjectsReviewerGivenReview() async {
    try {
      _initialProjects = await ApiService.fetchAllProjectsReviewerGivenReview();
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
        _dataSource.data = _initialProjects; // Update the projects list with fetched data
      });
    } catch (e) {
      print('Failed to fetch projects: $e');
      // Handle error if needed
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch all projects
    viewAllProjectsReviewerGivenReview();

    _dataSource = DataSource(
      onViewProjectButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewprojectadmin}?projectid=${data['ProjectID']}'),
      onViewReviewsButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewreviewoftheprojectadmin}?projectid=${data['ProjectID']}'),
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
        selectedMenuUri: RouteUri.reviewpaneloverview,
        body: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            RichText(
              text: TextSpan(
                style: themeData.textTheme.headlineMedium,
                children: const [
                  TextSpan(
                    text: 'Reviewed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(183, 255, 235, 59), // Change color to your desired color
                    ),
                  ),
                  TextSpan(
                    text: ' Projects',
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
                    const CardHeader(
                      title: 'Project List',
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
                                                name: 'search_project_title',
                                                decoration: const InputDecoration(
                                                  labelText: 'Search by Project Title',
                                                  hintText: 'Enter project title',
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
                                        SizedBox(
                                          width: 200.0,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                            child: FormBuilderDropdown(
                                                name: 'search_project_status',
                                                decoration: const InputDecoration(
                                                  labelText: 'Search by Project Status',
                                                  border: OutlineInputBorder(),
                                                  hoverColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  hintText: 'Select',
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  isDense: true,
                                                ),
                                                focusColor: Colors.transparent,
                                                items: [
                                                  '',
                                                  'Pending',
                                                  'Approved',
                                                  'Rejected',
                                                  'Running',
                                                  'Completed',
                                                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onChanged: (value) {
                                                  filterProjectsStatus(value!);
                                                }),
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
                                              style: themeData.extension<AppButtonTheme>()!.warningOutlined,
                                              onPressed: () => viewAllProjectsReviewerGivenReview(),
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
                                                  const Text("Refresh Reviewed Projects"),
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
                                                DataColumn(label: Text('ProjectID'), numeric: true),
                                                DataColumn(label: Text('CodeByRTC')),
                                                DataColumn(label: Text('ProjectTitle')),
                                                DataColumn(label: Text('ProjectStatus')),
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
  final void Function(Map<String, dynamic> data) onViewReviewsButtonPressed;
  final void Function(Map<String, dynamic> data) onViewProjectButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onViewReviewsButtonPressed,
    required this.onViewProjectButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    // Determine the maximum length of the project title to be displayed without scrolling
    const maxLength = 20; // Adjust this value as needed

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['ProjectID'].toString())),
      DataCell(Text(data['CodeByRTC'].toString())),
      DataCell(Text(data['ProjectTitle'].toString().length > maxLength
          ? '${data['ProjectTitle'].toString().substring(0, maxLength)}...' // Display a truncated title with ellipsis
          : data['ProjectTitle'].toString())),
      DataCell(Text(data['ProjectStatus'].toString())),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onViewProjectButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                  child: const Text("View Project"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onViewReviewsButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.warningOutlined,
                  child: const Text("View Reviews"),
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
