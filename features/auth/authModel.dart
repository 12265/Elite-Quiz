import 'package:flutterquiz/features/auth/cubits/authCubit.dart';

class AuthModel {
  final AuthProviders authProvider;
  final String firebaseId;
  final String jwtToken;
  final bool isNewUser;

  AuthModel({
    required this.jwtToken,
    required this.firebaseId,
    required this.authProvider,
    required this.isNewUser,
  });

  static AuthModel fromJson(Map<String, dynamic> json) {
    return AuthModel(
      jwtToken: json['jwtToken'],
      firebaseId: json['firebaseId'],
      authProvider: json['authProvider'],
      isNewUser: false,
    );
  }

  AuthModel copyWith({
    String? jwtToken,
    String? firebaseId,
    AuthProviders? authProvider,
    bool? isNewUser,
  }) {
    return AuthModel(
      jwtToken: jwtToken ?? this.jwtToken,
      firebaseId: firebaseId ?? this.firebaseId,
      authProvider: authProvider ?? this.authProvider,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}
