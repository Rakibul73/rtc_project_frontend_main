import 'dart:convert';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/views/screens/pdf_generate/pdf_generator.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:rtc_project_fronend/api_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class ViewNoticeScreen extends StatefulWidget {
  final String noticeID;

  const ViewNoticeScreen({
    Key? key,
    required this.noticeID,
  }) : super(key: key);

  @override
  State<ViewNoticeScreen> createState() => _ViewNoticeScreenState();
}

class _ViewNoticeScreenState extends State<ViewNoticeScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  Uint8List? _noticeFileBytes;
  late bool noticeFileisDOCPDFDOCX;
  Future<bool>? _future;

  void _showNoticeFilePicker() async {
    print('_showNoticeFilePicker: ');
    viewDOC(_noticeFileBytes!, _formData.datePublished);
  }

  void _downloadNotice() {
    downloadImage(_noticeFileBytes!, _formData.noticeFileLocation);
  }

  Future<bool> _getDataAsync() async {
    print('noticeID: ${widget.noticeID}');
    if (widget.noticeID.isNotEmpty) {
      print('noticeID: ${widget.noticeID}');
      await Future.delayed(const Duration(seconds: 1), () async {
        _formData.noticeID = widget.noticeID;

        int noticeID = int.parse(widget.noticeID);
        final noticeDetails = await ApiService.fetchANotice(
          noticeID,
        );
        if (noticeDetails[0]['statuscode'] == 401) {
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

        print(noticeDetails);

        if (noticeDetails.isNotEmpty) {
          _formData.noticeID = noticeDetails[0]['NoticeID'].toString();
          _formData.datePublished = noticeDetails[0]['DatePublished'];
          // ignore: unnecessary_null_comparison
          if (_formData.datePublished != null && _formData.datePublished.isNotEmpty) {
            DateTime utcDateTime = DateFormat('E, dd MMM yyyy HH:mm a').parseUTC(_formData.datePublished);
            _formData.datePublished = DateFormat('E, dd MMM yyyy hh:mm a').format(utcDateTime);
          }
          _formData.subject = noticeDetails[0]['Subject'];
          _formData.noticeFileLocation = noticeDetails[0]['NoticeFileLocation'];
          if (_formData.noticeFileLocation.toLowerCase().endsWith('.docx') ||
              _formData.noticeFileLocation.toLowerCase().endsWith('.doc') ||
              _formData.noticeFileLocation.toLowerCase().endsWith('.pdf')) {
            noticeFileisDOCPDFDOCX = true;
          } else {
            noticeFileisDOCPDFDOCX = false;
          }

          String noticefilePath = await ApiService.downloadFile('notice/download', _formData.noticeFileLocation);
          if (noticefilePath.isNotEmpty) {
            Uint8List fileBytes = base64Decode(noticefilePath);
            _noticeFileBytes = fileBytes;
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
      selectedMenuUri: RouteUri.circularnotice,
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
    final pageTitle = 'Notice - ID: ${widget.noticeID.isEmpty ? 'Invalid Notice-ID' : widget.noticeID}';

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
                    const CardHeader(title: "Edit Notice Here", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
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
                                  CardHeader(
                                    title: "Notice Published Date:   ${_formData.datePublished}",
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
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CardHeader(
                                    title: "Subject:   ${_formData.subject}",
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
                                    Visibility(
                                      visible: noticeFileisDOCPDFDOCX == true,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 1) - (kDefaultPadding * 1)),
                                        child: ElevatedButton(
                                          style: themeData.extension<AppButtonTheme>()!.warningText,
                                          onPressed: () {
                                            _showNoticeFilePicker();
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
                                              const Text("View Notice Doc"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Visibility(
                                      visible: noticeFileisDOCPDFDOCX == false,
                                      child: SizedBox(
                                        width: ((constraints.maxWidth * 1) - (kDefaultPadding * 1)),
                                        child: ElevatedButton(
                                          style: themeData.extension<AppButtonTheme>()!.warningText,
                                          onPressed: () {
                                            _downloadNotice();
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
                                              const Text("Download Notice"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Visibility(
                            visible: noticeFileisDOCPDFDOCX == false,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                                child: Stack(
                                  children: [
                                    _noticeFileBytes != null
                                        ? Image.memory(
                                            _noticeFileBytes!,
                                            fit: BoxFit.cover, // Adjust image to cover the entire space
                                            width: 800, // Adjust width as needed
                                            // height: 150, // Adjust height as needed
                                          )
                                        : const CircularProgressIndicator(),
                                  ],
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
                                  onPressed: () => GoRouter.of(context).go(RouteUri.circularnotice),
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
  String noticeID = '';
  String datePublished = '';
  String subject = '';
  String noticeFileLocation = '';
}
