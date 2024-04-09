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

class VerifiedUsersScreen extends StatefulWidget {
  const VerifiedUsersScreen({Key? key}) : super(key: key);

  @override
  State<VerifiedUsersScreen> createState() => _VerifiedUsersScreenState();
}

class _VerifiedUsersScreenState extends State<VerifiedUsersScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialVerifiedUsers = [];

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

// Function to filter userbased on search text
  void filterUserName(String searchText) {
    List<dynamic> updatedUsers = [];
    if (searchText.isEmpty) {
      setState(() {
        // Update the data source with all users
        _dataSource.data = List<dynamic>.from(_initialVerifiedUsers);
      });
    } else {
      updatedUsers = _initialVerifiedUsers.where((user) {
        final userName = user['Username'].toString().toLowerCase();
        final searchLowerCase = searchText.toLowerCase();
        return userName.contains(searchLowerCase);
      }).toList();
      setState(() {
        // Update the data source with filtered users
        _dataSource.data = updatedUsers;
      });
    }
  }

  void filterUserRole(String searchText) {
    List<dynamic> updatedUsers = [];
    if (searchText.isEmpty) {
      setState(() {
        _dataSource.data = List<dynamic>.from(_initialVerifiedUsers);
      });
    } else {
      updatedUsers = _initialVerifiedUsers.where((user) {
        final projectTitle = getRoleName(user['RoleID']).toString().toLowerCase();
        final searchLowerCase = searchText.toLowerCase();
        return projectTitle.contains(searchLowerCase);
      }).toList();
      setState(() {
        _dataSource.data = updatedUsers;
      });
    }
  }

  void filterUserFaculty(String searchText) {
    List<dynamic> updatedUsers = [];
    if (searchText.isEmpty) {
      setState(() {
        _dataSource.data = List<dynamic>.from(_initialVerifiedUsers);
      });
    } else {
      updatedUsers = _initialVerifiedUsers.where((user) {
        final projectTitle = user['FacultyName'].toString().toLowerCase();
        final searchLowerCase = searchText.toLowerCase();
        return projectTitle.contains(searchLowerCase);
      }).toList();
      setState(() {
        _dataSource.data = updatedUsers;
      });
    }
  }

  void viewAllVerifiedUsers() async {
    try {
      _initialVerifiedUsers = await ApiService.fetchAllVerifiedUsers();
      setState(() {
        _dataSource.data = _initialVerifiedUsers; // Update the verified users list with fetched data
      });
    } catch (e) {
      print('Failed to fetch verified users: $e');
      // Handle error if needed
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch all pending users
    viewAllVerifiedUsers();

    _dataSource = DataSource(
      onViewUserButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.verifieduser}?userid=${data['UserID']}'),
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
        selectedMenuUri: RouteUri.usermanagementoverview,
        body: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              'All Verified Users',
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
                      title: 'You can view their profile here & edit their details for correction',
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
                                    Row(mainAxisSize: MainAxisSize.min, children: [
                                      SizedBox(
                                        width: 200.0,
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
                                              filterUserName(value!);
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200.0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: kDefaultPadding * 1.5),
                                          child: FormBuilderDropdown(
                                              name: 'search_by_role',
                                              decoration: const InputDecoration(
                                                labelText: 'Search by Role',
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
                                                'Admin',
                                                'Teacher',
                                                'Researcher',
                                                'Reviewer',
                                                'Student',
                                              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                              onChanged: (value) {
                                                filterUserRole(value!);
                                              }),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 400.0,
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                          child: FormBuilderDropdown(
                                              name: 'search_by_faculty',
                                              decoration: const InputDecoration(
                                                labelText: 'Search by Faculty',
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
                                                'Faculty of Agriculture',
                                                'Faculty of Computer Science and Engineering',
                                                'Faculty of Business Administration',
                                                'Faculty of Animal Science and Veterinary Medicine',
                                                'Faculty of Fisheries',
                                                'Faculty of Environmental Science and Disaster Management',
                                                'Faculty of Nutrition and Food Science',
                                                'Faculty of Law and Land Administration',
                                              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                              onChanged: (value) {
                                                filterUserFaculty(value!);
                                              }),
                                        ),
                                      ),
                                    ]),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: kDefaultPadding),
                                          child: SizedBox(
                                            height: 40.0,
                                            child: ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                              onPressed: () => viewAllVerifiedUsers(),
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
                                                DataColumn(label: Text('UserID'), numeric: true),
                                                DataColumn(label: Text('Registered Role')),
                                                DataColumn(label: Text('Username')),
                                                DataColumn(label: Text('Fullname')),
                                                DataColumn(label: Text('Position')),
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
  final void Function(Map<String, dynamic> data) onViewUserButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onViewUserButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['UserID'].toString())),
      DataCell(Text(getRoleName(data['RoleID']))),
      DataCell(Text(data['Username'].toString())),
      DataCell(Text("${data['FirstName'].toString()} ${data['LastName'].toString()}")),
      DataCell(Text(data['PositionEnglish'].toString())),
      DataCell(Builder(
        builder: (context) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding),
                child: OutlinedButton(
                  onPressed: () => onViewUserButtonPressed.call(data),
                  style: Theme.of(context).extension<AppButtonTheme>()!.secondaryText,
                  child: const Text("View Profile"),
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
