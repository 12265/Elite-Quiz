import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';

import 'authCubit.dart';

//State
@immutable
abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpProgress extends SignUpState {
  final AuthProviders authProvider;

  SignUpProgress(this.authProvider);
}

class SignUpSuccess extends SignUpState {}

class SignUpFailure extends SignUpState {
  final String errorMessage;
  final AuthProviders authProvider;

  SignUpFailure(this.errorMessage, this.authProvider);
}

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;

  SignUpCubit(this._authRepository) : super(SignUpInitial());

  //signUp user
  void signUpUser(
    AuthProviders authProvider,
    String email,
    String password,
  ) {
    //emitting signup progress state
    emit(SignUpProgress(authProvider));
    _authRepository.signUpUser(email, password).then((value) =>
        //success
        emit(SignUpSuccess())).catchError((e) {
      //failure
      emit(SignUpFailure(e.toString(), authProvider));
    });
  }
}
