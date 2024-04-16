// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/card_elements.dart';
import 'package:rtc_project_fronend/views/widgets/portal_master_layout/portal_master_layout.dart';

class CreateCircularNoticeScreen extends StatefulWidget {
  const CreateCircularNoticeScreen({Key? key}) : super(key: key);

  @override
  State<CreateCircularNoticeScreen> createState() => _CreateCircularNoticeScreenState();
}

class _CreateCircularNoticeScreenState extends State<CreateCircularNoticeScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  List<PlatformFile>? _noticeFiles;
  String noticeFileLocation = '';

  void _onNoticeFileSelected(List<PlatformFile>? files) {
    setState(() {
      _noticeFiles = files != null ? List.from(files) : null; // Update to assign the list of files
    });
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

  Future<void> _doSave() async {
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

      final createNoticeData = {
        'NoticeFileLocation': noticeFileLocation,
        'Subject': _formData.subject,
        'DatePublished': datePublished,
      };

      final responseBody = await ApiService.createNotice(createNoticeData);

      if (responseBody['statuscode'] == 201) {
        print('do save');
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: "Notice created successfully.",
          width: kDialogWidth,
          btnOkText: 'OK',
          btnOkOnPress: () => GoRouter.of(context).go(RouteUri.circularnotice),
        );
        dialog.show();
      } else {
        final dialog = AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: "Error creating Notice {responseBody['message']}: ${responseBody['message']} , {responseBody['error']}: ${responseBody['error']}.",
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PortalMasterLayout(
      selectedMenuUri: RouteUri.circularnotice,
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
            Padding(
              padding: const EdgeInsets.only(bottom: kDefaultPadding),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardHeader(title: "Upload Circular Notice Here", backgroundColor: Color.fromARGB(255, 139, 161, 168), titleColor: Color.fromARGB(255, 50, 39, 42)),
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
                              name: 'subject_of_the_notice',
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
                                style: themeData.extension<AppButtonTheme>()!.successOutlined,
                                onPressed: _doSave,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: kDefaultPadding * 0.5),
                                      child: Icon(
                                        Icons.save_rounded,
                                        size: (themeData.textTheme.labelLarge!.fontSize! + 4.0),
                                      ),
                                    ),
                                    const Text(
                                      "Submit Notice",
                                    ),
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
          ],
        ),
      ),
    );
  }
}

class FormData {
  String password = '';
  String roleID = '';
  String subject = '';
}
