// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
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

  List<PlatformFile>? _profilePicFiles; // Change to List<PlatformFile>?
  void _onProfilePicFileSelected(List<PlatformFile>? files) {
    setState(() {
      _profilePicFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  Future<void> _uploadProfilePicFiles() async {
    if (_profilePicFiles != null && _profilePicFiles!.isNotEmpty) {
      // try {
      for (var file in _profilePicFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        _formData.profilePicLocation = fileName;
        print(fileName);
        final responseBody = await ApiService.uploadFile('profile-pic/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {
          print('Profile Pic File uploaded successfully');
        }
      }
      // } catch (e) {
      //   print('Failed to upload seal files: $e');
      //   // Handle error
      // }
    } else {
      print('No profile pic files selected');
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
      _formData.dateOfBirth = userDetails['user']['Dateofbirth'] ?? '';
      _formData.presentAddress = userDetails['user']['PresentAddress'] ?? '';
      _formData.permanentAddress = userDetails['user']['PermanentAddress'] ?? '';
      _formData.fullNameBangla = userDetails['user']['FullNameBangla'] ?? '';
      _formData.positionEnglish = userDetails['user']['PositionEnglish'] ?? '';
      _formData.positionBangla = userDetails['user']['PositionBangla'] ?? '';
      _formData.positionHeldSince = userDetails['user']['PositionHeldSince'] ?? '';
      _formData.gender = userDetails['user']['Gender'] ?? '';
      _formData.nid = userDetails['user']['Nid'] ?? '';
      _formData.nidLocation = userDetails['user']['NidLocation'] ?? '';
      _formData.instituteName = userDetails['user']['InstituteName'] ?? '';
      _formData.instituteLocation = userDetails['user']['InstituteLocation'] ?? '';
      _formData.instituteEmail = userDetails['user']['InstituteEmail'] ?? '';
      _formData.profilePicLocation = userDetails['user']['ProfilePicLocation'] ?? '';
      _formData.signatureLocation = userDetails['user']['SignatureLocation'] ?? '';
      _formData.sealLocation = userDetails['user']['SealLocation'] ?? '';
      _formData.salaryScale = userDetails['user']['SalaryScale'] ?? 0;
      _formData.highestAcademicQualification = userDetails['user']['HighestAcademicQualification'] ?? '';
      _formData.highestAcademicQualificationUniversity = userDetails['user']['HighestAcademicQualificationUniversity'] ?? '';
      _formData.highestAcademicQualificationCountry = userDetails['user']['HighestAcademicQualificationCountry'] ?? '';
      _formData.highestAcademicQualificationYear = userDetails['user']['HighestAcademicQualificationYear'] ?? 0;
      _formData.areaOfExpertise = userDetails['user']['AreaOfExpertise'] ?? '';
      _formData.experienceInResearch = userDetails['user']['ExperienceInResearch'] ?? 0;
      _formData.teaching = userDetails['user']['Teaching'] ?? 0;
      _formData.totalNumberOfCompleteProjects = userDetails['user']['TotalNumberOfCompleteProjects'] ?? 0;
      _formData.totalNumberOfCompletePublications = userDetails['user']['TotalNumberOfCompletePublications'] ?? 0;
      _formData.ongoingProjects = userDetails['user']['OngoingProjects'] ?? 0;
      _formData.studentID = userDetails['user']['StudentID'] ?? '';
      _formData.studentRegNo = userDetails['user']['StudentRegNo'] ?? '';
      _formData.firstEnrollmentSemester = userDetails['user']['FirstEnrollmentSemester'] ?? '';
      _formData.undergraduateCGPALevel = userDetails['user']['UndergraduateCGPALevel'] ?? '';

      _formData.userId = userDetails['user']['UserID'] ?? 0;
      _formData.rolename = getRoleName(userDetails['user']['RoleID']);
      print("/////////////////////////////");
    });

    // final profilePic = await ApiService.fetchProfilePic(_formData.profilePicLocation);
    // print('profilePic: $profilePic');

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

      // Call _uploadProfilePicFiles() to upload the profile picture files
      _uploadProfilePicFiles();

      print('do save start if');

      await userDataProvider.setUserDataAsync(
        firstname: _formData.firstName,
        lastname: _formData.lastName,
      );

      try {
        final updatedUserData = {
          'Username': _formData.username,
          'FirstName': _formData.firstName,
          'LastName': _formData.lastName,
          'FullNameBangla': _formData.fullNameBangla,
          'PositionEnglish': _formData.positionEnglish,
          'PositionBangla': _formData.positionBangla,
          'PositionHeldSince': _formData.positionHeldSince,
          'Gender': _formData.gender,
          // IF dob is '' empty string hen set it to NUll
          'Dateofbirth': _formData.dateOfBirth == '' ? null : _formData.dateOfBirth,
          'Phone': _formData.phone,
          'Email': _formData.email,
          'Nid': _formData.nid,
          'NidLocation': _formData.nidLocation,
          'InstituteName': _formData.instituteName,
          'InstituteLocation': _formData.instituteLocation,
          'InstituteEmail': _formData.instituteEmail,
          'PresentAddress': _formData.presentAddress,
          'PermanentAddress': _formData.permanentAddress,
          'ProfilePicLocation': _formData.profilePicLocation,
          'SignatureLocation': _formData.signatureLocation,
          'SealLocation': _formData.sealLocation,
          'SalaryScale': _formData.salaryScale,
          'HighestAcademicQualification': _formData.highestAcademicQualification,
          'HighestAcademicQualificationUniversity': _formData.highestAcademicQualificationUniversity,
          'HighestAcademicQualificationCountry': _formData.highestAcademicQualificationCountry,
          'HighestAcademicQualificationYear': _formData.highestAcademicQualificationYear,
          'AreaOfExpertise': _formData.areaOfExpertise,
          'ExperienceInResearch': _formData.experienceInResearch,
          'Teaching': _formData.teaching,
          'TotalNumberOfCompleteProjects': _formData.totalNumberOfCompleteProjects,
          'TotalNumberOfCompletePublications': _formData.totalNumberOfCompletePublications,
          'OngoingProjects': _formData.ongoingProjects,
          'StudentID': _formData.studentID,
          'StudentRegNo': _formData.studentRegNo,
          'FirstEnrollmentSemester': _formData.firstEnrollmentSemester,
          'UndergraduateCGPALevel': _formData.undergraduateCGPALevel,
          'RoleID': getRoleId(_formData.rolename),
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
    DateTime? initialDate = _formData.dateOfBirth != null && _formData.dateOfBirth!.isNotEmpty ? DateTime.parse(_formData.dateOfBirth) : null;

    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // Profile image
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: Stack(
              children: [
                FutureBuilder<String>(
                  future: ApiService.fetchProfilePic(_formData.profilePicLocation),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: MemoryImage(base64Decode(snapshot.data!)), // Convert base64 string to image bytes
                        radius: 60.0,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          FormBuilderFilePicker(
            name: 'profile_pic',
            // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
            allowMultiple: false,
            maxFiles: 1,
            type: FileType.any,
            previewImages: true,
            decoration: const InputDecoration(
              labelText: 'Select Profile Pic',
              border: OutlineInputBorder(),
            ),
            selector: const Row(
              children: [
                Icon(Icons.file_upload_rounded),
                Text('Upload'),
              ],
            ),
            // typeSelectors: [
            //   TypeSelector(
            //     type: FileType.custom,
            //     allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg'],
            //     selector: Row(
            //       children: [
            //         Icon(Icons.file_upload),
            //         Text('Upload'),
            //       ],
            //     ),
            //   ),
            // ],
            onChanged: _onProfilePicFileSelected,
          ),

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
              name: 'firstName',
              decoration: const InputDecoration(
                labelText: 'First Name',
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
                labelText: 'Last Name',
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
              name: 'fullNameBangla',
              decoration: const InputDecoration(
                labelText: 'Full Name Bangla',
                hintText: 'fullNameBangla',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.fullNameBangla,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.fullNameBangla = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'positionEnglish',
              decoration: const InputDecoration(
                labelText: 'Position English',
                hintText: 'positionEnglish',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.positionEnglish,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.positionEnglish = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'positionBangla',
              decoration: const InputDecoration(
                labelText: 'Position Bangla',
                hintText: 'positionBangla',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.positionBangla,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.positionBangla = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'positionHeldSince',
              decoration: const InputDecoration(
                labelText: 'Position Held Since',
                hintText: 'positionHeldSince',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.positionHeldSince,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.positionHeldSince = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'gender',
              decoration: const InputDecoration(
                labelText: 'Gender',
                hintText: 'gender',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.gender,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.gender = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderDateTimePicker(
              name: 'dateOfBirth',
              inputType: InputType.date,
              decoration: const InputDecoration(
                labelText: 'Date of birth',
                hintText: 'dateOfBirth',
                border: OutlineInputBorder(),
              ),
              initialValue: initialDate,
              textAlign: TextAlign.center,
              format: DateFormat("MMMM d, yyyy"),
              validator: FormBuilderValidators.required(),
              onSaved: (value) {
                if (value != null) {
                  _formData.dateOfBirth = value.toString();
                } else {
                  _formData.dateOfBirth = '';
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'phone',
              decoration: const InputDecoration(
                labelText: 'Phone',
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
              name: 'nid',
              decoration: const InputDecoration(
                labelText: 'Nid',
                hintText: 'nid',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.nid,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.nid = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'nidphoto',
              decoration: const InputDecoration(
                labelText: 'Nid Photo',
                hintText: 'nidphoto',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.nidLocation,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.nidLocation = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'instituteName',
              decoration: const InputDecoration(
                labelText: 'Institute Name',
                hintText: 'instituteName',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.instituteName,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.instituteName = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'instituteLocation',
              decoration: const InputDecoration(
                labelText: 'Institute Location',
                hintText: 'instituteLocation',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.instituteLocation,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.instituteLocation = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'instituteEmail',
              decoration: const InputDecoration(
                labelText: 'Institute Email',
                hintText: 'instituteEmail',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.instituteEmail,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.instituteEmail = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'presentAddress',
              decoration: const InputDecoration(
                labelText: 'Present Address',
                hintText: 'presentAddress',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.presentAddress,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.presentAddress = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'permanentAddress',
              decoration: const InputDecoration(
                labelText: 'Permanent Address',
                hintText: 'permanentAddress',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.permanentAddress,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.permanentAddress = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'profilePicLocation',
              decoration: const InputDecoration(
                labelText: 'Profile Pic Location',
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
            child: FormBuilderTextField(
              name: 'signatureLocation',
              decoration: const InputDecoration(
                labelText: 'Signature Location',
                hintText: 'signatureLocation',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.signatureLocation,
              onSaved: (value) => (_formData.signatureLocation = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'sealLocation',
              decoration: const InputDecoration(
                labelText: 'Seal Location',
                hintText: 'sealLocation',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.sealLocation,
              // validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.sealLocation = value ?? ''),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'salaryScale',
              decoration: const InputDecoration(
                labelText: 'Salary Scale',
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
              name: 'highestAcademicQualification',
              decoration: const InputDecoration(
                labelText: 'Highest Academic Qualification',
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
                labelText: 'Highest Academic Qualification University',
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
                labelText: 'Highest Academic Qualification Country',
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
                labelText: 'Highest Academic Qualification Year',
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
              name: 'areaOfExpertise',
              decoration: const InputDecoration(
                labelText: 'Area Of Expertise',
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
                labelText: 'Experience In Research',
                hintText: '(Years)',
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
              name: 'teaching',
              decoration: const InputDecoration(
                labelText: 'Teaching Experience',
                hintText: '(Years)',
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
                labelText: 'Total Number Of Complete Projects',
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
                labelText: 'Total Number Of Complete Publications',
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
                labelText: 'Ongoing Projects',
                hintText: 'ongoingProjects',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.ongoingProjects.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.ongoingProjects = int.parse(value ?? '0')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'studentID',
              decoration: const InputDecoration(
                labelText: 'Student ID',
                hintText: 'studentID',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.studentID.toString(),
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.studentID = int.parse(value ?? '0')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'studentRegNo',
              decoration: const InputDecoration(
                labelText: 'Student Reg. No.',
                hintText: 'studentRegNo',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.studentRegNo,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.studentRegNo = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'firstEnrollmentSemester',
              decoration: const InputDecoration(
                labelText: 'First Enrollment Semester',
                hintText: 'firstEnrollmentSemester',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.firstEnrollmentSemester,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.firstEnrollmentSemester = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderTextField(
              name: 'undergraduateCGPALevel',
              decoration: const InputDecoration(
                labelText: 'Undergraduate CGPA Level',
                hintText: 'undergraduateCGPALevel',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              initialValue: _formData.undergraduateCGPALevel,
              validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.undergraduateCGPALevel = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderDropdown(
              name: 'roleId',
              decoration: const InputDecoration(
                labelText: 'Role',
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
  String firstName = '';
  String lastName = '';
  String fullNameBangla = '';
  String positionEnglish = '';
  String positionBangla = '';
  String positionHeldSince = '';
  String gender = '';
  String dateOfBirth = '';
  String phone = '';
  String email = '';
  String nid = '';
  String nidLocation = '';
  String instituteName = '';
  String instituteLocation = '';
  String instituteEmail = '';
  String presentAddress = '';
  String permanentAddress = '';
  String profilePicLocation = '';
  String signatureLocation = '';
  String sealLocation = '';
  int salaryScale = 0;
  String highestAcademicQualification = '';
  String highestAcademicQualificationUniversity = '';
  String highestAcademicQualificationCountry = '';
  int highestAcademicQualificationYear = 0;
  String areaOfExpertise = '';
  int experienceInResearch = 0;
  int teaching = 0;
  int totalNumberOfCompleteProjects = 0;
  int totalNumberOfCompletePublications = 0;
  int ongoingProjects = 0;
  int studentID = 0;
  String studentRegNo = '';
  String firstEnrollmentSemester = '';
  String undergraduateCGPALevel = '';

  String rolename = '';
  int userId = 0;
}
