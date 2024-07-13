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

class AllFundConfirmListScreen extends StatefulWidget {
  const AllFundConfirmListScreen({Key? key}) : super(key: key);

  @override
  State<AllFundConfirmListScreen> createState() => _AllFundConfirmListScreenState();
}

class _AllFundConfirmListScreenState extends State<AllFundConfirmListScreen> {
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
      _initialProjects = await ApiService.fetchAdminFundConfirmList();
      setState(() {
        _dataSource.data = _initialProjects; // Update the projects list with fetched data
      });
    } catch (e) {
      // Handle error if needed
    }
  }

  void sendFund(int projectID) async {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: "Want to send fund for this project?",
      width: kDialogWidth,
      btnOkText: 'Yes',
      btnOkOnPress: () {
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: "উক্ত সম্মানীর সমূদয় অর্থ আইটি কর্তন পূর্বক অর্থ ও হিসাব শাখার মাধ্যমে স্ব স্ব ব্যক্তিগত হিসাবে (রুপালী ব্যাংক লিমিটেড, পবিপ্রবি শাখায়) প্রেরণ করতে হবে।",
          desc: "Please wait. After sending fund, press ok button.",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () async {
            final result = await ApiService.updateFundSendValue(projectID);
            if (result['statuscode'] == 200) {
              final dialog = AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                title: "Fund Sent Successfully",
                width: kDialogWidth,
                btnOkText: 'OK',
                btnOkOnPress: () {
                  viewAllProjects();
                },
              );
              dialog.show();
            } else if (result['statuscode'] == 401) {
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
          },
          btnCancelText: 'Cancel',
          btnCancelOnPress: () {},
        );
        dialog.show();
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
      onViewDetailsButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewrequestforaprojectfund}?projectid=${data['ProjectID']}'),
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
        selectedMenuUri: RouteUri.fundmonitoringpanel,
        body: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              'Fund Confirmation List',
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
                                                name: 'search_project_Title',
                                                decoration: const InputDecoration(
                                                  labelText: 'Search by Project Title',
                                                  hintText: 'Enter project Title',
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
                                                DataColumn(label: Text('TotalBudget')),
                                                DataColumn(label: Text('TotalHonorarium')),
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
  final void Function(Map<String, dynamic> data) onViewDetailsButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onViewDetailsButtonPressed,
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
      DataCell(Text(data['TotalBudget'].toString())),
      DataCell(Text(data['TotalHonorarium'].toString())),
      DataCell(Builder(builder: (context) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: kDefaultPadding),
              child: OutlinedButton(
                onPressed: () => onViewDetailsButtonPressed.call(data),
                style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                child: const Text("View Request"),
              ),
            ),
          ],
        );
      })),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  Future<String> getTheProjectFundSendOrNot(int projectID) async {
    final responseBody = await ApiService.checkProjectFundSendOrNot(projectID);
    String projectFundSendCheck = responseBody['ProjectFundSendCheck'];
    return projectFundSendCheck;
  }
}
