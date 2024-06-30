import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/constants/values.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print
import 'package:rtc_project_fronend/api_service.dart';
import 'dart:math';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_data_table_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormBuilderState>();

  late DataSource _dataSource;
  late List<dynamic> _initialSelfNotification = []; // Updated notifications list to hold all self notifications

  int roleID = 0;

  void viewAllSelfNotification() async {
    try {
      _initialSelfNotification = await ApiService.fetchMyNotifications();
      if (_initialSelfNotification[0]['statuscode'] == 401) {
        // ignore: use_build_context_synchronously
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
        _dataSource.data = _initialSelfNotification; // Update the self notifications list with fetched data
      });
    } catch (e) {
      print('Failed to fetch self notifications: $e');
      // Handle error if needed
    }
  }

  void markAsUnread(int notificationID) async {
    try {
      await ApiService.markAsUnread(notificationID);
      viewAllSelfNotification();
    } catch (e) {
      print('Failed to mark notification as unread: $e');
      // Handle error if needed
    }
  }

  void markAsRead(int notificationID) async {
    try {
      await ApiService.markAsRead(notificationID);
      viewAllSelfNotification();
    } catch (e) {
      print('Failed to mark notification as read: $e');
      // Handle error if needed
    }
  }

  void markAllAsRead() async {
    try {
      await ApiService.markAllAsRead();
      viewAllSelfNotification();
    } catch (e) {
      print('Failed to mark notification as read: $e');
      // Handle error if needed
    }
  }

  void fetchRoleIdFromLocalStorage() async {
    final sharedPref = await SharedPreferences.getInstance();
    roleID = sharedPref.getInt(StorageKeys.roleId) ?? 0;
    print(roleID);
  }

  @override
  void initState() {
    super.initState();
    // Fetch all notification list
    viewAllSelfNotification();
    // fetch roleID from local storage
    fetchRoleIdFromLocalStorage();

    _dataSource = DataSource(
      onViewNotificationButtonPressed: (data) {
        print('Mark as read button pressed: $data');
        markAsRead(data['NotificationID']);
        GoRouter.of(context).go('${RouteUri.viewindividualnotification}?notification_id=${data['NotificationID']}');
      },
      onMarkUnreadButtonPressed: (data) {
        print('Mark as unread button pressed: $data');
        markAsUnread(data['NotificationID']);
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
          'My Notifications',
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
                  title: 'Notification List',
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
                                    Visibility(
                                      visible: roleID == 1,
                                      child: SizedBox(
                                        height: 40.0,
                                        child: ElevatedButton(
                                          style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                          onPressed: () => GoRouter.of(context).go(RouteUri.viewallnotifications),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                child: Icon(
                                                  Icons.notification_important_outlined,
                                                  size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                ),
                                              ),
                                              const Text("View All Notifications Table"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 40.0,
                                      child: ElevatedButton(
                                        style: themeData.extension<AppButtonTheme>()!.secondaryOutlined,
                                        onPressed: () {
                                          markAllAsRead();
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                              child: Icon(
                                                Icons.mark_as_unread_outlined,
                                                size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                              ),
                                            ),
                                            const Text("Mark All As Read"),
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
                                          rowsPerPage: 20,
                                          showCheckboxColumn: false,
                                          showFirstLastButtons: true,
                                          columns: const [
                                            DataColumn(label: Text('Sender UserName')),
                                            DataColumn(label: Text('Message')),
                                            DataColumn(label: Text('Timestamp')),
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
  final void Function(Map<String, dynamic> data) onViewNotificationButtonPressed;
  final void Function(Map<String, dynamic> data) onMarkUnreadButtonPressed;
  List<dynamic> data;

  DataSource({
    required this.onViewNotificationButtonPressed,
    required this.onMarkUnreadButtonPressed,
    required this.data,
  });

  @override
  DataRow? getRow(int index) {
    final data = this.data[index];

    // Determine the maximum length of the Message to be displayed without scrolling
    const maxLength = 30; // Adjust this value as needed

    return DataRow.byIndex(
        index: index,
        selected: data['IsRead'] == 0, // Apply shading based on 'IsRead' status
        // onSelectChanged: (isSelected) {
        //   if (!isRead) {
        //     onMarkUnreadButtonPressed.call(data); // Mark as read when clicked (if not already read)
        //   }
        // },
        cells: [
          DataCell(FutureBuilder<String>(
            future: getSenderUserNameFromUserId(data['SenderUserID']),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data ?? ''); // Display the username when available
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const Text('Loading...'); // Show a loading indicator while fetching data
              }
            },
          )),
          DataCell(Text(data['Message'].toString().length > maxLength
              ? '${data['Message'].toString().substring(0, maxLength)}...' // Display a truncated Message with ellipsis
              : data['Message'].toString())),
          DataCell(Text(data['Timestamp'].toString())),
          DataCell(Builder(
            builder: (context) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: OutlinedButton(
                      onPressed: () => onViewNotificationButtonPressed.call(data),
                      style: Theme.of(context).extension<AppButtonTheme>()!.warningOutlined,
                      child: const Text("View Notification"),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => onMarkUnreadButtonPressed.call(data),
                    style: Theme.of(context).extension<AppButtonTheme>()!.successOutlined,
                    child: const Text("Mark as UnRead"),
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

  Future<String> getSenderUserNameFromUserId(int userId) async {
    final responseBody = await ApiService.getUsernameFromUserId(userId);
    String username = responseBody['Username'];
    return username;
  }
}
