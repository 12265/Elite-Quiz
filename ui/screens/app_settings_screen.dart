import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_localization.dart';
import '../../features/systemConfig/cubits/appSettingsCubit.dart';
import '../../features/systemConfig/system_config_repository.dart';
import '../../utils/constants/error_message_keys.dart';
import '../../utils/constants/string_labels.dart';
import '../widgets/customAppbar.dart';
import '../widgets/errorContainer.dart';

/// AppSettingsScreen shows app setting details like about us,
/// privacy policy, terms and conditions, etc.
///
/// It takes a required [title] parameter indicating which setting to load.
/// Uses AppSettingsCubit and SystemConfigRepository to fetch setting data.
/// [_settingType] determines type string to pass to cubit based on [title].
/// [fetchAppSetting] calls cubit method to fetch data.
///
/// [_onTapUrl] handles launching external urls.

class AppSettingsScreen extends StatefulWidget {
  final String title;

  const AppSettingsScreen({super.key, required this.title});

  static Route<AppSettingsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<AppSettingsCubit>(
        create: (_) => AppSettingsCubit(SystemConfigRepository()),
        child: AppSettingsScreen(title: routeSettings.arguments as String),
      ),
    );
  }

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late final _settingType = switch (widget.title) {
    aboutUs => "about_us",
    privacyPolicy => "privacy_policy",
    termsAndConditions => "terms_conditions",
    contactUs => "contact_us",
    howToPlayLbl => "instructions",
    _ => "",
  };
  late final _screenTitle =
      AppLocalization.of(context)!.getTranslatedValues(widget.title)!;

  @override
  void initState() {
    super.initState();
    fetchAppSetting();
  }

  void fetchAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting(_settingType);
    });
  }

  FutureOr<bool> _onTapUrl(String url) async {
    final canLaunch = await canLaunchUrl(Uri.parse(url));
    if (canLaunch) {
      launchUrl(Uri.parse(url));
    } else {
      log("Error Launching URL : $url", name: "Launch URL");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(title: Text(_screenTitle)),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: context.read<AppSettingsCubit>(),
        builder: (context, state) {
          if (state is AppSettingsFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: AppLocalization.of(context)!.getTranslatedValues(
                    convertErrorCodeToLanguageKey(state.errorCode))!,
                onTapRetry: fetchAppSetting,
                showErrorImage: true,
                errorMessageColor: Theme.of(context).primaryColor,
              ),
            );
          }

          if (state is AppSettingsFetchSuccess) {
            final size = MediaQuery.of(context).size;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: size.height * UiUtils.vtMarginPct,
                horizontal: size.width * UiUtils.hzMarginPct + 10,
              ),
              child: HtmlWidget(
                state.settingsData,
                onErrorBuilder: (_, e, err) => Text('$e error: $err'),
                onLoadingBuilder: (_, e, l) => const Center(
                  child: CircularProgressIndicator(),
                ),
                renderMode: RenderMode.column,
                textStyle: const TextStyle(fontSize: 14),
                onTapUrl: _onTapUrl,
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
