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

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _formData = FormData();

  var _isFormLoading = false;

  // Function to map role name to role ID
  int getRoleId(String roleName) {
    switch (roleName) {
      case 'Admin':
        return 1;
      case 'Teacher':
        return 4;
      case 'Student':
        return 5;
      case 'Reviewer':
        return 3;
      case 'Researcher':
        return 2;
      default:
        // Default to 1 (Admin) if not found
        return 1;
    }
  }

  Future<void> _doLoginAsync({
    required UserDataProvider userDataProvider,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    AppFocusHelper.instance.requestUnfocus();

    if (_formKey.currentState?.validate() ?? false) {
      // Validation passed.
      _formKey.currentState!.save();

      setState(() => _isFormLoading = true);

      Future.delayed(const Duration(seconds: 1), () async {
        final roleId = getRoleId(_formData.roleID); // Map role name to role ID
        final response = await ApiService.loginUser(
          username: _formData.username,
          password: _formData.password,
          roleID: roleId,
        );
        if (response['statuscode'] != 200) {
          onError.call('Invalid username or password or role.');
        } else {
          // User logged in successfully

          await storage.write(key: 'jwt_token', value: (response['access_token']).toString());
          await storage.write(key: 'user_id', value: (response['user_id']).toString());
          await storage.write(key: 'statuscode', value: response['statuscode'].toString());

          final userDetails = await ApiService.getSpecificUser(
            response['user_id'],
          );
          final firstName = userDetails['user']['FirstName'];
          final lastname = userDetails['user']['LastName'];
          final username = userDetails['user']['Username'];
          final userID = userDetails['user']['UserID'];
          // String ss;
          // if(userDetails['user']['ProfilePicLocation'] == null){
          //   ss = 'defaultprofilepic.png';
          // }
          // else{
          //   ss = userDetails['user']['ProfilePicLocation'];
          // }
          // final profilePicLocation = ss;
          final profilePicLocation = userDetails['user']['ProfilePicLocation'] ?? 'defaultprofilepic.png';
          final roleId = userDetails['user']['RoleID'];
          await userDataProvider.setUserDataAsync(
            username: username,
            firstname: firstName,
            lastname: lastname,
            profilePicLocation: profilePicLocation,
            roleId: roleId,
            userId: userID,
          );

          onSuccess.call();
        }

        setState(() => _isFormLoading = false);
      });
    }
  }

  void _onLoginSuccess(BuildContext context, int roleId) {
    if (roleId == 1) {
      GoRouter.of(context).go(RouteUri.home);
    } else {
      GoRouter.of(context).go(RouteUri.projectdashboard);
    }
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
                      "PSTU RTC Project Management",
                      style: themeData.textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 22.0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                      child: Text(
                        lang.adminPortalLogin,
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
                              name: 'username',
                              decoration: InputDecoration(
                                labelText: lang.username,
                                hintText: lang.username,
                                // helperText: '',
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              enableSuggestions: false,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) => (_formData.username = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: FormBuilderTextField(
                              name: 'password',
                              decoration: InputDecoration(
                                labelText: lang.password,
                                hintText: lang.password,
                                // helperText: '',
                                border: const OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                              ),
                              enableSuggestions: false,
                              obscureText: true,
                              validator: FormBuilderValidators.required(),
                              onSaved: (value) => (_formData.password = value ?? ''),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding * 2.0),
                            child: Theme(
                              data: themeData.copyWith(
                                // canvasColor: Colors.amber,
                                splashColor: Colors.amber,
                              ),
                              child: FormBuilderDropdown(
                                name: 'roleID',
                                decoration: const InputDecoration(
                                  labelText: 'Choose Role',
                                  border: OutlineInputBorder(),
                                  hoverColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hintText: 'Select',
                                ),
                                focusColor: Colors.transparent,
                                validator: FormBuilderValidators.required(),
                                items: ['Admin', 'Researcher', 'Reviewer', 'Teacher', 'Student'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                onSaved: (value) => (_formData.roleID = value ?? ''),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: kDefaultPadding),
                            child: SizedBox(
                              height: 40.0,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: themeData.extension<AppButtonTheme>()!.primaryElevated,
                                onPressed: (_isFormLoading
                                    ? null
                                    : () => _doLoginAsync(
                                          userDataProvider: context.read<UserDataProvider>(),
                                          onSuccess: () => _onLoginSuccess(context, getRoleId(_formData.roleID)),
                                          onError: (message) => _onLoginError(context, message),
                                        )),
                                child: Text(
                                  lang.login,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                            width: double.infinity,
                            child: OutlinedButton(
                              style: themeData.extension<AppButtonTheme>()!.secondaryOutlined,
                              onPressed: () => GoRouter.of(context).go(RouteUri.forgotpass),
                              child: const Text("Forgot Password ?"),
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
  String username = '';
  String password = '';
  String roleID = '';
}
