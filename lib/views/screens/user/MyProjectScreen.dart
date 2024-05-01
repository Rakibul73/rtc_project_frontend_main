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

class MyProjectScreen extends StatefulWidget {
  const MyProjectScreen({Key? key}) : super(key: key);

  @override
  State<MyProjectScreen> createState() => _MyProjectScreenState();
}

class _MyProjectScreenState extends State<MyProjectScreen> {
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

  void viewAllProjects() async {
    try {
      _initialProjects = await ApiService.fetchMyProjects();
      setState(() {
        _dataSource.data = _initialProjects; // Update the projects list with fetched data
      });
    } catch (e) {
      print('Failed to fetch projects: $e');
      // Handle error if needed
    }
  }

  Future<void> deletingProject(int projectID, String reasonForDelete) async {
    try {
      final responseBody = await ApiService.deleteProject(projectID);
      print(responseBody);

      if (responseBody['statusCode'] == 200) {
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: responseBody['message'],
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () {},
        );
        dialog.show();
        print('Project deleted successfully');
        // Refresh the initial projects list
        viewAllProjects();
      } else if (responseBody['statusCode'] == 403) {
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: "You don't have permission to delete this project.",
          desc: "Send a delete request to admin.",
          width: kDialogWidth,
          btnOkText: 'Send Request',
          btnCancelText: 'Cancel',
          btnCancelOnPress: () {},
          btnOkOnPress: () async {
            // Send a delete request to admin
            final responseBody = await ApiService.requestProjectDeletionToAdmin(projectID, reasonForDelete);
            print(responseBody);
            if (responseBody['statusCode'] == 200) {
              final dialog = AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                title: responseBody['message'],
                width: kDialogWidth,
                btnOkText: 'OK',
                btnOkOnPress: () {},
              );
              dialog.show();
              print('Project deletion request sent successfully');
            }
          },
        );
        dialog.show();
      }
    } catch (e) {
      print('Failed to delete project: $e');
    }
  }

  // function to delete a project with data['ProjectID']
  void deleteProject(int projectID) {
    TextEditingController reasonController = TextEditingController();
    final deleteDialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: "Delete this project?",
      desc: "Project Id $projectID will be deleted. This action cannot be undone.",
      width: kDialogWidth,
      btnOkText: 'Delete This',
      btnOkOnPress: () {
        late AwesomeDialog reasonDialog;
        reasonDialog = AwesomeDialog(
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.info,
          width: kDialogWidth * 2.0,
          keyboardAware: true,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Reason for deletion',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Material(
                  elevation: 0,
                  color: Colors.blueGrey.withAlpha(40),
                  child: TextFormField(
                    controller: reasonController,
                    autofocus: true,
                    minLines: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Reason for deletion',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                AnimatedButton(
                  isFixedHeight: false,
                  text: 'Delete Now',
                  pressEvent: () {
                    reasonDialog.dismiss();
                    deletingProject(projectID, reasonController.text);
                  },
                )
              ],
            ),
          ),
        );
        reasonDialog.show();
      },
      btnCancelOnPress: () {},
    );
    deleteDialog.show();
  }

  @override
  void initState() {
    super.initState();
    // Fetch all projects
    viewAllProjects();

    _dataSource = DataSource(
      onViewButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewproject}?projectid=${data['ProjectID']}'),
      onEditButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.editproject}?projectid=${data['ProjectID']}'),
      onDeleteButtonPressed: (data) {
        deleteProject(data['ProjectID']);
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
        body: ListView(
      padding: const EdgeInsets.all(kDefaultPadding),
      children: [
        Text(
          'My Project',
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
                  title: 'My Project List',
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
                                          style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                          onPressed: () => viewAllProjects(),
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
                                              const Text("View My Projects"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40.0,
                                      child: ElevatedButton(
                                        style: themeData.extension<AppButtonTheme>()!.successElevated,
                                        onPressed: () => GoRouter.of(context).go(RouteUri.createproject),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                              child: Icon(
                                                Icons.add,
                                                size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                              ),
                                            ),
                                            const Text("New"),
                                          ],
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
                                          rowsPerPage: 10,
                                          showCheckboxColumn: false,
                                          showFirstLastButtons: true,
                                          columns: const [
                                            DataColumn(label: Text('ProjectID'), numeric: true),
                                            DataColumn(label: Text('CodeByRTC')),
                                            DataColumn(label: Text('ProjectTitle')),
                                            DataColumn(label: Text('ProjectStatus')),
                                            DataColumn(label: Text('TotalPoints')),
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
  final void Function(Map<String, dynamic> data) onViewButtonPressed;
  final void Function(Map<String, dynamic> data) onEditButtonPressed;
  final void Function(Map<String, dynamic> data) onDeleteButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onViewButtonPressed,
    required this.onEditButtonPressed,
    required this.onDeleteButtonPressed,
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
      DataCell(Text(data['TotalPoints'].toString())),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: ElevatedButton(
                  onPressed: () => onViewButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoText,
                  child: const Text(
                    "View",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: ElevatedButton(
                  onPressed: () => onEditButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.secondaryText,
                  child: const Text(
                    "Edit",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => onDeleteButtonPressed.call(data),
                style: Theme.of(context).extension<AppButtonTheme>()!.errorText,
                child: const Text(
                  "Delete",
                  style: TextStyle(fontWeight: FontWeight.bold),
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
