import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/reportQuestion/reportQuestionCubit.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

void showReportQuestionBottomSheet({
  required BuildContext context,
  required String questionId,
  required ReportQuestionCubit reportQuestionCubit,
}) {
  showModalBottomSheet<_ReportQuestionBottomSheet>(
    shape: const RoundedRectangleBorder(
      borderRadius: UiUtils.bottomSheetTopRadius,
    ),
    isDismissible: false,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    enableDrag: false,
    isScrollControlled: true,
    context: context,
    builder: (_) => _ReportQuestionBottomSheet(
      questionId: questionId,
      reportQuestionCubit: reportQuestionCubit,
    ),
  );
}

class _ReportQuestionBottomSheet extends StatefulWidget {
  const _ReportQuestionBottomSheet({
    required this.questionId,
    required this.reportQuestionCubit,
  });

  final String questionId;
  final ReportQuestionCubit reportQuestionCubit;

  @override
  State<_ReportQuestionBottomSheet> createState() =>
      _ReportQuestionBottomSheetState();
}

class _ReportQuestionBottomSheetState
    extends State<_ReportQuestionBottomSheet> {
  final reason = TextEditingController();
  String errorMessage = "";

  void _reportQuestionListener(context, state) {
    if (state is ReportQuestionSuccess) {
      Navigator.pop(context);
    }

    if (state is ReportQuestionFailure) {
      if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
        UiUtils.showAlreadyLoggedInDialog(context: context);
        return;
      }

      ///
      setState(() {
        errorMessage = AppLocalization.of(context)!.getTranslatedValues(
            convertErrorCodeToLanguageKey(state.errorMessageCode))!;
      });
    }
  }

  Future<bool> _onWillPop() {
    if (widget.reportQuestionCubit.state is ReportQuestionInProgress) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  void _onTapClose() {
    if (widget.reportQuestionCubit.state is! ReportQuestionInProgress) {
      Navigator.of(context).pop();
    }
  }

  void _onTapReportQuestion() {
    if (widget.reportQuestionCubit.state is! ReportQuestionInProgress) {
      widget.reportQuestionCubit.reportQuestion(
        message: reason.text.trim(),
        questionId: widget.questionId,
        userId: context.read<UserDetailsCubit>().userId(),
      );
    }
  }

  ///
  /// --- UI ---
  ///

  String get _buttonTitle {
    late final String title;

    if (widget.reportQuestionCubit.state is ReportQuestionInProgress) {
      title = submittingButton;
    } else if (widget.reportQuestionCubit.state is ReportQuestionFailure) {
      title = retryLbl;
    } else {
      title = submitBtn;
    }

    return AppLocalization.of(context)!.getTranslatedValues(title)!;
  }

  @override
  Widget build(context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return BlocListener<ReportQuestionCubit, ReportQuestionState>(
      bloc: widget.reportQuestionCubit,
      listener: _reportQuestionListener,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: UiUtils.bottomSheetTopRadius,
          ),
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      child: IconButton(
                        onPressed: _onTapClose,
                        icon: Icon(
                          Icons.close,
                          size: 28.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                /// Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalization.of(context)!
                        .getTranslatedValues(reportQuestionKey)!,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),

                /// Reason Text Field
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: size.width * .125),
                  padding: const EdgeInsets.only(left: 20.0),
                  height: 60.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: colorScheme.background,
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.secondary),
                    controller: reason,
                    decoration: InputDecoration(
                      hintText: AppLocalization.of(context)!
                          .getTranslatedValues(enterReasonKey)!,
                      hintStyle: TextStyle(color: colorScheme.secondary),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: size.height * .02),

                /// Error Message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? const SizedBox(height: 20.0)
                      : SizedBox(
                          height: 20.0,
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: colorScheme.secondary),
                          ),
                        ),
                ),
                SizedBox(height: size.height * .02),

                /// Report Button
                BlocBuilder<ReportQuestionCubit, ReportQuestionState>(
                  bloc: widget.reportQuestionCubit,
                  builder: (context, state) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * .3),
                      child: CustomRoundedButton(
                        widthPercentage: size.width,
                        backgroundColor: Theme.of(context).primaryColor,
                        buttonTitle: _buttonTitle,
                        radius: 10.0,
                        showBorder: false,
                        onTap: _onTapReportQuestion,
                        fontWeight: FontWeight.bold,
                        titleColor: colorScheme.background,
                        height: 40.0,
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * .05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
