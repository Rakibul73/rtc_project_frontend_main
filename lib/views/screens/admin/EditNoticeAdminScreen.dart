import 'dart:convert';
import 'dart:typed_data';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/screens/pdf_generate/pdf_generator.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';
// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:rtc_project_fronend/api_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';

class EditNoticeAdminScreen extends StatefulWidget {
  final String noticeID;

  const EditNoticeAdminScreen({
    Key? key,
    required this.noticeID,
  }) : super(key: key);

  @override
  State<EditNoticeAdminScreen> createState() => _EditNoticeAdminScreenState();
}

class _EditNoticeAdminScreenState extends State<EditNoticeAdminScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  List<PlatformFile>? _noticeFiles;
  String noticeFileLocation = '';
  Uint8List? _noticeFileBytes;
  late bool noticeFileisDOCPDFDOCX;
  Future<bool>? _future;

  void _onNoticeFileSelected(List<PlatformFile>? files) {
    setState(() {
      _noticeFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
  }

  void _showNoticeFilePicker() async {
    print('_showNoticeFilePicker: ');
    viewDOC(_noticeFileBytes!, _formData.datePublished);
  }

  void _downloadNotice() {
    downloadImage(_noticeFileBytes!, _formData.noticeFileLocation);
  }

  Future<void> _uploadNoticeFiles() async {
    if (_noticeFiles != null && _noticeFiles!.isNotEmpty) {
      // try {
      for (var file in _noticeFiles!) {
        final fileBytes = file.bytes!;
        final fileName = file.name;
        noticeFileLocation = fileName;
        print(fileName);
        final responseBody = await ApiService.uploadFile('notice/upload', file, fileBytes, fileName);
        if (responseBody['statuscode'] == 200) {
          print('File uploaded successfully');
        }
      }
    } else {
      print('No notice files selected');
    }
  }

  Future<void> _doUpdate() async {
    AppFocusHelper.instance.requestUnfocus();

    print('do save start');
    print(_formKey.currentState?.saveAndValidate());
    print('do save start');

    if (_formKey.currentState?.saveAndValidate() == true) {
      _formKey.currentState!.save();

      await _uploadNoticeFiles();

      // get current date time
      final DateTime now = DateTime.now();
      final String datePublished = DateFormat('E, dd MMM yyyy hh:mm a').format(now);
      print(datePublished);

      final updateNoticeData = {
        'NoticeFileLocation': noticeFileLocation,
        'Subject': _formData.subject,
        'DatePublished': datePublished,
      };

      final responseBody = await ApiService.updateNotice(updateNoticeData, int.parse(widget.noticeID));

      if (responseBody['statuscode'] == 200) {
        print('do update');
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: "Notice updated successfully.",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () => GoRouter.of(context).go(RouteUri.circularnotice),
        );
        dialog.show();
      } else {
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: "Error updating Notice {responseBody['message']}: ${responseBody['message']} , {responseBody['error']}: ${responseBody['error']}.",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () {},
        );
        dialog.show();
      }
    } else {
      print("Input fields are not valid or empty.");
    }
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

        print(noticeDetails);

        if (noticeDetails.isNotEmpty) {
          _formData.noticeID = noticeDetails[0]['NoticeID'].toString();
          _formData.datePublished = noticeDetails[0]['DatePublished'];
          if (_formData.datePublished != null && _formData.datePublished.isNotEmpty) {
            DateTime utcDateTime = DateFormat('E, dd MMM yyyy HH:mm a').parseUTC(_formData.datePublished);
            _formData.datePublished = DateFormat('E, dd MMM yyyy hh:mm a').format(utcDateTime);
          }
          _formData.subject = noticeDetails[0]['Subject'];
          _formData.noticeFileLocation = noticeDetails[0]['NoticeFileLocation'];
          noticeFileLocation = _formData.noticeFileLocation;
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
                            child: FormBuilderTextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: null, // Allow unlimited lines
                              name: 'subject_of_the_notice',
                              initialValue: _formData.subject,
                              decoration: const InputDecoration(
                                labelText: 'Subject of the Notice',
                                hintText: 'Subject of the Notice',
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              validator: FormBuilderValidators.required(),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (value) => (_formData.subject = value ?? ''),
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
                                      Visibility(
                                        visible: noticeFileisDOCPDFDOCX == true,
                                        child: SizedBox(
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
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
                                                const Text("View Notice"),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: noticeFileisDOCPDFDOCX == false,
                                        child: SizedBox(
                                          width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
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
                                    ]),
                                    const SizedBox(width: kDefaultPadding),
                                    SizedBox(
                                      width: ((constraints.maxWidth * 0.5) - (kDefaultPadding * 0.5)),
                                      child: FormBuilderFilePicker(
                                        name: 'notice_file',
                                        allowMultiple: false,
                                        maxFiles: 1,
                                        type: FileType.any,
                                        previewImages: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Notice File',
                                          border: OutlineInputBorder(),
                                        ),
                                        selector: const Row(
                                          children: [
                                            Icon(Icons.file_upload_rounded),
                                            Text('Upload Notice Doc/Pdf'),
                                          ],
                                        ),
                                        onChanged: _onNoticeFileSelected,
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
                              const Spacer(),
                              SizedBox(
                                height: 40.0,
                                child: ElevatedButton(
                                  style: themeData.extension<AppButtonTheme>()!.primaryOutlined,
                                  onPressed: () {
                                    _doUpdate();
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                        child: Icon(
                                          Icons.update_outlined,
                                          size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                        ),
                                      ),
                                      const Text("Update Notice"),
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
