// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
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
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class ReviewIndividualProjectScreen extends StatefulWidget {
  final String projectID;

  const ReviewIndividualProjectScreen({
    Key? key,
    required this.projectID,
  }) : super(key: key);

  @override
  State<ReviewIndividualProjectScreen> createState() => _ReviewIndividualProjectScreenState();
}

class _ReviewIndividualProjectScreenState extends State<ReviewIndividualProjectScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  late List<dynamic> initialProjectGantts = [];
  late List<dynamic> initialProjectBudget = [];
  Future<bool>? _future;
  bool initialReviewExist = false;

  Future<bool> _getDataAsync() async {
    print('projectID: ${widget.projectID}');
    if (widget.projectID.isNotEmpty) {
      print('projectID: ${widget.projectID}');
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.projectID = widget.projectID;

        int projectID = int.parse(widget.projectID);
        final userDetails = await ApiService.getSpecificProject(
          projectID,
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
        _formData.coPiUserID = userDetails['project']['CoPiUserID'];
        _formData.studentUserID = userDetails['project']['StudentUserID'];

        _formData.piSealLocation = userDetails['project']['CreatorUserSealLocation'];
        _formData.piSignatureLocation = userDetails['project']['CreatorUserSignatureLocation'];
        _formData.piSignatureDate = userDetails['project']['CreatorUserSignatureDate'];

        _formData.commentsOfTheChairmanOfTheDepartment = userDetails['project']['ChairmanOfDepartmentComment'];
        _formData.chairmanOfDepartmentSealFileLocation = userDetails['project']['ChairmanOfDepartmentSealLocation'];
        _formData.chairmanOfDepartmentSignatureFileLocation = userDetails['project']['ChairmanOfDepartmentSignatureLocation'];
        _formData.dateOfChairmanOfTheDepartment = userDetails['project']['ChairmanOfDepartmentSignatureDate'];

        _formData.projectStatus = userDetails['project']['ProjectStatus'];
        _formData.projectSoftCopyLocation = userDetails['project']['ProjectSoftCopyLocation'] ?? '';

        final ganttDetails = await ApiService.fetchAllGanttOfAProjectReview(
          int.parse(_formData.projectID),
        );
        if (ganttDetails.isNotEmpty) {
          initialProjectGantts = ganttDetails;
        }
        print("initialProjectGantts: $initialProjectGantts");

        final budgetDetails = await ApiService.fetchAllBudgetOfAProjectReview(
          int.parse(_formData.projectID),
        );
        if (budgetDetails.isNotEmpty) {
          initialProjectBudget = budgetDetails;
        }
        print("initialProjectBudget: $initialProjectBudget");

        // read user id
        final userId = await storage.read(key: 'user_id');
        int userid = int.parse(userId!);
        final projectIDAndReviewerUserID = {
          'ProjectID': int.parse(_formData.projectID),
          'ReviewerUserID': userid,
        };
        final fetchSpecificReviewDetail = await ApiService.getAllReviewsForSpecificReviewer(projectIDAndReviewerUserID);
        print(fetchSpecificReviewDetail);
        print("==========*************===========");
        print((fetchSpecificReviewDetail['reviews']).length);

        if (fetchSpecificReviewDetail['statuscode'] == 200 && (fetchSpecificReviewDetail['reviews']).length != 0) {
          print("==========**S      T      A      R      T*****===========");
          print(fetchSpecificReviewDetail['reviews'][0]['Points'].runtimeType);
          _formData.totalMarks = fetchSpecificReviewDetail['reviews'][0]['Points'];
          _formData.markComment = fetchSpecificReviewDetail['reviews'][0]['Comments'];
          initialReviewExist = true;
        }

        print("==========**E      N      D*****===========");
      });
    }

    return true;
  }

  void _goSubmitReview(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Are you sure you want to submit this review for the project?",
      desc: "Note: This action cannot be undone.",
      width: kDialogWidth,
      btnOkText: "Yes",
      btnOkOnPress: () async {
        // here should make a api request to submit review
        _formKey.currentState!.save();
        // read user id
        final userId = await storage.read(key: 'user_id');
        int userid = int.parse(userId!);
        try {
          final reviewData = {
            'ProjectID': int.parse(_formData.projectID),
            'ReviewerUserID': userid,
            'Points': _formData.totalMarks,
            'Comments': _formData.markComment,
          };
          print(reviewData);
          final responseBody = await ApiService.createReviewSpecificProject(reviewData);
          if (responseBody['statuscode'] == 201) {
            // Handle success
            print('Review submitted successfully');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: "Review submitted successfully",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () => GoRouter.of(context).go(RouteUri.projecthavetoreview),
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
            print('Error submitting review: ${responseBody['message']}');
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Error submitting review: ${responseBody['message']}",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () {},
            );
            dialog.show();
          }
        } catch (e) {
          // Handle error
          print('Error submitting review: $e');
          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: "Error submitting review: $e",
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () {},
          );
          dialog.show();
        }
      },
      btnCancelText: "No",
      btnCancelOnPress: () {},
    );
    dialog.show();
  }

  void saveTotalMarks() {
    AppFocusHelper.instance.requestUnfocus();

    _formKey.currentState!.save();

    // Initialize totalMark to 0
    double totalMark = 0.0;

    // Helper function to parse and add the value to totalMark
    void addToTotal(String fieldValue) {
      if (fieldValue.isNotEmpty) {
        totalMark += double.parse(fieldValue);
      }
    }

    addToTotal(_formData.markBackground);
    addToTotal(_formData.markBudget);
    addToTotal(_formData.markExpected);
    addToTotal(_formData.markGantt);
    addToTotal(_formData.markIntro);
    addToTotal(_formData.markMethodology);
    addToTotal(_formData.markObjective);
    addToTotal(_formData.markProposal);
    addToTotal(_formData.markRelevance);
    addToTotal(_formData.markTitle);

    _formData.totalMarks = totalMark;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.projectreviewtracking,
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
    final pageTitle = 'Project - ID: ${widget.projectID.isEmpty ? 'New Project' : widget.projectID}';

    return FormBuilder(
        key: _formKey,
        autovalidateMode: AutovalidateMode.disabled,
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
                                      // const SizedBox(height: 20),
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
                                            FutureBuilder<String>(
                                              future: _formData.methodologyFileLocation.isNotEmpty
                                                  ? ApiService.downloadFile('methodology/download', _formData.methodologyFileLocation)
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
                                                    width: 150, // Adjust width as needed
                                                    // height: 50, // Adjust height as needed
                                                  );
                                                }
                                              },
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

            // add a review field here

            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(
                      title: "Review Section",
                      backgroundColor: Color.fromARGB(255, 139, 161, 168),
                      titleColor: Color.fromARGB(255, 50, 39, 42),
                      showDivider: false,
                    ),
                    Visibility(
                      visible: !initialReviewExist,
                      child: CardBody(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.6)),
                                    child: const Text(
                                      'Criteria',
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Text('Marks Distribution'),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: const Text('Given Marks'),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Project Title",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "5",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_title',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 5)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markTitle = value ?? '';
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Introduction, innovativeness and problem statement",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "15",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_intro',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 15)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markIntro = value ?? '';
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Specific objectives",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "5",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_objective',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 5)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markObjective = value ?? '';
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Relevance to the vision of PSTU and national development goals",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "10",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_relevance',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 10)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markRelevance = value ?? '';
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Review and background information",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "15",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_review',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 15)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markBackground = value ?? '';
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Expected outputs and benefits of stakeholder",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "5",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_benefits',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 5)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markExpected = value ?? '';
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Methodology",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "20",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_methodology',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 20)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markMethodology = value ?? '';
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Activity plan/Gantt chart",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "10",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_activity_plan_and_gantt_chart',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 10)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markGantt = value ?? '';
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Budget rationale",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "10",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_budget',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 10)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markBudget = value ?? '';
                                      },
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
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.5)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Proposal design, presentation and feasibility",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "5",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: FormBuilderTextField(
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      maxLines: 1, // Allow unlimited lines
                                      name: 'mark_Proposal',
                                      decoration: const InputDecoration(
                                        labelText: 'Mark',
                                        hintText: 'Mark (Out of 5)',
                                        border: OutlineInputBorder(),
                                        floatingLabelBehavior: FloatingLabelBehavior.always,
                                      ),
                                      onChanged: (value) {
                                        _formData.markProposal = value ?? '';
                                        print("markProposal: ${_formData.markProposal}");
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        _linearProgressIndicator(context, 1.0, const Color.fromARGB(255, 139, 161, 168), true),
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.48) - (kDefaultPadding * 0.48)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Total marks",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.12) - (kDefaultPadding * 0.12)),
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ElevatedButton(
                                            style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                            onPressed: () {
                                              setState(() {
                                                _formKey.currentState!.reset();
                                                _formData.totalMarks = 0.0;
                                              });
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.save_outlined, // Change icon based on edit mode
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                Text("Reset", style: themeData.textTheme.labelLarge),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: kDefaultPadding),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding * 0.5),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.10) - (kDefaultPadding * 0.10)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "100",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: kDefaultPadding),
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Tooltip(
                                            message: 'Out of 100',
                                            child: CardHeader(
                                              title: _formData.totalMarks.toString(),
                                              backgroundColor: const Color.fromARGB(255, 73, 108, 117),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          )
                                        ],
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
                                                _formKey.currentState!.validate();
                                                _formKey.currentState!.save();
                                                saveTotalMarks();
                                              });
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.save_outlined, // Change icon based on edit mode
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                Text("Save", style: themeData.textTheme.labelLarge),
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
                      ])),
                    ),
                    Visibility(
                      visible: initialReviewExist,
                      child: CardBody(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.6)),
                                    child: const Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CardHeader(
                                            title: "Total marks Given",
                                            backgroundColor: Color.fromARGB(255, 51, 55, 56),
                                            titleColor: Color.fromARGB(255, 238, 216, 221),
                                            showDivider: false,
                                          ),
                                        ],
                                      ),
                                    ),
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
                                            title: "${_formData.totalMarks} out of 100",
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
                    Visibility(
                      visible: !initialReviewExist,
                      child: CardBody(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0, top: kDefaultPadding * 1.0),
                              child: FormBuilderTextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null, // Allow unlimited lines
                                name: 'comment_for_this_project',
                                decoration: const InputDecoration(
                                  labelText: 'Comment for this Project',
                                  hintText: 'Comment for this Project',
                                  border: OutlineInputBorder(),
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                ),
                                onChanged: (value) {
                                  _formData.markComment = value ?? '';
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: initialReviewExist,
                      child: CardBody(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0, top: kDefaultPadding * 1.0),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CardHeader(
                                      title: _formData.markComment,
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.projecthavetoreview),
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
                                visible: !initialReviewExist,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: kDefaultPadding),
                                  child: SizedBox(
                                    height: 40.0,
                                    child: ElevatedButton(
                                      style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                      onPressed: () => _goSubmitReview(context),
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
                                          const Text("Submit Review"),
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

  Widget _linearProgressIndicator(BuildContext context, double? value, Color color, bool withBottomPadding) {
    final themeData = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: (withBottomPadding ? kDefaultPadding * 1.5 : 0.0)),
      child: Theme(
        data: themeData.copyWith(
          colorScheme: themeData.colorScheme.copyWith(primary: color),
        ),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: themeData.scaffoldBackgroundColor,
        ),
      ),
    );
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

  String markTitle = '';
  String markIntro = '';
  String markObjective = '';
  String markRelevance = '';
  String markBackground = '';
  String markMethodology = '';
  String markExpected = '';
  String markGantt = '';
  String markBudget = '';
  String markProposal = '';
  double totalMarks = 0.0;
  String markComment = '';

  String profilePicLocation1 = '';
  String profilePicLocation2 = '';
  String profilePicLocation3 = '';
  String reviewerUsername1 = '';
  String reviewerUsername2 = '';
  String reviewerUsername3 = '';
  String reviewerFullname1 = '';
  String reviewerFullname2 = '';
  String reviewerFullname3 = '';
  int reviewerUserId1 = 0;
  int reviewerUserId2 = 0;
  int reviewerUserId3 = 0;
  int fetchReviewerUserId1 = 0;
  int fetchReviewerUserId2 = 0;
  int fetchReviewerUserId3 = 0;

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
