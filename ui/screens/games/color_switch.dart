import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import '../../../features/ads/interstitial_ad_cubit.dart';
import '../../../features/ads/rewarded_ad_cubit.dart';
import '../../../features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import '../../../features/profileManagement/cubits/userDetailsCubit.dart';

class ColorSwitch extends StatefulWidget {
  State<ColorSwitch> createState() => _ColorSwitchState();
}

class _ColorSwitchState extends State<ColorSwitch> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  UnityWidgetController? _unityWidgetController;

  void initState() {
    super.initState();
  }

  void _addCoinsAfterRewardAd() {}

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: _scaffoldKey,
      body: UnityWidget(
        onUnityCreated: onUnityCreated,
        onUnityMessage: onUnityMessage,
        fullscreen: false,
      ),
    );
  }
  // Communication from Unity to Flutter
  void onUnityMessage(message) {
    if (message == "EXIT") {
      Navigator.pop(context);
      if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
        context.read<InterstitialAdCubit>().showAd(context,onAdDismissedCallback: () {
          _unityWidgetController!.postMessage("Music", "unMute", "");
          context.read<UpdateScoreAndCoinsCubit>().updateCoins(
            context.read<UserDetailsCubit>().userId(),
            1,
            true,
            "Color Switch",
          );
        });
      } else {
        context.read<RewardedAdCubit>().showAd(
              context: context,
              onAdDismissedCallback: _addCoinsAfterRewardAd,
            );
      }
    }else if(message == "isRewardAdReady")
    {
      if(context.read<RewardedAdCubit>().state is! RewardedAdLoaded)
      {
        _unityWidgetController!.postMessage("ShowAd", "lockTheButton", "");
      }
    } else if (message.length >= 9 && message.substring(0, 9) == "addCoins:") {
      _unityWidgetController!.postMessage("Music", "Mute", "");
      if (message.length == 10) {
        context.read<UserDetailsCubit>().updateScore(int.parse(message.substring(9, 10)));
        context.read<UpdateScoreAndCoinsCubit>().updateScore(
          context.read<UserDetailsCubit>().userId(),
          int.parse(message.substring(9, 10)),
        );
          context.read<InterstitialAdCubit>().showAd(context,onAdDismissedCallback: () {
            _unityWidgetController!.postMessage("Music", "unMute", "");
            context.read<UpdateScoreAndCoinsCubit>().updateCoins(
              context.read<UserDetailsCubit>().userId(),
              1,
              true,
              "Color Switch",
            );
          });
      }
      else if(message.length == 11)
        {
          context.read<UpdateScoreAndCoinsCubit>().updateScore(
            context.read<UserDetailsCubit>().userId(),
            int.parse(message.substring(9, 11)),
          );
          context.read<InterstitialAdCubit>().showAd(context,onAdDismissedCallback: () {
            _unityWidgetController!.postMessage("Music", "unMute", "");
            context.read<UpdateScoreAndCoinsCubit>().updateCoins(
              context.read<UserDetailsCubit>().userId(),
              1,
              true,
              "Color Switch",
            );
          });
        }
    }else if (message.length >= 12 && message.substring(0, 12) == "ShowRewardAd")
      {
        _unityWidgetController!.postMessage("Music", "Mute", "");
        if (message.length == 13) {
          context.read<UserDetailsCubit>().updateScore(int.parse(message.substring(12, 13)));
          context.read<UpdateScoreAndCoinsCubit>().updateScore(
            context.read<UserDetailsCubit>().userId(),
            int.parse(message.substring(12, 13)),
          );
          context.read<RewardedAdCubit>().showAd(
            context: context,
            onAdDismissedCallback: () {
              _unityWidgetController!.postMessage("Music", "unMute", "");
              context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                context.read<UserDetailsCubit>().userId(),
                2,
                true,
                "Color Switch",
              );
            },
          );
        }
        if (message.length == 14) {
          context.read<UserDetailsCubit>().updateScore(int.parse(message.substring(12, 14)));
          context.read<UpdateScoreAndCoinsCubit>().updateScore(
            context.read<UserDetailsCubit>().userId(),
            int.parse(message.substring(12, 14)),
          );
          context.read<RewardedAdCubit>().showAd(
            context: context,
            onAdDismissedCallback: () {
              _unityWidgetController!.postMessage("Music", "unMute", "");
              context.read<UpdateScoreAndCoinsCubit>().updateCoins(
                context.read<UserDetailsCubit>().userId(),
                2,
                true,
                "Color Switch",
              );
            },
          );
        }
      }
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(controller) {
    this._unityWidgetController = controller;
  }

  // Communication from Unity when new scene is loaded to Flutter
  void onUnitySceneLoaded(SceneLoaded sceneInfo) {
    print('Received scene loaded from unity: ${sceneInfo.name}');
    print(
        'Received scene loaded from unity buildIndex: ${sceneInfo.buildIndex}');
  }
}
