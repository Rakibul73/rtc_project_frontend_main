import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'dart:math';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_data_table_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({Key? key}) : super(key: key);

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialPendingUsers = []; // Updated projects list to hold all projects

// Function to filter projects based on search text
  void filterProjects(String searchText) {
    List<dynamic> updatedProjects = [];
    if (searchText.isEmpty) {
      setState(() {
        // Update the data source with all projects
        _dataSource.data = List<dynamic>.from(_initialPendingUsers);
      });
    } else {
      updatedProjects = _initialPendingUsers.where((project) {
        final projectTitle = project['Username'].toString().toLowerCase();
        final searchLowerCase = searchText.toLowerCase();
        return projectTitle.contains(searchLowerCase);
      }).toList();
      setState(() {
        // Update the data source with filtered projects
        _dataSource.data = updatedProjects;
      });
    }
  }

  void viewAllPendingUsers() async {
    try {
      _initialPendingUsers = await ApiService.fetchAllPendingUsers();
      setState(() {
        _dataSource.data = _initialPendingUsers; // Update the pending users list with fetched data
      });
    } catch (e) {
      print('Failed to fetch pending users: $e');
      // Handle error if needed
    }
  }

  Future<void> approvingPendingUser(int userID , String username) async {
    try {
      final responseBody = await ApiService.approvePendingUser(userID , username);
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
        print('Pending User approved successfully');
        // Refresh the initial pending users list
        viewAllPendingUsers();
      }
    } catch (e) {
      print('Failed to approve pending user: $e');
    }
  }
  
  Future<void> deletingProject(int userID) async {
    try {
      final responseBody = await ApiService.deletePendingUser(userID);
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
        print('Pending User deleted successfully');
        // Refresh the initial pending users list
        viewAllPendingUsers();
      }
    } catch (e) {
      print('Failed to delete pending user: $e');
    }
  }

  // function to delete a project with data['ProjectID']
  void deleteProject(int userID) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: "Delete this Pending User?",
      desc: "User Id $userID will be deleted. This action cannot be undone.",
      width: kDialogWidth,
      btnOkText: 'Delete User',
      btnOkOnPress: () {
        deletingProject(userID);
      },
      btnCancelOnPress: () {},
    );
    dialog.show();
  }
  // function to approve a pending user with data['UserID']
  void approvePendingUser(int userID , String username) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: "Approve this Pending User?",
      desc: "UserName: $username",
      width: kDialogWidth,
      btnOkText: 'Approve User',
      btnOkOnPress: () {
        approvingPendingUser(userID , username);
      },
      btnCancelOnPress: () {},
    );
    dialog.show();
  }

  @override
  void initState() {
    super.initState();
    // Fetch all pending users
    viewAllPendingUsers();

    _dataSource = DataSource(
      onVerifyButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.verifyuser}?pendinguserid=${data['UserID']}'),
      onApproveButtonPressed: (data) {
        approvePendingUser(data['UserID'] , data['Username']);
      },
      onDeleteButtonPressed: (data) {
        deleteProject(data['UserID']);
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
          'Pending Users',
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
                  title: 'Need to Approve these users',
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
                                SizedBox(
                                  width: 300.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                    child: FormBuilderTextField(
                                      name: 'search',
                                      decoration: const InputDecoration(
                                        labelText: 'Search by Username',
                                        hintText: 'Enter Username',
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
                                            DataColumn(label: Text('UserID'), numeric: true),
                                            DataColumn(label: Text('Registered Role')),
                                            DataColumn(label: Text('UserName')),
                                            DataColumn(label: Text('Email')),
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
  final void Function(Map<String, dynamic> data) onVerifyButtonPressed;
  final void Function(Map<String, dynamic> data) onApproveButtonPressed;
  final void Function(Map<String, dynamic> data) onDeleteButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onVerifyButtonPressed,
    required this.onApproveButtonPressed,
    required this.onDeleteButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['UserID'].toString())),
      DataCell(Text(getRoleName(data['RoleID']))),
      DataCell(Text(data['Username'].toString())),
      DataCell(Text(data['Email'].toString())),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onVerifyButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.warningOutlined,
                  child: const Text("Verify"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onApproveButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.infoOutlined,
                  child: const Text("Approve"),
                ),
              ),
              OutlinedButton(
                onPressed: () => onDeleteButtonPressed.call(data),
                style: Theme.of(context).extension<AppButtonTheme>()!.errorOutlined,
                child: const Text("Delete"),
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

  String getRoleName(int roleId) {
    switch (roleId) {
      case 1:
        return 'Admin';
      case 2:
        return 'Researcher';
      case 3:
        return 'Reviewer';
      case 4:
        return 'Teacher';
      case 5:
        return 'Student';
      default:
        return 'Unknown';
    }
  }
}
