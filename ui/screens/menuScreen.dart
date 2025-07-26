import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/localization/appLocalizationCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/deleteAccountCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizzone_category_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/features/systemConfig/model/supportedQuestionLanguage.dart';
import 'package:flutterquiz/ui/styles/theme/appTheme.dart';
import 'package:flutterquiz/ui/styles/theme/themeCubit.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:flutterquiz/utils/user_utils.dart';
import 'package:http/http.dart' as http;
import 'package:launch_review/launch_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/inAppPurchase/in_app_product.dart';
import '../../utils/constants/api_body_parameter_labels.dart';
import 'home/widgets/guest_mode_dialog.dart';

class MenuScreen extends StatefulWidget {
  final bool isGuest;

  const MenuScreen({super.key, required this.isGuest});

  @override
  State<MenuScreen> createState() => _MenuScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<DeleteAccountCubit>(
            create: (_) => DeleteAccountCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UploadProfileCubit>(
            create: (_) => UploadProfileCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: MenuScreen(isGuest: routeSettings.arguments as bool),
      ),
    );
  }
}

class _MenuScreenState extends State<MenuScreen> {
  final menuName = [
    "wallet",
    "coinHistory",
    "notificationLbl",
    "bookmarkLbl",
    "inviteFriendsLbl",
    "badges",
    "coinStore",
    "theme",
    "rewardsLbl",
    "statisticsLabel",
    "language",
    "aboutQuizApp",
    "howToPlayLbl",
    "shareAppLbl",
    "rateUsLbl",
    "logoutLbl",
    "deleteAccountLbl"
  ];

  final menuIcon = [
    "wallet_icon.svg",
    "coin_history_icon.svg",
    "notification_icon.svg",
    "bookmark.svg",
    "invite_friends.svg",
    "badges_icon.svg",
    "coin_icon.svg",
    "theme_icon.svg",
    "reword_icon.svg",
    "statistics_icon.svg",
    "language_icon.svg",
    "about_us_icon.svg",
    "how_to_play_icon.svg",
    "share_icon.svg",
    "rate_icon.svg",
    "logout_icon.svg",
    "delete_account.svg"
  ];

  late final List<SupportedLanguage> supportedLanguages;
  List<InAppProduct> iapProducts = [];

  @override
  void initState() {
    super.initState();
    final sysConfig = context.read<SystemConfigCubit>();
    supportedLanguages = sysConfig.getSupportedLanguages();

    if (!sysConfig.isCoinStoreEnabled) {
      menuName.removeWhere((e) => e == "coinStore");
      menuIcon.removeWhere((e) => e == "coin_icon.svg");
    }

    if (!sysConfig.isPaymentRequestEnabled) {
      menuName.removeWhere((e) => e == "wallet");
      menuIcon.removeWhere((e) => e == "wallet_icon.svg");
    }
    if (!sysConfig.isLanguageModeEnabled) {
      menuName.removeWhere((e) => e == "language");
      menuIcon.removeWhere((e) => e == "language_icon.svg");
    }

    if (widget.isGuest) {
      menuName.removeWhere((e) => e == "logoutLbl");
      menuIcon.removeWhere((e) => e == "logout_icon.svg");
      menuName.removeWhere((e) => e == "deleteAccountLbl");
      menuIcon.removeWhere((e) => e == "delete_account.svg");
    }

    scheduleMicrotask(() async => iapProducts = await fetchInAppProducts());
  }

  Future<List<InAppProduct>> fetchInAppProducts() async {
    try {
      final body = {accessValueKey: accessValue};
      final rawRes = await http.post(Uri.parse(getCoinStoreData), body: body);
      final res = jsonDecode(rawRes.body);

      if (res['error']) throw Exception(res['message'].toString());

      return List.from(
        res['data'].map<InAppProduct>((e) => InAppProduct.fromJson(e)),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return [];
  }

  String localizedValueOf(String key) =>
      AppLocalization.of(context)!.getTranslatedValues(key) ?? key;

  @override
  Widget build(BuildContext context) {
    final hzMargin = MediaQuery.of(context).size.width * UiUtils.hzMarginPct;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).primaryColor,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 30,
                      left: hzMargin,
                      right: hzMargin,
                    ),
                    height: MediaQuery.of(context).size.height * 0.24,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(10),
                      ),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: LayoutBuilder(
                      builder: (_, constraint) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: Navigator.of(context).pop,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                localizedValueOf("profileLbl"),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -80),
                    child: _buildGridviewList(),
                  ),
                ],
              ),
            ),
            BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
              listener: (context, state) {
                if (state is DeleteAccountSuccess) {
                  //Update state for globally cubits
                  context.read<BadgesCubit>().updateState(BadgesInitial());
                  context.read<BookmarkCubit>().updateState(BookmarkInitial());

                  //set local auth details to empty
                  AuthRepository().setLocalAuthDetails(
                      authStatus: false,
                      authType: "",
                      jwtToken: "",
                      firebaseId: "",
                      isNewUser: false);
                  //
                  UiUtils.setSnackbar(
                    localizedValueOf(accountDeletedSuccessfullyKey),
                    context,
                    false,
                  );
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(Routes.login);
                } else if (state is DeleteAccountFailure) {
                  UiUtils.setSnackbar(
                      localizedValueOf(
                        convertErrorCodeToLanguageKey(state.errorMessage),
                      ),
                      context,
                      false);
                }
              },
              bloc: context.read<DeleteAccountCubit>(),
              builder: (context, state) {
                if (state is DeleteAccountInProgress) {
                  return Container(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.275),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: AlertDialog(
                        shadowColor: Colors.transparent,
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressContainer(size: 45.0),
                            const SizedBox(width: 15.0),
                            Text(
                              localizedValueOf(deletingAccountKey),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleProfileEdit() {
    if (widget.isGuest) {
      showDialog(
        context: context,
        builder: (_) => GuestModeDialog(
          onTapYesButton: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(Routes.login);
          },
        ),
      );
    } else {
      Navigator.of(context).pushNamed(Routes.selectProfile, arguments: false);
    }
  }

  Widget _buildProfileCard(
    String profileUrl,
    String profileName,
    String profileDesc,
  ) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(6),
              width: size.width * .18,
              height: size.width * .18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
                ),
              ),
              child: UserUtils.getUserProfileWidget(
                pngBackgroundColor:
                    Theme.of(context).primaryColor.withOpacity(.2),
                profileUrl: profileUrl,
                width: double.maxFinite,
                height: double.maxFinite,
              ),
            ),
          ),
          SizedBox(width: size.width * 0.029),
          SizedBox(
            width: size.width * 0.63,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Profile Name
                    SizedBox(
                      width: size.width * 0.5,
                      child: Text(
                        profileName,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    /// Profile Description
                    SizedBox(
                      width: size.width * 0.5,
                      child: Text(
                        profileDesc,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                /// Edit Profile Button
                InkWell(
                  onTap: _handleProfileEdit,
                  child: Container(
                    height: size.width * .10,
                    width: size.width * .10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridviewList() {
    final hzMargin = MediaQuery.of(context).size.width * UiUtils.hzMarginPct;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hzMargin),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.isGuest
                    ? _buildProfileCard(
                        "",
                        localizedValueOf("helloGuest"),
                        localizedValueOf("provideGuestDetails"),
                      )

                    /// User Profile
                    : BlocBuilder<UserDetailsCubit, UserDetailsState>(
                        bloc: context.read<UserDetailsCubit>(),
                        builder: (context, state) {
                          if (state is UserDetailsFetchSuccess) {
                            final desc =
                                context.read<AuthCubit>().getAuthProvider() ==
                                        AuthProviders.mobile
                                    ? state.userProfile.mobileNumber!
                                    : state.userProfile.email!;
                            return _buildProfileCard(
                              state.userProfile.profileUrl!,
                              state.userProfile.name!,
                              desc,
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                const SizedBox(height: 20),

                ///
                GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    3,
                    (i) {
                      final name = localizedValueOf(menuName[i]);

                      return GestureDetector(
                        onTap: () => setState(() => _onPressed(menuName[i])),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Theme.of(context).colorScheme.background,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  UiUtils.getImagePath(menuIcon[i]),
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 85,
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeights.regular,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 4,
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    menuName.length - 3,
                    (index) {
                      /// skip first three
                      index += 3;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _onPressed(menuName[index])),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.background,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                UiUtils.getImagePath(menuIcon[index]),
                                color: Theme.of(context).primaryColor,
                                width: 25,
                                height: 25,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  localizedValueOf(menuName[index]),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                    fontWeight: FontWeights.regular,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onPressed(String index) {
    /// Menus that guest can click/use without being logged in.
    switch (index) {
      case "theme":
        _showThemeSelector();
        return;
      case "language":
        _showLanguageSelector();
        return;
      case "aboutQuizApp":
        Navigator.of(context).pushNamed(Routes.aboutApp);
        return;
      case "howToPlayLbl":
        Navigator.of(context)
            .pushNamed(Routes.appSettings, arguments: howToPlayLbl);
        return;
      case "shareAppLbl":
        {
          try {
            Share.share(
                "${context.read<SystemConfigCubit>().appUrl}\n${context.read<SystemConfigCubit>().shareAppText}");
          } catch (e) {
            UiUtils.setSnackbar(e.toString(), context, false);
          }
        }
        return;
      case "rateUsLbl":
        LaunchReview.launch(androidAppId: packageName, iOSAppId: iosAppId);
        return;
      case "coinStore":
        Navigator.of(context).pushNamed(Routes.coinStore, arguments: {
          "isGuest": widget.isGuest,
          "iapProducts": iapProducts,
        });
        return;
    }

    /// Menus that users can't use without signing in, (ex. in guest mode).
    if (widget.isGuest) {
      showDialog(
        context: context,
        builder: (_) => GuestModeDialog(onTapYesButton: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(Routes.login);
        }),
      );
      return;
    }

    /// Menus for logged in users only.
    switch (index) {
      case "notificationLbl":
        Navigator.of(context).pushNamed(Routes.notification);
        return;
      case "coinHistory":
        Navigator.of(context).pushNamed(Routes.coinHistory);
        return;
      case "wallet":
        Navigator.of(context).pushNamed(Routes.wallet);
        return;
      case "bookmarkLbl":
        Navigator.of(context).pushNamed(Routes.bookmark);
        return;
      case "inviteFriendsLbl":
        Navigator.of(context).pushNamed(Routes.referAndEarn);
        return;
      case "badges":
        Navigator.of(context).pushNamed(Routes.badges);
        return;
      case "rewardsLbl":
        Navigator.of(context).pushNamed(Routes.rewards);
        return;
      case "statisticsLabel":
        Navigator.of(context).pushNamed(Routes.statistics);
        return;
      case "logoutLbl":
        _showLogoutDialog();
        return;
      case "deleteAccountLbl":
        _showDeleteAccountDialog();
        return;
    }
  }

  void _showThemeSelector() {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: UiUtils.bottomSheetTopRadius,
          ),
          height: size.height * 0.5,
          padding: EdgeInsets.only(
            top: size.height * .02,
          ),
          child: BlocBuilder<ThemeCubit, ThemeState>(
            bloc: context.read<ThemeCubit>(),
            builder: (context, state) {
              AppTheme? currTheme = state.appTheme;
              final colorScheme = Theme.of(context).colorScheme;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      localizedValueOf("theme"),
                      style: TextStyle(
                        fontWeight: FontWeights.bold,
                        fontSize: 18,
                        color: colorScheme.onTertiary,
                      ),
                    ),
                  ),
                  // horizontal divider
                  Divider(
                    color: colorScheme.onTertiary.withOpacity(0.2),
                    thickness: 1,
                  ),
                  SizedBox(height: size.height * 0.02),
                  Container(
                    decoration: BoxDecoration(
                      color: currTheme == AppTheme.light
                          ? Theme.of(context).primaryColor
                          : colorScheme.onTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: size.width * UiUtils.hzMarginPct,
                    ),
                    child: RadioListTile<AppTheme>(
                      toggleable: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      tileColor: colorScheme.onTertiary.withOpacity(0.2),
                      value: AppTheme.light,
                      groupValue: currTheme,
                      activeColor: Colors.white,
                      title: Text(
                        localizedValueOf("lightTheme"),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: currTheme == AppTheme.light
                              ? Colors.white
                              : colorScheme.onTertiary,
                        ),
                      ),
                      secondary: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: currTheme == AppTheme.light
                                ? Colors.white
                                : colorScheme.onTertiary.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: SvgPicture.asset(
                          UiUtils.getImagePath("day.svg"),
                          width: 76,
                          height: 28,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (v) {
                        setState(() {
                          currTheme = v;
                          context.read<ThemeCubit>().changeTheme(currTheme!);
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: currTheme == AppTheme.dark
                          ? Theme.of(context).primaryColor
                          : colorScheme.onTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: size.width * UiUtils.hzMarginPct,
                    ),
                    child: RadioListTile<AppTheme>(
                      toggleable: true,
                      value: AppTheme.dark,
                      groupValue: currTheme,
                      activeColor: Colors.white,
                      title: Text(
                        localizedValueOf("darkTheme"),
                        style: TextStyle(
                          fontWeight: FontWeights.medium,
                          fontSize: 18,
                          color: currTheme == AppTheme.dark
                              ? Colors.white
                              : colorScheme.onTertiary,
                        ),
                      ),
                      secondary: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: currTheme == AppTheme.dark
                                ? Colors.white
                                : colorScheme.onTertiary.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: SvgPicture.asset(
                          UiUtils.getImagePath("night.svg"),
                          width: 76,
                          height: 28,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (v) {
                        setState(() {
                          currTheme = v;
                          context.read<ThemeCubit>().changeTheme(currTheme!);
                        });
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: UiUtils.bottomSheetTopRadius,
          ),
          height: MediaQuery.of(context).size.height * .6,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * .02,
          ),
          child: BlocConsumer<AppLocalizationCubit, AppLocalizationState>(
            bloc: context.read<AppLocalizationCubit>(),
            listener: (context, state) {
              context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                    type: UiUtils.getCategoryTypeNumberFromQuizType(
                        QuizTypes.quizZone),
                    userId: context.read<UserDetailsCubit>().userId(),
                  );
              context.read<QuizoneCategoryCubit>().getQuizCategoryWithUserId(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                    userId: context.read<UserDetailsCubit>().userId(),
                  );
              Navigator.of(context).pop();
            },
            builder: (context, state) {
              final textStyle = TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onTertiary,
              );

              var currLang = state.language;

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    /// Title
                    Text(
                      localizedValueOf("language"),
                      style: textStyle,
                    ),
                    const Divider(),

                    /// Supported Languages
                    ...supportedLanguages.map(
                      (language) {
                        final locale = UiUtils.getLocaleFromLanguageCode(
                            language.languageCode);
                        return Container(
                          decoration: BoxDecoration(
                            color: currLang == locale
                                ? Theme.of(context).primaryColor
                                : Theme.of(context)
                                    .colorScheme
                                    .onTertiary
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height * 0.01,
                            horizontal: MediaQuery.of(context).size.width *
                                UiUtils.hzMarginPct,
                          ),
                          child: RadioListTile(
                            toggleable: true,
                            activeColor: Colors.white,
                            value: locale,
                            title: Text(
                              language.language,
                              style: textStyle.copyWith(
                                color: currLang == locale
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onTertiary,
                              ),
                            ),
                            groupValue: currLang,
                            onChanged: (value) {
                              currLang = value!;

                              if (state.language != locale) {
                                context
                                    .read<AppLocalizationCubit>()
                                    .changeLanguage(language.languageCode);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shadowColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(UiUtils.getImagePath("logout_acc.svg")),
              const SizedBox(height: 32),
              Text(
                localizedValueOf(logoutLbl),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 19),
              Text(
                localizedValueOf(logoutDialogLbl),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 33),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();

                  context.read<BadgesCubit>().updateState(BadgesInitial());

                  context.read<BookmarkCubit>().updateState(BookmarkInitial());

                  context
                      .read<GuessTheWordBookmarkCubit>()
                      .updateState(GuessTheWordBookmarkInitial());

                  context
                      .read<AudioQuestionBookmarkCubit>()
                      .updateState(AudioQuestionBookmarkInitial());

                  context.read<AuthCubit>().signOut();
                  Navigator.of(context).pushReplacementNamed(Routes.login);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Theme.of(context).primaryColor),
                ),
                child: Text(
                  localizedValueOf("yesLogoutLbl"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
              ),
              const SizedBox(height: 19),
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(
                  localizedValueOf("stayLoggedLbl"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shadowColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SvgPicture.asset(UiUtils.getImagePath("delete_acc.svg")),
              const SizedBox(height: 32),
              Text(
                localizedValueOf("deleteAccountLbl"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 19),
              Text(
                localizedValueOf("deleteAccConfirmation"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const SizedBox(height: 33),
              TextButton(
                onPressed: () {
                  context.read<DeleteAccountCubit>().deleteUserAccount(
                        userId: context.read<UserDetailsCubit>().userId(),
                      );
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStatePropertyAll(Theme.of(context).primaryColor),
                ),
                child: Text(
                  localizedValueOf("yesDeleteAcc"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
              ),
              const SizedBox(height: 19),
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: Text(
                  localizedValueOf("keepAccount"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
