// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({Key? key}) : super(key: key);

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();
  final List<Widget> ganttfields = [];
  final List<Widget> budgetsummaryfields = [];

  Map<String, dynamic> ganttFormData = {};
  Map<String, dynamic> budgetFormData = {};
  late Future<List<User>> _usersFuture;
  late Future<List<User>> _studentUsersFuture;

  void _saveGanttFormData() {
    _formKey.currentState!.save();
    // Save the main work activity
    FormData2 mainFormData = FormData2(
        workActivity: _formKey.currentState!.fields['work_activity']!.value as String,
        activityStatus: _formKey.currentState!.fields['activity_status']!.value as String,
        duration: _formKey.currentState!.fields['duration']!.value.toString());

    List<FormData2> ganttFormDataList = [];
    ganttFormDataList.add(mainFormData);
    // Save the dynamically added GanttNewTextField data
    for (var i = 0; i < ganttfields.length; i++) {
      final fieldState = (ganttfields[i].key as GlobalKey<_GanttNewTextFieldState>).currentState!;
      final formData2 = fieldState.getFormData();
      ganttFormDataList.add(formData2);
    }
    Map<String, dynamic> consolidatedData = {
      'formDatas': ganttFormDataList.map((data) => data.toJson()).toList(),
    };
    ganttFormData = consolidatedData;
    print(ganttFormData);
  }

  void _saveBudgetFormData() {
    _formKey.currentState!.save();
    // Save the main work activity
    FormData3 mainFormData = FormData3(
        serialNo: _formKey.currentState!.fields['sl_no']!.value as String,
        item: _formKey.currentState!.fields['item']!.value as String,
        unitPrice: _formKey.currentState!.fields['unit_price']!.value.toString(),
        quantity: _formKey.currentState!.fields['quantity']!.value.toString(),
        totalCostTk: _formKey.currentState!.fields['total_cost_tk']!.value.toString());

    List<FormData3> budgetFormDataList = [];
    budgetFormDataList.add(mainFormData);
    // Save the dynamically added GanttNewTextField data
    for (var i = 0; i < budgetsummaryfields.length; i++) {
      final fieldState = (budgetsummaryfields[i].key as GlobalKey<_BudgetSummaryFieldsNewTextFieldState>).currentState!;
      final formData3 = fieldState.getFormData3();
      budgetFormDataList.add(formData3);
    }
    Map<String, dynamic> consolidatedData = {
      'formDatas': budgetFormDataList.map((data) => data.toJson()).toList(),
    };
    budgetFormData = consolidatedData;
    print(budgetFormData);
  }

  List<PlatformFile>? _methodologyFiles; // Change to List<PlatformFile>?
  // List<PlatformFile>? _creatorUserSignatureFiles; // Change to List<PlatformFile>?
  // List<PlatformFile>? _creatorUserSealFiles; // Change to List<PlatformFile>?
  List<PlatformFile>? _chairmanOfDepartmentSealFiles; // Change to List<PlatformFile>?
  List<PlatformFile>? _chairmanOfDepartmentSignatureFiles; // Change to List<PlatformFile>?
  String methodologyFileLocation = '';
  // String creatorUserSignatureFileLocation = '';
  // String creatorUserSealFileLocation = '';
  String chairmanOfDepartmentSealFileLocation = '';
  String chairmanOfDepartmentSignatureFileLocation = '';

  // Function to handle methodology file selection
  void _onMethodologyFileSelected(List<PlatformFile>? files) {
    setState(() {
      _methodologyFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });

    // Call _uploadSealFiles() to upload the selected files imidiately after selection
    // _uploadMethodologyFiles();
  }

  // // Function to handle creatorUserSignature file selection
  // void _onCreatorUserSignatureFileSelected(List<PlatformFile>? files) {
  //   setState(() {
  //     _creatorUserSignatureFiles = files != null ? List.from(files) : null; // Update to assign the list of files
  //   });
  // }

  // // Function to handle seal file selection
  // void _onCreatorUserSealFileSelected(List<PlatformFile>? files) {
  //   // Change parameter type to List<PlatformFile>?
  //   setState(() {
  //     _creatorUserSealFiles = files != null ? List.from(files) : null; // Update to assign the list of files
  //   });
  // }

  // Function to handle seal file selection
  void _onChairmanOfDepartmentSealFileSelected(List<PlatformFile>? files) {
    // Change parameter type to List<PlatformFile>?
    setState(() {
      _chairmanOfDepartmentSealFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  // Function to handle seal file selection
  void _onChairmanOfDepartmentSignatureFileSelected(List<PlatformFile>? files) {
    // Change parameter type to List<PlatformFile>?
    setState(() {
      _chairmanOfDepartmentSignatureFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  Future<void> _uploadMethodologyFiles() async {
    if (_methodologyFiles != null && _methodologyFiles!.isNotEmpty) {
      // try {
      for (var file in _methodologyFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        methodologyFileLocation = fileName;
        print(fileName);
        final responseBody = await ApiService.uploadFile('methodology/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {
          print('File uploaded successfully');
        }
        // Handle success
      }
      // } catch (e) {
      //   print('Failed to upload seal files: $e');
      //   // Handle error
      // }
    } else {
      print('No methodology files selected');
    }
  }

  // Future<void> _uploadCreatorUserSignatureFiles() async {
  //   if (_creatorUserSignatureFiles != null && _creatorUserSignatureFiles!.isNotEmpty) {
  //     // try {
  //     for (var file in _creatorUserSignatureFiles!) {
  //       final fileBytes = file.bytes!;
  //       final fileName = file.name;
  //       _formData.piSignatureLocation = fileName;
  //       print(fileName);
  //       final responseBody = await ApiService.uploadFile('signature/upload', file, fileBytes, fileName);
  //       if (responseBody['statuscode'] == 200) {
  //         print('File uploaded successfully');
  //       }
  //     }
  //     // } catch (e) {
  //     //   print('Failed to upload seal files: $e');
  //     //   // Handle error
  //     // }
  //   } else {
  //     print('No signature files selected');
  //   }
  // }

  // Future<void> _uploadCreatorUserSealFiles() async {
  //   if (_creatorUserSealFiles != null && _creatorUserSealFiles!.isNotEmpty) {
  //     // try {
  //     for (var file in _creatorUserSealFiles!) {
  //       final fileBytes = file.bytes!;
  //       final fileName = file.name;
  //       creatorUserSealFileLocation = fileName;
  //       print(fileName);
  //       final responseBody = await ApiService.uploadFile('seal/upload', file, fileBytes, fileName);
  //       if (responseBody['statuscode'] == 200) {
  //         print('File uploaded successfully');
  //       }
  //     }
  //     // } catch (e) {
  //     //   print('Failed to upload seal files: $e');
  //     //   // Handle error
  //     // }
  //   } else {
  //     print('No seal files selected');
  //   }
  // }

  Future<void> _uploadchairmanOfDepartmentSealFiles() async {
    if (_chairmanOfDepartmentSealFiles != null && _chairmanOfDepartmentSealFiles!.isNotEmpty) {
      // try {
      for (var file in _chairmanOfDepartmentSealFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        chairmanOfDepartmentSealFileLocation = fileName;
        print(fileName);
        final responseBody = await ApiService.uploadFile('seal/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {
          print('File uploaded successfully');
        }
      }
      // } catch (e) {
      //   print('Failed to upload seal files: $e');
      //   // Handle error
      // }
    } else {
      print('No seal files selected');
    }
  }

  Future<void> _uploadchairmanOfDepartmentSignatureFiles() async {
    if (_chairmanOfDepartmentSignatureFiles != null && _chairmanOfDepartmentSignatureFiles!.isNotEmpty) {
      // try {
      for (var file in _chairmanOfDepartmentSignatureFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        chairmanOfDepartmentSignatureFileLocation = fileName;
        print(fileName);
        final responseBody = await ApiService.uploadFile('signature/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {
          print('File uploaded successfully');
        }
      }
      // } catch (e) {
      //   print('Failed to upload seal files: $e');
      //   // Handle error
      // }
    } else {
      print('No signature files selected');
    }
  }

  Future<void> _doSave() async {
    AppFocusHelper.instance.requestUnfocus();

    print('do save start');
    print(_formKey.currentState?.saveAndValidate());
    // print(_formKey.currentState?.value.toString());
    print('do save start');

    if (_formKey.currentState?.saveAndValidate() == true) {
      _formKey.currentState!.save();

      // Call _uploadSealFiles() to upload the selected files
      await _uploadMethodologyFiles();
      // await _uploadCreatorUserSignatureFiles();
      // await _uploadCreatorUserSealFiles();
      await _uploadchairmanOfDepartmentSealFiles();
      await _uploadchairmanOfDepartmentSignatureFiles();

      final createProjectData = {
        'CodeByRTC': _formData.rtcCode,
        'DateRecieved': _formData.dateOfReceived,
        // Part I: Research Proposal Identification Data
        'ProjectTitle': _formData.projectTitle,
        'NatureOfResearchProposal': _formData.natureOfTheResearchProposal,
        'NameOfCollaboratingDepartments': _formData.nameOfCollaboratingDepartmentDepartment,
        'AddressOfCollaboratingDepartments': _formData.addressOfCollaboratingDepartmentDepartment,

        'NameOfCollaboratingInstitutes': _formData.nameOfCollaboratingDepartmentInstitute,
        'AddressOfCollaboratingInstitutes': _formData.addressOfCollaboratingDepartmentInstitute,
        'LocationOfFieldActivities': _formData.locationOfFieldActivities,
        'DurationOfResearchProjectAnnual': _formData.annualDurationOfResearchProject,
        'DurationOfResearchProjectLongTerm': _formData.longTermDurationOfResearchProject,
        'TotalBudgetOfResearchProposalTK': _formData.totalBudgetOfResearchProposal,
        'ExternalAgencyFundingSource': _formData.hasThisProposalBeenSubmittedToAnyOtherAgency,
        'ExternalAgencyFundingSourcesName': _formData.nameOfTheAgency,
        'ExternalAgencyFundingSourcesSubmissionDate': _formData.dateOfSubmission,
        'CommitmentOtherResearchProject': _formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader,
        'CommitmentOtherResearchProjectName': _formData.nameOfTheProject,
        // Part II: Outline of The Research Proposal
        'ProjectDescription': _formData.introductionResearchProposal,
        'MethodologyFileLocation': methodologyFileLocation,
        'ProjectObjective': _formData.specificObjectivesProposal,
        'PstuNationalGoal': _formData.relevanceStrategicDevelopmentGoals,
        'PriorResearchOverview': _formData.briefReviewAlreadyPerformedReferences,
        'Methodology': _formData.methodology,
        'ExpectedOutput': _formData.expectedOutputs,
        'SuccessIndicators': _formData.successIndicators,
        'Beneficiaries': _formData.beneficiaries,
        // Inputs
        'ManPowerExisting': _formData.manPowerExisting,
        'ManPowerRequired': _formData.manPowerRequired,
        'SmallEquipmentExisting': _formData.smallEquipmentExisting,
        'SmallEquipmentRequired': _formData.smallEquipmentRequired,
        'ResearchMaterialsExisting': _formData.researchMaterialsExisting,
        'ResearchMaterialsRequired': _formData.researchMaterialsRequired,
        'OtherExisting': _formData.othersExisting,
        'OtherRequired': _formData.othersRequired,
        // Signature
        'CreatorUserID': _formData.piUserID,
        'CoPiUserID': _formData.coPiUserID,
        'StudentUserID': _formData.studentUserID,

        'CreatorUserSealLocation': _formData.piSealLocation,
        'CreatorUserSignatureLocation': _formData.piSignatureLocation,
        'CreatorUserSignatureDate': _formData.piSignatureDate,

        'ChairmanOfDepartmentComment': _formData.commentsOfTheChairmanOfTheDepartment,
        'ChairmanOfDepartmentSealLocation': chairmanOfDepartmentSealFileLocation,
        'ChairmanOfDepartmentSignatureLocation': chairmanOfDepartmentSignatureFileLocation,
        'ChairmanOfDepartmentSignatureDate': _formData.dateOfChairmanOfTheDepartment,
      };

      print('0000000000000000000000000000');
      print(_formData.rtcCode);
      print(createProjectData);
      print('0000000000000000000000000000');
      // here should make a pi request to create project with the createProjectData
      final responseBody = await ApiService.createProject(createProjectData);

      print('createproject.dart ----- responseBody: $responseBody');
      print('createproject.dart ----- project_id: ${responseBody['project_id']}');

      final responseBodyGantt = await ApiService.createProjectGantt(responseBody['project_id'], ganttFormData);

      final responseBodyBudget = await ApiService.createprojectBudget(responseBody['project_id'], budgetFormData);

      if (responseBody['statuscode'] == 201 && responseBodyGantt['statuscode'] == 201 && responseBodyBudget['statuscode'] == 201) {
        print('do save');
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: "Project created successfully.",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () {},
        );
        dialog.show();
      } else {
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: "Error creating project {responseBody['message']}: ${responseBody['message']} , {responseBody['error']}: ${responseBody['error']}.",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () {},
        );
        dialog.show();
      }
    } else {
      //   final dialog = AwesomeDialog(
      //     context: context,
      //     dialogType: DialogType.error,
      //     title: "Input fields are not valid or empty.",
      //     width: kDialogWidth,
      //     btnOkText: 'OK',
      //     btnOkOnPress: () {},
      //   );
      //   dialog.show();
      print("Input fields are not valid or empty.");
    }
  }

  void _showWordCountExceededDialog(BuildContext context, int wordCount) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      title: "Maximum word count exceeded. Please enter less than $wordCount words.",
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    );
    dialog.show();
  }

  // Future<bool> _getDataAsync() async {
  //   await Future.delayed(const Duration(seconds: 1), () async {
  //     // read user id
  //     final userId = await storage.read(key: 'user_id');
  //     int userid = int.parse(userId!);
  //     print(userid);

  //     final userDetails = await ApiService.getSpecificUser(
  //       userid,
  //     );

  //     print("=============************===============");
  //     print(userDetails);
  //     print("=============*************================");

  //     if (userDetails['statuscode'] == 401) {
  //       // Handle token expiration
  //       // ignore: use_build_context_synchronously
  //       final dialog = AwesomeDialog(
  //         context: context,
  //         dialogType: DialogType.error,
  //         desc: "Token expired. Please login again.",
  //         width: kDialogWidth,
  //         btnOkText: 'OK',
  //         btnOkOnPress: () {},
  //       );
  //       dialog.show();
  //     }

  //     // _formData.userProfileImageUrl = 'https://picsum.photos/id/1005/300/300';
  //     // _formData.userProfileImageUrl = 'http://127.0.0.1:8080/dashboard/zzz.png';
  //     _formData.piName = userDetails['user']['Username'] ?? '';
  //     // _formData.firstName = userDetails['user']['FirstName'] ?? '';
  //     // _formData.lastName = userDetails['user']['LastName'] ?? '';
  //     _formData.piEmail = userDetails['user']['Email'] ?? '';
  //     _formData.piPhone = userDetails['user']['Phone'] ?? '';
  //     _formData.piAddress = userDetails['user']['Address'] ?? '';
  //     _formData.piAreaOfExpertise = userDetails['user']['AreaOfExpertise'] ?? '';
  //     _formData.piHighestQualificationCountry = userDetails['user']['HighestAcademicQualificationCountry'] ?? '';
  //     _formData.piHighestQualificationUniversity = userDetails['user']['HighestAcademicQualificationUniversity'] ?? '';
  //     _formData.piHighestQualification = userDetails['user']['HighestAcademicQualification'] ?? '';
  //     _formData.piReferencesOfLatestPublications = userDetails['user']['piReferencesOfLatestPublications'] ?? 'none';
  //     _formData.piHighestQualificationYear = userDetails['user']['HighestAcademicQualificationYear'] ?? 0;
  //     _formData.piSalaryScale = userDetails['user']['SalaryScale'] ?? 0;
  //     _formData.piExperienceInTeaching = userDetails['user']['Teaching'] ?? 0;
  //     _formData.piExperienceInResearch = userDetails['user']['ExperienceInResearch'] ?? 0;

  //     // _formData.totalNumberOfCompleteProjects = userDetails['user']['TotalNumberOfCompleteProjects'] ?? 0;
  //     // _formData.totalNumberOfCompletePublications = userDetails['user']['TotalNumberOfCompletePublications'] ?? 0;
  //     // _formData.ongoingProjects = userDetails['user']['OngoingProjects'] ?? 0;
  //     // _formData.userId = userDetails['user']['UserID'] ?? 0;
  //     // _formData.rolename = getRoleName(userDetails['user']['RoleID']);
  //     // _formData.profilePicLocation = userDetails['user']['ProfilePicLocation'] ?? '';
  //     print("/////////////////////////////");
  //   });

  //   return true;
  // }

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getAllUsersExceptStudents();
    _studentUsersFuture = ApiService.getOnlyStudentUser();
  }

  @override
  Widget build(BuildContext context) {
    // final lang = Lang.of(context);
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;
    final appButtonTheme = themeData.extension<AppButtonTheme>()!;

    return PortalMasterLayout(
      body: FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
        clearValueOnUnregister: false,
        onChanged: () {
          _formKey.currentState!.save();
        },
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            Text(
              "Research Proposal Application Form",
              style: themeData.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(
                        title: "This research proposal must be submitted according to the following format",
                        backgroundColor: Color.fromARGB(255, 139, 161, 168),
                        titleColor: Color.fromARGB(255, 50, 39, 42)),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: (kDefaultPadding * 22),
                                  child: FormBuilderTextField(
                                    name: 'RTC_Code',
                                    decoration: const InputDecoration(
                                      labelText: 'Code number of the project to be assigned by RTC',
                                      hintText: 'RTC Code',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.rtcCode = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: (kDefaultPadding * 22),
                                      child: FormBuilderDateTimePicker(
                                        name: 'date_of_received',
                                        inputType: InputType.date,
                                        decoration: const InputDecoration(
                                          labelText: 'Date of Received',
                                          border: OutlineInputBorder(),
                                        ),
                                        textAlign: TextAlign.center,
                                        format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                                        validator: FormBuilderValidators.required(),
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        onChanged: (value) => (_formData.dateOfReceived = value.toString()),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(title: "Part I: Research Proposal Identification Data", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              name: 'project_title',
                              decoration: const InputDecoration(
                                labelText: 'Project Title',
                                hintText: 'Project Title',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: FormBuilderValidators.required(),
                              onChanged: (value) => (_formData.projectTitle = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      // const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDropdown(
                                          name: 'name_of_collaborating_department',
                                          decoration: const InputDecoration(
                                            labelText: 'Name of Collaborating Department',
                                            border: OutlineInputBorder(),
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hintText: 'Select',
                                          ),
                                          focusColor: Colors.transparent,
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          items: [
                                            // 'Faculty of Agriculture',
                                            // 'Faculty of Computer Science and Engineering',
                                            // 'Faculty of Business Administration',
                                            // 'Faculty of Animal Science and Veterinary Medicine',
                                            // 'Faculty of Fisheries',
                                            // 'Faculty of Environmental Science and Disaster Management',
                                            // 'Faculty of Nutrition and Food Science',
                                            // 'Faculty of Law and Land Administration'
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
                                          onChanged: (value) => (_formData.nameOfCollaboratingDepartmentDepartment = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'address_of_collaborating_department',
                                          decoration: const InputDecoration(
                                            labelText: 'Address of Collaborating Department',
                                            hintText: 'Address of Collaborating Department',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: (value) => (_formData.addressOfCollaboratingDepartmentDepartment = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDropdown(
                                          name: 'name_of_collaborating_institute',
                                          decoration: const InputDecoration(
                                            labelText: 'Name of Collaborating Institute',
                                            border: OutlineInputBorder(),
                                            hoverColor: Colors.transparent,
                                            focusColor: Colors.transparent,
                                            hintText: 'Select',
                                          ),
                                          focusColor: Colors.transparent,
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          items: [
                                            'Patuakhali Science & Technology University (PSTU)',
                                          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                          onChanged: (value) => (_formData.nameOfCollaboratingDepartmentInstitute = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'address_of_collaborating_institute',
                                          decoration: const InputDecoration(
                                            labelText: 'Address of Collaborating Institute',
                                            hintText: 'Address of Collaborating Institute',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: (value) => (_formData.addressOfCollaboratingDepartmentInstitute = value ?? ''),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                      child: FormBuilderRadioGroup<String>(
                                        name: 'checkbox_group_horizontal',
                                        wrapSpacing: kDefaultPadding,
                                        orientation: OptionsOrientation.vertical,
                                        decoration: const InputDecoration(
                                          labelText: 'Nature of The Research Proposal',
                                          border: OutlineInputBorder(),
                                        ),
                                        options: const [
                                          FormBuilderFieldOption(value: 'Coordinated', child: Text('Coordinated')),
                                          FormBuilderFieldOption(value: 'Independent', child: Text('Independent')),
                                          FormBuilderFieldOption(value: 'Fundamental', child: Text('Fundamental')),
                                          FormBuilderFieldOption(value: 'Applied', child: Text('Applied')),
                                          FormBuilderFieldOption(value: 'Interdisciplinary', child: Text('Interdisciplinary')),
                                        ],
                                        validator: FormBuilderValidators.required(),
                                        autovalidateMode: AutovalidateMode.onUserInteraction,
                                        onChanged: (value) => (_formData.natureOfTheResearchProposal = value.toString()),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              name: 'location_of_field_activities',
                              decoration: const InputDecoration(
                                labelText: 'Location Of Field Activities',
                                hintText: '(Please specify major location(s) of research activities such as laboratory, farm, farmer’s field etc.)',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.locationOfFieldActivities = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDateRangePicker(
                                          name: 'annual_duration_of_research_project',
                                          firstDate: DateTime(1970),
                                          lastDate: DateTime(2030),
                                          format: DateFormat('MMMM d, yyyy'),
                                          decoration: const InputDecoration(
                                            labelText: 'Annual Duration Of Research Project',
                                            hintText: 'Annual Duration Of Research Project',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: (value) => (_formData.annualDurationOfResearchProject = value.toString()),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDateRangePicker(
                                          name: 'long_term_duration_of_research_project',
                                          firstDate: DateTime(1970),
                                          lastDate: DateTime(2030),
                                          format: DateFormat('MMMM d, yyyy'),
                                          decoration: const InputDecoration(
                                            labelText: 'Long-term Duration Of Research Project',
                                            hintText: 'Long-term Duration Of Research Project',
                                            border: OutlineInputBorder(),
                                          ),
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: (value) => (_formData.longTermDurationOfResearchProject = value.toString()),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'total_budget_of_research_proposal',
                                          decoration: const InputDecoration(
                                            prefixText: '৳ ',
                                            labelText: 'Total Budget Of Research Proposal',
                                            hintText: '(Taka)',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: (value) => (_formData.totalBudgetOfResearchProposal = value ?? ''),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderChoiceChip(
                                          name: 'has_this_proposal_been_submitted_to_any_other_agency',
                                          spacing: kDefaultPadding * 0.5,
                                          runSpacing: kDefaultPadding * 0.5,
                                          selectedColor: appColorScheme.warning,
                                          decoration: const InputDecoration(
                                            labelText: 'Has This Proposal Been Submitted To Any Other Agency For Financial Assistance?',
                                            border: OutlineInputBorder(),
                                          ),
                                          options: const [
                                            FormBuilderChipOption(value: 'Submitted', child: Text('Submitted')),
                                            FormBuilderChipOption(value: 'Not Submitted', child: Text('Not Submitted')),
                                          ],
                                          onChanged: (value) {
                                            _formData.hasThisProposalBeenSubmittedToAnyOtherAgency = value ?? '';
                                            // Clear fields if 'Not Submitted' is selected
                                            if (value == 'Not Submitted') {
                                              _formKey.currentState?.fields['name_of_the_agency']?.didChange('');
                                              _formKey.currentState?.fields['date_of_submission']?.didChange(null);
                                            }
                                            setState(() {}); // Trigger rebuild when choice changes
                                          },
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          // onSaved: (value) => (_formData.hasThisProposalBeenSubmittedToAnyOtherAgency = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      // if (_formKey.currentState?.fields['has_this_proposal_been_submitted_to_any_other_agency']?.value == 'Submitted') ...[
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'name_of_the_agency',
                                          decoration: const InputDecoration(
                                            labelText: 'Name of The Agency',
                                            hintText: 'Name of the agency',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          // validator: FormBuilderValidators.required(),
                                          onChanged: (value) => (_formData.nameOfTheAgency = value ?? ''),
                                        ),
                                      ),
                                      // if (_formKey.currentState?.fields['has_this_proposal_been_submitted_to_any_other_agency']?.value == 'Submitted')
                                      const SizedBox(height: 15),
                                      // if (_formKey.currentState?.fields['has_this_proposal_been_submitted_to_any_other_agency']?.value == 'Submitted')
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDateTimePicker(
                                          name: 'date_of_submission',
                                          inputType: InputType.date,
                                          decoration: const InputDecoration(
                                            labelText: 'Date Of Submission',
                                            border: OutlineInputBorder(),
                                          ),
                                          textAlign: TextAlign.center,
                                          format: DateFormat("EEEE, MMMM d, yyyy"),
                                          // validator: FormBuilderValidators.required(),
                                          onChanged: (value) => (_formData.dateOfSubmission = value.toString()),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      // ],
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderChoiceChip(
                                          name: 'is_there_any_commitment_to_other_research_project_as_pi_team_leader',
                                          spacing: kDefaultPadding * 0.5,
                                          runSpacing: kDefaultPadding * 0.5,
                                          selectedColor: appColorScheme.warning,
                                          decoration: const InputDecoration(
                                            labelText: 'Is There Any Commitment to Other Research Project(S) as PI / Team Leader?',
                                            border: OutlineInputBorder(),
                                          ),
                                          options: const [
                                            FormBuilderChipOption(value: 'Yes', child: Text('Yes')),
                                            FormBuilderChipOption(value: 'No', child: Text('No')),
                                          ],
                                          onChanged: (value) {
                                            _formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader = value ?? '';
                                            // Clear name of the project field if 'No' is selected
                                            if (value == 'No') {
                                              _formKey.currentState?.fields['name_of_the_project']?.didChange('');
                                            }
                                            setState(() {}); // Trigger rebuild when choice changes
                                          },
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          // onSaved: (value) => (_formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      // if (_formKey.currentState?.fields['is_there_any_commitment_to_other_research_project_as_pi_team_leader']?.value == 'Yes')
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'name_of_the_project',
                                          decoration: const InputDecoration(
                                            labelText: 'Name of The Project',
                                            hintText: 'Name of The Project',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          // validator: FormBuilderValidators.required(),
                                          onChanged: (value) => (_formData.nameOfTheProject = value ?? ''),
                                        ),
                                      ),
                                    ]),
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
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(title: "Part II: Outline of The Research Proposal", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                    CardBody(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              // maxLength: 300,
                              // onChanged: _limitWordCount,
                              name: 'introduction_identification_of_problem_and_justification_of_the_research_proposal',
                              decoration: const InputDecoration(
                                labelText: 'Introduction, Identification of Problem & Justification of The Research Proposal',
                                hintText: '(300 Words Maximum)',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.maxWordsCount(350),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.introductionResearchProposal = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'specific_objectives_of_the_proposal',
                              decoration: const InputDecoration(
                                labelText: 'Specific Objectives of The Proposal',
                                hintText: 'Specific Objectives Of The Proposal',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.specificObjectivesProposal = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'relevance_to_the_strategic_plan_of_pstu_national_development_goals',
                              decoration: const InputDecoration(
                                labelText: 'Relevance to The Strategic Plan of Pstu & National Development Goals',
                                hintText: 'Relevance to The Strategic Plan of Pstu & National Development Goals',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.relevanceStrategicDevelopmentGoals = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'brief_review_of_works_already_performed_in_progress_elsewhere_with_list_of_references',
                              decoration: const InputDecoration(
                                labelText: 'Brief Review of Works Already Performed / in Progress Elsewhere With List of References',
                                hintText: '(Maximum 500 Words)',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.maxWordsCount(550),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.briefReviewAlreadyPerformedReferences = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      // const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null, // Allow unlimited lines
                                          name: 'methodology',
                                          decoration: const InputDecoration(
                                            labelText: 'Methodology',
                                            hintText: 'Methodology',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          onChanged: (value) => (_formData.methodology = value ?? ''),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                      child: FormBuilderFilePicker(
                                        name: 'methodology_file',
                                        // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
                                        allowMultiple: true,
                                        maxFiles: 5,
                                        type: FileType.any,
                                        previewImages: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Methodology File',
                                          border: OutlineInputBorder(),
                                        ),
                                        selector: const Row(
                                          children: [
                                            Icon(Icons.file_upload_rounded),
                                            Text('Upload Methodology Flowchart / Diagram'),
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
                                        onChanged: _onMethodologyFileSelected,
                                        // onSaved: _onMethodologyFileSelected,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'expected_outputs',
                              decoration: const InputDecoration(
                                labelText: 'Expected Outputs',
                                hintText: 'Expected Outputs',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.expectedOutputs = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'success_indicators',
                              decoration: const InputDecoration(
                                labelText: 'Success Indicators',
                                hintText: 'Success Indicators',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.successIndicators = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'beneficiaries',
                              decoration: const InputDecoration(
                                labelText: 'Beneficiaries',
                                hintText: 'Beneficiaries',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.beneficiaries = value ?? ''),
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
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardBody(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding * 5.0,
                                  runSpacing: kDefaultPadding * 2.0,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 40.0,
                                        child: Text('Activity Plan/Gantt Chart (Annual Basis)', style: Theme.of(context).textTheme.titleMedium),
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
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'work_activity',
                                    decoration: const InputDecoration(
                                      labelText: 'Work/Activity',
                                      hintText: 'Work/Activity',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    onChanged: (value) => (_formData.workActivity = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderDateRangePicker(
                                    name: 'duration',
                                    firstDate: DateTime(1970),
                                    lastDate: DateTime(2030),
                                    format: DateFormat('MMMM d, yyyy'),
                                    decoration: const InputDecoration(
                                      labelText: 'Duration',
                                      hintText: 'Duration',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    onChanged: (value) => (_formData.duration = value.toString()),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: FormBuilderChoiceChip(
                                    name: 'activity_status',
                                    spacing: kDefaultPadding * 0.5,
                                    runSpacing: kDefaultPadding * 0.2,
                                    selectedColor: appColorScheme.warning,
                                    decoration: const InputDecoration(
                                      labelText: 'Activity Status',
                                      border: OutlineInputBorder(),
                                    ),
                                    options: const [
                                      FormBuilderChipOption(value: 'Completed', child: Text('Completed')),
                                      FormBuilderChipOption(value: 'Ongoing', child: Text('Ongoing')),
                                    ],
                                    // onChanged: (value) {
                                    //   setState(() {}); // Trigger rebuild when choice changes
                                    // },
                                    validator: FormBuilderValidators.required(),
                                    onChanged: (value) => (_formData.activityStatus = value ?? ''),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      ...ganttfields,
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveGanttFormData,
                              style: appButtonTheme.infoOutlined,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: kTextPadding),
                                    child: Icon(Icons.save_as),
                                  ),
                                  Text('Press Here to Save Activity-Plan Data'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  ganttfields.add(GanttNewTextField(
                                    key: GlobalKey<_GanttNewTextFieldState>(),
                                    name: 'name_${ganttfields.length}',
                                    onDelete: () {
                                      setState(() {
                                        ganttfields.removeAt(ganttfields.length - 1);
                                      });
                                    },
                                  ));
                                });
                              },
                              style: appButtonTheme.infoText,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: kTextPadding),
                                    child: Icon(Icons.add_chart_outlined),
                                  ),
                                  Text('Add field'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardBody(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding * 5.0,
                                  runSpacing: kDefaultPadding * 2.0,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 40.0,
                                        child: Text('Inputs', style: Theme.of(context).textTheme.titleLarge),
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
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: const Text('Input'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: const Text('Existing'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.1)),
                                  child: const Text('Required'),
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
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('A) Man Power:'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'man_power_existing',
                                    decoration: const InputDecoration(
                                      labelText: 'Man Power Existing',
                                      hintText: 'Man Power Existing',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.manPowerExisting = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'man_power_required',
                                    decoration: const InputDecoration(
                                      labelText: 'Man Power Required',
                                      hintText: 'Man Power Required',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.manPowerRequired = value ?? ''),
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
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('B) Small Equipment:'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'small_equipment_existing',
                                    decoration: const InputDecoration(
                                      labelText: 'Small Equipment Existing',
                                      hintText: 'Small Equipment Existing',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.smallEquipmentExisting = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'small_equipment_required',
                                    decoration: const InputDecoration(
                                      labelText: 'Small Equipment Required',
                                      hintText: 'Small Equipment Required',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.smallEquipmentRequired = value ?? ''),
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
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('C) Research Materials:'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'research_materials_existing',
                                    decoration: const InputDecoration(
                                      labelText: 'Research Materials Existing',
                                      hintText: 'Research Materials Existing',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.researchMaterialsExisting = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'research_materials_required',
                                    decoration: const InputDecoration(
                                      labelText: 'Research Materials Required',
                                      hintText: 'Research Materials Required',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.researchMaterialsRequired = value ?? ''),
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
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('D) Others:'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'others_existing',
                                    decoration: const InputDecoration(
                                      labelText: 'Others Existing',
                                      hintText: 'Others Existing',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.othersExisting = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'others_required',
                                    decoration: const InputDecoration(
                                      labelText: 'Others Required',
                                      hintText: 'if nothing required, type no',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.othersRequired = value ?? ''),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardBody(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  spacing: kDefaultPadding * 5.0,
                                  runSpacing: kDefaultPadding * 2.0,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 40.0,
                                        child: Text('Budget Summary (Annual Basis)', style: Theme.of(context).textTheme.titleMedium),
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
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                  child: const Text('Sl. No.'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: const Text('Item'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                  child: const Text('Quantity'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('Unit Price'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('Total cost (Tk)'),
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
                                  width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'sl_no',
                                    decoration: const InputDecoration(
                                      labelText: 'Sl. No.',
                                      hintText: 'Sl. No.',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.slNo = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'item',
                                    decoration: const InputDecoration(
                                      labelText: 'Item',
                                      hintText: 'Item',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.item = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'quantity',
                                    decoration: const InputDecoration(
                                      labelText: 'Quantity',
                                      hintText: 'Quantity',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.quantity = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'unit_price',
                                    decoration: const InputDecoration(
                                      labelText: 'Unit Price',
                                      hintText: '(Taka)',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.unitPrice = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: FormBuilderTextField(
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'total_cost_tk',
                                    decoration: const InputDecoration(
                                      labelText: 'Total cost (Tk)',
                                      hintText: '(Taka)',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: (value) => (_formData.totalCostTk = value ?? ''),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      ...budgetsummaryfields,
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveBudgetFormData,
                              style: appButtonTheme.infoOutlined,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: kTextPadding),
                                    child: Icon(Icons.save_as),
                                  ),
                                  Text('Press Here to Save Budget-Summary Data'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  budgetsummaryfields.add(BudgetSummaryFieldsNewTextField(
                                    key: GlobalKey<_BudgetSummaryFieldsNewTextFieldState>(),
                                    name: 'name_${budgetsummaryfields.length}',
                                    onDelete: () {
                                      setState(() {
                                        budgetsummaryfields.removeAt(budgetsummaryfields.length - 1);
                                      });
                                    },
                                  ));
                                });
                              },
                              style: appButtonTheme.infoText,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: kTextPadding),
                                    child: Icon(Icons.add_shopping_cart_outlined),
                                  ),
                                  Text('Add field'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: const Text('PI Signature', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: _buildPIImageWidget(context),
                                  ),
                                ]),
                                const SizedBox(width: kDefaultPadding),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: const Text('PI Signature Date', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: FormBuilderDateTimePicker(
                                      name: 'pi_signature_date',
                                      inputType: InputType.date,
                                      decoration: const InputDecoration(
                                        labelText: 'PI Signature Date',
                                        border: OutlineInputBorder(),
                                      ),
                                      textAlign: TextAlign.center,
                                      format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                                      validator: FormBuilderValidators.required(),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onChanged: (value) => (_formData.piSignatureDate = value.toString()),
                                    ),
                                  ),
                                ]),
                                const SizedBox(width: kDefaultPadding),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: const Text('PI Seal', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: _buildPISealWidget(context),
                                  ),
                                ])
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: FormBuilderTextField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null, // Allow unlimited lines
                          name: 'comments_of_the_chairman_of_the_department',
                          decoration: const InputDecoration(
                            labelText: 'Comments of the Chairman of the Department',
                            hintText: 'Comments of the Chairman of the Department',
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          // validator: FormBuilderValidators.required(),
                          onChanged: (value) => (_formData.commentsOfTheChairmanOfTheDepartment = value ?? ''),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: const Text('Chairman of the Department Signature', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  // SizedBox(
                                  //   width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  //   child: Container(
                                  //     alignment: Alignment.center,
                                  //     padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                  //     child: Stack(
                                  //       children: [
                                  //         FutureBuilder<String>(
                                  //           future: chairmanOfDepartmentSignatureFileLocation.isNotEmpty
                                  //               ? ApiService.fetchPicFile('signature/download', chairmanOfDepartmentSignatureFileLocation)
                                  //               : Future.value(""), // Check if value is not empty before making the API call
                                  //           builder: (context, snapshot) {
                                  //             if (snapshot.connectionState == ConnectionState.waiting) {
                                  //               return const CircularProgressIndicator();
                                  //             } else if (snapshot.hasError) {
                                  //               return Text('Error: ${snapshot.error}');
                                  //             } else {
                                  //               return Image.memory(
                                  //                 base64Decode(snapshot.data!), // Convert base64 string to image bytes
                                  //                 fit: BoxFit.cover, // Adjust image to cover the entire space
                                  //                 // width: 120, // Adjust width as needed
                                  //                 height: 50, // Adjust height as needed
                                  //               );
                                  //             }
                                  //           },
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(height: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: FormBuilderFilePicker(
                                      name: 'signature_of_the_chairman_of_the_department',
                                      // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
                                      allowMultiple: false,
                                      maxFiles: 1,
                                      type: FileType.any,
                                      previewImages: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Chairman of the Department Signature',
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
                                      onChanged: _onChairmanOfDepartmentSignatureFileSelected,
                                    ),
                                  ),
                                ]),
                                const SizedBox(width: kDefaultPadding),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: const Text('Chairman Signature Date', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: FormBuilderDateTimePicker(
                                      name: 'date_of_chairman_of_the_department',
                                      inputType: InputType.date,
                                      decoration: const InputDecoration(
                                        labelText: 'Chairman Signature Date',
                                        border: OutlineInputBorder(),
                                      ),
                                      textAlign: TextAlign.center,
                                      format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                                      validator: FormBuilderValidators.required(),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      onChanged: (value) => (_formData.dateOfChairmanOfTheDepartment = value.toString()),
                                    ),
                                  ),
                                ]),
                                const SizedBox(width: kDefaultPadding),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: const Text('Chairman of the Department Seal', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
                                  // SizedBox(
                                  //   width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  //   child: Container(
                                  //     alignment: Alignment.center,
                                  //     padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                  //     child: Stack(
                                  //       children: [
                                  //         FutureBuilder<String>(
                                  //           future: chairmanOfDepartmentSealFileLocation.isNotEmpty
                                  //               ? ApiService.fetchPicFile('seal/download', chairmanOfDepartmentSealFileLocation)
                                  //               : Future.value(""), // Check if value is not empty before making the API call
                                  //           builder: (context, snapshot) {
                                  //             if (snapshot.connectionState == ConnectionState.waiting) {
                                  //               return const CircularProgressIndicator();
                                  //             } else if (snapshot.hasError) {
                                  //               return Text('Error: ${snapshot.error}');
                                  //             } else {
                                  //               return Image.memory(
                                  //                 base64Decode(snapshot.data!), // Convert base64 string to image bytes
                                  //                 fit: BoxFit.cover, // Adjust image to cover the entire space
                                  //                 // width: 120, // Adjust width as needed
                                  //                 height: 50, // Adjust height as needed
                                  //               );
                                  //             }
                                  //           },
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(height: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: FormBuilderFilePicker(
                                      name: 'seal_of_the_chairman_of_the_department',
                                      // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
                                      allowMultiple: false,
                                      maxFiles: 1,
                                      type: FileType.any,
                                      previewImages: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Chairman of the Department Seal',
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
                                      onChanged: _onChairmanOfDepartmentSealFileSelected,
                                    ),
                                  ),
                                ]),
                              ],
                            );
                          },
                        ),
                      ),
                    ])),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      SizedBox(
                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CardHeader(title: "PART III: A. Principal Investigator (PI)", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                              CardBody(
                                // here add dropdown list of co-pi
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                                      child: FutureBuilder<List<User>>(
                                        future: _usersFuture,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const CircularProgressIndicator(); // Show loading indicator while fetching data
                                          } else if (snapshot.hasError) {
                                            return Text('Error: ${snapshot.error}');
                                          } else {
                                            return FormBuilderDropdown<User>(
                                              name: 'pi_name',
                                              decoration: const InputDecoration(
                                                labelText: 'PI Name',
                                                hintText: 'Select PI Name',
                                                border: OutlineInputBorder(),
                                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                              ),
                                              validator: FormBuilderValidators.required(),
                                              autovalidateMode: AutovalidateMode.onUserInteraction,
                                              items: snapshot.data!
                                                  .map((user) => DropdownMenuItem<User>(
                                                        value: user,
                                                        child: Text(user.getDisplayName()),
                                                      ))
                                                  .toList(),
                                              onChanged: (User? user) {
                                                if (user != null) {
                                                  setState(() {
                                                    _formData.piUserID = user.userId;
                                                    _formData.piSignatureLocation = user.signatureLocation;
                                                    _formData.piSealLocation = user.sealLocation;
                                                  });
                                                }
                                              },
                                            );
                                          }
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
                      const SizedBox(width: kDefaultPadding),
                      SizedBox(
                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                        child: CoPi(
                          formData: _formData,
                          usersFuture: _usersFuture,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Student(
                formData: _formData,
                studentUsersFuture: _studentUsersFuture,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CardBody(
                      child: Wrap(
                        direction: Axis.horizontal,
                        spacing: kDefaultPadding * 20.0,
                        runSpacing: kDefaultPadding * 2.0,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              height: 40.0,
                              child: ElevatedButton(
                                onPressed: _doSave,
                                style: appButtonTheme.primaryElevated,
                                child: const Text("Save"),
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
          ],
        ),
      ),
    );
  }

  // Widget _content(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const SizedBox(height: 25),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             return Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //                   // const SizedBox(height: 20),
  //                   SizedBox(
  //                     width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
  //                     child: FormBuilderTextField(
  //                       keyboardType: TextInputType.multiline,
  //                       maxLines: null, // Allow unlimited lines
  //                       name: 'pi_name',
  //                       decoration: const InputDecoration(
  //                         labelText: 'PI Name',
  //                         hintText: 'PI Name',
  //                         border: OutlineInputBorder(),
  //                         floatingLabelBehavior: FloatingLabelBehavior.always,
  //                       ),
  //                       validator: FormBuilderValidators.required(),
  //                       initialValue: _formData.piName,
  //                       onChanged: (value) => (_formData.piName = value ?? ''),
  //                     ),
  //                   ),
  //                 ]),
  //                 const SizedBox(width: kDefaultPadding),
  //                 SizedBox(
  //                   width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
  //                   child: FormBuilderTextField(
  //                     keyboardType: TextInputType.multiline,
  //                     maxLines: null, // Allow unlimited lines
  //                     name: 'pi_phone',
  //                     decoration: const InputDecoration(
  //                       labelText: 'PI Phone',
  //                       hintText: 'PI Phone',
  //                       border: OutlineInputBorder(),
  //                       floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     ),
  //                     validator: FormBuilderValidators.required(),
  //                     initialValue: _formData.piPhone,
  //                     onChanged: (value) => (_formData.piPhone = value ?? ''),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             return Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //                   // const SizedBox(height: 20),
  //                   SizedBox(
  //                     width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
  //                     child: FormBuilderTextField(
  //                       keyboardType: TextInputType.multiline,
  //                       maxLines: null, // Allow unlimited lines
  //                       name: 'pi_address',
  //                       decoration: const InputDecoration(
  //                         labelText: 'PI Address',
  //                         hintText: 'PI Address',
  //                         border: OutlineInputBorder(),
  //                         floatingLabelBehavior: FloatingLabelBehavior.always,
  //                       ),
  //                       validator: FormBuilderValidators.required(),
  //                       initialValue: _formData.piAddress,
  //                       onChanged: (value) => (_formData.piAddress = value ?? ''),
  //                     ),
  //                   ),
  //                 ]),
  //                 const SizedBox(width: kDefaultPadding),
  //                 SizedBox(
  //                   width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
  //                   child: FormBuilderTextField(
  //                     keyboardType: TextInputType.multiline,
  //                     maxLines: null, // Allow unlimited lines
  //                     name: 'pi_email',
  //                     decoration: const InputDecoration(
  //                       labelText: 'PI Email',
  //                       hintText: 'PI Email',
  //                       border: OutlineInputBorder(),
  //                       floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     ),
  //                     validator: FormBuilderValidators.required(),
  //                     initialValue: _formData.piEmail,
  //                     onChanged: (value) => (_formData.piEmail = value ?? ''),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             return Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //                   // const SizedBox(height: 20),
  //                   SizedBox(
  //                     width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
  //                     child: FormBuilderTextField(
  //                       keyboardType: TextInputType.multiline,
  //                       maxLines: null, // Allow unlimited lines
  //                       name: 'pi_salary_scale',
  //                       decoration: const InputDecoration(
  //                         labelText: 'PI Salary Scale',
  //                         hintText: 'PI Salary Scale',
  //                         border: OutlineInputBorder(),
  //                         floatingLabelBehavior: FloatingLabelBehavior.always,
  //                       ),
  //                       validator: FormBuilderValidators.required(),
  //                       initialValue: _formData.piSalaryScale.toString(),
  //                       onChanged: (value) => (_formData.piSalaryScale = int.parse(value ?? '0')),
  //                     ),
  //                   ),
  //                 ]),
  //                 const SizedBox(width: kDefaultPadding),
  //                 SizedBox(
  //                   width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
  //                   child: FormBuilderTextField(
  //                     keyboardType: TextInputType.multiline,
  //                     maxLines: null, // Allow unlimited lines
  //                     name: 'pi_basic_pay',
  //                     decoration: const InputDecoration(
  //                       labelText: 'PI Basic Pay',
  //                       hintText: 'PI Basic Pay',
  //                       border: OutlineInputBorder(),
  //                       floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     ),
  //                     validator: FormBuilderValidators.required(),
  //                     initialValue: _formData.piBasicPay.toString(),
  //                     onChanged: (value) => (_formData.piBasicPay = int.parse(value ?? '0')),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
  //         child: FormBuilderTextField(
  //           keyboardType: TextInputType.multiline,
  //           maxLines: null, // Allow unlimited lines
  //           name: 'pi_highest_academic_qualification',
  //           decoration: const InputDecoration(
  //             labelText: 'PI Highest Academic Qualification',
  //             hintText: 'PI Highest Academic Qualification',
  //             border: OutlineInputBorder(),
  //             floatingLabelBehavior: FloatingLabelBehavior.always,
  //           ),
  //           validator: FormBuilderValidators.required(),
  //           initialValue: _formData.piHighestQualification,
  //           onChanged: (value) => (_formData.piHighestQualification = value ?? ''),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             return Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 SizedBox(
  //                   width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
  //                   child: FormBuilderTextField(
  //                     keyboardType: TextInputType.multiline,
  //                     maxLines: null, // Allow unlimited lines
  //                     name: 'pi_highest_academic_qualification_university',
  //                     decoration: const InputDecoration(
  //                       labelText: 'PI Highest Academic Qualification University',
  //                       hintText: 'PI Highest Academic Qualification University',
  //                       border: OutlineInputBorder(),
  //                       floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     ),
  //                     validator: FormBuilderValidators.required(),
  //                     initialValue: _formData.piHighestQualificationUniversity,
  //                     onChanged: (value) => (_formData.piHighestQualificationUniversity = value ?? ''),
  //                   ),
  //                 ),
  //                 const SizedBox(width: kDefaultPadding),
  //                 SizedBox(
  //                   width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.2)),
  //                   child: FormBuilderTextField(
  //                     keyboardType: TextInputType.multiline,
  //                     maxLines: null, // Allow unlimited lines
  //                     name: 'pi_highest_academic_qualification_country',
  //                     decoration: const InputDecoration(
  //                       labelText: 'PI Highest Academic Qualification Country',
  //                       hintText: 'PI Highest Academic Qualification Country',
  //                       border: OutlineInputBorder(),
  //                       floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     ),
  //                     validator: FormBuilderValidators.required(),
  //                     initialValue: _formData.piHighestQualificationCountry,
  //                     onChanged: (value) => (_formData.piHighestQualificationCountry = value ?? ''),
  //                   ),
  //                 ),
  //                 const SizedBox(width: kDefaultPadding),
  //                 SizedBox(
  //                   width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.1)),
  //                   child: FormBuilderTextField(
  //                     keyboardType: TextInputType.multiline,
  //                     maxLines: null, // Allow unlimited lines
  //                     name: 'pi_highest_academic_qualification_year',
  //                     decoration: const InputDecoration(
  //                       labelText: 'PI Highest Qualification Year',
  //                       hintText: 'PI Highest Qualification Year',
  //                       border: OutlineInputBorder(),
  //                       floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     ),
  //                     validator: FormBuilderValidators.required(),
  //                     initialValue: _formData.piHighestQualificationYear.toString(),
  //                     onChanged: (value) => (_formData.piHighestQualificationYear = int.parse(value ?? '0')),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
  //         child: FormBuilderTextField(
  //           keyboardType: TextInputType.multiline,
  //           maxLines: null, // Allow unlimited lines
  //           name: 'pi_area_of_expertise',
  //           decoration: const InputDecoration(
  //             labelText: 'PI Area of Expertise',
  //             hintText: 'PI Area of Expertise',
  //             border: OutlineInputBorder(),
  //             floatingLabelBehavior: FloatingLabelBehavior.always,
  //           ),
  //           validator: FormBuilderValidators.required(),
  //           initialValue: _formData.piAreaOfExpertise,
  //           onChanged: (value) => (_formData.piAreaOfExpertise = value ?? ''),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
  //         child: LayoutBuilder(
  //           builder: (context, constraints) {
  //             return Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //                   // const SizedBox(height: 20),
  //                   SizedBox(
  //                     width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
  //                     child: FormBuilderTextField(
  //                       keyboardType: TextInputType.multiline,
  //                       maxLines: null, // Allow unlimited lines
  //                       name: 'pi_experience_in_research',
  //                       decoration: const InputDecoration(
  //                         labelText: 'PI Experience in Research (Years)',
  //                         hintText: 'PI Experience in Research (Years)',
  //                         border: OutlineInputBorder(),
  //                         floatingLabelBehavior: FloatingLabelBehavior.always,
  //                       ),
  //                       validator: FormBuilderValidators.required(),
  //                       initialValue: _formData.piExperienceInResearch.toString(),
  //                       onChanged: (value) => (_formData.piExperienceInResearch = int.parse(value ?? '0')),
  //                     ),
  //                   ),
  //                 ]),
  //                 const SizedBox(width: kDefaultPadding),
  //                 SizedBox(
  //                   width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
  //                   child: FormBuilderTextField(
  //                     keyboardType: TextInputType.multiline,
  //                     maxLines: null, // Allow unlimited lines
  //                     name: 'pi_experience_in_teaching',
  //                     decoration: const InputDecoration(
  //                       labelText: 'PI Experience in Teaching (Years)',
  //                       hintText: 'PI Experience in Teaching (Years)',
  //                       border: OutlineInputBorder(),
  //                       floatingLabelBehavior: FloatingLabelBehavior.always,
  //                     ),
  //                     validator: FormBuilderValidators.required(),
  //                     initialValue: _formData.piExperienceInTeaching.toString(),
  //                     onChanged: (value) => (_formData.piExperienceInTeaching = int.parse(value ?? '0')),
  //                   ),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
  //         child: FormBuilderTextField(
  //           keyboardType: TextInputType.multiline,
  //           maxLines: null, // Allow unlimited lines
  //           name: 'pi_references_of_latest_publications',
  //           decoration: const InputDecoration(
  //             labelText: 'PI References of latest Publications',
  //             hintText: 'PI References of latest Publications',
  //             border: OutlineInputBorder(),
  //             floatingLabelBehavior: FloatingLabelBehavior.always,
  //           ),
  //           validator: FormBuilderValidators.required(),
  //           initialValue: _formData.piReferencesOfLatestPublications,
  //           onChanged: (value) => (_formData.piReferencesOfLatestPublications = value ?? ''),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildPIImageWidget(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
      child: Stack(
        children: [
          FutureBuilder<String>(
            future: _formData.piSignatureLocation.isNotEmpty
                ? ApiService.fetchPicFile('signature/download', _formData.piSignatureLocation)
                : ApiService.fetchPicFile('signature/download', "defaultsignature.png"), // Check if value is not empty before making the API call
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
    );
  }

  Widget _buildPISealWidget(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
      child: Stack(
        children: [
          FutureBuilder<String>(
            future: _formData.piSealLocation.isNotEmpty
                ? ApiService.fetchPicFile('seal/download', _formData.piSealLocation)
                : ApiService.fetchPicFile('seal/download', "defaultseal.png"), // Check if value is not empty before making the API call
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
    );
  }
}

class GanttNewTextField extends StatefulWidget {
  final VoidCallback? onDelete;
  final String name;

  GanttNewTextField({Key? key, this.onDelete, required this.name}) : super(key: key);

  @override
  State<GanttNewTextField> createState() => _GanttNewTextFieldState();
}

class _GanttNewTextFieldState extends State<GanttNewTextField> {
  late String _activityStatus = '';
  late String _datePickerController = '';
  late String _workActivityController = '';

  @override
  void initState() {
    super.initState();
  }

  FormData2 getFormData() {
    return FormData2(
      workActivity: _workActivityController,
      duration: _datePickerController,
      activityStatus: _activityStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                child: FormBuilderTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // Allow unlimited lines
                  name: 'work_activity_${widget.name}',
                  decoration: const InputDecoration(
                    labelText: 'Work/Activity',
                    hintText: 'Work/Activity',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  // validator: FormBuilderValidators.required(),
                  onChanged: (value) => _workActivityController = value ?? '',
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              SizedBox(
                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                child: FormBuilderDateRangePicker(
                  name: 'duration_${widget.name}',
                  firstDate: DateTime(1970),
                  lastDate: DateTime(2030),
                  format: DateFormat('MMMM d, yyyy'),
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: 'Duration',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _datePickerController = value.toString(),
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              SizedBox(
                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                child: FormBuilderChoiceChip(
                  name: 'activity_status_${widget.name}',
                  spacing: kDefaultPadding * 0.5,
                  runSpacing: kDefaultPadding * 0.2,
                  selectedColor: appColorScheme.warning,
                  decoration: const InputDecoration(
                    labelText: 'Activity Status',
                    border: OutlineInputBorder(),
                  ),
                  options: const [
                    FormBuilderChipOption(value: 'Completed', child: Text('Completed')),
                    FormBuilderChipOption(value: 'Ongoing', child: Text('Ongoing')),
                  ],
                  onChanged: (value) => _activityStatus = value ?? '',
                ),
              ),
              if (widget.onDelete != null) const SizedBox(width: kDefaultPadding),
              SizedBox(
                width: ((constraints.maxWidth * 0.05) - (kDefaultPadding * 0.05)),
                child: IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: widget.onDelete,
                  color: appColorScheme.error,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Define the FormData and WorkActivity classes
class FormData2 {
  String workActivity;
  String duration;
  String activityStatus;

  FormData2({
    required this.workActivity,
    required this.duration,
    required this.activityStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'workActivity': workActivity,
      'duration': duration,
      'activityStatus': activityStatus,
    };
  }
}

class FormData3 {
  String totalCostTk;
  String unitPrice;
  String quantity;
  String item;
  String serialNo;

  FormData3({
    required this.totalCostTk,
    required this.unitPrice,
    required this.quantity,
    required this.item,
    required this.serialNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'serialNo': serialNo,
      'item': item,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalCostTk': totalCostTk,
    };
  }
}

class BudgetSummaryFieldsNewTextField extends StatefulWidget {
  final VoidCallback? onDelete;
  final String name;

  BudgetSummaryFieldsNewTextField({Key? key, this.onDelete, required this.name}) : super(key: key);

  @override
  State<BudgetSummaryFieldsNewTextField> createState() => _BudgetSummaryFieldsNewTextFieldState();
}

class _BudgetSummaryFieldsNewTextFieldState extends State<BudgetSummaryFieldsNewTextField> {
  late String _quantity = '';
  late String _item = '';
  late String _serialNo = '';
  late String _unitPrice = '';
  late String _totalCostTk = '';

  @override
  void initState() {
    super.initState();
  }

  FormData3 getFormData3() {
    return FormData3(
      serialNo: _serialNo,
      item: _item,
      quantity: _quantity,
      unitPrice: _unitPrice,
      totalCostTk: _totalCostTk,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final appColorScheme = themeData.extension<AppColorScheme>()!;

    return Padding(
      padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                child: FormBuilderTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // Allow unlimited lines
                  name: 'sl_no_${widget.name}',
                  decoration: const InputDecoration(
                    labelText: 'Sl. No.',
                    hintText: 'Sl. No.',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  // validator: FormBuilderValidators.required(),
                  onChanged: (value) => _serialNo = value ?? '',
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              SizedBox(
                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                child: FormBuilderTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // Allow unlimited lines
                  name: 'item_${widget.name}',
                  decoration: const InputDecoration(
                    labelText: 'Item',
                    hintText: 'Item',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  // validator: FormBuilderValidators.required(),
                  onChanged: (value) => _item = value ?? '',
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              SizedBox(
                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                child: FormBuilderTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // Allow unlimited lines
                  name: 'quantity_${widget.name}',
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Quantity',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  // validator: FormBuilderValidators.required(),
                  onChanged: (value) => _quantity = value ?? '',
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              SizedBox(
                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                child: FormBuilderTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // Allow unlimited lines
                  name: 'unit_price_${widget.name}',
                  decoration: const InputDecoration(
                    labelText: 'Unit Price',
                    hintText: '(Taka)',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  // validator: FormBuilderValidators.required(),
                  onChanged: (value) => _unitPrice = value ?? '',
                ),
              ),
              const SizedBox(width: kDefaultPadding),
              SizedBox(
                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                child: FormBuilderTextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // Allow unlimited lines
                  name: 'total_cost_tk_${widget.name}',
                  decoration: const InputDecoration(
                    labelText: 'Total cost (Tk)',
                    hintText: '(Taka)',
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  // validator: FormBuilderValidators.required(),
                  onChanged: (value) => _totalCostTk = value ?? '',
                ),
              ),
              if (widget.onDelete != null)
                SizedBox(
                  width: ((constraints.maxWidth * 0.05) - (kDefaultPadding * 0.05)),
                  child: IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: widget.onDelete,
                    color: appColorScheme.error,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class FormData {
  String password = '';
  String roleID = '';
  // String cgpaUndergraduateLevel = '';
  // String firstEnrollmentSemester = '';
  // String studentId = '';
  // String studentRegNo = '';
  // String studentName = '';
  int studentUserID = 0;
  // String coPiReferencesOfLatestPublications = '';
  // String coPiExperienceInTeaching = '';
  // String coPiExperienceInResearch = '';
  // String coPiAreaOfExpertise = '';
  // String coPiHighestAcademicQualificationYear = '';
  // String coPiHighestAcademicQualificationCountry = '';
  // String coPiHighestAcademicQualificationUniversity = '';
  // String coPiHighestAcademicQualification = '';
  // String coPiBasicPay = '';
  // String coPiSalaryScale = '';
  // String coPiEmail = '';
  // String coPiAddress = '';
  // String coPiPhone = '';
  // String coPiName = '';
  int coPiUserID = 0;
  // String piReferencesOfLatestPublications = '';
  // int piExperienceInTeaching = 0;
  // int piExperienceInResearch = 0;
  // String piAreaOfExpertise = '';
  // int piHighestQualificationYear = 0;
  // String piHighestQualificationCountry = '';
  // String piHighestQualificationUniversity = '';
  // String piHighestQualification = '';
  // int piBasicPay = 0;
  // int piSalaryScale = 0;
  // String piEmail = '';
  // String piAddress = '';
  // String piPhone = '';
  // String piName = '';
  int piUserID = 0;
  String dateOfChairmanOfTheDepartment = '';
  String commentsOfTheChairmanOfTheDepartment = '';
  String piSignatureDate = '';
  String piSignatureLocation = '';
  String piSealLocation = '';
  String totalCostTk = '';
  String unitPrice = '';
  String quantity = '';
  String item = '';
  String slNo = '';
  String othersRequired = '';
  String othersExisting = '';
  String researchMaterialsRequired = '';
  String researchMaterialsExisting = '';
  String smallEquipmentRequired = '';
  String smallEquipmentExisting = '';
  String manPowerRequired = '';
  String manPowerExisting = '';
  String activityStatus = '';
  String duration = '';
  String workActivity = '';
  String beneficiaries = '';
  String successIndicators = '';
  String expectedOutputs = '';
  String methodology = '';
  String briefReviewAlreadyPerformedReferences = '';
  String relevanceStrategicDevelopmentGoals = '';
  String specificObjectivesProposal = '';
  String introductionResearchProposal = '';
  String nameOfTheProject = '';
  String isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader = '';
  String dateOfSubmission = '';
  String nameOfTheAgency = '';
  String hasThisProposalBeenSubmittedToAnyOtherAgency = '';
  String totalBudgetOfResearchProposal = '';
  String longTermDurationOfResearchProject = '';
  String annualDurationOfResearchProject = '';
  String locationOfFieldActivities = '';
  String natureOfTheResearchProposal = '';
  String addressOfCollaboratingDepartmentInstitute = '';
  String addressOfCollaboratingDepartmentDepartment = '';
  String nameOfCollaboratingDepartmentInstitute = '';
  String nameOfCollaboratingDepartmentDepartment = '';
  String projectTitle = '';
  String dateOfReceived = '';
  String rtcCode = '';
}

class CoPi extends StatefulWidget {
  final Future<List<User>> usersFuture;
  final FormData formData;

  const CoPi({required this.formData, required this.usersFuture, Key? key}) : super(key: key);

  @override
  _CoPiState createState() => _CoPiState();
}

class _CoPiState extends State<CoPi> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: "PART III: B. Co-Principal Investigator (CO-PI)", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
          CardBody(
            // here add dropdown list of co-pi
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                  child: FutureBuilder<List<User>>(
                    future: widget.usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Show loading indicator while fetching data
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return FormBuilderDropdown<User>(
                          name: 'co_pi_name',
                          decoration: const InputDecoration(
                            labelText: 'CO-PI Name',
                            hintText: 'Select CO-PI Name',
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: FormBuilderValidators.required(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          items: snapshot.data!
                              .map((user) => DropdownMenuItem<User>(
                                    value: user,
                                    child: Text(user.getDisplayName()),
                                  ))
                              .toList(),
                          onChanged: (User? user) {
                            if (user != null) {
                              setState(() {
                                widget.formData.coPiUserID = user.userId;
                              });
                            }
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Student extends StatefulWidget {
  final Future<List<User>> studentUsersFuture;
  final FormData formData;

  const Student({required this.formData, required this.studentUsersFuture, Key? key}) : super(key: key);

  @override
  _StudentState createState() => _StudentState();
}

class _StudentState extends State<Student> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeader(title: "PART III: C. Student's Information (For Code: 4829): (MS/PhD)", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
          CardBody(
            // here add dropdown list of co-pi
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                  child: FutureBuilder<List<User>>(
                    future: widget.studentUsersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // Show loading indicator while fetching data
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return FormBuilderDropdown<User>(
                          name: 'student_name',
                          decoration: const InputDecoration(
                            labelText: 'Student Name',
                            hintText: 'Select Student Name',
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: FormBuilderValidators.required(),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          items: snapshot.data!
                              .map((user) => DropdownMenuItem<User>(
                                    value: user,
                                    child: Text(user.getDisplayName()),
                                  ))
                              .toList(),
                          onChanged: (User? user) {
                            if (user != null) {
                              setState(() {
                                widget.formData.studentUserID = user.userId;
                              });
                            }
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
