// ignore_for_file: avoid_print, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/constants/values.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html; // Import the 'html' library for web-specific functionalities

class EditProjectScreen extends StatefulWidget {
  final String projectID;

  const EditProjectScreen({
    Key? key,
    required this.projectID,
  }) : super(key: key);

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  Future<bool>? _future;
  List<PlatformFile>? _projectSoftCopyFiles;
  List<PlatformFile>? _methodologyFiles;
  List<PlatformFile>? _chairmanOfDepartmentSealFiles;
  List<PlatformFile>? _chairmanOfDepartmentSignatureFiles;

  late List<dynamic> ganttFormDataForUpload = [];
  late List<dynamic> budgetFormDataForUpload = [];
  late List<dynamic> initialProjectGantts = [];
  late List<dynamic> initialProjectBudget = [];

  Uint8List? _methodologyFileBytes;
  Uint8List? _piSignatureFileBytes;
  Uint8List? _piSealFileBytes;
  Uint8List? _chairmanSignatureFileBytes;
  Uint8List? _chairmanSealFileBytes;
  Uint8List? _downloadProjectFileBytes;

  late Future<List<User>> _usersFuture;
  late Future<List<User>> _studentUsersFuture;

  late UserDataProvider userDataProvider;

  void _onProjectSoftCopyFileSelected(List<PlatformFile>? files) {
    setState(() {
      _projectSoftCopyFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  void _onMethodologyFileSelected(List<PlatformFile>? files) {
    setState(() {
      _methodologyFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  void _onChairmanOfDepartmentSealFileSelected(List<PlatformFile>? files) {
    setState(() {
      _chairmanOfDepartmentSealFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  void _onChairmanOfDepartmentSignatureFileSelected(List<PlatformFile>? files) {
    setState(() {
      _chairmanOfDepartmentSignatureFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  Future<void> _uploadProjectSoftCopyFiles() async {
    if (_projectSoftCopyFiles != null && _projectSoftCopyFiles!.isNotEmpty) {
      for (var file in _projectSoftCopyFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        _formData.projectSoftCopyLocation = fileName;

        final responseBody = await ApiService.uploadFile('project_softcopy/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {}
        // Handle success
      }
    } else {}
  }

  Future<void> _uploadMethodologyFiles() async {
    if (_methodologyFiles != null && _methodologyFiles!.isNotEmpty) {
      for (var file in _methodologyFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        _formData.methodologyFileLocation = fileName;

        final responseBody = await ApiService.uploadFile('methodology/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {}
        // Handle success
      }
    } else {}
  }

  Future<void> _uploadchairmanOfDepartmentSealFiles() async {
    if (_chairmanOfDepartmentSealFiles != null && _chairmanOfDepartmentSealFiles!.isNotEmpty) {
      for (var file in _chairmanOfDepartmentSealFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        _formData.chairmanOfDepartmentSealFileLocation = fileName;

        final responseBody = await ApiService.uploadFile('seal/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {}
      }
    } else {}
  }

  Future<void> _uploadchairmanOfDepartmentSignatureFiles() async {
    if (_chairmanOfDepartmentSignatureFiles != null && _chairmanOfDepartmentSignatureFiles!.isNotEmpty) {
      for (var file in _chairmanOfDepartmentSignatureFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        _formData.chairmanOfDepartmentSignatureFileLocation = fileName;

        final responseBody = await ApiService.uploadFile('signature/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {}
      }
    } else {}
  }

  void _downloadProjectSoftCopy(String fileName) async {
    String downloadProjectReport = await ApiService.downloadFile('project_softcopy/download', fileName);
    if (downloadProjectReport.isNotEmpty) {
      Uint8List fileBytes = base64Decode(downloadProjectReport);
      _downloadProjectFileBytes = fileBytes;
    }
    final blob = html.Blob([_downloadProjectFileBytes], 'application/octet-stream');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final html.AnchorElement anchor = html.AnchorElement(href: url);
    anchor.download = fileName; // Specify the filename for the downloaded file
    anchor.click(); // Trigger the download
  }

  Future<bool> _getDataAsync() async {
    if (widget.projectID.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.projectID = widget.projectID;

        // read user id
        final userId = await storage.read(key: 'user_id');
        int userid = int.parse(userId!);

        int projectId = int.parse(widget.projectID);
        final userDetails = await ApiService.getSpecificProject(
          projectId,
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

        _formData.rtcCode = userDetails['project']['CodeByRTC'];
        _formData.dateOfReceived = userDetails['project']['DateRecieved'];
        // Part I: Research Proposal Identification Data
        _formData.projectTitle = userDetails['project']['ProjectTitle'];
        _formData.natureOfTheResearchProposal = userDetails['project']['NatureOfResearchProposal'];
        _formData.nameOfCollaboratingDepartmentDepartment = userDetails['project']['NameOfCollaboratingDepartments'];
        _formData.addressOfCollaboratingDepartmentDepartment = userDetails['project']['AddressOfCollaboratingDepartments'];

        _formData.nameOfCollaboratingDepartmentInstitute = userDetails['project']['NameOfCollaboratingInstitutes'];
        _formData.addressOfCollaboratingDepartmentInstitute = userDetails['project']['AddressOfCollaboratingInstitutes'];
        _formData.locationOfFieldActivities = userDetails['project']['LocationOfFieldActivities'];
        _formData.annualDurationOfResearchProject = userDetails['project']['DurationOfResearchProjectAnnual'];
        _formData.longTermDurationOfResearchProject = userDetails['project']['DurationOfResearchProjectLongTerm'];
        _formData.totalBudgetOfResearchProposal = userDetails['project']['TotalBudgetOfResearchProposalTK'].toString();
        _formData.hasThisProposalBeenSubmittedToAnyOtherAgency = userDetails['project']['ExternalAgencyFundingSource'];
        _formData.nameOfTheAgency = userDetails['project']['ExternalAgencyFundingSourcesName'];
        _formData.dateOfSubmission = userDetails['project']['ExternalAgencyFundingSourcesSubmissionDate'];
        _formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader = userDetails['project']['CommitmentOtherResearchProject'];
        _formData.nameOfTheProject = userDetails['project']['CommitmentOtherResearchProjectName'];
        // // Part II: Outline of The Research Proposal
        _formData.introductionResearchProposal = userDetails['project']['ProjectDescription'];
        _formData.methodologyFileLocation = userDetails['project']['MethodologyFileLocation'];
        String methodologyfilePath = _formData.methodologyFileLocation.isNotEmpty
            ? await ApiService.downloadFile('methodology/download', _formData.methodologyFileLocation)
            : await ApiService.downloadFile('methodology/download', "defaultmethodology.png"); // Check if value is not empty before making the API call
        if (methodologyfilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(methodologyfilePath);
          _methodologyFileBytes = fileBytes;
        }
        _formData.specificObjectivesProposal = userDetails['project']['ProjectObjective'];
        _formData.relevanceStrategicDevelopmentGoals = userDetails['project']['PstuNationalGoal'];
        _formData.briefReviewAlreadyPerformedReferences = userDetails['project']['PriorResearchOverview'];
        _formData.methodology = userDetails['project']['Methodology'];
        _formData.expectedOutputs = userDetails['project']['ExpectedOutput'];
        _formData.successIndicators = userDetails['project']['SuccessIndicators'];
        _formData.beneficiaries = userDetails['project']['Beneficiaries'];
        // // Inputs
        _formData.manPowerExisting = userDetails['project']['ManPowerExisting'];
        _formData.manPowerRequired = userDetails['project']['ManPowerRequired'];
        _formData.smallEquipmentExisting = userDetails['project']['SmallEquipmentExisting'];
        _formData.smallEquipmentRequired = userDetails['project']['SmallEquipmentRequired'];
        _formData.researchMaterialsExisting = userDetails['project']['ResearchMaterialsExisting'];
        _formData.researchMaterialsRequired = userDetails['project']['ResearchMaterialsRequired'];
        _formData.othersExisting = userDetails['project']['OtherExisting'];
        _formData.othersRequired = userDetails['project']['OtherRequired'];
        // // Signature
        _formData.piUserID = userDetails['project']['CreatorUserID'];
        final sharedPref = await SharedPreferences.getInstance();
        final firstName = sharedPref.getString(StorageKeys.firstname)!;
        final lastName = sharedPref.getString(StorageKeys.lastname)!;
        _formData.piName = "$firstName $lastName";
        _formData.coPiUserID = userDetails['project']['CoPiUserID'];
        _formData.studentUserID = userDetails['project']['StudentUserID'];

        _formData.piSealLocation = userDetails['project']['CreatorUserSealLocation'];
        String piSealfilePath = _formData.piSealLocation.isNotEmpty
            ? await ApiService.downloadFile('seal/download', _formData.piSealLocation)
            : await ApiService.downloadFile('seal/download', "defaultseal.png"); // Check if value is not empty before making the API call
        if (piSealfilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(piSealfilePath);
          _piSealFileBytes = fileBytes;
        }
        _formData.piSignatureLocation = userDetails['project']['CreatorUserSignatureLocation'];
        String piSignaturefilePath = _formData.piSignatureLocation.isNotEmpty
            ? await ApiService.downloadFile('signature/download', _formData.piSignatureLocation)
            : await ApiService.downloadFile('signature/download', "defaultsignature.png"); // Check if value is not empty before making the API call
        if (piSignaturefilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(piSignaturefilePath);
          _piSignatureFileBytes = fileBytes;
        }
        _formData.piSignatureDate = userDetails['project']['CreatorUserSignatureDate'];

        _formData.commentsOfTheChairmanOfTheDepartment = userDetails['project']['ChairmanOfDepartmentComment'];
        _formData.chairmanOfDepartmentSealFileLocation = userDetails['project']['ChairmanOfDepartmentSealLocation'];
        String chairmanSealfilePath = _formData.chairmanOfDepartmentSealFileLocation.isNotEmpty
            ? await ApiService.downloadFile('seal/download', _formData.chairmanOfDepartmentSealFileLocation)
            : await ApiService.downloadFile('seal/download', "defaultseal.png"); // Check if value is not empty before making the API call
        if (chairmanSealfilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(chairmanSealfilePath);
          _chairmanSealFileBytes = fileBytes;
        }
        _formData.chairmanOfDepartmentSignatureFileLocation = userDetails['project']['ChairmanOfDepartmentSignatureLocation'];
        String chairmanSignaturefilePath = _formData.chairmanOfDepartmentSignatureFileLocation.isNotEmpty
            ? await ApiService.downloadFile('signature/download', _formData.chairmanOfDepartmentSignatureFileLocation)
            : await ApiService.downloadFile('signature/download', "defaultsignature.png"); // Check if value is not empty before making the API call
        if (chairmanSignaturefilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(chairmanSignaturefilePath);
          _chairmanSignatureFileBytes = fileBytes;
        }
        _formData.dateOfChairmanOfTheDepartment = userDetails['project']['ChairmanOfDepartmentSignatureDate'];

        _formData.projectStatus = userDetails['project']['ProjectStatus'];
        _formData.projectSoftCopyLocation = userDetails['project']['ProjectSoftCopyLocation'] ?? '';

        final ganttDetails = await ApiService.fetchAllGanttOfAProject(
          projectId,
        );
        if (ganttDetails.isNotEmpty) {
          initialProjectGantts = ganttDetails;
        }

        final budgetDetails = await ApiService.fetchAllBudgetOfAProject(
          projectId,
        );
        if (budgetDetails.isNotEmpty) {
          initialProjectBudget = budgetDetails;
        }
      });
    }

    return true;
  }

  void _doUpdate(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final dialog = AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        title: "Confirm Update this project?",
        width: kDialogWidth,
        btnOkText: "Yes",
        btnOkOnPress: () async {
          _uploadMethodologyFiles();
          _uploadchairmanOfDepartmentSealFiles();
          _uploadchairmanOfDepartmentSignatureFiles();
          _uploadProjectSoftCopyFiles();

          final updateProjectData = {
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
            'TotalBudgetOfResearchProposalTK': int.parse(_formData.totalBudgetOfResearchProposal),
            'ExternalAgencyFundingSource': _formData.hasThisProposalBeenSubmittedToAnyOtherAgency,
            'ExternalAgencyFundingSourcesName': _formData.nameOfTheAgency,
            'ExternalAgencyFundingSourcesSubmissionDate': _formData.dateOfSubmission,
            'CommitmentOtherResearchProject': _formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader,
            'CommitmentOtherResearchProjectName': _formData.nameOfTheProject,
            // Part II: Outline of The Research Proposal
            'ProjectDescription': _formData.introductionResearchProposal,
            'MethodologyFileLocation': _formData.methodologyFileLocation,
            'ProjectObjective': _formData.specificObjectivesProposal,
            'PstuNationalGoal': _formData.relevanceStrategicDevelopmentGoals,
            'PriorResearchOverview': _formData.briefReviewAlreadyPerformedReferences,
            'Methodology': _formData.methodology,
            'ExpectedOutput': _formData.expectedOutputs,
            'SuccessIndicators': _formData.successIndicators,
            'Beneficiaries': _formData.beneficiaries,
            // // Inputs
            'ManPowerExisting': _formData.manPowerExisting,
            'ManPowerRequired': _formData.manPowerRequired,
            'SmallEquipmentExisting': _formData.smallEquipmentExisting,
            'SmallEquipmentRequired': _formData.smallEquipmentRequired,
            'ResearchMaterialsExisting': _formData.researchMaterialsExisting,
            'ResearchMaterialsRequired': _formData.researchMaterialsRequired,
            'OtherExisting': _formData.othersExisting,
            'OtherRequired': _formData.othersRequired,
            // // Signature
            'CreatorUserID': _formData.piUserID,
            'CoPiUserID': _formData.coPiUserID,
            'StudentUserID': _formData.studentUserID,

            'CreatorUserSealLocation': _formData.piSealLocation,
            'CreatorUserSignatureLocation': _formData.piSignatureLocation,
            'CreatorUserSignatureDate': _formData.piSignatureDate,

            'ChairmanOfDepartmentComment': _formData.commentsOfTheChairmanOfTheDepartment,
            'ChairmanOfDepartmentSealLocation': _formData.chairmanOfDepartmentSealFileLocation,
            'ChairmanOfDepartmentSignatureLocation': _formData.chairmanOfDepartmentSignatureFileLocation,
            'ChairmanOfDepartmentSignatureDate': _formData.dateOfChairmanOfTheDepartment,

            'ProjectStatus': _formData.projectStatus,
            'ProjectSoftCopyLocation': _formData.projectSoftCopyLocation,
          };
          // here should make a api request to create project with the updateProjectData
          final responseBody = await ApiService.updateProjectDetails(int.parse(widget.projectID), updateProjectData);

          // Iterate through the list of initialProjectGantts and update ganttData

          for (int i = 0; i < initialProjectGantts.length; i++) {
            Map<String, dynamic> ganttData = initialProjectGantts[i];
            // Get the corresponding FormBuilderState using GlobalKey
            final formState = GlobalKey<FormBuilderState>().currentState;

            if (formState != null && formState.saveAndValidate()) {
              // Update ganttData with the updated form values
              ganttData['Activity'] = formState.value['work_activity'];
              ganttData['ActivityStatus'] = formState.value['activity_status'];

              // Save the updated date values (StartDate and EndDate) in the desired format
              final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
              final DateTimeRange dateRange = formState.value['duration'];
              ganttData['StartDate'] = formatter.format(dateRange.start);
              ganttData['EndDate'] = formatter.format(dateRange.end);
            }

            ganttFormDataForUpload.add(ganttData);
          }

          final responseBodyGantt = await ApiService.updateProjectGanttDetails(int.parse(widget.projectID), ganttFormDataForUpload);

          // Iterate through the list of initialProjectBudget and update budgetData

          for (int i = 0; i < initialProjectBudget.length; i++) {
            Map<String, dynamic> budgetData = initialProjectBudget[i];
            // Get the corresponding FormBuilderState using GlobalKey
            final formState = GlobalKey<FormBuilderState>().currentState;

            if (formState != null && formState.saveAndValidate()) {
              // Update budgetData with the updated form values
              budgetData['SerialNo'] = formState.value['sl_no'];
              budgetData['Item'] = formState.value['item'];
              budgetData['Quantity'] = formState.value['quantity'];
              budgetData['UnitPrice'] = formState.value['unit_price'];
              budgetData['TotalCost'] = formState.value['total_cost_tk'];
            }

            budgetFormDataForUpload.add(budgetData);
          }

          final responseBodyBudget = await ApiService.updateProjectBudgetDetails(int.parse(widget.projectID), budgetFormDataForUpload);

          if (responseBody['statuscode'] == 200 && responseBodyGantt['statuscode'] == 200 && responseBodyBudget['statuscode'] == 200) {
            final d = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: "Project Updated Successfully",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () => GoRouter.of(context).go(RouteUri.myprojects),
            );
            d.show();
          }
        },
        btnCancelText: "No",
        btnCancelOnPress: () {},
      );
      dialog.show();
    }
  }

  void _doDelete(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();
    TextEditingController reasonController = TextEditingController();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: "Confirm Delete this project?",
      desc: "Project will be deleted. This action cannot be undone. Press Yes to confirm.",
      width: kDialogWidth,
      btnOkText: "Yes",
      btnOkOnPress: () async {
        late AwesomeDialog reasonDialog;
        reasonDialog = AwesomeDialog(
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.info,
          width: kDialogWidth * 2.0,
          keyboardAware: true,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Reason for deletion',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 10,
                ),
                Material(
                  elevation: 0,
                  color: Colors.blueGrey.withAlpha(40),
                  child: TextFormField(
                    controller: reasonController,
                    autofocus: true,
                    minLines: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reason for deletion';
                      }
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Reason for deletion',
                      prefixIcon: Icon(Icons.text_fields),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                AnimatedButton(
                  isFixedHeight: false,
                  text: 'Delete Now',
                  pressEvent: () async {
                    reasonDialog.dismiss();
                    // here should make a api request to delete project
                    final responseBody = await ApiService.deleteProject(int.parse(widget.projectID));
                    if (responseBody['statusCode'] == 200) {
                      final dialog = AwesomeDialog(
                        context: context,
                        dialogType: DialogType.success,
                        title: responseBody['message'],
                        width: kDialogWidth,
                        btnOkText: 'OK',
                        btnOkOnPress: () => GoRouter.of(context).go(RouteUri.myprojects),
                      );
                      dialog.show();
                    } else if (responseBody['statusCode'] == 403) {
                      final dialog = AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        title: "You don't have permission to delete this project.",
                        desc: "Please contact admin.",
                        width: kDialogWidth,
                        btnOkText: 'Send Delete Request to Admin',
                        btnOkOnPress: () async {
                          // Send a delete request to admin
                          final responseBody = await ApiService.requestProjectDeletionToAdmin(int.parse(_formData.projectID), reasonController.text);

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
                          }
                        },
                      );
                      dialog.show();
                    }
                  },
                )
              ],
            ),
          ),
        );
        reasonDialog.show();
      },
      btnCancelText: "No",
      btnCancelOnPress: () {},
    );
    dialog.show();
  }

  @override
  void initState() {
    super.initState();
    _usersFuture = ApiService.getAllUsersExceptStudents();
    _studentUsersFuture = ApiService.getOnlyStudentUser();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.myprojects,
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
    final appColorScheme = themeData.extension<AppColorScheme>()!;
    final pageTitle = 'Project - ID: ${widget.projectID.isEmpty ? 'New Project' : widget.projectID}';

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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: (kDefaultPadding * 22),
                                      child: FormBuilderTextField(
                                        initialValue: _formData.rtcCode,
                                        name: 'RTC_Code',
                                        decoration: const InputDecoration(
                                          labelText: 'Code number of the project to be assigned by RTC',
                                          hintText: 'RTC Code',
                                          border: OutlineInputBorder(),
                                          floatingLabelBehavior: FloatingLabelBehavior.always,
                                        ),
                                        validator: FormBuilderValidators.required(),
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
                                            initialValue: DateTime.parse(_formData.dateOfReceived),
                                            textAlign: TextAlign.center,
                                            format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                                            validator: FormBuilderValidators.required(),
                                            onChanged: (value) => (_formData.dateOfReceived = value.toString()),
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
                              initialValue: _formData.projectTitle,
                              name: 'project_title',
                              decoration: const InputDecoration(
                                labelText: 'Project Title',
                                hintText: 'Project Title',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
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
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDropdown(
                                          initialValue: _formData.nameOfCollaboratingDepartmentDepartment,
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
                                          onChanged: (value) => (_formData.nameOfCollaboratingDepartmentDepartment = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          initialValue: _formData.addressOfCollaboratingDepartmentDepartment,
                                          name: 'address_of_collaborating_department',
                                          decoration: const InputDecoration(
                                            labelText: 'Address of Collaborating Department',
                                            hintText: 'Address of Collaborating Department',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
                                          onChanged: (value) => (_formData.addressOfCollaboratingDepartmentDepartment = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDropdown(
                                          initialValue: _formData.nameOfCollaboratingDepartmentInstitute,
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
                                          initialValue: _formData.addressOfCollaboratingDepartmentInstitute,
                                          name: 'address_of_collaborating_institute',
                                          decoration: const InputDecoration(
                                            labelText: 'Address of Collaborating Institute',
                                            hintText: 'Address of Collaborating Institute',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
                                          onChanged: (value) => (_formData.addressOfCollaboratingDepartmentInstitute = value ?? ''),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                      child: FormBuilderRadioGroup<String>(
                                        initialValue: _formData.natureOfTheResearchProposal,
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
                              initialValue: _formData.locationOfFieldActivities,
                              name: 'location_of_field_activities',
                              decoration: const InputDecoration(
                                labelText: 'Location Of Field Activities',
                                hintText: '(Please specify major location(s) of research activities such as laboratory, farm, farmer’s field etc.)',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
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
                                          initialValue: DateTimeRange(
                                            start: DateTime.parse(_formData.annualDurationOfResearchProject.split(' - ')[0].trim()),
                                            end: DateTime.parse(_formData.annualDurationOfResearchProject.split(' - ')[1].trim()),
                                          ),
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
                                          onChanged: (value) => (_formData.annualDurationOfResearchProject = value.toString()),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderDateRangePicker(
                                          initialValue: DateTimeRange(
                                            start: DateTime.parse(_formData.longTermDurationOfResearchProject.split(' - ')[0].trim()),
                                            end: DateTime.parse(_formData.longTermDurationOfResearchProject.split(' - ')[1].trim()),
                                          ),
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
                                          onChanged: (value) => (_formData.longTermDurationOfResearchProject = value.toString()),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          initialValue: _formData.totalBudgetOfResearchProposal,
                                          name: 'total_budget_of_research_proposal',
                                          decoration: const InputDecoration(
                                            prefixText: '৳ ',
                                            labelText: 'Total Budget Of Research Proposal',
                                            hintText: '(Taka)',
                                            border: OutlineInputBorder(),
                                            floatingLabelBehavior: FloatingLabelBehavior.always,
                                          ),
                                          validator: FormBuilderValidators.required(),
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
                                          initialValue: _formData.hasThisProposalBeenSubmittedToAnyOtherAgency,
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
                                          // onSaved: (value) => (_formData.hasThisProposalBeenSubmittedToAnyOtherAgency = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      // if (_formKey.currentState?.fields['has_this_proposal_been_submitted_to_any_other_agency']?.value == 'Submitted') ...[
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'name_of_the_agency',
                                          initialValue: _formData.nameOfTheAgency,
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
                                          // ignore: unnecessary_null_comparison
                                          initialValue: _formData.dateOfSubmission != null ? DateTime.tryParse(_formData.dateOfSubmission) : null,
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
                                          initialValue: _formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader,
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
                                          // onSaved: (value) => (_formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader = value ?? ''),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      // if (_formKey.currentState?.fields['is_there_any_commitment_to_other_research_project_as_pi_team_leader']?.value == 'Yes')
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: FormBuilderTextField(
                                          name: 'name_of_the_project',
                                          initialValue: _formData.nameOfTheProject,
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
                              initialValue: _formData.introductionResearchProposal,
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'introduction_identification_of_problem_and_justification_of_the_research_proposal',
                              decoration: const InputDecoration(
                                labelText: 'Introduction, Identification of Problem & Justification of The Research Proposal',
                                hintText: '(300 Words Maximum)',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.maxWordsCount(350),
                              ]),
                              onChanged: (value) => (_formData.introductionResearchProposal = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              initialValue: _formData.specificObjectivesProposal,
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
                              onChanged: (value) => (_formData.specificObjectivesProposal = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              initialValue: _formData.relevanceStrategicDevelopmentGoals,
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
                              onChanged: (value) => (_formData.relevanceStrategicDevelopmentGoals = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              initialValue: _formData.briefReviewAlreadyPerformedReferences,
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'brief_review_of_works_already_performed_in_progress_elsewhere_with_list_of_references',
                              decoration: const InputDecoration(
                                labelText: 'Brief Review of Works Already Performed / in Progress Elsewhere With List of References',
                                hintText: '(Maximum 500 Words)',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.maxWordsCount(550),
                              ]),
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
                                        width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                        child: FormBuilderTextField(
                                          initialValue: _formData.methodology,
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
                                          onChanged: (value) => (_formData.methodology = value ?? ''),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
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
                                            Text('Flowchart / Diagram'),
                                          ],
                                        ),
                                        onChanged: _onMethodologyFileSelected,
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                        child: Stack(
                                          children: [
                                            _methodologyFileBytes != null
                                                ? Image.memory(
                                                    _methodologyFileBytes!,
                                                    fit: BoxFit.cover, // Adjust image to cover the entire space
                                                    width: 150, // Adjust width as needed
                                                    // height: 50, // Adjust height as needed
                                                  )
                                                : const CircularProgressIndicator(),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              initialValue: _formData.expectedOutputs,
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
                              onChanged: (value) => (_formData.expectedOutputs = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              initialValue: _formData.successIndicators,
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
                              onChanged: (value) => (_formData.successIndicators = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              initialValue: _formData.beneficiaries,
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
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true, // Ensure the ListView takes only the necessary space
                                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
                                    itemCount: initialProjectGantts.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> ganttData = initialProjectGantts[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                                        child: FormBuilder(
                                          // Use a unique key for each form to manage state separately
                                          key: GlobalKey<FormBuilderState>(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                                child: FormBuilderTextField(
                                                  initialValue: ganttData['Activity'], // Use ganttData instead of _formData
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: null, // Allow unlimited lines
                                                  name: 'work_activity',
                                                  decoration: const InputDecoration(
                                                    labelText: 'Work/Activity',
                                                    hintText: 'Work/Activity',
                                                    border: OutlineInputBorder(),
                                                    floatingLabelBehavior: FloatingLabelBehavior.always,
                                                  ),
                                                  onChanged: (value) => (ganttData['Activity'] = value ?? ''), // Update ganttData
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.2)),
                                                child: FormBuilderDateRangePicker(
                                                    initialValue: DateTimeRange(
                                                      start: DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(ganttData['StartDate']),
                                                      end: DateFormat('EEE, dd MMM yyyy HH:mm:ss').parse(ganttData['EndDate']),
                                                    ),
                                                    name: 'duration',
                                                    firstDate: DateTime(1970),
                                                    lastDate: DateTime(2030),
                                                    format: DateFormat('MMMM d, yyyy'),
                                                    decoration: const InputDecoration(
                                                      labelText: 'Duration',
                                                      hintText: 'Duration',
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          final DateFormat formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
                                                          ganttData['StartDate'] = formatter.format(value.start);
                                                          ganttData['EndDate'] = formatter.format(value.end);
                                                        });
                                                      }
                                                    }),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.1)),
                                                child: FormBuilderChoiceChip(
                                                  initialValue: ganttData['ActivityStatus'],
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
                                                  onChanged: (value) => (ganttData['ActivityStatus'] = value ?? ''), // Update ganttData
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
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
                                    initialValue: _formData.manPowerExisting,
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
                                    onChanged: (value) => (_formData.manPowerExisting = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    initialValue: _formData.manPowerRequired,
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
                                    initialValue: _formData.smallEquipmentExisting,
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
                                    onChanged: (value) => (_formData.smallEquipmentExisting = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    initialValue: _formData.smallEquipmentRequired,
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
                                    initialValue: _formData.researchMaterialsExisting,
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
                                    onChanged: (value) => (_formData.researchMaterialsExisting = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    initialValue: _formData.researchMaterialsRequired,
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
                                    initialValue: _formData.othersExisting,
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
                                    onChanged: (value) => (_formData.othersExisting = value ?? ''),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: FormBuilderTextField(
                                    initialValue: _formData.othersRequired,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null, // Allow unlimited lines
                                    name: 'others_required',
                                    decoration: const InputDecoration(
                                      labelText: 'Others Required',
                                      hintText: 'Others Required',
                                      border: OutlineInputBorder(),
                                      floatingLabelBehavior: FloatingLabelBehavior.always,
                                    ),
                                    validator: FormBuilderValidators.required(),
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
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true, // Ensure the ListView takes only the necessary space
                                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling of the ListView
                                    itemCount: initialProjectBudget.length,
                                    itemBuilder: (context, index) {
                                      Map<String, dynamic> budgetData = initialProjectBudget[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                                        child: FormBuilder(
                                          // Use a unique key for each form to manage state separately
                                          key: GlobalKey<FormBuilderState>(),
                                          autovalidateMode: AutovalidateMode.onUserInteraction,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['SerialNo'].toString(),
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
                                                  onChanged: (value) => (budgetData['SerialNo'] = value ?? 0),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['Item'],
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
                                                  onChanged: (value) => (budgetData['Item'] = value ?? ''),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['Quantity'].toString(),
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
                                                  onChanged: (value) => (budgetData['Quantity'] = value ?? 0),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['UnitPrice'].toString(),
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
                                                  onChanged: (value) => (budgetData['UnitPrice'] = value ?? 0.0),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                                child: FormBuilderTextField(
                                                  initialValue: budgetData['TotalCost'].toString(),
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
                                                  onChanged: (value) => (budgetData['TotalCost'] = value ?? 0.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
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
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                      child: Stack(
                                        children: [
                                          _piSignatureFileBytes != null
                                              ? Image.memory(
                                                  _piSignatureFileBytes!,
                                                  fit: BoxFit.cover, // Adjust image to cover the entire space
                                                  // width: 150, // Adjust width as needed
                                                  height: 50, // Adjust height as needed
                                                )
                                              : const CircularProgressIndicator(),
                                        ],
                                      ),
                                    ),
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
                                      // ignore: unnecessary_null_comparison
                                      initialValue: _formData.piSignatureDate != null ? DateTime.tryParse(_formData.piSignatureDate) : null,
                                      textAlign: TextAlign.center,
                                      format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
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
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                      child: Stack(
                                        children: [
                                          _piSealFileBytes != null
                                              ? Image.memory(
                                                  _piSealFileBytes!,
                                                  fit: BoxFit.cover, // Adjust image to cover the entire space
                                                  // width: 150, // Adjust width as needed
                                                  height: 50, // Adjust height as needed
                                                )
                                              : const CircularProgressIndicator(),
                                        ],
                                      ),
                                    ),
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
                          initialValue: _formData.commentsOfTheChairmanOfTheDepartment,
                          keyboardType: TextInputType.multiline,
                          maxLines: null, // Allow unlimited lines
                          name: 'comments_of_the_chairman_of_the_department',
                          decoration: const InputDecoration(
                            labelText: 'Comments of the Chairman of the Department',
                            hintText: 'Comments of the Chairman of the Department',
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: FormBuilderValidators.required(),
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
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                      child: Stack(
                                        children: [
                                          _chairmanSignatureFileBytes != null
                                              ? Image.memory(
                                                  _chairmanSignatureFileBytes!,
                                                  fit: BoxFit.cover, // Adjust image to cover the entire space
                                                  // width: 150, // Adjust width as needed
                                                  height: 50, // Adjust height as needed
                                                )
                                              : const CircularProgressIndicator(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
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
                                      // ignore: unnecessary_null_comparison
                                      initialValue: _formData.dateOfChairmanOfTheDepartment != null ? DateTime.tryParse(_formData.dateOfChairmanOfTheDepartment) : null,
                                      textAlign: TextAlign.center,
                                      format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
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
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                      child: Stack(
                                        children: [
                                          _chairmanSealFileBytes != null
                                              ? Image.memory(
                                                  _chairmanSealFileBytes!,
                                                  fit: BoxFit.cover, // Adjust image to cover the entire space
                                                  // width: 150, // Adjust width as needed
                                                  height: 50, // Adjust height as needed
                                                )
                                              : const CircularProgressIndicator(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: kDefaultPadding),
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
                              CardHeader(
                                title: _formData.piName,
                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                showDivider: false,
                              ),
                              // CardBody(
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Padding(
                              //         padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                              //         child: CardHeader(
                              //           title: _formData.piName,
                              //           backgroundColor: Color.fromARGB(255, 74, 89, 96),
                              //           titleColor: Color.fromARGB(255, 151, 204, 197),
                              //           showDivider: false,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: kDefaultPadding),
                      SizedBox(
                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                        child: _CoPi(
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
              child: _Student(
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
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: _formData.projectStatus == 'Pending' || _formData.projectStatus == 'Rejected',
                                  child: SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const CardHeader(
                                            title: 'Project Status :',
                                            backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                            titleColor: Color.fromARGB(255, 151, 204, 197),
                                            showDivider: false,
                                          ),
                                          CardHeader(
                                            title: _formData.projectStatus,
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
                                  visible: _formData.projectStatus == 'Approved',
                                  child: SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: FormBuilderDropdown(
                                      initialValue: _formData.projectStatus,
                                      name: 'project_status',
                                      decoration: const InputDecoration(
                                        labelText: 'Project Status',
                                        border: OutlineInputBorder(),
                                        hoverColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hintText: 'Select',
                                      ),
                                      focusColor: Colors.transparent,
                                      validator: FormBuilderValidators.required(),
                                      items: [
                                        'Approved',
                                        'Running',
                                        'Completed',
                                      ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                      onChanged: (value) => (_formData.projectStatus = value ?? ''),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                Visibility(
                                  visible: _formData.projectStatus != 'Pending' && _formData.projectStatus != 'Rejected',
                                  child: SizedBox(
                                    width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                    child: FormBuilderFilePicker(
                                      name: 'project_softcopy',
                                      // allowedExtensions: const ['jpg', 'png', 'pdf', 'jpeg'],
                                      allowMultiple: false,
                                      maxFiles: 1,
                                      type: FileType.any,
                                      previewImages: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Project SoftCopy File',
                                        border: OutlineInputBorder(),
                                      ),
                                      selector: const Row(
                                        children: [
                                          Icon(Icons.file_upload_rounded),
                                          Text('Project Report SoftCopy'),
                                        ],
                                      ),
                                      onChanged: _onProjectSoftCopyFileSelected,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                // const Spacer(),
                                Visibility(
                                  visible: _formData.projectSoftCopyLocation.isNotEmpty,
                                  child: SizedBox(
                                    height: 40.0,
                                    width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.warningOutlined,
                                      onPressed: () => _downloadProjectSoftCopy(_formData.projectSoftCopyLocation),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.file_download_outlined,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          const Text("Download SoftCopy"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: _formData.projectSoftCopyLocation.isEmpty,
                                  child: SizedBox(
                                    height: 40.0,
                                    width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding),
                                      child: Text(
                                        "Project SoftCopy Not Available yet",
                                        style: TextStyle(
                                          color: appColorScheme.info,
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
                    ])),
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.myprojects),
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
                                visible: widget.projectID.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: kDefaultPadding),
                                  child: SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.errorElevated,
                                      onPressed: () => _doDelete(context),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.delete_rounded,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          const Text("Delete"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: widget.projectID.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: kDefaultPadding),
                                  child: SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.successElevated,
                                      onPressed: () => _doUpdate(context),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.check_circle_outline_rounded,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          const Text("Update"),
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
  String projectID = '';
  String price = '';

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
  String piName = '';
  int piUserID = 0;
  String projectStatus = '';
  String projectSoftCopyLocation = '';
  String dateOfChairmanOfTheDepartment = '';
  String chairmanOfDepartmentSignatureFileLocation = '';
  String chairmanOfDepartmentSealFileLocation = '';
  String commentsOfTheChairmanOfTheDepartment = '';
  String piSignatureDate = '';
  String piSignatureLocation = '';
  String piSealLocation = '';
  String othersRequired = '';
  String othersExisting = '';
  String researchMaterialsRequired = '';
  String researchMaterialsExisting = '';
  String smallEquipmentRequired = '';
  String smallEquipmentExisting = '';
  String manPowerRequired = '';
  String manPowerExisting = '';
  String beneficiaries = '';
  String successIndicators = '';
  String expectedOutputs = '';
  String methodology = '';
  String briefReviewAlreadyPerformedReferences = '';
  String relevanceStrategicDevelopmentGoals = '';
  String specificObjectivesProposal = '';
  String introductionResearchProposal = '';
  String methodologyFileLocation = '';
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
  String addressOfCollaboratingDepartmentDepartment = '';
  String addressOfCollaboratingDepartmentInstitute = '';
  String nameOfCollaboratingDepartmentInstitute = '';
  String nameOfCollaboratingDepartmentDepartment = '';
  String projectTitle = '';
  String dateOfReceived = '';
  String rtcCode = '';
}

class _CoPi extends StatefulWidget {
  final Future<List<User>> usersFuture;
  final FormData formData;

  const _CoPi({required this.formData, required this.usersFuture, Key? key}) : super(key: key);

  @override
  _CoPiState createState() => _CoPiState();
}

class _CoPiState extends State<_CoPi> {
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
                        User? selectedUser = snapshot.data?.firstWhere(
                          (user) => user.userId == widget.formData.coPiUserID,
                          orElse: () => snapshot.data!.first,
                        );
                        return FormBuilderDropdown<User>(
                          name: 'co_pi_name',
                          initialValue: selectedUser,
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

class _Student extends StatefulWidget {
  final Future<List<User>> studentUsersFuture;
  final FormData formData;

  const _Student({required this.formData, required this.studentUsersFuture, Key? key}) : super(key: key);

  @override
  _StudentState createState() => _StudentState();
}

class _StudentState extends State<_Student> {
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
                        User? selectedUser = snapshot.data?.firstWhere(
                          (user) => user.userId == widget.formData.studentUserID,
                          orElse: () => snapshot.data!.first,
                        );
                        return FormBuilderDropdown<User>(
                          name: 'student_name',
                          initialValue: selectedUser,
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
