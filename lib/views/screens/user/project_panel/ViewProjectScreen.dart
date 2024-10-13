// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/views/screens/pdf_generate/pdf_generator.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'dart:html' as html; // Import the 'html' library for web-specific functionalities

class ViewProjectScreen extends StatefulWidget {
  final String projectID;

  const ViewProjectScreen({
    Key? key,
    required this.projectID,
  }) : super(key: key);

  @override
  State<ViewProjectScreen> createState() => _ViewProjectScreenState();
}

class _ViewProjectScreenState extends State<ViewProjectScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  late List<dynamic> initialProjectGantts = [];
  late List<dynamic> initialProjectBudget = [];
  Future<bool>? _future;
  Uint8List? _methodologyFileBytes;
  Uint8List? _piSignatureFileBytes;
  Uint8List? _piSealFileBytes;
  Uint8List? _chairmanSignatureFileBytes;
  Uint8List? _chairmanSealFileBytes;
  Uint8List? _downloadProjectFileBytes;

  void _pdfHandleButtonPress() {
    final d = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: "Project Proposal Generating.....",
      desc: "Please wait...5 seconds",
      width: kDialogWidth,
      headerAnimationLoop: true,
    );
    Future.wait([
      d.show(),
      Future.delayed(const Duration(seconds: 5), () => d.dismiss()),
      generateProjectProposalPDFUser(
          _formData, context, _methodologyFileBytes, _piSignatureFileBytes, _piSealFileBytes, _chairmanSignatureFileBytes, _chairmanSealFileBytes, initialProjectGantts, initialProjectBudget),
    ]).then((_) {
      d.dismiss();
    });
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
        if (_formData.dateOfReceived != null && _formData.dateOfReceived.isNotEmpty) {
          _formData.dateOfReceived = DateFormat("MMMM d, yyyy").format(DateTime.parse(_formData.dateOfReceived));
        }
        // Part I: Research Proposal Identification Data
        _formData.projectTitle = userDetails['project']['ProjectTitle'];
        _formData.natureOfTheResearchProposal = userDetails['project']['NatureOfResearchProposal'];
        _formData.nameOfCollaboratingDepartmentDepartment = userDetails['project']['NameOfCollaboratingDepartments'];
        _formData.addressOfCollaboratingDepartmentDepartment = userDetails['project']['AddressOfCollaboratingDepartments'];

        _formData.nameOfCollaboratingDepartmentInstitute = userDetails['project']['NameOfCollaboratingInstitutes'];
        _formData.addressOfCollaboratingDepartmentInstitute = userDetails['project']['AddressOfCollaboratingInstitutes'];
        _formData.locationOfFieldActivities = userDetails['project']['LocationOfFieldActivities'];
        _formData.annualDurationOfResearchProject = userDetails['project']['DurationOfResearchProjectAnnual'] ?? "";
        _formData.longTermDurationOfResearchProject = userDetails['project']['DurationOfResearchProjectLongTerm'] ?? "";
        _formData.totalBudgetOfResearchProposal = userDetails['project']['TotalBudgetOfResearchProposalTK'].toString();
        _formData.hasThisProposalBeenSubmittedToAnyOtherAgency = userDetails['project']['ExternalAgencyFundingSource'];
        _formData.nameOfTheAgency = userDetails['project']['ExternalAgencyFundingSourcesName'];
        _formData.dateOfSubmission = userDetails['project']['ExternalAgencyFundingSourcesSubmissionDate'] ?? "";
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
        _formData.coPiUserID = userDetails['project']['CoPiUserID'] ?? 0;
        _formData.studentUserID = userDetails['project']['StudentUserID'] ?? 0;

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
        if (_formData.piSignatureDate != null && _formData.piSignatureDate.isNotEmpty) {
          _formData.piSignatureDate = DateFormat("MMMM d, yyyy").format(DateTime.parse(_formData.piSignatureDate));
        }

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
        if (_formData.dateOfChairmanOfTheDepartment != null && _formData.dateOfChairmanOfTheDepartment.isNotEmpty) {
          _formData.dateOfChairmanOfTheDepartment = DateFormat("MMMM d, yyyy").format(DateTime.parse(_formData.dateOfChairmanOfTheDepartment));
        }

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

        // get student user details
        if (_formData.studentUserID != null && _formData.studentUserID != 0) {
          final studentUserDetails = await ApiService.getSpecificUser(
            _formData.studentUserID,
          );
          if (studentUserDetails['statuscode'] == 401) {
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
          } else {
            _formData.studentName = studentUserDetails['user']['FirstName'] + ' ' + studentUserDetails['user']['LastName'];
            _formData.studentId = studentUserDetails['user']['StudentID'].toString();
            _formData.studentRegNo = studentUserDetails['user']['StudentRegNo'] ?? '';
            _formData.firstEnrollmentSemester = studentUserDetails['user']['FirstEnrollmentSemester'] ?? '';
            _formData.cgpaUndergraduateLevel = studentUserDetails['user']['UndergraduateCGPALevel'] ?? '';
          }
        } else {
          // Reset student related fields if studentUserID is null or 0
          _formData.studentName = '';
          _formData.studentId = '';
          _formData.studentRegNo = '';
          _formData.firstEnrollmentSemester = '';
          _formData.cgpaUndergraduateLevel = '';
        }

        // get PI user details
        final piUserDetails = await ApiService.getSpecificUser(
          _formData.piUserID,
        );
        if (piUserDetails['statuscode'] == 401) {
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
        _formData.piName = piUserDetails['user']['FirstName'] + ' ' + piUserDetails['user']['LastName'];
        _formData.piPresentAddress = piUserDetails['user']['PresentAddress'] ?? '';
        _formData.piPositionEnglish = piUserDetails['user']['PositionEnglish'] ?? '';
        _formData.piDepartmentName = piUserDetails['user']['DepartmentName'] ?? '';
        _formData.piFacultyName = piUserDetails['user']['FacultyName'] ?? '';
        _formData.piBasicPay = piUserDetails['user']['BasicPay'].toString();
        _formData.piInstituteLocation = piUserDetails['user']['InstituteLocation'] ?? '';
        _formData.piInstituteName = piUserDetails['user']['InstituteName'] ?? '';
        _formData.piPermanentAddress = piUserDetails['user']['PermanentAddress'] ?? '';
        _formData.piEmail = piUserDetails['user']['Email'] ?? '';
        _formData.piPhone = piUserDetails['user']['Phone'] ?? '';
        _formData.piSalaryScale = piUserDetails['user']['SalaryScale'] ?? '';
        _formData.piHighestAcademicQualification = piUserDetails['user']['HighestAcademicQualification'] ?? '';
        _formData.piHighestAcademicQualificationUniversity = piUserDetails['user']['HighestAcademicQualificationUniversity'] ?? '';
        _formData.piHighestAcademicQualificationCountry = piUserDetails['user']['HighestAcademicQualificationCountry'] ?? '';
        _formData.piHighestAcademicQualificationYear = piUserDetails['user']['HighestAcademicQualificationYear'].toString();
        _formData.piAreaOfExpertise = piUserDetails['user']['AreaOfExpertise'] ?? '';
        _formData.piExperienceInResearch = piUserDetails['user']['ExperienceInResearch'].toString();
        _formData.piExperienceInTeaching = piUserDetails['user']['Teaching'].toString();
        _formData.piReferencesOfLatestPublications = piUserDetails['user']['ReferencesOfLatestPublications'] ?? '';

        // get CO-PI user details
        if (_formData.coPiUserID != null && _formData.coPiUserID != 0) {
          final coPiUserDetails = await ApiService.getSpecificUser(
            _formData.coPiUserID,
          );
          if (coPiUserDetails['statuscode'] == 401) {
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
          } else {
            _formData.coPiName = coPiUserDetails['user']['FirstName'] + ' ' + coPiUserDetails['user']['LastName'];
            _formData.coPiPresentAddress = coPiUserDetails['user']['PresentAddress'] ?? '';
            _formData.coPiPermanentAddress = coPiUserDetails['user']['PermanentAddress'] ?? '';
            _formData.coPiPositionEnglish = coPiUserDetails['user']['PositionEnglish'] ?? '';
            _formData.coPiDepartmentName = coPiUserDetails['user']['DepartmentName'] ?? '';
            _formData.coPiFacultyName = coPiUserDetails['user']['FacultyName'] ?? '';
            _formData.coPiBasicPay = coPiUserDetails['user']['BasicPay'].toString();
            _formData.coPiInstituteLocation = coPiUserDetails['user']['InstituteLocation'] ?? '';
            _formData.coPiInstituteName = coPiUserDetails['user']['InstituteName'] ?? '';
            _formData.coPiEmail = coPiUserDetails['user']['Email'] ?? '';
            _formData.coPiPhone = coPiUserDetails['user']['Phone'] ?? '';
            _formData.coPiSalaryScale = coPiUserDetails['user']['SalaryScale'] ?? '';
            _formData.coPiHighestAcademicQualification = coPiUserDetails['user']['HighestAcademicQualification'] ?? '';
            _formData.coPiHighestAcademicQualificationUniversity = coPiUserDetails['user']['HighestAcademicQualificationUniversity'] ?? '';
            _formData.coPiHighestAcademicQualificationCountry = coPiUserDetails['user']['HighestAcademicQualificationCountry'] ?? '';
            _formData.coPiHighestAcademicQualificationYear = coPiUserDetails['user']['HighestAcademicQualificationYear'].toString();
            _formData.coPiAreaOfExpertise = coPiUserDetails['user']['AreaOfExpertise'] ?? '';
            _formData.coPiExperienceInResearch = coPiUserDetails['user']['ExperienceInResearch'].toString();
            _formData.coPiExperienceInTeaching = coPiUserDetails['user']['Teaching'].toString();
            _formData.coPiReferencesOfLatestPublications = coPiUserDetails['user']['ReferencesOfLatestPublications'] ?? '';
          }
        } else {
          // Reset CO-PI related fields if coPiUserID is null or 0
          _formData.coPiName = '';
          _formData.coPiPresentAddress = '';
          _formData.coPiPermanentAddress = '';
          _formData.coPiPositionEnglish = '';
          _formData.coPiDepartmentName = '';
          _formData.coPiFacultyName = '';
          _formData.coPiBasicPay = '';
          _formData.coPiInstituteLocation = '';
          _formData.coPiInstituteName = '';
          _formData.coPiEmail = '';
          _formData.coPiPhone = '';
          _formData.coPiSalaryScale = '';
          _formData.coPiHighestAcademicQualification = '';
          _formData.coPiHighestAcademicQualificationUniversity = '';
          _formData.coPiHighestAcademicQualificationCountry = '';
          _formData.coPiHighestAcademicQualificationYear = '';
          _formData.coPiAreaOfExpertise = '';
          _formData.coPiExperienceInResearch = '';
          _formData.coPiExperienceInTeaching = '';
          _formData.coPiReferencesOfLatestPublications = '';
        }
      });
    }

    return true;
  }

  void _goEditPage(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Are you sure you want to edit this project?",
      width: kDialogWidth,
      btnOkText: "Yes",
      btnOkOnPress: () => GoRouter.of(context).go('${RouteUri.editproject}?projectid=${widget.projectID}'),
      btnCancelText: "No",
      btnCancelOnPress: () {},
    );
    dialog.show();
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
                            child: Row(
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
                                          title: 'RTC Code :',
                                          backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                          titleColor: Color.fromARGB(255, 151, 204, 197),
                                          showDivider: false,
                                        ),
                                        CardHeader(
                                          title: _formData.rtcCode,
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
                                      width: (kDefaultPadding * 28),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Date of Received :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.dateOfReceived,
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
                                    title: 'Project Title :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  CardHeader(
                                    title: _formData.projectTitle,
                                    backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                    titleColor: const Color.fromARGB(255, 238, 216, 221),
                                    showDivider: false,
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
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const CardHeader(
                                                title: 'Name of Collaborating Department :',
                                                backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                titleColor: Color.fromARGB(255, 151, 204, 197),
                                                showDivider: false,
                                              ),
                                              CardHeader(
                                                title: _formData.nameOfCollaboratingDepartmentDepartment,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const CardHeader(
                                                title: 'Address of Collaborating Department :',
                                                backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                titleColor: Color.fromARGB(255, 151, 204, 197),
                                                showDivider: false,
                                              ),
                                              CardHeader(
                                                title: _formData.addressOfCollaboratingDepartmentDepartment,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const CardHeader(
                                                title: 'Name of Collaborating Institute :',
                                                backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                titleColor: Color.fromARGB(255, 151, 204, 197),
                                                showDivider: false,
                                              ),
                                              CardHeader(
                                                title: _formData.nameOfCollaboratingDepartmentInstitute,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const CardHeader(
                                                title: 'Address of Collaborating Institute :',
                                                backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                titleColor: Color.fromARGB(255, 151, 204, 197),
                                                showDivider: false,
                                              ),
                                              CardHeader(
                                                title: _formData.addressOfCollaboratingDepartmentInstitute,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                    ]),
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
                                    // const SizedBox(height: 20),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Nature of The Research Proposal :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.natureOfTheResearchProposal,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Location Of Field Activities :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.locationOfFieldActivities,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.32) - (kDefaultPadding * 0.32)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Total Budget Of Research Proposal :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.totalBudgetOfResearchProposal,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // const SizedBox(height: 20),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Annual Duration Of Research Project :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title:
                                                  "${DateFormat('dd MMM yyyy').format(DateTime.parse(_formData.annualDurationOfResearchProject.split(" - ")[0].split(" ")[0]))}  To  ${DateFormat('dd MMM yyyy').format(DateTime.parse(_formData.annualDurationOfResearchProject.split(" - ")[1].split(" ")[0]))}",
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Long-term Duration Of Research Project :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              // 2020-07-01 00:00:00.000
                                              title:
                                                  "${DateFormat('dd MMM yyyy').format(DateTime.parse(_formData.longTermDurationOfResearchProject.split(" - ")[0].split(" ")[0]))}  To  ${DateFormat('dd MMM yyyy').format(DateTime.parse(_formData.longTermDurationOfResearchProject.split(" - ")[1].split(" ")[0]))}",

                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
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
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const CardHeader(
                                                title: 'Has This Proposal Been Submitted To Any Other Agency For Financial Assistance?',
                                                backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                titleColor: Color.fromARGB(255, 151, 204, 197),
                                                showDivider: false,
                                              ),
                                              CardHeader(
                                                title: _formData.hasThisProposalBeenSubmittedToAnyOtherAgency,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(height: 30),
                                      Visibility(
                                        visible: _formData.hasThisProposalBeenSubmittedToAnyOtherAgency == "Submitted",
                                        child: SizedBox(
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const CardHeader(
                                                  title: 'Name of The Agency :',
                                                  backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                  titleColor: Color.fromARGB(255, 151, 204, 197),
                                                  showDivider: false,
                                                ),
                                                CardHeader(
                                                  title: _formData.nameOfTheAgency,
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
                                        visible: _formData.hasThisProposalBeenSubmittedToAnyOtherAgency == "Submitted",
                                        child: SizedBox(
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const CardHeader(
                                                  title: 'Date Of Submission :',
                                                  backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                  titleColor: Color.fromARGB(255, 151, 204, 197),
                                                  showDivider: false,
                                                ),
                                                CardHeader(
                                                  title: _formData.dateOfSubmission,
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const CardHeader(
                                                title: 'Is There Any Commitment to Other Research Project(S) as PI / Team Leader?',
                                                backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                titleColor: Color.fromARGB(255, 151, 204, 197),
                                                showDivider: false,
                                              ),
                                              CardHeader(
                                                title: _formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader,
                                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: _formData.isThereAnyCommitmentToOtherResearchProjectAsPiTeamLeader == "Yes",
                                        child: SizedBox(
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const CardHeader(
                                                  title: 'Name of The Project :',
                                                  backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                  titleColor: Color.fromARGB(255, 151, 204, 197),
                                                  showDivider: false,
                                                ),
                                                CardHeader(
                                                  title: _formData.nameOfTheProject,
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
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
                                    title: 'Introduction, Identification of Problem & Justification of The Research Proposal :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  ReadMoreText(
                                    text: _formData.introductionResearchProposal,
                                    maxLength: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CardHeader(
                                    title: 'Specific Objectives of The Proposal :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  ReadMoreText(
                                    text: _formData.specificObjectivesProposal,
                                    maxLength: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CardHeader(
                                    title: 'Relevance to The Strategic Plan of Pstu & National Development Goals :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  ReadMoreText(
                                    text: _formData.relevanceStrategicDevelopmentGoals,
                                    maxLength: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CardHeader(
                                    title: 'Brief Review of Works Already Performed / in Progress Elsewhere With List of References :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  ReadMoreText(
                                    text: _formData.briefReviewAlreadyPerformedReferences,
                                    maxLength: 50,
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
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.7) - (kDefaultPadding * 0.7)),
                                        child: Card(
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const CardHeader(
                                                title: 'Methodology :',
                                                backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                                titleColor: Color.fromARGB(255, 151, 204, 197),
                                                showDivider: false,
                                              ),
                                              ReadMoreText(
                                                text: _formData.methodology,
                                                maxLength: 50,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
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
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CardHeader(
                                    title: 'Expected Outputs :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  ReadMoreText(
                                    text: _formData.expectedOutputs,
                                    maxLength: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CardHeader(
                                    title: 'Success Indicators :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  ReadMoreText(
                                    text: _formData.successIndicators,
                                    maxLength: 50,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CardHeader(
                                    title: 'Beneficiaries :',
                                    backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                    titleColor: Color.fromARGB(255, 151, 204, 197),
                                    showDivider: false,
                                  ),
                                  ReadMoreText(
                                    text: _formData.beneficiaries,
                                    maxLength: 50,
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
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: ganttData['Activity'],
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.2)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title:
                                                            "${DateFormat("d MMM yyyy").format(DateFormat("E, d MMM yyyy HH:mm:ss 'GMT'").parseUTC(ganttData['StartDate']))}  To  ${DateFormat("d MMM yyyy").format(DateFormat("E, d MMM yyyy HH:mm:ss 'GMT'").parseUTC(ganttData['EndDate']))}",
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.1)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: ganttData['ActivityStatus'],
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
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CardHeader(
                                          title: _formData.manPowerExisting,
                                          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                          titleColor: const Color.fromARGB(255, 238, 216, 221),
                                          showDivider: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CardHeader(
                                          title: _formData.manPowerRequired,
                                          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                          titleColor: const Color.fromARGB(255, 238, 216, 221),
                                          showDivider: false,
                                        ),
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
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('B) Small Equipment:'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CardHeader(
                                          title: _formData.smallEquipmentExisting,
                                          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                          titleColor: const Color.fromARGB(255, 238, 216, 221),
                                          showDivider: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CardHeader(
                                          title: _formData.smallEquipmentRequired,
                                          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                          titleColor: const Color.fromARGB(255, 238, 216, 221),
                                          showDivider: false,
                                        ),
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
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('C) Research Materials:'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CardHeader(
                                          title: _formData.researchMaterialsExisting,
                                          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                          titleColor: const Color.fromARGB(255, 238, 216, 221),
                                          showDivider: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CardHeader(
                                          title: _formData.researchMaterialsRequired,
                                          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                          titleColor: const Color.fromARGB(255, 238, 216, 221),
                                          showDivider: false,
                                        ),
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
                                  width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                  child: const Text('D) Others:'),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.4) - (kDefaultPadding * 0.4)),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CardHeader(
                                          title: _formData.othersExisting,
                                          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                          titleColor: const Color.fromARGB(255, 238, 216, 221),
                                          showDivider: false,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: kDefaultPadding),
                                SizedBox(
                                  width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CardHeader(
                                          title: _formData.othersRequired,
                                          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                          titleColor: const Color.fromARGB(255, 238, 216, 221),
                                          showDivider: false,
                                        ),
                                      ],
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
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['SerialNo'].toString(),
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['Item'],
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.1) - (kDefaultPadding * 0.1)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['Quantity'].toString(),
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['UnitPrice'].toString(),
                                                        backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                        titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                        showDivider: false,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: kDefaultPadding),
                                              SizedBox(
                                                width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                                child: Card(
                                                  clipBehavior: Clip.antiAlias,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CardHeader(
                                                        title: budgetData['TotalCost'].toString(),
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
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const CardHeader(
                                            title: 'PI Signature Date :',
                                            backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                            titleColor: Color.fromARGB(255, 151, 204, 197),
                                            showDivider: false,
                                          ),
                                          CardHeader(
                                            title: _formData.piSignatureDate,
                                            backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                            titleColor: const Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
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
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CardHeader(
                                title: 'Comments of the Chairman of the Department :',
                                backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                titleColor: Color.fromARGB(255, 151, 204, 197),
                                showDivider: false,
                              ),
                              CardHeader(
                                title: _formData.commentsOfTheChairmanOfTheDepartment,
                                backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                titleColor: const Color.fromARGB(255, 238, 216, 221),
                                showDivider: false,
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
                                ]),
                                const SizedBox(width: kDefaultPadding),
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const CardHeader(
                                            title: 'Chairman Signature Date :',
                                            backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                            titleColor: Color.fromARGB(255, 151, 204, 197),
                                            showDivider: false,
                                          ),
                                          CardHeader(
                                            title: _formData.dateOfChairmanOfTheDepartment,
                                            backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                            titleColor: const Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Name :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piName,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Address :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piPresentAddress,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piPermanentAddress,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Email :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piEmail,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Phone :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piPhone,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Salary Scale :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piSalaryScale,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Highest Academic Qualification :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piHighestAcademicQualification,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piHighestAcademicQualificationUniversity,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piHighestAcademicQualificationCountry,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piHighestAcademicQualificationYear,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Area of Expertise :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piAreaOfExpertise,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Experience in Research :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piExperienceInResearch,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI Teaching :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piExperienceInTeaching,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'PI References of Latest Publications :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.piReferencesOfLatestPublications,
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
                      const SizedBox(width: kDefaultPadding),
                      SizedBox(
                        width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CardHeader(
                                  title: "PART III: B. Co-Principal Investigator (CO-PI)", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
                              CardBody(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Name :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiName,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Address :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiPresentAddress,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiPermanentAddress,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Email :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiEmail,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Phone :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiPhone,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Salary Scale :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiSalaryScale,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Highest Academic Qualification :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiHighestAcademicQualification,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiHighestAcademicQualificationUniversity,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiHighestAcademicQualificationCountry,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiHighestAcademicQualificationYear,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Area of Expertise :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiAreaOfExpertise,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Experience in Research :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiExperienceInResearch,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI Teaching :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiExperienceInTeaching,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CO-PI References of Latest Publications :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.coPiReferencesOfLatestPublications,
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
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(
                        title: "PART III: C. Student's Information (For Code: 4829): (MS/PhD)", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
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
                                      width: ((constraints.maxWidth * 0.7) - (kDefaultPadding * 0.7)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Studen Name :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.studentName,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Reg. No. :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
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
                                    // const SizedBox(height: 20),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Student ID :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.studentId,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.33) - (kDefaultPadding * 0.33)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'First Enrollment Semester :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
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
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.32) - (kDefaultPadding * 0.32)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'CGPA at Undergraduate Level :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: _formData.cgpaUndergraduateLevel,
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CardBody(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
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
                                const SizedBox(width: kDefaultPadding),
                                const Spacer(),
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
                                        "Project Report Not Available yet",
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
                                visible: _formData.projectID.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: kDefaultPadding),
                                  child: SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.successText,
                                      onPressed: () {
                                        _pdfHandleButtonPress();
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.download_for_offline_outlined,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          const Text("Download Project Proposal"),
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
                                      style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                      onPressed: () => _goEditPage(context),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                            child: Icon(
                                              Icons.mode_edit_outline_outlined,
                                              size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                            ),
                                          ),
                                          const Text("Edit Project"),
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

class ReadMoreText extends StatefulWidget {
  final String text;
  final int maxLength;

  const ReadMoreText({
    Key? key,
    required this.text,
    this.maxLength = 50,
  }) : super(key: key);

  @override
  _ReadMoreTextState createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Column(
      children: [
        CardHeader(
          title: isExpanded ? widget.text : _getTrimmedText(),
          backgroundColor: const Color.fromARGB(255, 51, 55, 56),
          titleColor: const Color.fromARGB(255, 238, 216, 221),
          showDivider: false,
        ),
        ElevatedButton(
          style: themeData.extension<AppButtonTheme>()!.secondaryText,
          onPressed: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                child: Icon(
                  isExpanded ? Icons.arrow_upward_outlined : Icons.arrow_downward_outlined,
                  size: (themeData.textTheme.labelSmall!.fontSize! + 4.0),
                ),
              ),
              Text(
                isExpanded ? 'Show less' : 'See more',
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTrimmedText() {
    if (widget.text.length <= widget.maxLength) {
      return widget.text;
    }
    return '${widget.text.substring(0, widget.maxLength)}... ';
  }
}

class FormData {
  String projectID = '';
  String roleID = '';

  String cgpaUndergraduateLevel = '';
  String firstEnrollmentSemester = '';
  String studentId = '';
  String studentRegNo = '';
  String studentName = '';
  int studentUserID = 0;

  String coPiReferencesOfLatestPublications = '';
  String coPiExperienceInTeaching = '';
  String coPiExperienceInResearch = '';
  String coPiAreaOfExpertise = '';
  String coPiHighestAcademicQualificationYear = '';
  String coPiHighestAcademicQualificationCountry = '';
  String coPiHighestAcademicQualificationUniversity = '';
  String coPiHighestAcademicQualification = '';
  String coPiBasicPay = '';
  String coPiSalaryScale = '';
  String coPiEmail = '';
  String coPiPresentAddress = '';
  String coPiPermanentAddress = '';
  String coPiPhone = '';
  String coPiName = '';
  String coPiPositionEnglish = '';
  String coPiDepartmentName = '';
  String coPiFacultyName = '';
  String coPiInstituteLocation = '';
  String coPiInstituteName = '';
  int coPiUserID = 0;

  String piReferencesOfLatestPublications = '';
  String piExperienceInTeaching = '';
  String piExperienceInResearch = '';
  String piAreaOfExpertise = '';
  String piHighestAcademicQualificationYear = '';
  String piHighestAcademicQualificationCountry = '';
  String piHighestAcademicQualificationUniversity = '';
  String piHighestAcademicQualification = '';
  String piBasicPay = '';
  String piSalaryScale = '';
  String piEmail = '';
  String piPresentAddress = '';
  String piPermanentAddress = '';
  String piPhone = '';
  String piName = '';
  String piPositionEnglish = '';
  String piDepartmentName = '';
  String piFacultyName = '';
  String piInstituteLocation = '';
  String piInstituteName = '';
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
