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

class ProjectHaveToReviewScreen extends StatefulWidget {
  const ProjectHaveToReviewScreen({Key? key}) : super(key: key);

  @override
  State<ProjectHaveToReviewScreen> createState() => _ProjectHaveToReviewScreenState();
}

class _ProjectHaveToReviewScreenState extends State<ProjectHaveToReviewScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialProjectHaveToReviewList = [];

// Function to filter projects based on search text
  void filterProjects(String searchText) {
    List<dynamic> updatedProjects = [];
    if (searchText.isEmpty) {
      setState(() {
        // Update the data source with all projects
        _dataSource.data = List<dynamic>.from(_initialProjectHaveToReviewList);
      });
    } else {
      updatedProjects = _initialProjectHaveToReviewList.where((project) {
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

  void filterProjectsStatus(String searchText) {
    List<dynamic> updatedProjects = [];
    if (searchText.isEmpty) {
      setState(() {
        // Update the data source with all projects
        _dataSource.data = List<dynamic>.from(_initialProjectHaveToReviewList);
      });
    } else {
      updatedProjects = _initialProjectHaveToReviewList.where((project) {
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

  void viewAllProjectHaveToReviewList() async {
    try {
      _initialProjectHaveToReviewList = await ApiService.fetchAllProjectHaveToReviewList();
      setState(() {
        _dataSource.data = _initialProjectHaveToReviewList;
      });
    } catch (e) {
      print('Failed to fetch Project Have To Review List: $e');
      // Handle error if needed
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch all pending users
    viewAllProjectHaveToReviewList();

    _dataSource = DataSource(
      onGiveReviewButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.reviewprojectscreen}?projectid=${data['ProjectID']}'),
      onViewReviewProjectButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.reviewprojectscreen}?projectid=${data['ProjectID']}'),
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
      selectedMenuUri: RouteUri.projectreviewtracking,
        body: ListView(
      padding: const EdgeInsets.all(kDefaultPadding),
      children: [
        Text(
          'Viewing as a Reviewer',
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
                  title: 'Project Lists',
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
  final void Function(Map<String, dynamic> data) onGiveReviewButtonPressed;
  final void Function(Map<String, dynamic> data) onViewReviewProjectButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onGiveReviewButtonPressed,
    required this.onViewReviewProjectButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    // Determine the maximum length of the project title to be displayed without scrolling
    const maxLength = 20; // Adjust this value as needed

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['ProjectID'].toString())),
      DataCell(Text(data['ProjectTitle'].toString().length > maxLength
          ? '${data['ProjectTitle'].toString().substring(0, maxLength)}...' // Display a truncated title with ellipsis
          : data['ProjectTitle'].toString())),
      DataCell(Text(data['ProjectStatus'].toString())),
      DataCell(FutureBuilder<String>(
        future: getTheProjectReviewedOrNot(data['ProjectID']),
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
                      onPressed: () => onGiveReviewButtonPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                      child: const Text("Give Review"),
                    ),
                  ),
                ),
                Visibility(
                  visible: snapshot.data == "Yes",
                  child: Padding(
                      padding: const EdgeInsets.only(right: kDefaultPadding),
                      child: Tooltip(
                        message: 'Already Given Review',
                        child: OutlinedButton(
                          onPressed: null,
                          style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
                          child: const Text("Give Review"),
                        ),
                      )),
                ),
                Visibility(
                  visible: snapshot.data == "Yes",
                  child: Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: OutlinedButton(
                      onPressed: () => onViewReviewProjectButtonPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.warningOutlined,
                      child: const Text("View Review & Project"),
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

  Future<String> getTheProjectReviewedOrNot(int projectID) async {
    // read user id
    final userId = await storage.read(key: 'user_id');
    int userid = int.parse(userId!);
    final responseBody = await ApiService.checkProjectReviewedOrNot(projectID, userid);
    String projectReviewCheck = responseBody['ProjectReviewCheck'];
    return projectReviewCheck;
  }
}
