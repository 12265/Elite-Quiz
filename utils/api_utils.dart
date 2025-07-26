import 'dart:developer';

import 'package:flutterquiz/features/auth/authLocalDataSource.dart';
import 'package:flutterquiz/features/auth/authRemoteDataSource.dart';

class ApiUtils {
  static Future<Map<String, String>> getHeaders() async {
    String jwtToken = AuthLocalDataSource.getJwtToken();

    if (jwtToken.isEmpty) {

        jwtToken = await AuthRemoteDataSource().getJWTTokenOfUser(
          firebaseId: AuthLocalDataSource.getUserFirebaseId(),
          type: AuthLocalDataSource.getAuthType(),
        );
        await AuthLocalDataSource.setJwtToken(jwtToken);
    }

    log(name: 'API: JWT Token', jwtToken);

    return {"Authorization": 'Bearer $jwtToken'};
  }
}
