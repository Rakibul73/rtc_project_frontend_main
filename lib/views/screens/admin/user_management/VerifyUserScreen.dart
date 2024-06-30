import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:rtc_project_fronend/api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class VerifyUserScreen extends StatefulWidget {
  final String pendingUserID;

  const VerifyUserScreen({
    Key? key,
    required this.pendingUserID,
  }) : super(key: key);

  @override
  State<VerifyUserScreen> createState() => _VerifyUserScreenState();
}

class _VerifyUserScreenState extends State<VerifyUserScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  bool editusername = false;
  bool editemail = false;
  bool editfirstname = false;
  bool editlastname = false;
  bool editphone = false;
  bool editfacultyname = false;
  bool editrole = false;
  bool initialPendingUserDataChange = false;

  Future<bool>? _future;

  // Function to map role name to role ID
  int getRoleId(String roleName) {
    switch (roleName) {
      case 'Admin':
        return 1;
      case 'Teacher':
        return 4;
      case 'Student':
        return 5;
      case 'Reviewer':
        return 3;
      case 'Researcher':
        return 2;
      default:
        // Default to 1 (Admin) if not found
        return 1;
    }
  }

  // Function to map role ID to role name
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

  Future<bool> _getDataAsync() async {
    print('pendingUserID: ${widget.pendingUserID}');
    if (widget.pendingUserID.isNotEmpty) {
      print('pendingUserID: ${widget.pendingUserID}');
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.pendingUserID = widget.pendingUserID;

        int pendingUserID = int.parse(widget.pendingUserID);
        final userDetails = await ApiService.getSpecificPendingUser(
          pendingUserID,
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

        print(userDetails['TempUser']);

        _formData.userName = userDetails['TempUser']['Username'];
        _formData.email = userDetails['TempUser']['Email'];
        _formData.firstName = userDetails['TempUser']['FirstName'];
        _formData.lastName = userDetails['TempUser']['LastName'];
        _formData.phone = userDetails['TempUser']['Phone'];
        _formData.facultyName = userDetails['TempUser']['FacultyName'];
        _formData.roleID = getRoleName(userDetails['TempUser']['RoleID']);
      });
    }

    return true;
  }

  Future<void> approvingPendingUser(int userID, String username) async {
    try {
      final responseBody = await ApiService.approvePendingUser(userID, username);
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
        // Go to pending users screen
        GoRouter.of(context).go(RouteUri.pendingusers);
      }
    } catch (e) {
      print('Failed to approve pending user: $e');
    }
  }

  // function to approve a pending user with data['UserID']
  void approvePendingUser(int userID, String username) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      title: "Approve this Pending User?",
      desc: "UserName: $username",
      width: kDialogWidth,
      btnOkText: 'Approve User',
      btnOkOnPress: () {
        approvingPendingUser(userID, username);
      },
      btnCancelOnPress: () {},
    );
    dialog.show();
  }

  void _goSaveChanges(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Are you sure you want to save changes?",
      width: kDialogWidth,
      btnOkText: "Yes",
      btnOkOnPress: () async {
        _formKey.currentState!.save();
        try {
          final updatedTempUserData = {
            'Username': _formData.userName,
            'FirstName': _formData.firstName,
            'LastName': _formData.lastName,
            'Phone': _formData.phone,
            'Email': _formData.email,
            'FacultyName': _formData.facultyName,
            'RoleID': getRoleId(_formData.roleID),
          };
          final responseBody = await ApiService.updateTempUserDetails(int.parse(widget.pendingUserID), updatedTempUserData);
          if (responseBody['statuscode'] == 200) {
            // Handle success
            print('User updated successfully');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: "Updated successfull",
              desc: "Username: ${_formData.userName}",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () {},
            );
            dialog.show();
          } else if (responseBody['msg'] == "Token has expired") {
            // Handle error
            print('Token has expired');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Token has expired , please login again",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () {},
            );
            dialog.show();
          } else {
            // Handle error
            print('Error updating Temp user: ${responseBody['message']}');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Error updating Temp user: ${responseBody['message']}",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () {},
            );
            dialog.show();
          }
        } catch (e) {
          // Handle error
          print('Error updating temp user: $e');
          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: "Error updating Temp user: $e",
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () {},
          );
          dialog.show();
        }
        // making Save_changes button disabled after clicking on it
        setState(() {
          initialPendingUserDataChange = false;
        });
      },
      btnCancelText: "No",
      btnCancelOnPress: () {},
    );
    dialog.show();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.usermanagementoverview,
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
    final pageTitle = 'Pending User - ID: ${widget.pendingUserID.isEmpty ? 'Invalid User-ID' : widget.pendingUserID}';

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
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0, top: kDefaultPadding),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Pending Username :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Visibility(
                                      visible: !editusername,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.userName,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editusername,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'userName',
                                                decoration: const InputDecoration(
                                                  hintText: 'User Name',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.userName,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.userName = value ?? ''),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                              onPressed: () {
                                                setState(() {
                                                  editusername = !editusername; // Toggle edit mode
                                                  if (!editusername) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialPendingUserDataChange = true;
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                    child: Icon(
                                                      editusername
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editusername ? "Save" : "Edit"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: kDefaultPadding),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Role :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Visibility(
                                      visible: !editrole,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.roleID,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editrole,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderDropdown(
                                                name: 'roleId',
                                                decoration: const InputDecoration(
                                                  hintText: 'roleId',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                hint: const Text('Select'),
                                                initialValue: _formData.roleID,
                                                validator: FormBuilderValidators.required(),
                                                items: ['Admin', 'Researcher', 'Reviewer', 'Teacher', 'Student'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onSaved: (value) => (_formData.roleID = value ?? ''),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                              onPressed: () {
                                                setState(() {
                                                  editrole = !editrole; // Toggle edit mode
                                                  if (!editrole) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialPendingUserDataChange = true;
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                    child: Icon(
                                                      editrole
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editrole ? "Save" : "Edit"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: kDefaultPadding),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'First Name :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Visibility(
                                      visible: !editfirstname,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.firstName,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editfirstname,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'firstName',
                                                decoration: const InputDecoration(
                                                  hintText: 'First Name',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.firstName,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.firstName = value ?? ''),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                              onPressed: () {
                                                setState(() {
                                                  editfirstname = !editfirstname; // Toggle edit mode
                                                  if (!editfirstname) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialPendingUserDataChange = true;
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                    child: Icon(
                                                      editfirstname
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editfirstname ? "Save" : "Edit"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: kDefaultPadding),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: kDefaultPadding * 2.0,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Last Name :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Visibility(
                                      visible: !editlastname,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.lastName,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editlastname,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'lastName',
                                                decoration: const InputDecoration(
                                                  hintText: 'Last Name',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.lastName,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.lastName = value ?? ''),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                              onPressed: () {
                                                setState(() {
                                                  editlastname = !editlastname; // Toggle edit mode
                                                  if (!editlastname) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialPendingUserDataChange = true;
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                    child: Icon(
                                                      editlastname
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editlastname ? "Save" : "Edit"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: kDefaultPadding),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Email :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Visibility(
                                      visible: !editemail,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.email,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editemail,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'email',
                                                decoration: const InputDecoration(
                                                  hintText: 'Email',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.email,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.email = value ?? ''),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                              onPressed: () {
                                                setState(() {
                                                  editemail = !editemail; // Toggle edit mode
                                                  if (!editemail) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialPendingUserDataChange = true;
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                    child: Icon(
                                                      editemail
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editemail ? "Save" : "Edit"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: kDefaultPadding),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Phone :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Visibility(
                                      visible: !editphone,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.phone,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editphone,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'phone',
                                                decoration: const InputDecoration(
                                                  hintText: 'Phone',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.phone,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.phone = value ?? ''),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                              onPressed: () {
                                                setState(() {
                                                  editphone = !editphone; // Toggle edit mode
                                                  if (!editphone) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialPendingUserDataChange = true;
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                    child: Icon(
                                                      editphone
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editphone ? "Save" : "Edit"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: kDefaultPadding),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Faculty Name :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Visibility(
                                      visible: !editfacultyname,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.facultyName,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editfacultyname,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderDropdown(
                                                name: 'facultyName',
                                                decoration: const InputDecoration(
                                                  labelText: 'Faculty Name',
                                                  hintText: 'facultyName',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                hint: const Text('Select'),
                                                initialValue: _formData.facultyName,
                                                validator: FormBuilderValidators.required(),
                                                items: [
                                                  'Faculty of Agriculture',
                                                  'Faculty of Computer Science and Engineering',
                                                  'Faculty of Business Administration',
                                                  'Faculty of Animal Science and Veterinary Medicine',
                                                  'Faculty of Fisheries',
                                                  'Faculty of Environmental Science and Disaster Management',
                                                  'Faculty of Nutrition and Food Science',
                                                  'Faculty of Law and Land Administration'
                                                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onSaved: (value) => (_formData.facultyName = value ?? ''),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ElevatedButton(
                                              style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                              onPressed: () {
                                                setState(() {
                                                  editfacultyname = !editfacultyname; // Toggle edit mode
                                                  if (!editfacultyname) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialPendingUserDataChange = true;
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                    child: Icon(
                                                      editfacultyname
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editfacultyname ? "Save" : "Edit"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: kDefaultPadding),
                                          ],
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.pendingusers),
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
                                visible: initialPendingUserDataChange,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: kDefaultPadding),
                                  child: SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.successOutlined,
                                      onPressed: () => _goSaveChanges(context),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.save_outlined,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          const Text("Save Changes"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: widget.pendingUserID.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: kDefaultPadding),
                                  child: SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                      onPressed: () {
                                        approvePendingUser(int.parse(widget.pendingUserID), _formData.userName);
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.verified_outlined,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          const Text("Approve This User"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
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
  String pendingUserID = '';
  String roleID = '';
  String email = '';
  String phone = '';
  String firstName = '';
  String lastName = '';
  String userName = '';
  String facultyName = '';
}
