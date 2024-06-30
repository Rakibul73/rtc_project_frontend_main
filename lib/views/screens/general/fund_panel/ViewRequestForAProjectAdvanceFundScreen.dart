// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/constants/values.dart';
import 'package:rtc_project_fronend/views/screens/pdf_generate/pdf_generator.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewRequestForAProjectAdvanceFundScreen extends StatefulWidget {
  final String projectID;

  const ViewRequestForAProjectAdvanceFundScreen({
    Key? key,
    required this.projectID,
  }) : super(key: key);

  @override
  State<ViewRequestForAProjectAdvanceFundScreen> createState() => _ViewRequestForAProjectAdvanceFundScreenState();
}

class _ViewRequestForAProjectAdvanceFundScreenState extends State<ViewRequestForAProjectAdvanceFundScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  late List<dynamic> initialProjectBudget = [];
  Future<bool>? _future;

  Uint8List? _piSignatureFileBytes;
  Uint8List? _piSealFileBytes;
  Uint8List? _chairmanSignatureFileBytes;
  Uint8List? _chairmanSealFileBytes;

  void _pdfHandleButtonPress() {
    final d = AwesomeDialog(
      context: context,
      dialogType: DialogType.infoReverse,
      title: "Pdf Generating.....",
      desc: "Please wait...5 seconds",
      width: kDialogWidth,
      headerAnimationLoop: true,
    );
    Future.wait([
      d.show(),
      Future.delayed(const Duration(seconds: 5), () => d.dismiss()),
      generateRequestForAdvancePDF(_formData, context, _piSignatureFileBytes, _piSealFileBytes, _chairmanSignatureFileBytes, _chairmanSealFileBytes, initialProjectBudget),
    ]).then((_) {
      d.dismiss();
    });
  }

  Future<bool> _getDataAsync() async {
    print('projectID: ${widget.projectID}');
    if (widget.projectID.isNotEmpty) {
      print('projectID: ${widget.projectID}');
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.projectID = widget.projectID;

        int projectID = int.parse(widget.projectID);
        final projectDetailForFundSelf = await ApiService.getSpecificProjectForAdvanceFundSelf(
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

        print(projectDetailForFundSelf['project']);

        _formData.rtcCode = projectDetailForFundSelf['project']['CodeByRTC'].toString();
        _formData.projectTitle = projectDetailForFundSelf['project']['ProjectTitle'];
        _formData.totalBudget = projectDetailForFundSelf['project']['TotalBudgetOfResearchProposalTK'].toString();

        _formData.piUserID = projectDetailForFundSelf['project']['CreatorUserID'];
        _formData.piSealLocation = projectDetailForFundSelf['project']['CreatorUserSealLocation'];
        String piSealfilePath = _formData.piSealLocation.isNotEmpty
            ? await ApiService.downloadFile('seal/download', _formData.piSealLocation)
            : await ApiService.downloadFile('seal/download', "defaultseal.png"); // Check if value is not empty before making the API call
        if (piSealfilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(piSealfilePath);
          _piSealFileBytes = fileBytes;
        }
        _formData.piSignatureLocation = projectDetailForFundSelf['project']['CreatorUserSignatureLocation'];
        String piSignaturefilePath = _formData.piSignatureLocation.isNotEmpty
            ? await ApiService.downloadFile('signature/download', _formData.piSignatureLocation)
            : await ApiService.downloadFile('signature/download', "defaultsignature.png"); // Check if value is not empty before making the API call
        if (piSignaturefilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(piSignaturefilePath);
          _piSignatureFileBytes = fileBytes;
        }
        _formData.chairmanOfDepartmentSealFileLocation = projectDetailForFundSelf['project']['ChairmanOfDepartmentSealLocation'];
        String chairmanSealfilePath = _formData.chairmanOfDepartmentSealFileLocation.isNotEmpty
            ? await ApiService.downloadFile('seal/download', _formData.chairmanOfDepartmentSealFileLocation)
            : await ApiService.downloadFile('seal/download', "defaultseal.png"); // Check if value is not empty before making the API call
        if (chairmanSealfilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(chairmanSealfilePath);
          _chairmanSealFileBytes = fileBytes;
        }
        _formData.chairmanOfDepartmentSignatureFileLocation = projectDetailForFundSelf['project']['ChairmanOfDepartmentSignatureLocation'];
        String chairmanSignaturefilePath = _formData.chairmanOfDepartmentSignatureFileLocation.isNotEmpty
            ? await ApiService.downloadFile('signature/download', _formData.chairmanOfDepartmentSignatureFileLocation)
            : await ApiService.downloadFile('signature/download', "defaultsignature.png"); // Check if value is not empty before making the API call
        if (chairmanSignaturefilePath.isNotEmpty) {
          Uint8List fileBytes = base64Decode(chairmanSignaturefilePath);
          _chairmanSignatureFileBytes = fileBytes;
        }

        final budgetDetails = await ApiService.fetchAllBudgetOfAProject(
          int.parse(_formData.projectID),
        );
        if (budgetDetails.isNotEmpty) {
          initialProjectBudget = budgetDetails;
        }
        print("initialProjectBudget: $initialProjectBudget");

        final userDetailsForFundApply = await ApiService.getSpecificUserDetailsForFundApply(
          _formData.piUserID,
        );

        _formData.piEmail = userDetailsForFundApply['user']['Email'] ?? '';
        _formData.piPhone = userDetailsForFundApply['user']['Phone'] ?? '';
        _formData.piInstituteName = userDetailsForFundApply['user']['InstituteName'] ?? '';
        _formData.piFacultyName = userDetailsForFundApply['user']['FacultyName'] ?? '';
        _formData.piDepartmentName = userDetailsForFundApply['user']['DepartmentName'] ?? '';
        _formData.piPosition = userDetailsForFundApply['user']['PositionEnglish'] ?? '';
        _formData.piInstituteAddress = userDetailsForFundApply['user']['InstituteLocation'] ?? '';
        _formData.piName = userDetailsForFundApply['user']['FirstName'] + ' ' + userDetailsForFundApply['user']['LastName'] ?? '';

        final fundDetails = await ApiService.getAdvanceFundDetailsForSpecificProject(
          int.parse(_formData.projectID),
        );

        _formData.requestedAmount = fundDetails['fund']['RequestedAmount'] ?? '';
        _formData.piSignatureDate = fundDetails['fund']['PiSignatureDate'] ?? '';
        // ignore: unnecessary_null_comparison
        if (_formData.piSignatureDate != null && _formData.piSignatureDate.isNotEmpty) {
          _formData.piSignatureDate = DateFormat("MMMM d, yyyy").format(DateTime.parse(_formData.piSignatureDate));
        }
        _formData.dateOfChairmanOfTheDepartment = fundDetails['fund']['ChairmanOfDepartmentSignatureDate'] ?? '';
        // ignore: unnecessary_null_comparison
        if (_formData.dateOfChairmanOfTheDepartment != null && _formData.dateOfChairmanOfTheDepartment.isNotEmpty) {
          _formData.dateOfChairmanOfTheDepartment = DateFormat("MMMM d, yyyy").format(DateTime.parse(_formData.dateOfChairmanOfTheDepartment));
        }

        print("==========**E      N      D*****===========");
      });
    }

    return true;
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
    var pageTitle = 'Request For Advance of Research Project FY: $previousYear-$currentYear';

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
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: _formData.requestedAmount.toString(),
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
                            child: Row(
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
                                    width: (kDefaultPadding * 22),
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
                                  const SizedBox(height: kDefaultPadding),
                                  SizedBox(
                                    width: (kDefaultPadding * 22),
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
                                      const SizedBox(height: kDefaultPadding),
                                      SizedBox(
                                        width: (kDefaultPadding * 22),
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
                                      const SizedBox(height: kDefaultPadding),
                                      SizedBox(
                                        width: (kDefaultPadding * 22),
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
                                    ]),
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
                                  onPressed: () async {
                                    final sharedPref = await SharedPreferences.getInstance();
                                    final roleID = sharedPref.getInt(StorageKeys.roleId) ?? 0;
                                    if (roleID == 1) {
                                      GoRouter.of(context).go(RouteUri.alladvancefundrequestqueuelist);
                                    } else {
                                      GoRouter.of(context).go(RouteUri.projecticanapplyforrequestforadvance);
                                    }
                                  },
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
                                        const Text("Download PDF"),
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
}

class FormData {
  String projectID = '';

  double requestedAmount = 0.0;
  String dateOfChairmanOfTheDepartment = '';
  String piSignatureDate = '';

  String piInstituteName = '';
  String piInstituteAddress = '';
  String piFacultyName = '';
  String piPosition = '';
  String piDepartmentName = '';
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
