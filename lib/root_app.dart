import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rtc_project_fronend/app_router.dart';
import 'package:rtc_project_fronend/generated/l10n.dart';
import 'package:rtc_project_fronend/providers/app_preferences_provider.dart';
import 'package:rtc_project_fronend/providers/user_data_provider.dart';
import 'package:rtc_project_fronend/theme/themes.dart';
import 'package:rtc_project_fronend/utils/app_focus_helper.dart';

class RootApp extends StatefulWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  GoRouter? _appRouter;

  Future<bool>? _future;

  Future<bool> _getScreenDataAsync(AppPreferencesProvider appPreferencesProvider, UserDataProvider userDataProvider) async {
    await appPreferencesProvider.loadAsync();
    await userDataProvider.loadAsync();

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppPreferencesProvider()),
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
      ],
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              // Tap anywhere to dismiss soft keyboard.
              AppFocusHelper.instance.requestUnfocus();
            },
            child: FutureBuilder<bool>(
              initialData: null,
              future: (_future ??= _getScreenDataAsync(context.read<AppPreferencesProvider>(), context.read<UserDataProvider>())),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return Consumer<AppPreferencesProvider>(
                    builder: (context, provider, child) {
                      _appRouter ??= appRouter(context.read<UserDataProvider>());

                      return MaterialApp.router(
                        debugShowCheckedModeBanner: false,
                        routeInformationProvider: _appRouter!.routeInformationProvider,
                        routeInformationParser: _appRouter!.routeInformationParser,
                        routerDelegate: _appRouter!.routerDelegate,
                        supportedLocales: Lang.delegate.supportedLocales,
                        localizationsDelegates: const [
                          Lang.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          FormBuilderLocalizations.delegate,
                        ],
                        // locale: provider.locale,
                        onGenerateTitle: (context) => "PSTU Research & Training Center",
                        theme: AppThemeData.instance.light(),
                        darkTheme: AppThemeData.instance.dark(),
                        themeMode: provider.themeMode,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
