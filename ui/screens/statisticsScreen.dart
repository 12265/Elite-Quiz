import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/statistic/cubits/statisticsCubit.dart';
import 'package:flutterquiz/features/statistic/statisticRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/badgesIconContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();

  static Route<StatisticsScreen> route() => CupertinoPageRoute(
        builder: (_) => BlocProvider<StatisticCubit>(
          create: (_) => StatisticCubit(StatisticRepository()),
          child: const StatisticsScreen(),
        ),
      );
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _detailsCardHeightPercentage = 0.145;
  static const _detailsCardBorderRadius = 20.0;
  static const _showTotalBadgesCounter = 4;

  get _detailsTitleTextStyle => TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onTertiary,
        fontSize: 18.0,
      );

  static const _correctAnsColor = Color(0xFF62A9CD);
  static const _incorrectAnsColor = Color(0xFF8C4593);
  static const _wonColor = Color(0xFF90C88A);
  static const _lostColor = Color(0xFFF79478);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context
          .read<StatisticCubit>()
          .getStatisticWithBattle(context.read<UserDetailsCubit>().userId());
    });

    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });
  }

  Widget _buildCollectedBadgesContainer() {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<BadgesCubit, BadgesState>(
      bloc: context.read<BadgesCubit>(),
      builder: (context, state) {
        final unlockedBadges = context.read<BadgesCubit>().getUnlockedBadges();

        if (state is! BadgesFetchSuccess || unlockedBadges.isEmpty) {
          return const SizedBox.shrink();
        }

        void onTapViewAll() => Navigator.of(context).pushNamed(Routes.badges);

        final visibleBadges = (unlockedBadges.length < _showTotalBadgesCounter
            ? unlockedBadges
            : unlockedBadges.sublist(0, _showTotalBadgesCounter));

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 5.0),
                  Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(collectedBadgesKey)!,
                    style: _detailsTitleTextStyle,
                  ),
                  const Spacer(),
                  unlockedBadges.length > _showTotalBadgesCounter
                      ? GestureDetector(
                          onTap: onTapViewAll,
                          child: Text(
                            AppLocalization.of(context)!
                                .getTranslatedValues(viewAllKey)!,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(width: 5.0),
                ],
              ),
              const SizedBox(height: 10.0),
              Container(
                height: MediaQuery.of(context).size.height *
                    (_detailsCardHeightPercentage),
                decoration: BoxDecoration(
                  boxShadow: [
                    UiUtils.buildBoxShadow(
                      blurRadius: 3.0,
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(2.5, 2.5),
                    ),
                  ],
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(_detailsCardBorderRadius),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: visibleBadges
                      .map(
                        (badge) => Container(
                          width: size.width * .20,
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              BadgesIconContainer(
                                addTopPadding: false,
                                badge: badge,
                                constraints: BoxConstraints(
                                  maxHeight: size.height *
                                      _detailsCardHeightPercentage,
                                  maxWidth: size.width * (0.2),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                                child: Text(
                                  badge.badgeLabel,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeights.medium,
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
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionDetailsContainer() {
    final statistics = context.read<StatisticCubit>().getStatisticsDetails();

    final totalAnswers = int.parse(statistics.answeredQuestions);
    final correctAnswers = int.parse(statistics.correctAnswers);
    final incorrectAnswers = totalAnswers - correctAnswers;

    final textStyle = TextStyle(
      color: Theme.of(context).canvasColor,
      fontSize: 18,
    );

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 5.0),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(questionDetailsKey)!,
              style: _detailsTitleTextStyle,
            )
          ],
        ),
        const SizedBox(height: 10.0),
        Container(
          height: MediaQuery.of(context).size.height *
              (_detailsCardHeightPercentage),
          decoration: BoxDecoration(
              boxShadow: [
                UiUtils.buildBoxShadow(
                  blurRadius: 3.0,
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(2.5, 2.5),
                ),
              ],
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(_detailsCardBorderRadius)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    child: StatisticsPieChart(
                      width: 82,
                      height: 82,
                      values: [
                        (no: correctAnswers, arcColor: _correctAnsColor),
                        (no: incorrectAnswers, arcColor: _incorrectAnsColor),
                      ],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              statistics.answeredQuestions,
                              style: textStyle.copyWith(
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                            Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues(totalKey)!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiary
                                    .withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _dot(_correctAnsColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(correctKey)!} : ",
                              style: textStyle,
                            ),
                            Text(
                              statistics.correctAnswers,
                              style: textStyle.copyWith(
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_incorrectAnsColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(incorrectKey)!} : ",
                              style: textStyle,
                            ),
                            Text(
                              incorrectAnswers.toString(),
                              style: textStyle.copyWith(
                                fontWeight: FontWeights.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dot(Color? color, {final double size = 8}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildBattleStatisticsContainer() {
    final statistics = context.read<StatisticCubit>().getStatisticsDetails();

    final won = int.parse(statistics.battleVictories);
    final lost = int.parse(statistics.battleLoose);
    final drawn = int.parse(statistics.battleDrawn);
    final total = won + lost + drawn;

    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 5.0),
            Text(
              AppLocalization.of(context)!
                  .getTranslatedValues(battleStatisticsKey)!,
              style: _detailsTitleTextStyle,
            )
          ],
        ),
        const SizedBox(height: 10.0),
        Container(
          height: MediaQuery.of(context).size.height *
              (_detailsCardHeightPercentage),
          decoration: BoxDecoration(
            boxShadow: [
              UiUtils.buildBoxShadow(
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(2.5, 2.5),
              ),
            ],
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(_detailsCardBorderRadius),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textStyle = TextStyle(
                color: Theme.of(context).canvasColor,
                fontSize: 18,
              );

              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    child: StatisticsPieChart(
                      width: 82,
                      height: 82,
                      values: [
                        (no: drawn, arcColor: _incorrectAnsColor),
                        (no: lost, arcColor: _lostColor),
                        (no: won, arcColor: _wonColor),
                      ],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              total.toString(),
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              AppLocalization.of(context)!
                                  .getTranslatedValues(totalKey)!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiary
                                    .withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            _dot(_incorrectAnsColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues("draw")!} : ",
                              style: textStyle,
                            ),
                            Text(
                              statistics.battleDrawn,
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_wonColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(wonKey)!} : ",
                              style: textStyle,
                            ),
                            Text(
                              won.toString(),
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _dot(_lostColor),
                            const SizedBox(width: 10),
                            Text(
                              "${AppLocalization.of(context)!.getTranslatedValues(lostKey)!} : ",
                              style: textStyle,
                            ),
                            Text(
                              statistics.battleLoose,
                              style: textStyle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _noStatistics() {
    final size = MediaQuery.of(context).size;

    void onTapPlay() {
      // Note: this will work, because we have locked the statistics in guest mode.
      Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
      Navigator.of(context).pushNamed(
        Routes.category,
        arguments: {"quizType": QuizTypes.quizZone},
      );
    }

    void onTapHome() {
      // Note: this will work, because we have locked the statistics in guest mode.
      Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
    }

    return SizedBox(
      height: size.height * 0.75,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            UiUtils.getImagePath("not_found.svg"),
            height: size.height * 0.18,
            width: size.width * 0.18,
          ),
          SizedBox(height: size.height * 0.015),
          Text(
            AppLocalization.of(context)!
                .getTranslatedValues("noStatisticsLbl")!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontWeight: FontWeights.bold,
              fontSize: 22.0,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            AppLocalization.of(context)!
                .getTranslatedValues("noStatisticsDescLbl")!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
              fontWeight: FontWeights.regular,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * 0.035),
          if (context.read<SystemConfigCubit>().isQuizZoneEnabled) ...[
            CustomRoundedButton(
              widthPercentage: size.width,
              backgroundColor: Theme.of(context).primaryColor,
              buttonTitle:
                  AppLocalization.of(context)!.getTranslatedValues(playLbl),
              radius: 10,
              showBorder: false,
              height: 50,
              onTap: onTapPlay,
            ),
            SizedBox(height: size.height * 0.015),
          ],
          CustomRoundedButton(
            widthPercentage: size.width,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            buttonTitle:
                AppLocalization.of(context)!.getTranslatedValues(homeBtn),
            radius: 10,
            showBorder: false,
            height: 50,
            titleColor: Theme.of(context).primaryColor,
            onTap: onTapHome,
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContainer({
    required bool showQuestionAndBattleStatistics,
  }) {
    final size = MediaQuery.of(context).size;
    const vSpace = SizedBox(height: 20.0);

    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: size.height * UiUtils.vtMarginPct,
        horizontal: size.width * UiUtils.hzMarginPct,
      ),
      children: [
        _buildCollectedBadgesContainer(),
        vSpace,
        if (showQuestionAndBattleStatistics) ...[
          Column(
            children: [
              _buildQuestionDetailsContainer(),
              vSpace,
              _buildBattleStatisticsContainer(),
              vSpace,
            ],
          )
        ] else ...[
          _noStatistics(),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(AppLocalization.of(context)!
            .getTranslatedValues(statisticsLabelKey)!),
      ),
      body: BlocConsumer<StatisticCubit, StatisticState>(
        listener: (context, state) {
          if (state is StatisticFetchFailure) {
            if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
              UiUtils.showAlreadyLoggedInDialog(context: context);
            }
          }
        },
        builder: (_, state) {
          if (state is StatisticInitial || state is StatisticFetchInProgress) {
            return const Center(child: CircularProgressContainer());
          }
          return _buildStatisticsContainer(
            showQuestionAndBattleStatistics: state is StatisticFetchSuccess,
          );
        },
      ),
    );
  }
}

class StatisticsPieChart extends StatelessWidget {
  const StatisticsPieChart({
    super.key,
    required this.width,
    required this.height,
    required this.values,
    this.strokeWidth = 8.0,
    required this.child,
  });

  final List<({int no, Color arcColor})> values;
  final double width;
  final double height;
  final double strokeWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _StatisticsPieChart(values: values, strokeWidth: strokeWidth),
        child: child,
      ),
    );
  }
}

class _StatisticsPieChart extends CustomPainter {
  final List<({int no, Color arcColor})> values;
  final double strokeWidth;

  _StatisticsPieChart({required this.values, required this.strokeWidth}) {
    assert(
      values.isNotEmpty,
      "Values can't be empty. Provide correct values like, for ex. [(no: 10, arcColor: Colors.red)]",
    );
  }

  static const _pi = 3.1415926535897932;

  @override
  void paint(Canvas canvas, Size size) {
    final halfWidth = size.width * .5;
    final center = Offset(size.width * .5, halfWidth);
    final rect = Rect.fromCircle(center: center, radius: halfWidth);

    final total = values.fold(0, (prev, v) => prev += v.no);

    final p = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    /// No Data to Display Chart
    if (total == 0) {
      canvas.drawCircle(center, halfWidth, p..color = Colors.grey.shade300);
      return;
    }

    const pi2 = _pi * 2;
    double oldStart = 3 * (_pi * .5);

    for (var val in values) {
      final sweep = (val.no * pi2) / total;

      canvas.drawArc(rect, oldStart, sweep, false, p..color = val.arcColor);

      oldStart += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant oldDelegate) => false;
}
