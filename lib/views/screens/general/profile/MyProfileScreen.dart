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

      print(userDetails['user']['PresentAddress']);

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
      _formData.nidLocation = userDetails['user']['NidLocation'] ?? 'defaultnid.png';
      _formData.facultyName = userDetails['user']['FacultyName'] ?? '';
      _formData.departmentName = userDetails['user']['DepartmentName'] ?? '';
      _formData.instituteName = userDetails['user']['InstituteName'] ?? '';
      _formData.instituteLocation = userDetails['user']['InstituteLocation'] ?? '';
      _formData.instituteEmail = userDetails['user']['InstituteEmail'] ?? '';
      print(" Institute Email: ${_formData.instituteEmail}");

      _formData.profilePicLocation = userDetails['user']['ProfilePicLocation'] ?? 'defaultprofilepic.png';
      print(" presentAddress: ${_formData.presentAddress}");
      _formData.signatureLocation = userDetails['user']['SignatureLocation'] ?? 'defaultsignature.png';
      print(" Signature Location: ${_formData.signatureLocation}");
      _formData.sealLocation = userDetails['user']['SealLocation'] ?? 'defaultseal.png';
      _formData.salaryScale = userDetails['user']['SalaryScale'] ?? '';
      _formData.basicPay = userDetails['user']['BasicPay'] ?? 0.0;
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
      _formData.userId = userDetails['user']['UserID'] ?? 0;
      _formData.rolename = getRoleName(userDetails['user']['RoleID']);
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");

      _formData.studentID = userDetails['user']['StudentID'] ?? 0;
      print("xxxxxxxx                               xxxxxxxxxxxxx");

      _formData.studentRegNo = userDetails['user']['StudentRegNo'] ?? '';

      _formData.firstEnrollmentSemester = userDetails['user']['FirstEnrollmentSemester'] ?? '';

      _formData.undergraduateCGPALevel = userDetails['user']['UndergraduateCGPALevel'] ?? '';

      print("/////////////////////////////");
    });

    // final profilePic = await ApiService.downloadFile(_formData.profilePicLocation);
    print("Student ID: ${_formData.studentID}");

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
      _uploadSignatureFiles();
      _uploadSealFiles();
      _uploadNidFiles();

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
          'FacultyName': _formData.facultyName,
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
          FormBuilderFilePicker(
            name: 'profilePicLocation',
            // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
            allowMultiple: false,
            maxFiles: 1,
            type: FileType.any,
            previewImages: true,
            decoration: const InputDecoration(
              labelText: 'Select Profile Pic',
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
              // validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.fullNameBangla = value ?? ''),
            ),
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.positionEnglish = value ?? ''),
              ),
            ),
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.positionBangla = value ?? ''),
              ),
            ),
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.positionHeldSince = value ?? ''),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderDropdown(
              name: 'gender',
              decoration: const InputDecoration(
                labelText: 'Gender',
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
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
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
              // validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.nid = value ?? ''),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
            child: Stack(
              children: [
                FutureBuilder<String>(
                  future:
                      _formData.nidLocation.isNotEmpty ? ApiService.downloadFile('nid/download', _formData.nidLocation) : Future.value(""), // Check if value is not empty before making the API call
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
          FormBuilderFilePicker(
            name: 'nidphoto',
            // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
            allowMultiple: false,
            maxFiles: 1,
            type: FileType.any,
            previewImages: true,
            decoration: const InputDecoration(
              labelText: 'Select Nid File',
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
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderDropdown(
              name: 'facultyName',
              decoration: const InputDecoration(
                labelText: 'Faculty Name',
                hintText: 'Faculty Name',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              hint: const Text('Select'),
              initialValue: _formData.facultyName,
              validator: FormBuilderValidators.required(),
              items: [
                '',
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
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderDropdown(
              name: 'departmentname',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                labelText: 'Department Name',
                hintText: 'Department Name',
              ),
              focusColor: Colors.transparent,
              validator: FormBuilderValidators.required(),
              initialValue: _formData.departmentName,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              items: [
                '',
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
              onSaved: (value) => (_formData.departmentName = value ?? ''),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
            child: FormBuilderDropdown(
              name: 'instituteName',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                labelText: 'Institute Name',
                hintText: 'Institute Name',
              ),
              focusColor: Colors.transparent,
              validator: FormBuilderValidators.required(),
              initialValue: _formData.instituteName,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              items: const [
                DropdownMenuItem(
                  value: '',
                  child: Text(''),
                ),
                DropdownMenuItem(
                  value: 'Patuakhali Science & Technology University (PSTU)',
                  child: Text('Patuakhali Science & Technology University (PSTU)'),
                ),
                // Add more DropdownMenuItem as needed with unique values
              ],
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
              // validator: FormBuilderValidators.required(),
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
              // validator: FormBuilderValidators.required(),
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
              // validator: FormBuilderValidators.required(),
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
              // validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.permanentAddress = value ?? ''),
            ),
          ),

          Visibility(
            visible: _formData.rolename != 'Student',
            child: Container(
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
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: FormBuilderFilePicker(
              name: 'signatureLocation',
              // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
              allowMultiple: false,
              maxFiles: 1,
              type: FileType.any,
              previewImages: true,
              decoration: const InputDecoration(
                labelText: 'Select Signature File',
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
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Container(
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
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: FormBuilderFilePicker(
              name: 'sealLocation',
              // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
              allowMultiple: false,
              maxFiles: 1,
              type: FileType.any,
              previewImages: true,
              decoration: const InputDecoration(
                labelText: 'Select Seal File',
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
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
              child: FormBuilderTextField(
                name: 'salaryScale',
                decoration: const InputDecoration(
                  labelText: 'Salary Scale',
                  hintText: 'salaryScale',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                initialValue: _formData.salaryScale,
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.salaryScale = value ?? ''),
              ),
            ),
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
              child: FormBuilderTextField(
                name: 'basicpay',
                decoration: const InputDecoration(
                  labelText: 'Basic Pay',
                  hintText: 'Basic Pay',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                initialValue: _formData.basicPay.toString(),
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.basicPay = double.parse(value ?? '0.0')),
              ),
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
              // validator: FormBuilderValidators.required(),
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
              // validator: FormBuilderValidators.required(),
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
              // validator: FormBuilderValidators.required(),
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
              // validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.highestAcademicQualificationYear = int.parse(value ?? '0')),
            ),
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.areaOfExpertise = value ?? ''),
              ),
            ),
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.experienceInResearch = int.parse(value ?? '0')),
              ),
            ),
          ),
          Visibility(
            visible: _formData.rolename != 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.teaching = int.parse(value ?? '0')),
              ),
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
              // validator: FormBuilderValidators.required(),
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
              // validator: FormBuilderValidators.required(),
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
              // validator: FormBuilderValidators.required(),
              onSaved: (value) => (_formData.ongoingProjects = int.parse(value ?? '0')),
            ),
          ),
          Visibility(
            visible: _formData.rolename == 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.studentID = int.parse(value ?? '0')),
              ),
            ),
          ),
          Visibility(
            visible: _formData.rolename == 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.studentRegNo = value ?? ''),
              ),
            ),
          ),
          Visibility(
            visible: _formData.rolename == 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.firstEnrollmentSemester = value ?? ''),
              ),
            ),
          ),
          Visibility(
            visible: _formData.rolename == 'Student',
            child: Padding(
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
                // validator: FormBuilderValidators.required(),
                onSaved: (value) => (_formData.undergraduateCGPALevel = value ?? ''),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
          //   child: FormBuilderDropdown(
          //     name: 'roleId',
          //     decoration: const InputDecoration(
          //       labelText: 'Role',
          //       hintText: 'roleId',
          //       border: OutlineInputBorder(),
          //       floatingLabelBehavior: FloatingLabelBehavior.always,
          //     ),
          //     hint: const Text('Select'),
          //     initialValue: _formData.rolename,
          //     validator: FormBuilderValidators.required(),
          //     items: ['Admin', 'Researcher', 'Reviewer', 'Teacher', 'Student'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          //     onSaved: (value) => (_formData.rolename = value ?? ''),
          //   ),
          // ),
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
  String facultyName = '';
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
