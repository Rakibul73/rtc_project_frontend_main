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
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class RequestForAProjectFundAdvanceScreen extends StatefulWidget {
  final String projectID;

  const RequestForAProjectFundAdvanceScreen({
    Key? key,
    required this.projectID,
  }) : super(key: key);

  @override
  State<RequestForAProjectFundAdvanceScreen> createState() => _RequestForAProjectFundScreenState();
}

class _RequestForAProjectFundScreenState extends State<RequestForAProjectFundAdvanceScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  late List<dynamic> initialProjectBudget = [];
  Future<bool>? _future;

  Future<bool> _getDataAsync() async {
    if (widget.projectID.isNotEmpty) {
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.projectID = widget.projectID;

        int projectID = int.parse(widget.projectID);
        final projectDetailForFundSelf = await ApiService.getSpecificProjectForFundSelf(
          projectID,
        );

        if (projectDetailForFundSelf['statuscode'] == 401) {
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

        final userId = await storage.read(key: 'user_id');
        int userid = int.parse(userId!);

        _formData.rtcCode = projectDetailForFundSelf['project']['CodeByRTC'].toString();
        _formData.projectTitle = projectDetailForFundSelf['project']['ProjectTitle'];
        _formData.totalBudget = projectDetailForFundSelf['project']['TotalBudgetOfResearchProposalTK'].toString();

        _formData.piUserID = userid;
        _formData.piSealLocation = projectDetailForFundSelf['project']['CreatorUserSealLocation'];
        _formData.piSignatureLocation = projectDetailForFundSelf['project']['CreatorUserSignatureLocation'];

        _formData.chairmanOfDepartmentSealFileLocation = projectDetailForFundSelf['project']['ChairmanOfDepartmentSealLocation'];
        _formData.chairmanOfDepartmentSignatureFileLocation = projectDetailForFundSelf['project']['ChairmanOfDepartmentSignatureLocation'];

        final budgetDetails = await ApiService.fetchAllBudgetOfAProject(
          int.parse(_formData.projectID),
        );
        if (budgetDetails.isNotEmpty) {
          initialProjectBudget = budgetDetails;
        }

        final userDetailsForFundApply = await ApiService.getSpecificUserDetailsForFundApply(
          _formData.piUserID,
        );

        _formData.piEmail = userDetailsForFundApply['user']['Email'] ?? '';
        _formData.piPhone = userDetailsForFundApply['user']['Phone'] ?? '';
        _formData.piInstituteName = userDetailsForFundApply['user']['InstituteName'] ?? '';
        _formData.piFacultyName = userDetailsForFundApply['user']['FacultyName'] ?? '';
        _formData.piInstituteAddress = userDetailsForFundApply['user']['InstituteLocation'] ?? '';
        _formData.piName = userDetailsForFundApply['user']['FirstName'] + ' ' + userDetailsForFundApply['user']['LastName'] ?? '';
      });
    }

    return true;
  }

  void _goSubmitReview(BuildContext context) {
    AppFocusHelper.instance.requestUnfocus();

    _formKey.currentState!.validate();
    _formKey.currentState!.save();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Are you sure you want to submit a request for advance?",
      desc: "Note: This action cannot be undone.",
      width: kDialogWidth,
      btnOkText: "Yes",
      btnOkOnPress: () async {
        // here should make a api request to submit review
        _formKey.currentState!.save();
        try {
          final fundRequestData = {
            'ProjectID': int.parse(_formData.projectID),
            'TotalBudget': _formData.totalBudget,
            'RequestedAmount': _formData.requestedAmountForAdvance,
            'PiSignatureDate': _formData.piSignatureDate,
            'ChairmanOfDepartmentSignatureDate': _formData.dateOfChairmanOfTheDepartment,
            'RequestForAdvanceFundDone': 1, // 0 = not Request , 1 = 1st request
            'AdvanceFundRecievedDone': 0, // 0 = not Received , 1 = 1st Received
          };

          final responseBody = await ApiService.createAdvanceFundRequestForSpecificProject(fundRequestData);
          if (responseBody['statuscode'] == 201) {
            // Handle success
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: "Project Advance fund request submitted successfully",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () => GoRouter.of(context).go(RouteUri.projecticanapplyforrequestforadvance),
            );
            dialog.show();
          } else if (responseBody['msg'] == "Token has expired") {
            // Handle error

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

            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Error submitting request: ${responseBody['message']}",
              width: kDialogWidth,
              btnOkText: 'OK',
              btnOkOnPress: () {},
            );
            dialog.show();
          }
        } catch (e) {
          // Handle error

          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            title: "Error submitting request: $e",
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

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.projectfundmanagement,
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
    final currentYear = DateTime.now().year;
    final previousYear = DateTime.now().year - 1;
    var pageTitle = 'Request For Advance Of Research Project FY: $previousYear-$currentYear';

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
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'Project ID :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.projectID,
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
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'Research/RTC Code :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'Faculty :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.piFacultyName,
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
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'Title of the Project :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'Name of the PI :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'Office Address of the PI :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.piInstituteAddress,
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
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'PI Phone :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'PI Email :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
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
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'Total Budget :',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.totalBudget,
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
                            padding: const EdgeInsets.only(bottom: kDefaultPadding, top: kDefaultPadding),
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
                                              title: 'Requested Amount:',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.55) - (kDefaultPadding * 0.55)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          FormBuilderTextField(
                                            name: 'requested_amount',
                                            decoration: const InputDecoration(
                                              labelText: 'Requested amount',
                                              hintText: '(TK.)',
                                              border: OutlineInputBorder(),
                                              floatingLabelBehavior: FloatingLabelBehavior.always,
                                            ),
                                            validator: FormBuilderValidators.required(),
                                            onSaved: (value) => (_formData.requestedAmountForAdvance = double.parse(value ?? '0.0')),
                                          ),
                                        ],
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      SizedBox(
                                        width: (kDefaultPadding * 22),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                          child: Stack(
                                            children: [
                                              FutureBuilder<String>(
                                                future: _formData.chairmanOfDepartmentSignatureFileLocation.isNotEmpty
                                                    ? ApiService.downloadFile('signature/download', _formData.chairmanOfDepartmentSignatureFileLocation)
                                                    : ApiService.downloadFile('signature/download', "defaultsignature.png"), // Check if value is not empty before making the API call
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
                                      const SizedBox(height: kDefaultPadding),
                                      SizedBox(
                                        width: (kDefaultPadding * 22),
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
                                          onChanged: (value) => (_formData.dateOfChairmanOfTheDepartment = value.toString()),
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPadding),
                                      SizedBox(
                                        width: (kDefaultPadding * 22),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                          child: Stack(
                                            children: [
                                              FutureBuilder<String>(
                                                future: _formData.chairmanOfDepartmentSealFileLocation.isNotEmpty
                                                    ? ApiService.downloadFile('seal/download', _formData.chairmanOfDepartmentSealFileLocation)
                                                    : ApiService.downloadFile('seal/download', "defaultseal.png"), // Check if value is not empty before making the API call
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
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          SizedBox(
                                            width: (kDefaultPadding * 22),
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                              child: Stack(
                                                children: [
                                                  FutureBuilder<String>(
                                                    future: _formData.piSignatureLocation.isNotEmpty
                                                        ? ApiService.downloadFile('signature/download', _formData.piSignatureLocation)
                                                        : ApiService.downloadFile('signature/download', "defaultsignature.png"), // Check if value is not empty before making the API call
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
                                          const SizedBox(height: kDefaultPadding),
                                          SizedBox(
                                            width: (kDefaultPadding * 22),
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
                                              onChanged: (value) => (_formData.piSignatureDate = value.toString()),
                                            ),
                                          ),
                                          const SizedBox(height: kDefaultPadding),
                                          SizedBox(
                                            width: (kDefaultPadding * 22),
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                              child: Stack(
                                                children: [
                                                  FutureBuilder<String>(
                                                    future: _formData.piSealLocation.isNotEmpty
                                                        ? ApiService.downloadFile('seal/download', _formData.piSealLocation)
                                                        : ApiService.downloadFile('seal/download', "defaultseal.png"), // Check if value is not empty before making the API call
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
                                        ]),
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.projecticanapplyforrequestforadvance),
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
                              Padding(
                                padding: const EdgeInsets.only(right: kDefaultPadding),
                                child: SizedBox(
                                  height: 40.0,
                                  child: ElevatedButton(
                                    style: themeData.extension<AppButtonTheme>()!.primaryOutlined,
                                    onPressed: () => _goSubmitReview(context),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                          child: Icon(
                                            Icons.arrow_circle_right_outlined,
                                            size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                          ),
                                        ),
                                        const Text("Submit Request for Advance"),
                                      ],
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

class FormData {
  String projectID = '';

  double requestedAmountForAdvance = 0.0;
  String dateOfChairmanOfTheDepartment = '';
  String piSignatureDate = '';

  String piInstituteName = '';
  String piInstituteAddress = '';
  String piFacultyName = '';
  String piEmail = '';
  String piPhone = '';
  String piName = '';
  int piUserID = 0;

  String chairmanOfDepartmentSignatureFileLocation = '';
  String chairmanOfDepartmentSealFileLocation = '';
  String totalBudget = '';

  String piSignatureLocation = '';
  String piSealLocation = '';
  String projectTitle = '';
  String rtcCode = '';
}
