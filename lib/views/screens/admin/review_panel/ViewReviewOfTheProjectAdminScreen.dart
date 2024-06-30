import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
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

class ViewReviewOfTheProjectAdminScreen extends StatefulWidget {
  final String projectID;

  const ViewReviewOfTheProjectAdminScreen({
    Key? key,
    required this.projectID,
  }) : super(key: key);

  @override
  State<ViewReviewOfTheProjectAdminScreen> createState() => _ViewReviewOfTheProjectAdminScreenState();
}

class _ViewReviewOfTheProjectAdminScreenState extends State<ViewReviewOfTheProjectAdminScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  bool editusername = false;
  bool editemail = false;
  bool editfirstname = false;
  bool editlastname = false;
  bool editphone = false;
  bool editrole = false;
  bool initialPendingUserDataChange = false;

  Future<bool>? _future;

  void _sendCommentsToPI() async {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Want to Send Comments to PI?",
      desc: "Press Yes to confirm.",
      width: kDialogWidth,
      btnOkText: 'Yes',
      btnOkOnPress: () async {
        final responseBody = await ApiService.updatePiCanViewOrNot(int.parse(_formData.projectID));
        if (responseBody['statuscode'] == 200) {
          // Handle success
          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: "Comments Sent successfully",
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () {},
          );
          dialog.show();
        }
      },
      btnCancelOnPress: () {},
      btnCancelText: 'No',
    );
    dialog.show();
  }

  void _updateProjectStatusAndPoints() async {
    AppFocusHelper.instance.requestUnfocus();

    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: "Want to update project status and points?",
      desc: "This action cannot be undone. Press Yes to confirm.",
      width: kDialogWidth,
      btnOkText: 'Yes',
      btnOkOnPress: () async {
        _formKey.currentState!.validate();
        _formKey.currentState!.save();
        final updateProjectStatusAndPoints = {
          'ProjectStatus': _formData.projectStatus,
          'TotalPoints': ((_formData.reviewPoint1 + _formData.reviewPoint2 + _formData.reviewPoint3) / 3.0),
        };
        final responseBody = await ApiService.updateProjectStatusAndPoints(int.parse(_formData.projectID), updateProjectStatusAndPoints);
        if (responseBody['statuscode'] == 200) {
          // Handle success
          final dialog = AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            title: "ProjectStatus & Point Updated successfully",
            width: kDialogWidth,
            btnOkText: 'OK',
            btnOkOnPress: () => GoRouter.of(context).go(RouteUri.projectreviewerhasgivenreview),
          );
          dialog.show();
        }
      },
      btnCancelOnPress: () {},
      btnCancelText: 'No',
    );
    dialog.show();
  }

  Future<bool> _getDataAsync() async {
    print('projectID: ${widget.projectID}');
    if (widget.projectID.isNotEmpty) {
      print('projectID: ${widget.projectID}');
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.projectID = widget.projectID;

        int projectID = int.parse(widget.projectID);
        final reviewsDetails = await ApiService.fetchAllReviewForSpecificProject(
          projectID,
        );
        if (reviewsDetails[0]['statuscode'] == 401) {
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

        if (reviewsDetails.isNotEmpty) {
          _formData.reviewComment1 = reviewsDetails[0]['Comments'];
          _formData.reviewComment2 = reviewsDetails[1]['Comments'];
          _formData.reviewComment3 = reviewsDetails[2]['Comments'];
          _formData.reviewPoint1 = reviewsDetails[0]['Points'];
          _formData.reviewPoint2 = reviewsDetails[1]['Points'];
          _formData.reviewPoint3 = reviewsDetails[2]['Points'];
          _formData.reviewerUserId1 = reviewsDetails[0]['ReviewerUserID'];
          _formData.reviewerUserId2 = reviewsDetails[1]['ReviewerUserID'];
          _formData.reviewerUserId3 = reviewsDetails[2]['ReviewerUserID'];
          _formData.reviewId1 = reviewsDetails[0]['ReviewID'];
          _formData.reviewId2 = reviewsDetails[1]['ReviewID'];
          _formData.reviewId3 = reviewsDetails[2]['ReviewID'];

          final reviewerDetails1 = await ApiService.getSpecificUserMinimum(
            _formData.reviewerUserId1,
          );
          if (reviewerDetails1['statuscode'] == 200) {
            _formData.reviewerFirstname1 = reviewerDetails1['user']['FirstName'];
            _formData.reviewerLastname1 = reviewerDetails1['user']['LastName'];
            _formData.reviewerUsername1 = reviewerDetails1['user']['Username'];
            _formData.reviewerProfilePicLocation1 = reviewerDetails1['user']['ProfilePicLocation'] ?? '';
          }
          final reviewerDetails2 = await ApiService.getSpecificUserMinimum(
            _formData.reviewerUserId2,
          );
          if (reviewerDetails2['statuscode'] == 200) {
            _formData.reviewerFirstname2 = reviewerDetails2['user']['FirstName'];
            _formData.reviewerLastname2 = reviewerDetails2['user']['LastName'];
            _formData.reviewerUsername2 = reviewerDetails2['user']['Username'];
            _formData.reviewerProfilePicLocation2 = reviewerDetails2['user']['ProfilePicLocation'] ?? '';
          }
          final reviewerDetails3 = await ApiService.getSpecificUserMinimum(
            _formData.reviewerUserId3,
          );
          if (reviewerDetails3['statuscode'] == 200) {
            _formData.reviewerFirstname3 = reviewerDetails3['user']['FirstName'];
            _formData.reviewerLastname3 = reviewerDetails3['user']['LastName'];
            _formData.reviewerUsername3 = reviewerDetails3['user']['Username'];
            _formData.reviewerProfilePicLocation3 = reviewerDetails3['user']['ProfilePicLocation'] ?? '';
          }

          final projectStatus = await ApiService.getProjectStatusSpecificProject(
            int.parse(widget.projectID),
          );
          if (projectStatus['statuscode'] == 200) {
            _formData.projectStatus = projectStatus['ProjectStatus'];
          }
        }
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.reviewpaneloverview,
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
    final pageTitle = 'Project - ID: ${widget.projectID.isEmpty ? 'Invalid Project-ID' : widget.projectID}';

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
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                                          child: Stack(
                                            children: [
                                              FutureBuilder<String>(
                                                future: _formData.reviewerProfilePicLocation1.isNotEmpty
                                                    ? ApiService.downloadFile('profile-pic/download', _formData.reviewerProfilePicLocation1)
                                                    : ApiService.downloadFile('profile-pic/download', "defaultprofilepic.png"), // Check if value is not empty before making the API call
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
                                                      height: 120, // Adjust height as needed
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
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.45) - (kDefaultPadding * 0.45)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Fullname:  ${_formData.reviewerFirstname1} ${_formData.reviewerLastname1}',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: "Username:  ${_formData.reviewerUsername1}",
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Given Point:  ${_formData.reviewPoint1}',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.6)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: "Comment:  ${_formData.reviewComment1}",
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                                          child: Stack(
                                            children: [
                                              FutureBuilder<String>(
                                                future: _formData.reviewerProfilePicLocation2.isNotEmpty
                                                    ? ApiService.downloadFile('profile-pic/download', _formData.reviewerProfilePicLocation2)
                                                    : ApiService.downloadFile('profile-pic/download', "defaultprofilepic.png"), // Check if value is not empty before making the API call
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
                                                      height: 120, // Adjust height as needed
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
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.45) - (kDefaultPadding * 0.45)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Fullname:  ${_formData.reviewerFirstname2} ${_formData.reviewerLastname2}',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: "Username:  ${_formData.reviewerUsername2}",
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Given Point:  ${_formData.reviewPoint2}',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.6)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: "Comment:  ${_formData.reviewComment2}",
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.2) - (kDefaultPadding * 0.2)),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.0),
                                          child: Stack(
                                            children: [
                                              FutureBuilder<String>(
                                                future: _formData.reviewerProfilePicLocation3.isNotEmpty
                                                    ? ApiService.downloadFile('profile-pic/download', _formData.reviewerProfilePicLocation3)
                                                    : ApiService.downloadFile('profile-pic/download', "defaultprofilepic.png"), // Check if value is not empty before making the API call
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
                                                      height: 120, // Adjust height as needed
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
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.45) - (kDefaultPadding * 0.45)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Fullname:  ${_formData.reviewerFirstname3} ${_formData.reviewerLastname3}',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.3) - (kDefaultPadding * 0.3)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: "Username:  ${_formData.reviewerUsername3}",
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      const SizedBox(height: kDefaultPadding * 1.0),
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.15) - (kDefaultPadding * 0.15)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: 'Given Point:  ${_formData.reviewPoint3}',
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: kDefaultPadding * 0.5),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.6) - (kDefaultPadding * 0.6)),
                                          child: Card(
                                            clipBehavior: Clip.antiAlias,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                CardHeader(
                                                  title: "Comment:  ${_formData.reviewComment3}",
                                                  backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                                  titleColor: const Color.fromARGB(255, 238, 216, 221),
                                                  showDivider: false,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.30) - (kDefaultPadding * 0.30)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Average Point:  ${(_formData.reviewPoint1 + _formData.reviewPoint2 + _formData.reviewPoint3) / 3.0}',
                                              backgroundColor: const Color.fromARGB(255, 51, 55, 56),
                                              titleColor: const Color.fromARGB(255, 238, 216, 221),
                                              showDivider: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.30) - (kDefaultPadding * 0.30)),
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
                                              'Pending',
                                              'Approved',
                                              'Rejected',
                                              'Running',
                                              'Completed',
                                            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                            onChanged: (value) => (_formData.projectStatus = value ?? ''),
                                          ),
                                        ),
                                        const SizedBox(height: kDefaultPadding * 2),
                                        SizedBox(
                                          width: ((constraints.maxWidth * 0.30) - (kDefaultPadding * 0.30)),
                                          child: ElevatedButton(
                                            style: themeData.extension<AppButtonTheme>()!.successText,
                                            onPressed: () {
                                              _updateProjectStatusAndPoints();
                                            },
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                  child: Icon(
                                                    Icons.check_outlined,
                                                    size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                  ),
                                                ),
                                                const Text(
                                                  "Confirm Project Status & Point",
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: kDefaultPadding),
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: ((constraints.maxWidth * 0.30) - (kDefaultPadding * 0.30)),
                                        child: ElevatedButton(
                                          style: themeData.extension<AppButtonTheme>()!.warningText,
                                          onPressed: () {
                                            _sendCommentsToPI();
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                                child: Icon(
                                                  Icons.send_outlined,
                                                  size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                                ),
                                              ),
                                              const Text("Send Comments to PI", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: kDefaultPadding * 2),
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.projectreviewerhasgivenreview),
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
  String reviewComment1 = '';
  String reviewComment2 = '';
  String reviewComment3 = '';
  double reviewPoint1 = 0.0;
  double reviewPoint2 = 0.0;
  double reviewPoint3 = 0.0;
  int reviewId1 = 0;
  int reviewId2 = 0;
  int reviewId3 = 0;
  int reviewerUserId1 = 0;
  int reviewerUserId2 = 0;
  int reviewerUserId3 = 0;
  String reviewerUsername1 = '';
  String reviewerUsername2 = '';
  String reviewerUsername3 = '';
  String reviewerFirstname1 = '';
  String reviewerFirstname2 = '';
  String reviewerFirstname3 = '';
  String reviewerLastname1 = '';
  String reviewerLastname2 = '';
  String reviewerLastname3 = '';
  String reviewerProfilePicLocation1 = '';
  String reviewerProfilePicLocation2 = '';
  String reviewerProfilePicLocation3 = '';

  String projectStatus = '';
}
