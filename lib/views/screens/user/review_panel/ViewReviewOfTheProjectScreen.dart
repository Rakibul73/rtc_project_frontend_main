import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:rtc_project_fronend/api_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class ViewReviewOfTheProjectScreen extends StatefulWidget {
  final String projectID;

  const ViewReviewOfTheProjectScreen({
    Key? key,
    required this.projectID,
  }) : super(key: key);

  @override
  State<ViewReviewOfTheProjectScreen> createState() => _ViewReviewOfTheProjectScreenState();
}

class _ViewReviewOfTheProjectScreenState extends State<ViewReviewOfTheProjectScreen> {
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
          _formData.reviewId1 = reviewsDetails[0]['ReviewID'];
          _formData.reviewId2 = reviewsDetails[1]['ReviewID'];
          _formData.reviewId3 = reviewsDetails[2]['ReviewID'];

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
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5, top: kDefaultPadding * 0.5),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.22) - (kDefaultPadding * 0.22)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Reviewer 1:',
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5, top: kDefaultPadding * 0.5),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.22) - (kDefaultPadding * 0.22)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Reviewer 2:',
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5, top: kDefaultPadding * 0.5),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.22) - (kDefaultPadding * 0.22)),
                                      child: const Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            CardHeader(
                                              title: 'Reviewer 3:',
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 0.5, top: kDefaultPadding * 0.5),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const CardHeader(
                                              title: 'Average Point:',
                                              backgroundColor: Color.fromARGB(255, 74, 89, 96),
                                              titleColor: Color.fromARGB(255, 151, 204, 197),
                                              showDivider: false,
                                            ),
                                            CardHeader(
                                              title: '${(_formData.reviewPoint1 + _formData.reviewPoint2 + _formData.reviewPoint3) / 3.0}',
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
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
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
                                      ],
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.myprojectreview),
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
                              SizedBox(
                                height: 40.0,
                                child: ElevatedButton(
                                  style: themeData.extension<AppButtonTheme>()!.infoOutlined,
                                  onPressed: () => GoRouter.of(context).go('${RouteUri.editproject}?projectid=${_formData.projectID}'),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                        child: Icon(
                                          Icons.list_alt_rounded,
                                          size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                        ),
                                      ),
                                      const Text("View Project"),
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

  String projectStatus = '';
}
