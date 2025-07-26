import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

abstract class RewardedAdState {}

class RewardedAdInitial extends RewardedAdState {}

class RewardedAdLoaded extends RewardedAdState {}

class RewardedAdLoadInProgress extends RewardedAdState {}

class RewardedAdFailure extends RewardedAdState {}

class RewardedAdCubit extends Cubit<RewardedAdState> {
  RewardedAdCubit() : super(RewardedAdInitial());

  RewardedAd? _rewardedAd;

  RewardedAd? get rewardedAd => _rewardedAd;

  void _createGoogleRewardedAd(BuildContext context) {
    //dispose ad and then load
    _rewardedAd?.dispose();
    RewardedAd.load(
      adUnitId: context.read<SystemConfigCubit>().googleRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdFailedToLoad: (error) {
        print("Rewarded ad failed to load");
        emit(RewardedAdFailure());
      }, onAdLoaded: (ad) {
        _rewardedAd = ad;
        print("Rewarded ad loaded successfully");
        emit(RewardedAdLoaded());
      }),
    );
  }

  void createUnityRewardsAd() {
    UnityAds.load(
      placementId: unityRewardsPlacement(),
      onComplete: (placementId) => emit(RewardedAdLoaded()),
      onFailed: (p, e, m) => emit(RewardedAdFailure()),
    );
  }

  void createRewardedAd(
    BuildContext context, {
    required Function onFbRewardAdCompleted,
  }) {
    emit(RewardedAdLoadInProgress());

    var sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (sysConfigCubit.adsType == 1) {
        _createGoogleRewardedAd(context);
      } else {
        createUnityRewardsAd();
      }
    }
  }

  Future<void> createDailyRewardAd(BuildContext context) async {
    emit(RewardedAdLoadInProgress());

    final sysConfig = context.read<SystemConfigCubit>();
    if (sysConfig.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (sysConfig.adsType == 1) {
        _createGoogleRewardedAd(context);
      } else {
        createUnityRewardsAd();
      }
    }
  }

  Future<void> showDailyAd({required BuildContext context}) async {
    final sysConfigCubit = context.read<SystemConfigCubit>();
    final userDetails = context.read<UserDetailsCubit>();

    print("Ads State : $state");
    if (sysConfigCubit.isAdsEnable && state is RewardedAdLoaded) {
      ///
      if (sysConfigCubit.adsType == 1) {
        _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) async {
            ad.dispose();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            emit(RewardedAdFailure());
          },
        );
        rewardedAd?.show(onUserEarnedReward: (_, __) {
          log("Watched Daily Ad", name: "Admob Ads");
          userDetails.watchedDailyAd().then((_) async {
            await context.read<UserDetailsCubit>().isDailyAdsAvailable();
            context.read<UserDetailsCubit>().fetchUserDetails();

            if (!context.mounted) return;

            UiUtils.setSnackbar(
              "${AppLocalization.of(context)!.getTranslatedValues("earnedLbl")!} "
              "${sysConfigCubit.coinsPerDailyAdView} "
              "${AppLocalization.of(context)!.getTranslatedValues("coinsLbl")!}",
              context,
              false,
              duration: const Duration(seconds: 2),
            );

            createDailyRewardAd(context);
          }).catchError((e) {
            if (e.toString() == errorCodeDailyAdsLimitSucceeded) {
              UiUtils.setSnackbar(
                AppLocalization.of(context)!
                    .getTranslatedValues("dailyAdsLimitExceeded")!,
                context,
                false,
              );
            }
          });
        });
      } else {
        UnityAds.showVideoAd(
          placementId: unityRewardsPlacement(),
          onComplete: (_) async {
            userDetails.watchedDailyAd().then((_) async {
              await context.read<UserDetailsCubit>().isDailyAdsAvailable();
              context.read<UserDetailsCubit>().fetchUserDetails();

              if (!context.mounted) return;

              UiUtils.setSnackbar(
                "${AppLocalization.of(context)!.getTranslatedValues("earnedLbl")!} "
                "${sysConfigCubit.coinsPerDailyAdView} "
                "${AppLocalization.of(context)!.getTranslatedValues("coinsLbl")!}",
                context,
                false,
                duration: const Duration(seconds: 2),
              );
            }).catchError((e) {
              if (e.toString() == errorCodeDailyAdsLimitSucceeded) {
                UiUtils.setSnackbar(
                  AppLocalization.of(context)!
                      .getTranslatedValues("dailyAdsLimitExceeded")!,
                  context,
                  false,
                );
              }
            });
            log("Watched Daily Ad", name: "Admob Ads");

            return createDailyRewardAd(context);
          },
        );
      }
    } else if (state is RewardedAdFailure) {
      createDailyRewardAd(context);
    }
  }

  void showAd({
    required Function onAdDismissedCallback,
    required BuildContext context,
  }) {
    //if ads is enable
    var sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      if (state is RewardedAdLoaded) {
        //if google ad is enable
        if (sysConfigCubit.adsType == 1) {
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onAdDismissedCallback();
              createRewardedAd(context, onFbRewardAdCompleted: () {});
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              //need to show this reason to user
              emit(RewardedAdFailure());
              createRewardedAd(context, onFbRewardAdCompleted: () {});
            },
          );
          rewardedAd?.show(onUserEarnedReward: (_, __) => {});
        } else {
          UnityAds.showVideoAd(
            placementId: unityRewardsPlacement(),
            onComplete: (placementId) {
              onAdDismissedCallback();
              createRewardedAd(context, onFbRewardAdCompleted: () {});
            },
            onFailed: (placementId, error, message) =>
                print('Video Ad $placementId failed: $error $message'),
            onStart: (placementId) => print('Video Ad $placementId started'),
            onClick: (placementId) => print('Video Ad $placementId click'),
          );
        }
      } else if (state is RewardedAdFailure) {
        //create reward ad if ad is not loaded successfully
        createRewardedAd(context, onFbRewardAdCompleted: onAdDismissedCallback);
      }
    }
  }

  String unityRewardsPlacement() {
    if (Platform.isAndroid) {
      return "Rewarded_Android";
    }
    if (Platform.isIOS) {
      return "Rewarded_iOS";
    }

    return "";
  }

  @override
  Future<void> close() async {
    _rewardedAd?.dispose();
    return super.close();
  }
}
