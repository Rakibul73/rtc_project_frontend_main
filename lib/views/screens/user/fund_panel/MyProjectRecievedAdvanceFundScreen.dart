// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'dart:math';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_data_table_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class MyProjectRecievedAdvanceFundScreen extends StatefulWidget {
  const MyProjectRecievedAdvanceFundScreen({Key? key}) : super(key: key);

  @override
  State<MyProjectRecievedAdvanceFundScreen> createState() => _MyProjectRecievedAdvanceFundScreenState();
}

class _MyProjectRecievedAdvanceFundScreenState extends State<MyProjectRecievedAdvanceFundScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialProjects = []; // Updated projects list to hold all projects

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
      _initialProjects = await ApiService.fetchMyAdvanceFundedProject();
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
      // Handle error if needed
    }
  }

  void confirmFundRecieved(int projectID) {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: "Want to confirm advance recieved for this project?",
      desc: "Note: This action cannot be undone.",
      width: kDialogWidth,
      btnOkText: 'Yes',
      btnOkOnPress: () async {
        final result = await ApiService.updateConfirmAdvanceFundRecieved(projectID);
        if (result['statuscode'] == 200) {
          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: "Advance Recieved Confirmation Sent Successfully",
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () {
              viewAllProjects();
            },
          );
          dialog.show();
        }
      },
      btnCancelText: 'No',
      btnCancelOnPress: () {},
    );
    dialog.show();
  }

  @override
  void initState() {
    super.initState();
    // Fetch all projects
    viewAllProjects();

    _dataSource = DataSource(
      // onSendFundConfirmationButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.requestforaprojectfund}?projectid=${data['ProjectID']}'),
      onSendFundConfirmationButtonPressed: (data) {
        confirmFundRecieved(data['ProjectID']);
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
        selectedMenuUri: RouteUri.projectfundmanagement,
        body: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              'Advance Funded Projects',
              style: themeData.textTheme.headlineMedium,
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
                                                  const Text("Refresh Page"),
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
                                              rowsPerPage: 10,
                                              showCheckboxColumn: false,
                                              showFirstLastButtons: true,
                                              columns: const [
                                                DataColumn(label: Text('ProjectID'), numeric: true),
                                                DataColumn(label: Text('CodeByRTC')),
                                                DataColumn(label: Text('ProjectTitle')),
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
  final void Function(Map<String, dynamic> data) onSendFundConfirmationButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onSendFundConfirmationButtonPressed,
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
      DataCell(FutureBuilder<String>(
        future: getTheProjectFundConfirmationSendOrNot(data['ProjectID']),
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
                      onPressed: () => onSendFundConfirmationButtonPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                      child: const Text("Send Advance Received Confirmation"),
                    ),
                  ),
                ),
                Visibility(
                  visible: snapshot.data == "Yes",
                  child: Padding(
                      padding: const EdgeInsets.only(right: kDefaultPadding),
                      child: Tooltip(
                        message: "Already Send",
                        child: OutlinedButton(
                          onPressed: null,
                          style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
                          child: const Text("Send Advance Received Confirmation"),
                        ),
                      )),
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

  Future<String> getTheProjectFundConfirmationSendOrNot(int projectID) async {
    final responseBody = await ApiService.checkProjectAdvanceFundConfirmedOrNot(projectID);
    String projectConfirmFundCheck = responseBody['ProjectConfirmAdvanceFundCheck'];
    return projectConfirmFundCheck;
  }
}
