class SystemConfigModel {
  // TODO: audio timer for ques [audioTimer], after timer ends show options, if user hasn't opened them.
  late bool adsEnabled;
  late int adsType;
  late String androidBannerId;
  late String androidGameID;
  late String androidInterstitialId;
  late String androidRewardedId;
  late bool answerMode;
  late String appLink;
  late bool appMaintenance;
  late String appVersion;
  late String appVersionIos;
  late bool audioQuestionMode;
  late int audioTimer;
  late bool battleGroupCategoryMode;
  late bool battleModeGroup;
  late bool battleModeOne;
  late bool battleRandomCategoryMode;
  late int coinAmount;
  late int coinLimit;
  late bool contestMode;
  late String currencySymbol;
  late bool dailyQuizMode;
  late String earnCoin;
  late bool examMode;
  late String falseValue;
  late String fixQuestion;
  late bool forceUpdate;
  late int funAndLearnTimer;
  late bool funNLearnMode;
  late int guessTheWordMaxWinningCoins;
  late bool guessTheWordMode;
  late int guessTheWordTimer;
  late bool inAppPurchaseMode;
  late String iosAppLink;
  late String iosBannerId;
  late String iosGameID;
  late String iosInterstitialId;
  late String iosMoreApps;
  late String iosRewardedId;
  late bool languageMode;
  late int lifelineDeductCoins;
  late bool mathQuizMode;
  late int mathsQuizTimer;
  late int maxWinningCoins;
  late double maxWinningPercentage;
  late String moreApps;
  late String optionEMode;
  late String paymentMessage;
  late bool paymentMode;
  late int perCoin;
  late int playScore;
  late int quizTimer;
  late int randomBattleEntryCoins;
  late int randomBattleSeconds;
  late String referCoin;
  late int reviewAnswersDeductCoins;
  late String rewardCoin;
  late bool selfChallengeMode;
  late int selfChallengeTimer;
  late String shareAppText;
  late String showAnswerCorrectness;
  late String systemTimezone;
  late String systemTimezoneGmt;
  late String totalQuestion;
  late String trueValue;
  late bool truefalseMode;
  late String welcomeBonusCoins;
  late final String botImage;
  late final bool isDailyAdsEnabled;
  late final String coinsPerDailyAdView;
  late final int totalDailyAds;
  late final bool quizZoneMode;

  SystemConfigModel({
    required this.adsEnabled,
    required this.adsType,
    required this.androidBannerId,
    required this.androidGameID,
    required this.androidInterstitialId,
    required this.androidRewardedId,
    required this.answerMode,
    required this.appLink,
    required this.appMaintenance,
    required this.appVersion,
    required this.appVersionIos,
    required this.audioQuestionMode,
    required this.audioTimer,
    required this.battleGroupCategoryMode,
    required this.battleModeGroup,
    required this.battleModeOne,
    required this.battleRandomCategoryMode,
    required this.coinAmount,
    required this.coinLimit,
    required this.contestMode,
    required this.currencySymbol,
    required this.dailyQuizMode,
    required this.earnCoin,
    required this.examMode,
    required this.falseValue,
    required this.fixQuestion,
    required this.forceUpdate,
    required this.funAndLearnTimer,
    required this.funNLearnMode,
    required this.guessTheWordMaxWinningCoins,
    required this.guessTheWordMode,
    required this.guessTheWordTimer,
    required this.inAppPurchaseMode,
    required this.iosAppLink,
    required this.iosBannerId,
    required this.iosGameID,
    required this.iosInterstitialId,
    required this.iosMoreApps,
    required this.iosRewardedId,
    required this.languageMode,
    required this.lifelineDeductCoins,
    required this.mathQuizMode,
    required this.mathsQuizTimer,
    required this.maxWinningCoins,
    required this.maxWinningPercentage,
    required this.moreApps,
    required this.optionEMode,
    required this.paymentMessage,
    required this.paymentMode,
    required this.perCoin,
    required this.playScore,
    required this.quizTimer,
    required this.randomBattleEntryCoins,
    required this.randomBattleSeconds,
    required this.referCoin,
    required this.reviewAnswersDeductCoins,
    required this.rewardCoin,
    required this.selfChallengeMode,
    required this.selfChallengeTimer,
    required this.shareAppText,
    required this.showAnswerCorrectness,
    required this.systemTimezone,
    required this.systemTimezoneGmt,
    required this.totalQuestion,
    required this.trueValue,
    required this.truefalseMode,
    required this.welcomeBonusCoins,
    required this.botImage,
    required this.quizZoneMode,
  });

  SystemConfigModel.fromJson(Map<String, dynamic> json) {
    // Note: Assume you always get the value, so if there is issue you know where it is.
    // Move Default Values when no data is found to systemConfigCubit.
    adsEnabled = json['in_app_ads_mode'] == "1";
    adsType = int.parse(json['ads_type'] ?? "0");
    androidBannerId = json['android_banner_id'] ?? "";
    androidGameID = json['android_game_id'] ?? "";
    androidInterstitialId = json['android_interstitial_id'] ?? "";
    androidRewardedId = json['android_rewarded_id'] ?? "";
    answerMode = json['answer_mode'] == "1";
    appLink = json['app_link'] ?? "";
    appMaintenance = json['app_maintenance'] == "1";
    appVersion = json['app_version'] ?? "";
    appVersionIos = json['app_version_ios'] ?? "";
    audioQuestionMode = json['audio_mode_question'] == "1";
    audioTimer = int.parse(json['audio_seconds'] ?? "0");
    battleGroupCategoryMode =
        (json['battle_group_category_mode'] ?? "0") == "1";
    battleModeGroup = json['battle_mode_group'] == "1";
    battleModeOne = (json['battle_mode_one'] ?? "0") == "1";
    battleRandomCategoryMode =
        (json['battle_random_category_mode'] ?? "0") == "1";
    coinAmount = int.parse(json['coin_amount'] ?? "0");
    coinLimit = int.parse(json['coin_limit'] ?? "0");
    contestMode = (json['contest_mode'] ?? "0") == "1";
    currencySymbol = json['currency_symbol'] ?? '\$';
    dailyQuizMode = (json['daily_quiz_mode'] ?? "0") == "1";
    earnCoin = json['earn_coin'] ?? "";
    examMode = (json['exam_module'] ?? "0") == "1";
    falseValue = json['false_value'] ?? "";
    fixQuestion = json['fix_question'] ?? "";
    forceUpdate = json['force_update'] == "1";
    funAndLearnTimer = int.parse(json['fun_and_learn_time_in_seconds'] ?? "0");
    funNLearnMode = (json['fun_n_learn_question'] ?? "0") == "1";
    guessTheWordMaxWinningCoins =
        int.parse(json['guess_the_word_max_winning_coin'] ?? "0");
    guessTheWordMode = (json['guess_the_word_question'] ?? "0") == "1";
    guessTheWordTimer = int.parse(json['guess_the_word_seconds'] ?? "0");
    inAppPurchaseMode = json['in_app_purchase_mode'] == "1";
    iosAppLink = json['ios_app_link'] ?? "";
    iosBannerId = json['ios_banner_id'] ?? "";
    iosGameID = json['ios_game_id'] ?? "";
    iosInterstitialId = json['ios_interstitial_id'] ?? "";
    iosMoreApps = json['ios_more_apps'] ?? "";
    iosRewardedId = json['ios_rewarded_id'] ?? "";
    languageMode = (json['language_mode'] ?? "0") == "1";
    lifelineDeductCoins = int.parse(json['lifeline_deduct_coin'] ?? "0");
    mathQuizMode = json['maths_quiz_mode'] == "1";
    mathsQuizTimer = int.parse(json['maths_quiz_seconds'] ?? "0");
    maxWinningCoins = int.parse(json['maximum_winning_coins'] ?? "0");
    maxWinningPercentage =
        double.parse(json['maximum_coins_winning_percentage'] ?? "0");
    moreApps = json['more_apps'] ?? "";
    optionEMode = json['option_e_mode'] ?? "";
    paymentMessage = json['payment_message'] ?? "";
    paymentMode = json['payment_mode'] == "1";
    perCoin = int.parse(json['per_coin'] ?? "0");
    playScore = int.parse(json['score'] ?? "0");
    quizTimer = int.parse(json['quiz_zone_duration'] ?? "0");
    randomBattleEntryCoins = int.parse(json['random_battle_entry_coin'] ?? "0");
    randomBattleSeconds = int.parse(json['random_battle_seconds'] ?? "0");
    referCoin = json['refer_coin'] ?? "";
    reviewAnswersDeductCoins =
        int.parse(json['review_answers_deduct_coin'] ?? "0");
    rewardCoin = json['reward_coin'] ?? "";
    selfChallengeMode = json['self_challenge_mode'] == "1";
    selfChallengeTimer = int.parse(json['self_challange_max_minutes'] ?? "0");
    shareAppText = json['shareapp_text'] ?? "";
    showAnswerCorrectness = json['answer_mode'] ?? "1";
    systemTimezone = json['system_timezone'] ?? "";
    systemTimezoneGmt = json['system_timezone_gmt'] ?? "";
    totalQuestion = json['total_question'] ?? "";
    trueValue = json['true_value'] ?? "";
    truefalseMode = (json['true_false_mode'] ?? "0") == "1";
    welcomeBonusCoins = json['welcome_bonus_coin'] ?? "";
    botImage = json['bot_image'] ?? "";
    coinsPerDailyAdView = json["daily_ads_coins"] ?? "0";
    isDailyAdsEnabled = (json["daily_ads_visibility"] ?? "0") == "1";
    totalDailyAds = int.parse(json["daily_ads_counter"] ?? "0");
    quizZoneMode = (json["quiz_zone_mode"] ?? "0") == "1";
  }
}
