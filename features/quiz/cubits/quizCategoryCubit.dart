import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/category.dart';

import '../quizRepository.dart';

@immutable
abstract class QuizCategoryState {}

class QuizCategoryInitial extends QuizCategoryState {}

class QuizCategoryProgress extends QuizCategoryState {}

class QuizCategorySuccess extends QuizCategoryState {
  final List<Category> categories;

  QuizCategorySuccess(this.categories);
}

class QuizCategoryFailure extends QuizCategoryState {
  final String errorMessage;

  QuizCategoryFailure(this.errorMessage);
}

class QuizCategoryCubit extends Cubit<QuizCategoryState> {
  final QuizRepository _quizRepository;

  QuizCategoryCubit(this._quizRepository) : super(QuizCategoryInitial());

  void getQuizCategoryWithUserId({
    required String languageId,
    required String type,
    required String userId,
  }) async {
    emit(QuizCategoryProgress());
    _quizRepository
        .getCategory(languageId: languageId, type: type, userId: userId)
        .then((v) => emit(QuizCategorySuccess(v)))
        .catchError((e) => emit(QuizCategoryFailure(e.toString())));
  }

  void getQuizCategory({
    required String languageId,
    required String type,
  }) async {
    emit(QuizCategoryProgress());
    _quizRepository
        .getCategorywithoutuser(languageId: languageId, type: type)
        .then((v) => emit(QuizCategorySuccess(v)))
        .catchError((e) => emit(QuizCategoryFailure(e.toString())));
  }

  void updateState(QuizCategoryState updatedState) {
    emit(updatedState);
  }

  void unlockPremiumCategory({required String id}) {
    if (state is QuizCategorySuccess) {
      final categories = (state as QuizCategorySuccess).categories;

      final idx = categories.indexWhere((c) => c.id == id);

      if (idx != -1) {
        emit(QuizCategoryProgress());

        categories[idx] = categories[idx].copyWith(hasUnlocked: true);

        emit(QuizCategorySuccess(categories));
      }
    }
  }

  bool isPremiumCategoryUnlocked(String categoryId) {
    if (state is QuizCategorySuccess) {
      final categories = (state as QuizCategorySuccess).categories;

      final idx = categories.indexWhere((c) => c.id == categoryId);

      if (idx != -1) {
        final cate = categories[idx];
        return !cate.isPremium || (cate.isPremium && cate.hasUnlocked);
      }
    }
    return false;
  }

  getCat() {
    if (state is QuizCategorySuccess) {
      return (state as QuizCategorySuccess).categories;
    }
    return "";
  }
}
