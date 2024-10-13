// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class ViewIndividualNotificationScreen extends StatefulWidget {
  final String notificationID;

  const ViewIndividualNotificationScreen({
    Key? key,
    required this.notificationID,
  }) : super(key: key);

  @override
  State<ViewIndividualNotificationScreen> createState() => _ViewIndividualNotificationScreenState();
}

class _ViewIndividualNotificationScreenState extends State<ViewIndividualNotificationScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  final List<Widget> ganttfields = [];
  final List<Widget> budgetsummaryfields = [];
  Future<bool>? _future;

  Future<bool> _getDataAsync() async {
    if (widget.notificationID.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.notificationID = widget.notificationID;

        int notificationID = int.parse(widget.notificationID);
        final userDetails = await ApiService.getSpecificNotification(
          notificationID,
        );

        if (userDetails['statuscode'] == 401) {
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

        _formData.notificationID = userDetails['Notification']['NotificationID'].toString();
        _formData.isRead = userDetails['Notification']['IsRead'].toString();
        _formData.message = userDetails['Notification']['Message'];
        _formData.receiverUserID = userDetails['Notification']['ReceiverUserID'].toString();
        _formData.senderUserID = userDetails['Notification']['SenderUserID'].toString();
        _formData.timestamp = userDetails['Notification']['Timestamp'];
        // if IsDeleted = 0 , then this project deletion request is not yet done
        _formData.isDeleted = userDetails['Notification']['IsDeleted'] ?? 0;
      });
    }

    return true;
  }

  Future<void> _handleProjectDeletionRequest(BuildContext context) async {
    // Extract project ID from the message
    int notificationId = int.parse(widget.notificationID);

    // Call the API service to handle the project deletion request
    final result = await ApiService.handleProjectDeletionRequest(notificationId);

    if (result['statuscode'] == 401) {
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
    if (result['statuscode'] == 404) {
      // Handle token expiration
      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        desc: result['error'],
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {
          GoRouter.of(context).go(RouteUri.viewallnotifications);
        },
      );
      dialog.show();
    }
    if (result['statuscode'] == 500) {
      // Handle token expiration
      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        desc: result['error'],
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {
          GoRouter.of(context).go(RouteUri.viewallnotifications);
        },
      );
      dialog.show();
    }
    if (result['statuscode'] == 200) {
      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        desc: result['message'],
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {
          GoRouter.of(context).go(RouteUri.viewallnotifications);
        },
      );
      dialog.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.searchproject,
      body: FutureBuilder<bool>(
        initialData: null,
        future: (_future ??= _getDataAsync()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            if (snapshot.hasData && snapshot.data!) {
              return _content(context);
            }
          } else if (snapshot.hasData && snapshot.data!) {
            return _content(context);
          }
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: SizedBox(
              height: 40.0,
              width: 40.0,
              child: CircularProgressIndicator(
                backgroundColor: themeData.scaffoldBackgroundColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _content(BuildContext context) {
    final themeData = Theme.of(context);
    final pageTitle = 'Notification - ID: ${widget.notificationID.isEmpty ? 'No Notification' : widget.notificationID}';

    return FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        clearValueOnUnregister: false,
        autoFocusOnValidationFailure: true,
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              pageTitle,
              style: themeData.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: (kDefaultPadding * 16),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Sender :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.senderUserID,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: SizedBox(
                                          width: (kDefaultPadding * 20),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const CardHeader(
                                                  title: 'Timestamp :',
                                                  backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                  titleColor: Color.fromARGB(255, 151, 204, 197),
                                                  showDivider: false,
                                                ),
                                                CardHeader(
                                                  title: DateFormat("EEEE, MMMM d, yyyy 'at' h:mm a").format(DateFormat('E, d MMM yyyy HH:mm:ss').parseUtc(_formData.timestamp).toLocal()),
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CardHeader(
                                    title: 'Message :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  CardHeader(
                                    title: _formData.message,
                                    backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                    titleColor: const Color.fromARGB(255, 238, 216, 221),
                                    showDivider: false,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40.0,
                                child: ElevatedButton(
                                  style: themeData.extension<AppButtonTheme>()!.secondaryElevated,
                                  onPressed: () => GoRouter.of(context).go(RouteUri.notification),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                        child: Icon(
                                          Icons.arrow_circle_left_outlined,
                                          size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                        ),
                                      ),
                                      const Text("Back"),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Visibility(
                                // if IsDeleted = 0 , then this project deletion request is not yet done
                                visible: _formData.message.startsWith('ProjectDeletionRequest') && _formData.isDeleted == 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: kDefaultPadding),
                                  child: SizedBox(
                                      height: 40.0,
                                      child: Tooltip(
                                        message: 'Already Deleted',
                                        child: ElevatedButton(
                                          style: themeData.extension<AppButtonTheme>()!.errorOutlined,
                                          onPressed: null,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                child: Icon(
                                                  Icons.delete_outline_outlined,
                                                  size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                ),
                                              ),
                                              const Text("Delete Requested Project"),
                                            ],
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                              Visibility(
                                // if IsDeleted = 0 , then this project deletion request is not yet done
                                visible: _formData.message.startsWith('ProjectDeletionRequest') && _formData.isDeleted == 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: kDefaultPadding),
                                  child: SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.errorOutlined,
                                      onPressed: () => _handleProjectDeletionRequest(context),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.delete_outline_outlined,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          const Text("Delete Requested Project"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Visibility(
                              //   visible: widget.notificationID.isNotEmpty,
                              //   child: Padding(
                              //     padding: const EdgeInsets.only(right: kDefaultPadding),
                              //     child: SizedBox(
                              //       height: 40.0,
                              //       child: ElevatedButton(
                              //         style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                              //         onPressed: () {
                              //           // approvePendingUser(int.parse(widget.notificationID), _formData.userName);
                              //         },
                              //         child: Row(
                              //           mainAxisSize: MainAxisSize.min,
                              //           crossAxisAlignment: CrossAxisAlignment.center,
                              //           children: [
                              //             Padding(
                              //               padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                              //               child: Icon(
                              //                 Icons.verified_outlined,
                              //                 size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                              //               ),
                              //             ),
                              //             const Text("Approve This User"),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // )
                            ],
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

class FormData {
  String notificationID = '';
  String senderUserID = '';
  String receiverUserID = '';
  String message = '';
  String timestamp = '';
  String isRead = '';
  int isDeleted = 0;
}
