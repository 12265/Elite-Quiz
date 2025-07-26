import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';

import '../quizRepository.dart';

@immutable
abstract class SubCategoryState {}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryFetchInProgress extends SubCategoryState {}

class SubCategoryFetchSuccess extends SubCategoryState {
  final List<Subcategory> subcategoryList;
  final String? categoryId;

  SubCategoryFetchSuccess(this.categoryId, this.subcategoryList);
}

class SubCategoryFetchFailure extends SubCategoryState {
  final String errorMessage;

  SubCategoryFetchFailure(this.errorMessage);
}

class SubCategoryCubit extends Cubit<SubCategoryState> {
  final QuizRepository _quizRepository;

  SubCategoryCubit(this._quizRepository) : super(SubCategoryInitial());

  void fetchSubCategory(String category, String userId) async {
    emit(SubCategoryFetchInProgress());
    _quizRepository
        .getSubCategory(category, userId)
        .then(
          (val) => emit(SubCategoryFetchSuccess(category, val)),
        )
        .catchError((e) {
      print(e.toString());
      emit(SubCategoryFetchFailure(e.toString()));
    });
  }

  void updateState(SubCategoryState updatedState) {
    emit(updatedState);
  }

  void unlockPremiumSubCategory({required categoryId, required String id}) {
    if (state is SubCategoryFetchSuccess) {
      final subcategories = (state as SubCategoryFetchSuccess).subcategoryList;

      final idx = subcategories.indexWhere((s) => s.id == id);

      if (idx != -1) {
        emit(SubCategoryFetchInProgress());
        subcategories[idx] = subcategories[idx].copyWith(hasUnlocked: true);
        emit(SubCategoryFetchSuccess(categoryId, subcategories));
      }
    }
  }
}
