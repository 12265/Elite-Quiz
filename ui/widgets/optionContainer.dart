import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

class OptionContainer extends StatefulWidget {
  final Function hasSubmittedAnswerForCurrentQuestion;
  final Function submitAnswer;
  final AnswerOption answerOption;
  final BoxConstraints constraints;
  final String correctOptionId;
  final String submittedAnswerId;
  final bool showAudiencePoll;
  final int? audiencePollPercentage;
  final bool showAnswerCorrectness;
  final bool canResubmitAnswer;
  final QuizTypes quizType;
  final bool trueFalseOption;

  const OptionContainer({
    super.key,
    required this.quizType,
    required this.showAnswerCorrectness,
    this.canResubmitAnswer = false,
    required this.showAudiencePoll,
    required this.hasSubmittedAnswerForCurrentQuestion,
    required this.constraints,
    required this.answerOption,
    required this.correctOptionId,
    required this.submitAnswer,
    required this.submittedAnswerId,
    this.audiencePollPercentage,
    this.trueFalseOption = false,
  });

  @override
  State<OptionContainer> createState() => _OptionContainerState();
}

class _OptionContainerState extends State<OptionContainer>
    with TickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
  );
  late Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(
          parent: animationController, curve: Curves.easeInQuad));

  late AnimationController topContainerAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 180));
  late Animation<double> topContainerOpacityAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    parent: topContainerAnimationController,
    curve: const Interval(0.0, 0.25, curve: Curves.easeInQuad),
  ));

  late Animation<double> topContainerAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: topContainerAnimationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInQuad)));

  late Animation<double> answerCorrectnessAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: topContainerAnimationController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeInQuad)));

  late double heightPercentage = 0.105;
  late final _audioPlayer = AudioPlayer();

  late TextSpan textSpan = TextSpan(
    text: widget.answerOption.title,
    style: GoogleFonts.nunito(
      textStyle: TextStyle(
        color: optionTextColor,
        height: 1.0,
        fontSize: 16.0,
      ),
    ),
  );

  @override
  void dispose() {
    animationController.dispose();
    topContainerAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void playSound(String trackName) async {
    if (context.read<SettingsCubit>().getSettings().sound) {
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.setAsset(trackName, preload: true);
      await _audioPlayer.play();
    }
  }

  void playVibrate() async {
    if (context.read<SettingsCubit>().getSettings().vibration) {
      UiUtils.vibrate();
    }
  }

  int calculateMaxLines() {
    TextPainter textPainter =
        TextPainter(text: textSpan, textDirection: Directionality.of(context));

    textPainter.layout(maxWidth: widget.constraints.maxWidth * 0.85);

    return textPainter.computeLineMetrics().length;
  }

  bool get isCorrectAnswer => widget.answerOption.id == widget.correctOptionId;

  bool get isSubmittedAnswer =>
      widget.answerOption.id == widget.submittedAnswerId;

  Color get optionTextColor {
    final colorScheme = Theme.of(context).colorScheme;

    if (!widget.showAnswerCorrectness) {
      return isSubmittedAnswer
          ? colorScheme.background
          : colorScheme.onTertiary;
    }

    if (widget.hasSubmittedAnswerForCurrentQuestion() &&
        (isSubmittedAnswer || isCorrectAnswer)) {
      return colorScheme.background;
    }

    return colorScheme.onTertiary;
  }

  Color _buildOptionBackgroundColor() {
    if (!widget.showAnswerCorrectness) {
      return isSubmittedAnswer
          ? Theme.of(context).primaryColor
          : Theme.of(context).colorScheme.background;
    }

    if (widget.hasSubmittedAnswerForCurrentQuestion()) {
      return isCorrectAnswer
          ? kCorrectAnswerColor
          : isSubmittedAnswer
              ? kWrongAnswerColor
              : Theme.of(context).colorScheme.background;
    }

    return Theme.of(context).colorScheme.background;
  }

  void _onTapOptionContainer() {
    if (widget.showAnswerCorrectness) {
      //if user has submitted the answer then do not show correctness of the answer
      if (!widget.hasSubmittedAnswerForCurrentQuestion()) {
        widget.submitAnswer(widget.answerOption.id);

        topContainerAnimationController.forward();

        if (widget.correctOptionId == widget.answerOption.id) {
          playSound(correctAnswerSoundTrack);
        } else {
          playSound(wrongAnswerSoundTrack);
        }
        playVibrate();
      }
    } else {
      widget.submitAnswer(widget.answerOption.id);

      playSound(clickEventSoundTrack);
      playVibrate();
    }
  }

  Widget _buildOptionDetails(double optionWidth) {
    int maxLines = calculateMaxLines();
    if (!widget.hasSubmittedAnswerForCurrentQuestion()) {
      heightPercentage = maxLines > 2
          ? (heightPercentage + (0.03 * (maxLines - 2)))
          : heightPercentage;
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (_, child) {
        return Transform.scale(
          scale: animation.drive(Tween<double>(begin: 1.0, end: 0.9)).value,
          child: child,
        );
      },
      child: Container(
        margin: EdgeInsets.only(top: widget.constraints.maxHeight * (0.015)),
        height: widget.quizType == QuizTypes.groupPlay
            ? widget.constraints.maxHeight * (heightPercentage * 0.75)
            : widget.constraints.maxHeight * (heightPercentage),
        width: optionWidth,
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: maxLines > 2 ? 7.50 : 0,
                ),
                color: _buildOptionBackgroundColor(),
                alignment: AlignmentDirectional.centerStart,
                child:
                     Center(
                            child: RichText(
                            text: textSpan,
                            textAlign: TextAlign.center,
                          )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    textSpan = TextSpan(
      text: widget.answerOption.title,
      style: GoogleFonts.nunito(
        textStyle: TextStyle(
          color: optionTextColor,
          height: 1.0,
          fontSize: 16.0,
        ),
      ),
    );
    return GestureDetector(
      onTapCancel: animationController.reverse,
      onTap: () async {
        animationController.reverse();
        _onTapOptionContainer();
      },
      onTapDown: (_) => animationController.forward(),
      child: widget.showAudiencePoll
          ? Row(
              children: [
                _buildOptionDetails(widget.constraints.maxWidth * .8),
                const SizedBox(width: 10),
                Text(
                  "${widget.audiencePollPercentage}%",
                  style: GoogleFonts.nunito(
                    textStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontSize: 16.0,
                      fontWeight: FontWeights.bold,
                    ),
                  ),
                ),
              ],
            )
          : _buildOptionDetails(widget.constraints.maxWidth),
    );
  }
}
