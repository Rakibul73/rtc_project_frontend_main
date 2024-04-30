// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/constants/values.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'dart:math';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_data_table_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CircularNoticeScreen extends StatefulWidget {
  const CircularNoticeScreen({Key? key}) : super(key: key);

  @override
  State<CircularNoticeScreen> createState() => _CircularNoticeScreenState();
}

class _CircularNoticeScreenState extends State<CircularNoticeScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialNotice = [];

  // Function to filter projects based on search text
  void filterSubject(String searchText) {
    List<dynamic> updatedSubject = [];
    if (searchText.isEmpty) {
      setState(() {
        _dataSource.data = List<dynamic>.from(_initialNotice);
      });
    } else {
      updatedSubject = _initialNotice.where((project) {
        final subject = project['Subject'].toString().toLowerCase();
        final searchLowerCase = searchText.toLowerCase();
        return subject.contains(searchLowerCase);
      }).toList();
      setState(() {
        _dataSource.data = updatedSubject;
      });
    }
  }

  void viewAllNotice() async {
    try {
      _initialNotice = await ApiService.fetchAllNotice();
      setState(() {
        _dataSource.data = _initialNotice; // Update the projects list with fetched data
      });
    } catch (e) {
      print('Failed to fetch notice: $e');
      // Handle error if needed
    }
  }

  Future<void> deletingNotice(int noticeID) async {
    try {
      final responseBody = await ApiService.deleteNotice(noticeID);
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
        print('Notices deleted successfully');
        viewAllNotice();
      }
    } catch (e) {
      print('Failed to delete project: $e');
    }
  }

  // function to delete a project with data['ProjectID']
  void deleteNotice(int noticeID) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: "Delete this Notice?",
      desc: "Notice Id $noticeID will be deleted. This action cannot be undone.",
      width: kDialogWidth,
      btnOkText: 'Delete This',
      btnOkOnPress: () {
        deletingNotice(noticeID);
      },
      btnCancelOnPress: () {},
    );
    dialog.show();
  }

  @override
  void initState() {
    super.initState();
    viewAllNotice();

    _dataSource = DataSource(
      onViewButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.viewnotice}?noticeid=${data['NoticeID']}'),
      onEditButtonPressed: (data) => GoRouter.of(context).go('${RouteUri.editnoticeadmin}?noticeid=${data['NoticeID']}'),
      onDeleteButtonPressed: (data) {
        deleteNotice(data['NoticeID']);
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
    var isAdmin = Provider.of<UserDataProvider>(context).roleId;

    return PortalMasterLayout(
        body: ListView(
      padding: const EdgeInsets.all(kDefaultPadding),
      children: [
        Text(
          'View All Circular Notices',
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
                                            name: 'search',
                                            decoration: const InputDecoration(
                                              labelText: 'Search by Subject',
                                              hintText: 'Enter Subject',
                                              border: OutlineInputBorder(),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                              isDense: true,
                                            ),
                                            onChanged: (value) {
                                              filterSubject(value!);
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
                                        child: OutlinedButton(
                                          style: themeData.extension<AppButtonTheme>()!.infoText,
                                          onPressed: () => viewAllNotice(),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                child: Icon(
                                                  Icons.refresh_outlined,
                                                  size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                ),
                                              ),
                                              const Text(
                                                "Refresh",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: isAdmin == 1,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding),
                                        child: SizedBox(
                                          height: 40.0,
                                          child: OutlinedButton(
                                            style: themeData.extension<AppButtonTheme>()!.primaryText,
                                            onPressed: () => GoRouter.of(context).go(RouteUri.createcircularnotice),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.add_alert_sharp,
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                const Text(
                                                  "Create Notice",
                                                ),
                                              ],
                                            ),
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
                                            DataColumn(label: Text('NoticeID'), numeric: true),
                                            DataColumn(label: Text('Date Published')),
                                            DataColumn(label: Text('Subject')),
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
  final void Function(Map<String, dynamic> data) onEditButtonPressed;
  final void Function(Map<String, dynamic> data) onViewButtonPressed;
  final void Function(Map<String, dynamic> data) onDeleteButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onEditButtonPressed,
    required this.onViewButtonPressed,
    required this.onDeleteButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    // Determine the maximum length of the project title to be displayed without scrolling
    const maxLength = 20; // Adjust this value as needed
    DateTime utcDateTime = DateFormat('E, dd MMM yyyy HH:mm a').parseUTC(data['DatePublished'].toString());
    print("utcDateTime : , $utcDateTime");
    String formattedTime = DateFormat('E, dd MMM yyyy hh:mm a').format(utcDateTime);

    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data['NoticeID'].toString())),
      DataCell(Text(formattedTime)),
      DataCell(Text(data['Subject'].toString().length > maxLength
          ? '${data['Subject'].toString().substring(0, maxLength)}...' // Display a truncated title with ellipsis
          : data['Subject'].toString())),
      DataCell(FutureBuilder<int>(
        future: getRoleID(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: kDefaultPadding),
                  child: ElevatedButton(
                    onPressed: () => onViewButtonPressed.call(data),
                    style: Theme.of(context).extension<AppButtonTheme>()!.warningText,
                    child: const Text("View Notice"),
                  ),
                ),
                Visibility(
                  visible: snapshot.data == 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: ElevatedButton(
                      onPressed: () => onEditButtonPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.secondaryText,
                      child: const Text("Edit"),
                    ),
                  ),
                ),
                Visibility(
                  visible: snapshot.data == 1,
                  child: ElevatedButton(
                    onPressed: () => onDeleteButtonPressed.call(data),
                    style: Theme.of(context).extension<AppButtonTheme>()!.errorText,
                    child: const Text("Delete"),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text('Error vai: ${snapshot.error}');
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

  Future<int> getRoleID() async {
    final sharedPref = await SharedPreferences.getInstance();
    int? roleId = sharedPref.getInt(StorageKeys.roleId);
    return roleId ?? 0;
  }
}
