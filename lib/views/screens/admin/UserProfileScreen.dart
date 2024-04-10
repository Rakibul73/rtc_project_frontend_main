import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

class UserProfileScreen extends StatefulWidget {
  final String userID;

  const UserProfileScreen({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  bool editusername = false;
  bool editemail = false;
  bool editfirstname = false;
  bool editlastname = false;
  bool editphone = false;
  bool editfacultyname = false;
  bool editrole = false;
  bool editfullnamebangla = false;
  bool editgender = false;
  bool editdob = false;
  bool editpositionenglish = false;
  bool editpositionbangla = false;
  bool editpositionheldsince = false;
  bool editdepartmentname = false;
  bool editinstituteName = false;
  bool editistitutelocation = false;
  bool editinstituteemail = false;
  bool editsalaryscale = false;
  bool editbasicpay = false;
  bool editAreaOfExpertise = false;
  bool editExperienceInResearch = false;
  bool editTeaching = false;
  bool editTotalNumberOfCompleteProjects = false;
  bool editTotalNumberOfCompletePublications = false;
  bool editOngoingProjects = false;
  bool editReferencesOfLatestPublications = false;
  bool editNid = false;
  bool editNidLocation = false;
  bool editPresentAddress = false;
  bool editPermanentAddress = false;
  bool editProfilePicLocation = false;
  bool editSignatureLocation = false;
  bool editSealLocation = false;
  bool editHighestAcademicQualification = false;
  bool editHighestAcademicQualificationUniversity = false;
  bool editHighestAcademicQualificationCountry = false;
  bool editHighestAcademicQualificationYear = false;
  bool editStudentID = false;
  bool editStudentRegNo = false;
  bool editFirstEnrollmentSemester = false;
  bool editUndergraduateCGPALevel = false;
  bool initialUserDataChange = false;

  Future<bool>? _future;

  List<PlatformFile>? _profilePicFiles;
  List<PlatformFile>? _signatureFiles;
  List<PlatformFile>? _sealFiles;
  List<PlatformFile>? _nidFiles;
  void _onProfilePicFileSelected(List<PlatformFile>? files) {
    setState(() {
      _profilePicFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  void _onSignatureFileSelected(List<PlatformFile>? files) {
    setState(() {
      _signatureFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  void _onSealFileSelected(List<PlatformFile>? files) {
    setState(() {
      _sealFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  void _onNidFileSelected(List<PlatformFile>? files) {
    setState(() {
      _nidFiles = files != null ? List.from(files) : null; // Update to assign the list of files
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

  Future<void> _uploadSignatureFiles() async {
    if (_signatureFiles != null && _signatureFiles!.isNotEmpty) {
      // try {
      for (var file in _signatureFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        _formData.signatureLocation = fileName;
        print(fileName);
        final responseBody = await ApiService.uploadFile('signature/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {
          print('Signature File uploaded successfully');
        }
      }
      // } catch (e) {
      //   print('Failed to upload seal files: $e');
      //   // Handle error
      // }
    } else {
      print('No Signature files selected');
    }
  }

  Future<void> _uploadSealFiles() async {
    if (_sealFiles != null && _sealFiles!.isNotEmpty) {
      // try {
      for (var file in _sealFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        _formData.sealLocation = fileName;
        print(fileName);
        final responseBody = await ApiService.uploadFile('seal/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {
          print('Seal File uploaded successfully');
        }
      }
      // } catch (e) {
      //   print('Failed to upload seal files: $e');
      //   // Handle error
      // }
    } else {
      print('No Seal files selected');
    }
  }

  Future<void> _uploadNidFiles() async {
    if (_nidFiles != null && _nidFiles!.isNotEmpty) {
      // try {
      for (var file in _nidFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        _formData.nidLocation = fileName;
        print(fileName);
        final responseBody = await ApiService.uploadFile('nid/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {
          print('Nid File uploaded successfully');
        }
      }
      // } catch (e) {
      //   print('Failed to upload Nid files: $e');
      //   // Handle error
      // }
    } else {
      print('No Nid files selected');
    }
  }

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
    print('userID: ${widget.userID}');
    if (widget.userID.isNotEmpty) {
      print('userID: ${widget.userID}');
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.userID = widget.userID;

        int userID = int.parse(widget.userID);
        final userDetails = await ApiService.getSpecificUser(
          userID,
        );

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

        print(userDetails['user']);

        _formData.userID = userDetails['user']['UserID'].toString();
        _formData.rolename = getRoleName(userDetails['user']['RoleID']);
        _formData.username = userDetails['user']['Username'] ?? '';
        _formData.positionEnglish = userDetails['user']['PositionEnglish'] ?? '';
        _formData.positionBangla = userDetails['user']['PositionBangla'] ?? '';
        _formData.positionHeldSince = userDetails['user']['PositionHeldSince'] ?? '';
        _formData.email = userDetails['user']['Email'] ?? '';
        _formData.firstName = userDetails['user']['FirstName'] ?? '';
        _formData.lastName = userDetails['user']['LastName'] ?? '';
        _formData.fullNameBangla = userDetails['user']['FullNameBangla'] ?? '';
        _formData.presentAddress = userDetails['user']['PresentAddress'] ?? '';
        _formData.permanentAddress = userDetails['user']['PermanentAddress'] ?? '';
        _formData.gender = userDetails['user']['Gender'] ?? '';
        _formData.nid = userDetails['user']['Nid'] ?? '';
        _formData.nidLocation = userDetails['user']['NidLocation'] ?? '';
        _formData.facultyName = userDetails['user']['FacultyName'] ?? '';
        _formData.departmentName = userDetails['user']['DepartmentName'] ?? '';
        _formData.instituteName = userDetails['user']['InstituteName'] ?? '';
        _formData.instituteLocation = userDetails['user']['InstituteLocation'] ?? '';
        _formData.instituteEmail = userDetails['user']['InstituteEmail'] ?? '';
        _formData.phone = userDetails['user']['Phone'] ?? '';
        _formData.dateOfBirth = userDetails['user']['Dateofbirth'] ?? '';
        _formData.salaryScale = userDetails['user']['SalaryScale'] ?? '';
        _formData.basicPay = userDetails['user']['BasicPay'] ?? 0.0;
        _formData.highestAcademicQualification = userDetails['user']['HighestAcademicQualification'] ?? '';
        _formData.highestAcademicQualificationUniversity = userDetails['user']['HighestAcademicQualificationUniversity'] ?? '';
        _formData.highestAcademicQualificationCountry = userDetails['user']['HighestAcademicQualificationCountry'] ?? '';
        _formData.highestAcademicQualificationYear = userDetails['user']['HighestAcademicQualificationYear'] ?? 0;
        _formData.referencesOfLatestPublications = userDetails['user']['ReferencesOfLatestPublications'] ?? '';
        _formData.areaOfExpertise = userDetails['user']['AreaOfExpertise'] ?? '';
        _formData.experienceInResearch = userDetails['user']['ExperienceInResearch'] ?? 0;
        _formData.teaching = userDetails['user']['Teaching'] ?? 0;
        _formData.profilePicLocation = userDetails['user']['ProfilePicLocation'] ?? '';
        _formData.signatureLocation = userDetails['user']['SignatureLocation'] ?? '';
        _formData.sealLocation = userDetails['user']['SealLocation'] ?? '';
        _formData.totalNumberOfCompleteProjects = userDetails['user']['TotalNumberOfCompleteProjects'] ?? 0;
        _formData.totalNumberOfCompletePublications = userDetails['user']['TotalNumberOfCompletePublications'] ?? 0;
        _formData.ongoingProjects = userDetails['user']['OngoingProjects'] ?? 0;
        _formData.studentID = userDetails['user']['StudentID'] ?? 0;
        _formData.studentRegNo = userDetails['user']['StudentRegNo'] ?? '';
        _formData.firstEnrollmentSemester = userDetails['user']['FirstEnrollmentSemester'] ?? '';
        _formData.undergraduateCGPALevel = userDetails['user']['UndergraduateCGPALevel'] ?? '';
      });
    }

    return true;
  }

  void _goSaveChanges(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Update User Data?",
      desc: "Are you sure you want to update this user's profile you edited?",
      width: kDialogWidth,
      btnOkText: "Yes",
      btnOkOnPress: () async {
        _formKey.currentState!.save();
        try {
          final updatedUserData = {
            'RoleID': getRoleId(_formData.rolename),
            'Username': _formData.username,
            'FirstName': _formData.firstName,
            'LastName': _formData.lastName,
            'Phone': _formData.phone,
            'Email': _formData.email,
            'FacultyName': _formData.facultyName,
            'FullNameBangla': _formData.fullNameBangla,
            'PositionEnglish': _formData.positionEnglish,
            'PositionBangla': _formData.positionBangla,
            'PositionHeldSince': _formData.positionHeldSince,
            'Gender': _formData.gender,
            // IF dob is '' empty string then set it to NUll
            'Dateofbirth': _formData.dateOfBirth == '' ? null : _formData.dateOfBirth,
            'Nid': _formData.nid,
            'NidLocation': _formData.nidLocation,
            'DepartmentName': _formData.departmentName,
            'InstituteName': _formData.instituteName,
            'InstituteLocation': _formData.instituteLocation,
            'InstituteEmail': _formData.instituteEmail,
            'PresentAddress': _formData.presentAddress,
            'PermanentAddress': _formData.permanentAddress,
            'ProfilePicLocation': _formData.profilePicLocation,
            'SignatureLocation': _formData.signatureLocation,
            'SealLocation': _formData.sealLocation,
            'SalaryScale': _formData.salaryScale,
            'BasicPay': _formData.basicPay,
            'HighestAcademicQualification': _formData.highestAcademicQualification,
            'HighestAcademicQualificationUniversity': _formData.highestAcademicQualificationUniversity,
            'HighestAcademicQualificationCountry': _formData.highestAcademicQualificationCountry,
            'HighestAcademicQualificationYear': _formData.highestAcademicQualificationYear,
            'AreaOfExpertise': _formData.areaOfExpertise,
            'ExperienceInResearch': _formData.experienceInResearch,
            'Teaching': _formData.teaching,
            'TotalNumberOfCompleteProjects': _formData.totalNumberOfCompleteProjects,
            'ReferencesOfLatestPublications': _formData.referencesOfLatestPublications,
            'TotalNumberOfCompletePublications': _formData.totalNumberOfCompletePublications,
            'OngoingProjects': _formData.ongoingProjects,
            'StudentID': _formData.studentID,
            'StudentRegNo': _formData.studentRegNo,
            'FirstEnrollmentSemester': _formData.firstEnrollmentSemester,
            'UndergraduateCGPALevel': _formData.undergraduateCGPALevel,
          };
          _uploadNidFiles();
          _uploadProfilePicFiles();
          _uploadSignatureFiles();
          _uploadSealFiles();
          final responseBody = await ApiService.updateUserDetailsAdminMode(int.parse(widget.userID), updatedUserData);
          if (responseBody['statuscode'] == 200) {
            // Handle success
            print('User updated successfully');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: "Updated successfull",
              desc: "Username: ${_formData.username}",
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
            print('Error updatin user: ${responseBody['message']}');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Error updating this user: ${responseBody['message']}",
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
        // making Save_changes button disabled after clicking on it
        setState(() {
          initialUserDataChange = false;
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
    final pageTitle = 'Verified User Details - ID: ${widget.userID.isEmpty ? 'Invalid User-ID' : widget.userID}';

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
                                              title: 'Username :',
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
                                                title: _formData.username,
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
                                                initialValue: _formData.username,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.username = value ?? ''),
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
                                                    initialUserDataChange = true;
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
                                                title: _formData.rolename,
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
                                                name: 'rolename',
                                                decoration: const InputDecoration(
                                                  hintText: 'rolename',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                hint: const Text('Select'),
                                                initialValue: _formData.rolename,
                                                validator: FormBuilderValidators.required(),
                                                items: ['Admin', 'Researcher', 'Reviewer', 'Teacher', 'Student'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onSaved: (value) => (_formData.rolename = value ?? ''),
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
                                                    initialUserDataChange = true;
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
                                                    initialUserDataChange = true;
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
                                                    initialUserDataChange = true;
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
                                              title: 'FullName (Bangla) :',
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
                                      visible: !editfullnamebangla,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.fullNameBangla,
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
                                      visible: editfullnamebangla,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'FullNameBangla',
                                                decoration: const InputDecoration(
                                                  hintText: 'FullName (Bangla)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.fullNameBangla,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.fullNameBangla = value ?? ''),
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
                                                  editfullnamebangla = !editfullnamebangla; // Toggle edit mode
                                                  if (!editfullnamebangla) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editfullnamebangla
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editfullnamebangla ? "Save" : "Edit"),
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
                                              title: 'Gender :',
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
                                      visible: !editgender,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.gender,
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
                                      visible: editgender,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderDropdown(
                                                name: 'gender',
                                                decoration: const InputDecoration(
                                                  hintText: 'gender',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                hint: const Text('Select'),
                                                initialValue: _formData.gender,
                                                validator: FormBuilderValidators.required(),
                                                items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onSaved: (value) => (_formData.gender = value ?? ''),
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
                                                  editgender = !editgender; // Toggle edit mode
                                                  if (!editgender) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editgender
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editgender ? "Save" : "Edit"),
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
                                              title: 'Date of Birth :',
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
                                      visible: !editdob,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: DateFormat("MMMM d, yyyy").format(DateTime.parse(_formData.dateOfBirth)),
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
                                      visible: editdob,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderDateTimePicker(
                                                name: 'dateOfBirth',
                                                inputType: InputType.date,
                                                decoration: const InputDecoration(
                                                  hintText: 'dateOfBirth',
                                                  border: OutlineInputBorder(),
                                                ),
                                                // ignore: unnecessary_null_comparison
                                                initialValue: _formData.dateOfBirth != null && _formData.dateOfBirth!.isNotEmpty ? DateTime.parse(_formData.dateOfBirth) : null,
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
                                                  editdob = !editdob; // Toggle edit mode
                                                  if (!editdob) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editdob
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editdob ? "Save" : "Edit"),
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
                                                validator: FormBuilderValidators.compose([
                                                  FormBuilderValidators.required(),
                                                  FormBuilderValidators.email(),
                                                ]),
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
                                                    initialUserDataChange = true;
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
                                                    initialUserDataChange = true;
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
                                              title: 'Position (English) :',
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
                                      visible: !editpositionenglish,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.positionEnglish,
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
                                      visible: editpositionenglish,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'positionenglish',
                                                decoration: const InputDecoration(
                                                  hintText: 'Position (English)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.positionEnglish,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.positionEnglish = value ?? ''),
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
                                                  editpositionenglish = !editpositionenglish; // Toggle edit mode
                                                  if (!editpositionenglish) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editpositionenglish
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editpositionenglish ? "Save" : "Edit"),
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
                                              title: 'Position (Bangla) :',
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
                                      visible: !editpositionbangla,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.positionBangla,
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
                                      visible: editpositionbangla,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'positionbangla',
                                                decoration: const InputDecoration(
                                                  hintText: '(Bangla)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.positionBangla,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.positionBangla = value ?? ''),
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
                                                  editpositionbangla = !editpositionbangla; // Toggle edit mode
                                                  if (!editpositionbangla) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editpositionbangla
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editpositionbangla ? "Save" : "Edit"),
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
                                              title: 'Position Held Since :',
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
                                      visible: !editpositionheldsince,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.positionHeldSince,
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
                                      visible: editpositionheldsince,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'positionheldsince',
                                                decoration: const InputDecoration(
                                                  hintText: '(Year only)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.positionHeldSince,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.positionHeldSince = value ?? ''),
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
                                                  editpositionheldsince = !editpositionheldsince; // Toggle edit mode
                                                  if (!editpositionheldsince) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editpositionheldsince
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editpositionheldsince ? "Save" : "Edit"),
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
                                              title: 'Department Name :',
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
                                      visible: !editdepartmentname,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.departmentName,
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
                                      visible: editdepartmentname,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderDropdown(
                                                name: 'departmentname',
                                                decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hoverColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  hintText: 'Select',
                                                ),
                                                focusColor: Colors.transparent,
                                                validator: FormBuilderValidators.required(),
                                                initialValue: _formData.departmentName,
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                items: [
                                                  'Department of Computer Science and Information Technology',
                                                  'Department of Computer and Communication Engineering',
                                                  'Department of Electrical and Electronics Engineering',
                                                  'Department of Physics and Mechanical Engineering',
                                                  'Department of Mathematics',
                                                  'Department of Marine Fisheries and Oceanography',
                                                  'Department of Genetics and Animal Breeding',
                                                  'Department of Fisheries Technology',
                                                  'Department of Human Nutrition and Dietetics',
                                                  'Department of Biochemistry and Food Analysis',
                                                  'Department of Environmental Sanitation',
                                                  'Department of Food Microbiology',
                                                  'Department of Food Technology and Engineering',
                                                  'Department of Post Harvest Technology and Marketing',
                                                  'Department of Dairy Science',
                                                  'Department of Animal Products and By-Products Technology',
                                                  'Department of Basic Science',
                                                  'Department of General Animal Science and Animal Nutrition',
                                                  'Department of Microbiology and Public Health',
                                                  'Department of Pathology and Parasitology',
                                                  'Department of Physiology and Pharmacology',
                                                  'Department of Poultry Science',
                                                  'Department of Disaster Risk Management',
                                                  'Department of Law and Land Administration',
                                                  'Department of Anatomy and Histology',
                                                  'Department of Fisheries Biology and Genetics',
                                                  'Department of Aquaculture',
                                                  'Department of Marketing',
                                                  'Department of Management Studies',
                                                  'Department of Language and Communication',
                                                  'Department of Finance and Banking',
                                                  'Department of Economics and Sociology',
                                                  'Department of Agricultural Botany',
                                                  'Department of Accounting and Information Systems',
                                                  'Department of Fisheries Management',
                                                  'Department of Agricultural Chemistry',
                                                  'Department of Disaster Resilience and Engineering',
                                                  'Department of Medicine Surgery and Obstetrics',
                                                  'Department of Agricultural Engineering',
                                                  'Department of Emergency Management',
                                                  'Department of Agricultural Extension and Rural Development',
                                                  'Department of Environmental Science',
                                                  'Department of Geo Information Science and Earth Observation',
                                                  'Department of Agroforestry',
                                                  'Department of Agronomy',
                                                  'Department of Animal Science',
                                                  'Department of Community Health and Hygiene',
                                                  'Department of Biotechnology',
                                                  'Department of Entomology',
                                                  'Department of Genetics and Plant Breeding',
                                                  'Department of Horticulture',
                                                  'Department of Plant Pathology',
                                                  'Department of Soil Science',
                                                  'Department of Statistics',
                                                  'Department of Climate Smart Agricultured',
                                                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onChanged: (value) => (_formData.departmentName = value ?? ''),
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
                                                  editdepartmentname = !editdepartmentname; // Toggle edit mode
                                                  if (!editdepartmentname) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editdepartmentname
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editdepartmentname ? "Save" : "Edit"),
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
                                              title: 'Faculty Name:',
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
                                                  hintText: 'Select',
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
                                                    initialUserDataChange = true;
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
                                              title: 'Institute Name :',
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
                                      visible: !editinstituteName,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.instituteName,
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
                                      visible: editinstituteName,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderDropdown(
                                                name: 'instituteName',
                                                decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hoverColor: Colors.transparent,
                                                  focusColor: Colors.transparent,
                                                  hintText: 'Select',
                                                ),
                                                focusColor: Colors.transparent,
                                                validator: FormBuilderValidators.required(),
                                                initialValue: _formData.instituteName,
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                items: [
                                                  'Patuakhali Science & Technology University (PSTU)',
                                                ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                                onChanged: (value) => (_formData.instituteName = value ?? ''),
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
                                                  editinstituteName = !editinstituteName; // Toggle edit mode
                                                  if (!editinstituteName) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editinstituteName
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editinstituteName ? "Save" : "Edit"),
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
                                              title: 'Institute Location (Office Address):',
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
                                      visible: !editistitutelocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.instituteLocation,
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
                                      visible: editistitutelocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'instituteLocation',
                                                maxLines: null,
                                                decoration: const InputDecoration(
                                                  hintText: '(Office Address)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.instituteLocation,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.instituteLocation = value ?? ''),
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
                                                  editistitutelocation = !editistitutelocation; // Toggle edit mode
                                                  if (!editistitutelocation) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editistitutelocation
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editistitutelocation ? "Save" : "Edit"),
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
                                              title: 'Institute Email :',
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
                                      visible: !editinstituteemail,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.instituteEmail,
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
                                      visible: editinstituteemail,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'instituteEmail',
                                                decoration: const InputDecoration(
                                                  hintText: '@pstu.ac.bd',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.instituteEmail,
                                                validator: FormBuilderValidators.compose([
                                                  FormBuilderValidators.required(),
                                                  FormBuilderValidators.email(),
                                                ]),
                                                onSaved: (value) => (_formData.instituteEmail = value ?? ''),
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
                                                  editinstituteemail = !editinstituteemail; // Toggle edit mode
                                                  if (!editinstituteemail) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editinstituteemail
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editinstituteemail ? "Save" : "Edit"),
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
                                              title: 'Salary Scale :',
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
                                      visible: !editsalaryscale,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.salaryScale,
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
                                      visible: editsalaryscale,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'salaryScale',
                                                decoration: const InputDecoration(
                                                  hintText: '(Range of Tk.)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.salaryScale,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.salaryScale = value ?? ''),
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
                                                  editsalaryscale = !editsalaryscale; // Toggle edit mode
                                                  if (!editsalaryscale) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editsalaryscale
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editsalaryscale ? "Save" : "Edit"),
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
                                              title: 'Basic Pay :',
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
                                      visible: !editbasicpay,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.basicPay.toString(),
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
                                      visible: editbasicpay,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'basicPay',
                                                decoration: const InputDecoration(
                                                  hintText: '(Tk.)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.basicPay.toString(),
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.basicPay = double.parse(value ?? '0.0')),
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
                                                  editbasicpay = !editbasicpay; // Toggle edit mode
                                                  if (!editbasicpay) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editbasicpay
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editbasicpay ? "Save" : "Edit"),
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
                                              title: 'Area of Expertise :',
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
                                      visible: !editAreaOfExpertise,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.areaOfExpertise,
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
                                      visible: editAreaOfExpertise,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'areaOfExpertise',
                                                maxLines: null,
                                                decoration: const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.areaOfExpertise,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.areaOfExpertise = value ?? ''),
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
                                                  editAreaOfExpertise = !editAreaOfExpertise; // Toggle edit mode
                                                  if (!editAreaOfExpertise) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editAreaOfExpertise
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editAreaOfExpertise ? "Save" : "Edit"),
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
                                              title: 'Experience in Research :',
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
                                      visible: !editExperienceInResearch,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.experienceInResearch.toString(),
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
                                      visible: editExperienceInResearch,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'areaOfExpertise',
                                                decoration: const InputDecoration(
                                                  hintText: "(No of Years)",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.experienceInResearch.toString(),
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.experienceInResearch = int.parse(value ?? '0')),
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
                                                  editExperienceInResearch = !editExperienceInResearch; // Toggle edit mode
                                                  if (!editExperienceInResearch) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editExperienceInResearch
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editExperienceInResearch ? "Save" : "Edit"),
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
                                              title: 'Teaching Experience:',
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
                                      visible: !editTeaching,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.teaching.toString(),
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
                                      visible: editTeaching,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'teachingExperience',
                                                decoration: const InputDecoration(
                                                  hintText: "(No of Years)",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.teaching.toString(),
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.teaching = int.parse(value ?? '0')),
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
                                                  editTeaching = !editTeaching; // Toggle edit mode
                                                  if (!editTeaching) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editTeaching
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editTeaching ? "Save" : "Edit"),
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
                                              title: 'Total Number of Complete Projects :',
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
                                      visible: !editTotalNumberOfCompleteProjects,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.totalNumberOfCompleteProjects.toString(),
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
                                      visible: editTotalNumberOfCompleteProjects,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'totalNumberOfCompleteProjects',
                                                decoration: const InputDecoration(
                                                  hintText: "(No of Projects)",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.totalNumberOfCompleteProjects.toString(),
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.totalNumberOfCompleteProjects = int.parse(value ?? '0')),
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
                                                  editTotalNumberOfCompleteProjects = !editTotalNumberOfCompleteProjects; // Toggle edit mode
                                                  if (!editTotalNumberOfCompleteProjects) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editTotalNumberOfCompleteProjects
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editTotalNumberOfCompleteProjects ? "Save" : "Edit"),
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
                                              title: 'Total Number of Complete Publications:',
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
                                      visible: !editTotalNumberOfCompletePublications,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.totalNumberOfCompletePublications.toString(),
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
                                      visible: editTotalNumberOfCompletePublications,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'totalNumberOfCompletePublications',
                                                decoration: const InputDecoration(
                                                  hintText: "(No of Publications)",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.totalNumberOfCompletePublications.toString(),
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.totalNumberOfCompletePublications = int.parse(value ?? '0')),
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
                                                  editTotalNumberOfCompletePublications = !editTotalNumberOfCompletePublications; // Toggle edit mode
                                                  if (!editTotalNumberOfCompletePublications) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editTotalNumberOfCompletePublications
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editTotalNumberOfCompletePublications ? "Save" : "Edit"),
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
                                              title: 'Ongoing Projects :',
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
                                      visible: !editOngoingProjects,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.ongoingProjects.toString(),
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
                                      visible: editOngoingProjects,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'ongoingProjects',
                                                decoration: const InputDecoration(
                                                  hintText: "(No of Running Projects)",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.ongoingProjects.toString(),
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.ongoingProjects = int.parse(value ?? '0')),
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
                                                  editOngoingProjects = !editOngoingProjects; // Toggle edit mode
                                                  if (!editOngoingProjects) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editOngoingProjects
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editOngoingProjects ? "Save" : "Edit"),
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
                                              title: 'References of Latest Publications :',
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
                                      visible: !editReferencesOfLatestPublications,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.referencesOfLatestPublications,
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
                                      visible: editReferencesOfLatestPublications,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                maxLines: null,
                                                name: 'referencesOfLatestPublications',
                                                decoration: const InputDecoration(
                                                  hintText: 'References',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.referencesOfLatestPublications,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.referencesOfLatestPublications = value ?? ''),
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
                                                  editReferencesOfLatestPublications = !editReferencesOfLatestPublications; // Toggle edit mode
                                                  if (!editReferencesOfLatestPublications) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editReferencesOfLatestPublications
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editReferencesOfLatestPublications ? "Save" : "Edit"),
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
                                              title: 'Nid No:',
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
                                      visible: !editNid,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.nid,
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
                                      visible: editNid,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'nid',
                                                decoration: const InputDecoration(
                                                  hintText: 'Nid No',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.nid,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.nid = value ?? ''),
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
                                                  editNid = !editNid; // Toggle edit mode
                                                  if (!editNid) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editNid
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editNid ? "Save" : "Edit"),
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
                                              title: 'Nid Photo :',
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
                                      visible: !editNidLocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                                child: Stack(
                                                  children: [
                                                    FutureBuilder<String>(
                                                      future: _formData.nidLocation.isNotEmpty
                                                          ? ApiService.downloadFile('nid/download', _formData.nidLocation)
                                                          : Future.value(""), // Check if value is not empty before making the API call
                                                      builder: (context, snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return const CircularProgressIndicator();
                                                        } else if (snapshot.hasError) {
                                                          return Text('Error: ${snapshot.error}');
                                                        } else {
                                                          return Image.memory(
                                                            base64Decode(snapshot.data!), // Convert base64 string to image bytes
                                                            fit: BoxFit.cover, // Adjust image to cover the entire space
                                                            // width: 120, // Adjust width as needed
                                                            height: 50, // Adjust height as needed
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editNidLocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderFilePicker(
                                                name: 'nidphoto',
                                                // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
                                                allowMultiple: false,
                                                maxFiles: 1,
                                                type: FileType.any,
                                                previewImages: true,
                                                decoration: const InputDecoration(
                                                  hintText: 'nidphoto',
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
                                                onChanged: _onNidFileSelected,
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
                                                  editNidLocation = !editNidLocation; // Toggle edit mode
                                                  if (!editNidLocation) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editNidLocation
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editNidLocation ? "Save" : "Edit"),
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
                                              title: 'Present Address:',
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
                                      visible: !editPresentAddress,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.presentAddress,
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
                                      visible: editPresentAddress,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'presentAddress',
                                                decoration: const InputDecoration(
                                                  hintText: "Present Address",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.presentAddress,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.presentAddress = value ?? ''),
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
                                                  editPresentAddress = !editPresentAddress; // Toggle edit mode
                                                  if (!editPresentAddress) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editPresentAddress
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editPresentAddress ? "Save" : "Edit"),
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
                                              title: 'Permanent Address:',
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
                                      visible: !editPermanentAddress,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.permanentAddress,
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
                                      visible: editPermanentAddress,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'permanentAddress',
                                                decoration: const InputDecoration(
                                                  hintText: "Permanent Address",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.permanentAddress,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.permanentAddress = value ?? ''),
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
                                                  editPermanentAddress = !editPermanentAddress; // Toggle edit mode
                                                  if (!editPermanentAddress) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editPermanentAddress
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editPermanentAddress ? "Save" : "Edit"),
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
                                              title: 'Profile Picture:',
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
                                      visible: !editProfilePicLocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                                child: Stack(
                                                  children: [
                                                    FutureBuilder<String>(
                                                      future: _formData.profilePicLocation.isNotEmpty
                                                          ? ApiService.downloadFile('profile-pic/download', _formData.profilePicLocation)
                                                          : Future.value(""), // Check if value is not empty before making the API call
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
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editProfilePicLocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderFilePicker(
                                                name: 'profilePicLocation',
                                                // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
                                                allowMultiple: false,
                                                maxFiles: 1,
                                                type: FileType.any,
                                                previewImages: true,
                                                decoration: const InputDecoration(
                                                  hintText: 'profilePicLocation',
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
                                                  editProfilePicLocation = !editProfilePicLocation; // Toggle edit mode
                                                  if (!editProfilePicLocation) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editProfilePicLocation
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editProfilePicLocation ? "Save" : "Edit"),
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
                                              title: 'Signature Photo :',
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
                                      visible: !editSignatureLocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                                child: Stack(
                                                  children: [
                                                    FutureBuilder<String>(
                                                      future: _formData.signatureLocation.isNotEmpty
                                                          ? ApiService.downloadFile('signature/download', _formData.signatureLocation)
                                                          : Future.value(""), // Check if value is not empty before making the API call
                                                      builder: (context, snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return const CircularProgressIndicator();
                                                        } else if (snapshot.hasError) {
                                                          return Text('Error: ${snapshot.error}');
                                                        } else {
                                                          return Image.memory(
                                                            base64Decode(snapshot.data!), // Convert base64 string to image bytes
                                                            fit: BoxFit.cover, // Adjust image to cover the entire space
                                                            // width: 120, // Adjust width as needed
                                                            height: 50, // Adjust height as needed
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editSignatureLocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderFilePicker(
                                                name: 'signatureLocation',
                                                // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
                                                allowMultiple: false,
                                                maxFiles: 1,
                                                type: FileType.any,
                                                previewImages: true,
                                                decoration: const InputDecoration(
                                                  hintText: 'signatureLocation',
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
                                                onChanged: _onSignatureFileSelected,
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
                                                  editSignatureLocation = !editSignatureLocation; // Toggle edit mode
                                                  if (!editSignatureLocation) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editSignatureLocation
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editSignatureLocation ? "Save" : "Edit"),
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
                                              title: 'Seal Photo :',
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
                                      visible: !editSealLocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                                child: Stack(
                                                  children: [
                                                    FutureBuilder<String>(
                                                      future: _formData.sealLocation.isNotEmpty
                                                          ? ApiService.downloadFile('seal/download', _formData.sealLocation)
                                                          : Future.value(""), // Check if value is not empty before making the API call
                                                      builder: (context, snapshot) {
                                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                                          return const CircularProgressIndicator();
                                                        } else if (snapshot.hasError) {
                                                          return Text('Error: ${snapshot.error}');
                                                        } else {
                                                          return Image.memory(
                                                            base64Decode(snapshot.data!), // Convert base64 string to image bytes
                                                            fit: BoxFit.cover, // Adjust image to cover the entire space
                                                            // width: 120, // Adjust width as needed
                                                            height: 50, // Adjust height as needed
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: editSealLocation,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderFilePicker(
                                                name: 'sealLocation',
                                                // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
                                                allowMultiple: false,
                                                maxFiles: 1,
                                                type: FileType.any,
                                                previewImages: true,
                                                decoration: const InputDecoration(
                                                  hintText: 'sealLocation',
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
                                                onChanged: _onSealFileSelected,
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
                                                  editSealLocation = !editSealLocation; // Toggle edit mode
                                                  if (!editSealLocation) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editSealLocation
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editSealLocation ? "Save" : "Edit"),
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
                                              title: 'Highest Academic Qualification:',
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
                                      visible: !editHighestAcademicQualification,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.highestAcademicQualification,
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
                                      visible: editHighestAcademicQualification,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'highestAcademicQualification',
                                                decoration: const InputDecoration(
                                                  hintText: "(eg. B.Sc. in Computer Science)",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.highestAcademicQualification,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.highestAcademicQualification = value ?? ''),
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
                                                  editHighestAcademicQualification = !editHighestAcademicQualification; // Toggle edit mode
                                                  if (!editHighestAcademicQualification) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editHighestAcademicQualification
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editHighestAcademicQualification ? "Save" : "Edit"),
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
                                              title: 'Highest Academic Qualification University :',
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
                                      visible: !editHighestAcademicQualificationUniversity,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.highestAcademicQualificationUniversity.toString(),
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
                                      visible: editHighestAcademicQualificationUniversity,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'highestAcademicQualificationUniversity',
                                                decoration: const InputDecoration(
                                                  hintText: "(University Name)",
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.highestAcademicQualificationUniversity,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.highestAcademicQualificationUniversity = value ?? ''),
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
                                                  editHighestAcademicQualificationUniversity = !editHighestAcademicQualificationUniversity; // Toggle edit mode
                                                  if (!editHighestAcademicQualificationUniversity) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editHighestAcademicQualificationUniversity
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editHighestAcademicQualificationUniversity ? "Save" : "Edit"),
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
                                              title: 'Highest Academic Qualification Country :',
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
                                      visible: !editHighestAcademicQualificationCountry,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.highestAcademicQualificationCountry,
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
                                      visible: editHighestAcademicQualificationCountry,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                maxLines: null,
                                                name: 'highestAcademicQualificationCountry',
                                                decoration: const InputDecoration(
                                                  hintText: '(Country Name)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.highestAcademicQualificationCountry,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.highestAcademicQualificationCountry = value ?? ''),
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
                                                  editHighestAcademicQualificationCountry = !editHighestAcademicQualificationCountry; // Toggle edit mode
                                                  if (!editHighestAcademicQualificationCountry) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editHighestAcademicQualificationCountry
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editHighestAcademicQualificationCountry ? "Save" : "Edit"),
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
                                              title: 'Highest Academic Qualification Year:',
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
                                      visible: !editHighestAcademicQualificationYear,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.highestAcademicQualificationYear.toString(),
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
                                      visible: editHighestAcademicQualificationYear,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                maxLines: null,
                                                name: 'highestAcademicQualificationYear',
                                                decoration: const InputDecoration(
                                                  hintText: '(Year)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.highestAcademicQualificationYear.toString(),
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.highestAcademicQualificationYear = int.parse(value ?? '0')),
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
                                                  editHighestAcademicQualificationYear = !editHighestAcademicQualificationYear; // Toggle edit mode
                                                  if (!editHighestAcademicQualificationYear) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editHighestAcademicQualificationYear
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editHighestAcademicQualificationYear ? "Save" : "Edit"),
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
                                              title: 'Student ID :',
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
                                      visible: !editStudentID,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.studentID.toString(),
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
                                      visible: editStudentID,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'studentID',
                                                decoration: const InputDecoration(
                                                  hintText: 'Enter Student ID',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.studentID.toString(),
                                                // validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.studentID = int.parse(value ?? '0')),
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
                                                  editStudentID = !editStudentID; // Toggle edit mode
                                                  if (!editStudentID) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editStudentID
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editStudentID ? "Save" : "Edit"),
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
                                              title: 'Student Reg.No. :',
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
                                      visible: !editStudentRegNo,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.studentRegNo,
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
                                      visible: editStudentRegNo,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'regNo',
                                                decoration: const InputDecoration(
                                                  hintText: 'Reg. No.',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.studentRegNo,
                                                // validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.studentRegNo = value ?? ''),
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
                                                  editStudentRegNo = !editStudentRegNo; // Toggle edit mode
                                                  if (!editStudentRegNo) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editStudentRegNo
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editStudentRegNo ? "Save" : "Edit"),
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
                                              title: 'First Enrollment Semester :',
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
                                      visible: !editFirstEnrollmentSemester,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.firstEnrollmentSemester,
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
                                      visible: editFirstEnrollmentSemester,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'firstEnrollmentSemester',
                                                decoration: const InputDecoration(
                                                  hintText: '(eg. Semester - 1)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.firstEnrollmentSemester,
                                                // validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.firstEnrollmentSemester = value ?? ''),
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
                                                  editFirstEnrollmentSemester = !editFirstEnrollmentSemester; // Toggle edit mode
                                                  if (!editFirstEnrollmentSemester) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editFirstEnrollmentSemester
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editFirstEnrollmentSemester ? "Save" : "Edit"),
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
                                              title: 'Undergraduate CGPA Level :',
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
                                      visible: !editUndergraduateCGPALevel,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CardHeader(
                                                title: _formData.undergraduateCGPALevel,
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
                                      visible: editUndergraduateCGPALevel,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              FormBuilderTextField(
                                                name: 'undergraduateCGPALevel',
                                                decoration: const InputDecoration(
                                                  hintText: '(eg. 4.0)',
                                                  border: OutlineInputBorder(),
                                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                                ),
                                                initialValue: _formData.undergraduateCGPALevel,
                                                validator: FormBuilderValidators.required(),
                                                onSaved: (value) => (_formData.undergraduateCGPALevel = value ?? ''),
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
                                                  editUndergraduateCGPALevel = !editUndergraduateCGPALevel; // Toggle edit mode
                                                  if (!editUndergraduateCGPALevel) {
                                                    // Save changes if transitioning from edit mode to view mode
                                                    _formKey.currentState!.validate();
                                                    _formKey.currentState!.save();
                                                    // Change pending user data change to true for re-rendering the Save_changes button
                                                    initialUserDataChange = true;
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
                                                      editUndergraduateCGPALevel
                                                          ? Icons.save_outlined // Change icon based on edit mode
                                                          : Icons.mode_edit_outline_outlined,
                                                      size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                    ),
                                                  ),
                                                  Text(editUndergraduateCGPALevel ? "Save" : "Edit"),
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.verifiedusers),
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
                                visible: initialUserDataChange,
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
  String userID = '';
  String roleID = '';
  String rolename = '';

  String email = '';
  String phone = '';
  String firstName = '';
  String lastName = '';
  String facultyName = '';

  String username = '';
  String fullNameBangla = '';
  String positionEnglish = '';
  String positionBangla = '';
  String positionHeldSince = '';
  String gender = '';
  String dateOfBirth = '';
  String nid = '';
  String nidLocation = '';
  String departmentName = '';
  String instituteName = '';
  String instituteLocation = '';
  String instituteEmail = '';
  String presentAddress = '';
  String permanentAddress = '';
  String profilePicLocation = '';
  String signatureLocation = '';
  String sealLocation = '';

  String salaryScale = '';
  double basicPay = 0.0;
  String highestAcademicQualification = '';
  String highestAcademicQualificationUniversity = '';
  String highestAcademicQualificationCountry = '';
  int highestAcademicQualificationYear = 0;
  String areaOfExpertise = '';
  String referencesOfLatestPublications = '';
  int experienceInResearch = 0;
  int teaching = 0;
  int totalNumberOfCompleteProjects = 0;
  int totalNumberOfCompletePublications = 0;
  int ongoingProjects = 0;

  int studentID = 0;
  String studentRegNo = '';
  String firstEnrollmentSemester = '';
  String undergraduateCGPALevel = '';
}
