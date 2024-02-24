// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/generated/l10n.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

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
    await Future.delayed(const Duration(seconds: 1), () async {
      // read user id
      final userId = await storage.read(key: 'user_id');
      int userid = int.parse(userId!);
      print(userid);

      final userDetails = await ApiService.getSpecificUser(
        userid,
      );

      print("=============************===============");
      print(userDetails);
      print("=============*************================");

      if (userDetails['statuscode'] == 401) {
        // Handle token expiration
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          desc: "Token expired. Please login again.",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () {},
        );
        dialog.show();
      }

      _formData.userProfileImageUrl = 'https://picsum.photos/id/1005/300/300';
      // _formData.userProfileImageUrl = 'http://127.0.0.1:8080/dashboard/zzz.png';
      _formData.username = userDetails['user']['Username'] ?? '';
      _formData.firstName = userDetails['user']['FirstName'] ?? '';
      _formData.lastName = userDetails['user']['LastName'] ?? '';
      _formData.email = userDetails['user']['Email'] ?? '';
      _formData.phone = userDetails['user']['Phone'] ?? '';
      _formData.address = userDetails['user']['Address'] ?? '';
      _formData.areaOfExpertise = userDetails['user']['AreaOfExpertise'] ?? '';
      _formData.experienceInResearch = userDetails['user']['ExperienceInResearch'] ?? 0;
      _formData.highestAcademicQualificationCountry = userDetails['user']['HighestAcademicQualificationCountry'] ?? '';
      _formData.highestAcademicQualificationUniversity = userDetails['user']['HighestAcademicQualificationUniversity'] ?? '';
      _formData.highestAcademicQualification = userDetails['user']['HighestAcademicQualification'] ?? '';
      _formData.highestAcademicQualificationYear = userDetails['user']['HighestAcademicQualificationYear'] ?? 0;
      _formData.salaryScale = userDetails['user']['SalaryScale'] ?? 0;
      _formData.teaching = userDetails['user']['Teaching'] ?? 0;
      _formData.totalNumberOfCompleteProjects = userDetails['user']['TotalNumberOfCompleteProjects'] ?? 0;
      _formData.totalNumberOfCompletePublications = userDetails['user']['TotalNumberOfCompletePublications'] ?? 0;
      _formData.ongoingProjects = userDetails['user']['OngoingProjects'] ?? 0;
      _formData.userId = userDetails['user']['UserID'] ?? 0;
      _formData.rolename = getRoleName(userDetails['user']['RoleID']);
      _formData.profilePicLocation = userDetails['user']['ProfilePicLocation'] ?? '';
      print("/////////////////////////////");
    });

    return true;
  }

  Future<void> _doSave(BuildContext context, UserDataProvider userDataProvider) async {
    AppFocusHelper.instance.requestUnfocus();

    print('do save start');
    print(_formKey.currentState?.validate());
    print(_formKey.currentState?.value);
    print('do save start');

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print('do save start if');

      await userDataProvider.setUserDataAsync(
        firstname: _formData.firstName,
        lastname: _formData.lastName,
      );

      try {
        final updatedUserData = {
          'username': _formData.username,
          'FirstName': _formData.firstName,
          'LastName': _formData.lastName,
          'Address': _formData.address,
          'AreaOfExpertise': _formData.areaOfExpertise,
          'ExperienceInResearch': _formData.experienceInResearch,
          'HighestAcademicQualificationCountry': _formData.highestAcademicQualificationCountry,
          'HighestAcademicQualificationUniversity': _formData.highestAcademicQualificationUniversity,
          'HighestAcademicQualification': _formData.highestAcademicQualification,
          'HighestAcademicQualificationYear': _formData.highestAcademicQualificationYear,
          'Phone': _formData.phone,
          'ProfilePicLocation': _formData.profilePicLocation,
          'RoleID': getRoleId(_formData.rolename),
          'SalaryScale': _formData.salaryScale,
          'Teaching': _formData.teaching,
          'TotalNumberOfCompleteProjects': _formData.totalNumberOfCompleteProjects,
          'TotalNumberOfCompletePublications': _formData.totalNumberOfCompletePublications,
          'OngoingProjects': _formData.ongoingProjects,
        };

        final userId = _formData.userId;

        final responseBody = await ApiService.updateUserDetails(userId, updatedUserData);

        print('xxx ----- responseBody: $responseBody');

        if (responseBody['statuscode'] == 200) {
          // Handle success
          print('User updated successfully');
          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: "Your profile has been updated successfully!",
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
          print('Error updating user: ${responseBody['message']}');
          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: "Error updating user: ${responseBody['message']}",
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () {},
          );

          dialog.show();
        }
      } catch (e) {
        // Handle error
        print('Error updating user: $e');
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: "Error updating user: $e",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () {},
        );
        dialog.show();
      }
    } else {
      print("Form data: ${_formKey.currentState?.value}");
      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Form data is not valid",
        width: kDialogWidth,
        btnOkText: 'OK',
        btnOkOnPress: () {},
      );
      dialog.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      body: ListView(
        padding: const EdgeInsets.all(kDefaultPadding),
        children: [
          Text(
            lang.myProfile,
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
                    title: "My Profile Details",
                  ),
                  CardBody(
                    child: FutureBuilder<bool>(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Profile image
          // Container(
          //   alignment: Alignment.center,
          //   padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
          //   child: Stack(
          //     children: [
          //       CircleAvatar(
          //         backgroundColor: Colors.white,
          //         backgroundImage: NetworkImage(_formData.userProfileImageUrl),
          //         // backgroundImage: NetworkImage(_formData.userProfileImageUrl),
          //         radius: 60.0,
          //       ),
          //       Positioned(
          //         top: 0.0,
          //         right: 0.0,
          //         child: SizedBox(
          //           height: 40.0,
          //           width: 40.0,
          //           child: ElevatedButton(
          //             // image edit picker button
          //             onPressed: () {},
          //             style: themeData.extension<AppButtonTheme>()!.secondaryElevated.copyWith(
          //                   shape: MaterialStateProperty.all(const CircleBorder()),
          //                   padding: MaterialStateProperty.all(EdgeInsets.zero),
          //                 ),
          //             child: const Icon(
          //               Icons.edit_rounded,
          //               size: 20.0,
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: FormBuilderTextField(
              name: 'username',
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Username',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.username,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.username = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'email',
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Email',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.email,
              keyboardType: TextInputType.emailAddress,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.email = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'firstName',
              decoration: const InputDecoration(
                labelText: 'firstName',
                hintText: 'firstName',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.firstName,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.firstName = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'lastName',
              decoration: const InputDecoration(
                labelText: 'lastName',
                hintText: 'lastName',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.lastName,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.lastName = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'address',
              decoration: const InputDecoration(
                labelText: 'address',
                hintText: 'address',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.address,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.address = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'areaOfExpertise',
              decoration: const InputDecoration(
                labelText: 'areaOfExpertise',
                hintText: 'areaOfExpertise',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.areaOfExpertise,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.areaOfExpertise = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'experienceInResearch',
              decoration: const InputDecoration(
                labelText: 'experienceInResearch',
                hintText: 'experienceInResearch',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.experienceInResearch.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.experienceInResearch = int.parse(value ?? '0')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'highestAcademicQualification',
              decoration: const InputDecoration(
                labelText: 'highestAcademicQualification',
                hintText: 'highestAcademicQualification',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.highestAcademicQualification,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.highestAcademicQualification = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'highestAcademicQualificationUniversity',
              decoration: const InputDecoration(
                labelText: 'highestAcademicQualificationUniversity',
                hintText: 'highestAcademicQualificationUniversity',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.highestAcademicQualificationUniversity,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.highestAcademicQualificationUniversity = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'highestAcademicQualificationCountry',
              decoration: const InputDecoration(
                labelText: 'highestAcademicQualificationCountry',
                hintText: 'highestAcademicQualificationCountry',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.highestAcademicQualificationCountry,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.highestAcademicQualificationCountry = value ?? ''),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'highestAcademicQualificationYear',
              decoration: const InputDecoration(
                labelText: 'highestAcademicQualificationYear',
                hintText: 'highestAcademicQualificationYear',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.highestAcademicQualificationYear.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.highestAcademicQualificationYear = int.parse(value ?? '0')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'phone',
              decoration: const InputDecoration(
                labelText: 'phone',
                hintText: 'phone',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.phone,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.phone = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'profilePicLocation',
              decoration: const InputDecoration(
                labelText: 'profilePicLocation',
                hintText: 'profilePicLocation',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.profilePicLocation,
              // validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.profilePicLocation = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderDropdown(
              name: 'roleId',
              decoration: const InputDecoration(
                labelText: 'roleId',
                hintText: 'roleId',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              hint: const Text('Select'),
              initialValue: _formData.rolename,
              validator: FormBuilderValidators.required(),
              items: ['Admin', 'Researcher', 'Reviewer', 'Teacher', 'Student'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onSaved: (value) => (_formData.rolename = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'salaryScale',
              decoration: const InputDecoration(
                labelText: 'salaryScale',
                hintText: 'salaryScale',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.salaryScale.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.salaryScale = int.parse(value ?? '0')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'teaching',
              decoration: const InputDecoration(
                labelText: 'teaching',
                hintText: 'teaching',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.teaching.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.teaching = int.parse(value ?? '0')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'totalNumberOfCompleteProjects',
              decoration: const InputDecoration(
                labelText: 'totalNumberOfCompleteProjects',
                hintText: 'totalNumberOfCompleteProjects',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.totalNumberOfCompleteProjects.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.totalNumberOfCompleteProjects = int.parse(value ?? '0')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'totalNumberOfCompletePublications',
              decoration: const InputDecoration(
                labelText: 'totalNumberOfCompletePublications',
                hintText: 'totalNumberOfCompletePublications',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.totalNumberOfCompletePublications.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.totalNumberOfCompletePublications = int.parse(value ?? '0')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'ongoingProjects',
              decoration: const InputDecoration(
                labelText: 'ongoingProjects',
                hintText: 'ongoingProjects',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.ongoingProjects.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.ongoingProjects = int.parse(value ?? '0')),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 40.0,
              child: ElevatedButton(
                style: themeData.extension<AppButtonTheme>()!.successElevated,
                onPressed: () => _doSave(context, context.read<UserDataProvider>()),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                      child: Icon(
                        Icons.save_rounded,
                        size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                      ),
                    ),
                    Text(lang.save),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormData {
  String userProfileImageUrl = '';
  String username = '';
  String email = '';
  String firstName = '';
  String lastName = '';
  String address = '';
  String areaOfExpertise = '';
  int experienceInResearch = 0;
  String highestAcademicQualificationCountry = '';
  String highestAcademicQualificationUniversity = '';
  String highestAcademicQualification = '';
  int highestAcademicQualificationYear = 0;
  String phone = '';
  String profilePicLocation = '';
  String rolename = '';
  int salaryScale = 0;
  int teaching = 0;
  int totalNumberOfCompleteProjects = 0;
  int totalNumberOfCompletePublications = 0;
  int ongoingProjects = 0;
  int userId = 0;
}
