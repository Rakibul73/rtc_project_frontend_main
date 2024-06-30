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

class AllAdvanceFundRequestQueueListScreen extends StatefulWidget {
  const AllAdvanceFundRequestQueueListScreen({Key? key}) : super(key: key);

  @override
  State<AllAdvanceFundRequestQueueListScreen> createState() => _AllAdvanceFundRequestQueueListScreenState();
}

class _AllAdvanceFundRequestQueueListScreenState extends State<AllAdvanceFundRequestQueueListScreen> {
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

  void viewAllProjects() async {
    try {
      _initialProjects = await ApiService.fetchAdminAdvanceFundQueueList();
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

  void sendFund(int projectID) async {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: "Want to send Advance fund for this project?",
      width: kDialogWidth,
      btnOkText: 'Yes',
      btnOkOnPress: () {
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: "উক্ত সম্মানীর সমূদয় অর্থ আইটি কর্তন পূর্বক অর্থ ও হিসাব শাখার মাধ্যমে স্ব স্ব ব্যক্তিগত হিসাবে (রুপালী ব্যাংক লিমিটেড, পবিপ্রবি শাখায়) প্রেরণ করতে হবে।",
          desc: "Please wait. After sending advance, press ok button.",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () async {
            final result = await ApiService.updateAdvanceFundSendValue(projectID);
            if (result['statuscode'] == 200) {
              final dialog = AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                title: "Advance Sent Successfully",
                width: kDialogWidth,
                btnOkText: 'OK',
                btnOkOnPress: () {
                  viewAllProjects();
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
      onViewFundButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewrequestforaprojectadvancefund}?projectid=${data['ProjectID']}'),
      onSendFundButtonPressed: (data) {
        sendFund(data['ProjectID']);
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
        selectedMenuUri: RouteUri.fundmonitoringpanel,
        body: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              'Queue List For Advance Request',
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
                                              style: themeData.extension<AppButtonTheme>()!.primaryOutlined,
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
                                                DataColumn(label: Text('TotalBudget')),
                                                DataColumn(label: Text('Requested Amount')),
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
  final void Function(Map<String, dynamic> data) onViewFundButtonPressed;
  final void Function(Map<String, dynamic> data) onSendFundButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onViewFundButtonPressed,
    required this.onSendFundButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['ProjectID'].toString())),
      DataCell(Text(data['TotalBudget'].toString())),
      DataCell(Text(data['RequestedAmount'].toString())),
      DataCell(FutureBuilder<String>(
        future: getTheProjectFundSendOrNot(data['ProjectID']),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: kDefaultPadding),
                  child: OutlinedButton(
                    onPressed: () => onViewFundButtonPressed.call(data),
                    style: Theme.of(context).extension<AppButtonTheme>()!.primaryOutlined,
                    child: const Text("View Advance Fund Details"),
                  ),
                ),
                Visibility(
                  visible: snapshot.data == "No",
                  child: Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: OutlinedButton(
                      onPressed: () => onSendFundButtonPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.primaryOutlined,
                      child: const Text("Send Advance"),
                    ),
                  ),
                ),
                Visibility(
                  visible: snapshot.data == "Yes",
                  child: Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: OutlinedButton(
                      onPressed: null,
                      style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                      child: const Text("Advance Already Send"),
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

  Future<String> getTheProjectFundSendOrNot(int projectID) async {
    final responseBody = await ApiService.checkProjectAdvanceFundSendOrNot(projectID);
    String projectFundSendCheck = responseBody['ProjectAdvanceFundSendCheck'];
    return projectFundSendCheck;
  }
}
