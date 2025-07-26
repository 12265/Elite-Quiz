//State
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/systemConfig/model/supportedQuestionLanguage.dart';
import 'package:flutterquiz/features/systemConfig/model/systemConfigModel.dart';
import 'package:flutterquiz/features/systemConfig/system_config_repository.dart';

abstract class SystemConfigState {}

class SystemConfigInitial extends SystemConfigState {}

class SystemConfigFetchInProgress extends SystemConfigState {}

class SystemConfigFetchSuccess extends SystemConfigState {
  final SystemConfigModel systemConfigModel;
  final List<SupportedLanguage> supportedLanguages;
  final List<String> emojis;

  final List<String> defaultProfileImages;

  SystemConfigFetchSuccess({
    required this.systemConfigModel,
    required this.defaultProfileImages,
    required this.supportedLanguages,
    required this.emojis,
  });
}

class SystemConfigFetchFailure extends SystemConfigState {
  final String errorCode;

  SystemConfigFetchFailure(this.errorCode);
}

class SystemConfigCubit extends Cubit<SystemConfigState> {
  final SystemConfigRepository _systemConfigRepository;

  SystemConfigCubit(this._systemConfigRepository)
      : super(SystemConfigInitial());

  void getSystemConfig() async {
    emit(SystemConfigFetchInProgress());
    try {
      List<SupportedLanguage> supportedLanguages = [];
      final systemConfig = await _systemConfigRepository.getSystemConfig();
      final defaultProfileImages = await _systemConfigRepository
          .getImagesFromFile("assets/files/defaultProfileImages.json");

      final emojis = await _systemConfigRepository
          .getImagesFromFile("assets/files/emojis.json");

      if (systemConfig.languageMode) {
        supportedLanguages =
            await _systemConfigRepository.getSupportedQuestionLanguages();
      }
      emit(SystemConfigFetchSuccess(
        systemConfigModel: systemConfig,
        defaultProfileImages: defaultProfileImages,
        supportedLanguages: supportedLanguages,
        emojis: emojis,
      ));
    } catch (e) {
      emit(SystemConfigFetchFailure(e.toString()));
    }
  }

  List<SupportedLanguage> getSupportedLanguages() =>
      state is SystemConfigFetchSuccess
          ? (state as SystemConfigFetchSuccess).supportedLanguages
          : [];

  List<String> getEmojis() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).emojis
      : [];

  SystemConfigModel? get systemConfigModel => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel
      : null;

  String get shareAppText => systemConfigModel?.shareAppText ?? "";

  bool get isLanguageModeEnabled => systemConfigModel?.languageMode ?? false;

  bool get isCategoryEnabledForBattle =>
      systemConfigModel?.battleRandomCategoryMode ?? false;

  bool get isCategoryEnabledForGroupBattle =>
      systemConfigModel?.battleGroupCategoryMode ?? false;

  bool get showAnswerCorrectness => systemConfigModel?.answerMode ?? true;

  bool get isDailyQuizEnabled => systemConfigModel?.dailyQuizMode ?? false;

  bool get isTrueFalseQuizEnabled => systemConfigModel?.truefalseMode ?? false;

  bool get isContestEnabled => systemConfigModel?.contestMode ?? false;

  bool get isFunNLearnEnabled => systemConfigModel?.funNLearnMode ?? false;

  bool get isOneVsOneBattleEnabled => systemConfigModel?.battleModeOne ?? false;

  bool get isGroupBattleEnabled => systemConfigModel?.battleModeGroup ?? false;

  bool get isExamQuizEnabled => systemConfigModel?.examMode ?? false;

  bool get isGuessTheWordEnabled =>
      systemConfigModel?.guessTheWordMode ?? false;

  bool get isAudioQuizEnabled => systemConfigModel?.audioQuestionMode ?? false;

  bool get isQuizZoneEnabled => systemConfigModel?.quizZoneMode ?? false;

  String get appVersion => Platform.isIOS
      ? systemConfigModel?.appVersionIos ?? "1.0.0+1"
      : systemConfigModel?.appVersion ?? "1.0.0+1";

  String get appUrl => Platform.isIOS
      ? systemConfigModel?.iosAppLink ?? ""
      : systemConfigModel?.appLink ?? "";

  String get googleBannerId => Platform.isIOS
      ? systemConfigModel?.iosBannerId ?? ""
      : systemConfigModel?.androidBannerId ?? "";

  String get googleInterstitialAdId => Platform.isIOS
      ? systemConfigModel?.iosInterstitialId ?? ""
      : systemConfigModel?.androidInterstitialId ?? "";

  String get googleRewardedAdId => Platform.isIOS
      ? systemConfigModel?.iosRewardedId ?? ""
      : systemConfigModel?.androidRewardedId ?? "";

  bool get isForceUpdateEnable => systemConfigModel?.forceUpdate ?? false;

  bool get isAppUnderMaintenance => systemConfigModel?.appMaintenance ?? false;

  String get referrerEarnCoin => systemConfigModel?.earnCoin ?? "0";

  String get refereeEarnCoin => systemConfigModel?.referCoin ?? "0";

  bool get isAdsEnable => systemConfigModel?.adsEnabled ?? false;

  bool get isDailyAdsEnabled => systemConfigModel?.isDailyAdsEnabled ?? false;

  String get coinsPerDailyAdView =>
      systemConfigModel?.coinsPerDailyAdView ?? "0";

  bool get isPaymentRequestEnabled => systemConfigModel?.paymentMode ?? false;

  bool get isSelfChallengeQuizEnabled =>
      systemConfigModel?.selfChallengeMode ?? false;

  bool get isCoinStoreEnabled => systemConfigModel?.inAppPurchaseMode ?? false;

  bool get isMathQuizEnabled => systemConfigModel?.mathQuizMode ?? false;

  int get perCoin => systemConfigModel?.perCoin ?? 0;

  int get coinAmount => systemConfigModel?.coinAmount ?? 0;

  int get minimumCoinLimit => systemConfigModel?.coinLimit ?? 0;

  int get adsType => systemConfigModel?.adsType ?? 0;

  String get unityGameId => Platform.isIOS
      ? systemConfigModel?.iosGameID ?? ""
      : systemConfigModel?.androidGameID ?? "";

  int get playScore => systemConfigModel?.playScore ?? 0;

  int get quizZoneQuizTimer => systemConfigModel?.quizTimer ?? 0;

  int get randomBattleQuizTimer => systemConfigModel?.randomBattleSeconds ?? 0;

  int get selfChallengeQuizTimer => systemConfigModel?.selfChallengeTimer ?? 0;

  int get guessTheWordQuizTimer => systemConfigModel?.guessTheWordTimer ?? 0;

  int get mathsQuizTimer => systemConfigModel?.mathsQuizTimer ?? 0;

  int get funNLearnQuizTimer => systemConfigModel?.funAndLearnTimer ?? 0;

  int get audioQuizTimer => systemConfigModel?.audioTimer ?? 0;

  double get maxCoinsWinningPercentage =>
      systemConfigModel?.maxWinningPercentage ?? 0;

  int get maxWinningCoins => systemConfigModel?.maxWinningCoins ?? 0;

  int get guessTheWordMaxWinningCoins =>
      systemConfigModel?.guessTheWordMaxWinningCoins ?? 0;

  int get randomBattleEntryCoins =>
      systemConfigModel?.randomBattleEntryCoins ?? 0;

  int get reviewAnswersDeductCoins =>
      systemConfigModel?.reviewAnswersDeductCoins ?? 0;

  int get lifelinesDeductCoins => systemConfigModel?.lifelineDeductCoins ?? 0;

  List<String> get defaultAvatarImages => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).defaultProfileImages
      : [];

  String get botImage => systemConfigModel?.botImage ?? "";

  String get payoutRequestCurrency => systemConfigModel?.currencySymbol ?? "";
}
