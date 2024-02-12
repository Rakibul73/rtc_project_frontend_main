// ignore_for_file: avoid_print

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rtc_project_fronend/api_service.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/constants/dimens.dart';
import 'package:rtc_project_fronend/generated/l10n.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_button_theme.dart';
import 'package:rtc_project_fronend/theme/theme_extensions/app_color_scheme.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';
import 'package:rtc_project_fronend/views/widgets/public_master_layout/public_master_layout.dart';

class ForgotPass extends StatefulWidget {
  const ForgotPass({Key? key}) : super(key: key);

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  var _isFormLoading = false;

  Future<void> _doPassResetAsync({
    required UserDataProvider userDataProvider,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      // Validation passed.
      _formKey.currentState!.save();

      setState(() => _isFormLoading = true);

      await userDataProvider.setUserDataAsync(
        email: _formData.email,
      );

      Future.delayed(const Duration(seconds: 1), () async {
        final responseCode = await ApiService.resetPasswordRequest(_formData.email);

        if (responseCode == 200) {
          onSuccess.call();
        } else if (responseCode == 404) {
          onError.call('Email not found');
          print("ssssssssssssssssssssssssssssss");
        } else {
          onError.call('Something went wrong');
          print("ssssssssssssssssssssssssssssss");
        }

        setState(() => _isFormLoading = false);
      });
    }
  }

  void _onPassresetrequestSuccess(BuildContext context) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      desc: "Password reset OTP sent to = ${_formData.email}",
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {
        GoRouter.of(context).go(RouteUri.resetpassscreen);
      },
    );
    dialog.show();

    // Navigator.pushReplacementNamed(context, '/dashboard');
    print("GoRouter.of(context).go(RouteUri.login);");
  }

  void _onLoginError(BuildContext context, String message) {
    final dialog = AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      desc: message,
      width: kDialogWidth,
      btnOkText: 'OK',
      btnOkOnPress: () {},
    );
    dialog.show();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Lang.of(context);
    final themeData = Theme.of(context);

    return PublicMasterLayout(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.only(top: kDefaultPadding * 5.0),
            constraints: const BoxConstraints(maxWidth: 400.0),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: kDefaultPadding),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        height: 80.0,
                      ),
                    ),
                    Text(
                      "PSTU Research & Training Center",
                      style: themeData.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600, fontSize: 22.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                      child: Text(
                        "Forgot Password ?",
                        style: themeData.textTheme.titleMedium,
                      ),
                    ),
                    FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 1.5),
                            child: FormBuilderTextField(
                              name: 'email',
                              decoration: InputDecoration(
                                labelText: lang.email,
                                hintText: lang.email,
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) => (_formData.email = value ?? ''),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                          //   child: Theme(
                          //     data: themeData.copyWith(
                          //       // canvasColor: Colors.amber,
                          //       splashColor: Colors.amber,
                          //     ),
                          //     child: FormBuilderDropdown(
                          //       name: 'roleID',
                          //       decoration: const InputDecoration(
                          //         labelText: 'Choose Role',
                          //         border: OutlineInputBorder(),
                          //         hoverColor: Colors.transparent,
                          //         focusColor: Colors.transparent,
                          //       ),
                          //       allowClear: true,
                          //       focusColor: Colors.transparent,
                          //       hint: const Text('Select'),
                          //       validator: FormBuilderValidators.required(),
                          //       items: ['Admin', 'Researcher', 'Reviewer', 'Teacher', 'Student'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          //       onSaved: (value) => (_formData.roleID = value ?? ''),
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding),
                            child: SizedBox(
                              height: 40.0,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: themeData.extension<AppButtonTheme>()!.primaryElevated,
                                onPressed: (_isFormLoading
                                    ? null
                                    : () => _doPassResetAsync(
                                          userDataProvider: context.read<UserDataProvider>(),
                                          onSuccess: () => _onPassresetrequestSuccess(context),
                                          onError: (message) => _onLoginError(context, message),
                                        )),
                                child: const Text(
                                  "Reset Password",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                            width: double.infinity,
                            child: OutlinedButton(
                              style: themeData.extension<AppButtonTheme>()!.secondaryOutlined,
                              onPressed: () => GoRouter.of(context).go(RouteUri.login),
                              child: const Text("Back to Login"),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                            width: double.infinity,
                            child: TextButton(
                              style: themeData.extension<AppButtonTheme>()!.secondaryText,
                              onPressed: () => GoRouter.of(context).go(RouteUri.register),
                              child: RichText(
                                text: TextSpan(
                                  text: '${lang.dontHaveAnAccount} ',
                                  style: TextStyle(
                                    color: themeData.colorScheme.onSurface,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: lang.registerNow,
                                      style: TextStyle(
                                        color: themeData.extension<AppColorScheme>()!.hyperlink,
                                        decoration: TextDecoration.underline,
                                      ),
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
          ),
        ),
      ),
    );
  }
}

class FormData {
  String email = '';
  String password = '';
  String roleID = '';
}
