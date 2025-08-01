import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/api_body_parameter_labels.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:http/http.dart' as http;

class ProfileManagementRemoteDataSource {
  /*
  {id: 11, firebase_id: G1thaSiA43WYx29dOXmUd6jqUWS2,
  name: RAHUL HIRANI, email: rahulhiraniphotoshop@gmail.com, mobile: ,
  type: gmail, profile: https://lh3.googleusercontent.com/a/AATXAJyzUAfJwUFTV3yE6tM9KdevDnX2rcM8vm3GKHFz=s96-c, fcm_id: dwMNB7WrRbGJ_alB_moZbs:APA91bFuKIMzXGelNem5CqqWPyj2TQaFEB54glL_i-jSgmwERya9be4fZKyLrRwdt28vZWkIYKxXTl8pkWJAcqxWQG_yOvTwVpqB50-owcD9MBxRxzD5tPviMCl0AUJoq5ur1ZsDpnpY,
  coins: 0, refer_code: , friends_code: , ip_address: , status: 1,
  date_registered: 2021-06-07 15:27:59, all_time_score: 0, all_time_rank: 0}
  */

  Future<dynamic> getUserDetailsById() async {
    try {
      //body of post request
      final body = {accessValueKey: accessValue};

      final response = await http.post(Uri.parse(getUserDetailsByIdUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      print(e.toString());
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }

  /*response ********{"error":false,"message":"Profile uploaded successfully!","data":{profileKey:"http:\/\/flutterquiz.thewrteam.in\/images\/profile\/1623326274.jpg"}}*/
  Future addProfileImage(File? images, String? userId) async {
    try {
      Map<String, String?> body = {
        userIdKey: userId,
        accessValueKey: accessValue
      };
      Map<String, File?> fileList = {
        imageKey: images,
      };
      var response = await postApiFile(
          Uri.parse(uploadProfileUrl), fileList, body, userId);
      final res = json.decode(response);
      if (res['error']) {
        throw ProfileManagementException(errorMessageCode: res['message']);
      }
      return res['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }
  Future<dynamic> updateAdminCoins({
    required String userId,
    required String coins,
    required String title,
    String? type, //dashing_debut, clash_winner
  }) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        coinsKey: coins,
        titleKey: title,
        statusKey: (int.parse(coins) < 0) ? "1" : "0",
        typeKey: type ?? "",
      };
      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }

      final response = await http.post(Uri.parse(updateUserCoinsAndScoreUrl),
          body: body, headers: {"Authorization": 'Bearer eyJ0eXAiOiJqd3QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MDI3NzI3NTUsImlzcyI6IlF1aXoiLCJleHAiOjE3MDUzNjQ3NTUsInVzZXJfaWQiOiIxIiwiZmlyZWJhc2VfaWQiOiJ0dWhLbWtLZHJYZ1I2ajV1OTdGaXNBNHMzMkIyIiwic3ViIjoiUXVpeiBBdXRoZW50aWNhdGlvbiJ9.1-P82UbUFeJk9e1-Wf2ox1jim6t3lkyiLluigq4ChhU'});
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      print("LOST CONNEXION ");
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }
  Future postApiFile(Uri url, Map<String, File?> fileList,
      Map<String, String?> body, String? userId) async {
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(await ApiUtils.getHeaders());

      body.forEach((key, value) {
        request.fields[key] = value!;
      });

      for (var key in fileList.keys.toList()) {
        var pic = await http.MultipartFile.fromPath(key, fileList[key]!.path);
        request.files.add(pic);
      }
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 200) {
        return response;
      } else {
        throw ProfileManagementException(
            errorMessageCode: errorCodeDefaultMessage);
      }
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }

  /*
    body of this post request
    access_key:8525
    user_id:1
    coins:10      //if deduct coin than set with minus sign -2
    score:2
   */
  Future<dynamic> updateCoinsAndScore({
    required String userId,
    required String score,
    required String coins,
    required String title,
    String? type,
  }) async {
    try {
      //body of post request
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        coinsKey: coins,
        scoreKey: score,
        typeKey: type ?? "",
        titleKey: title,
        statusKey: (int.parse(coins) < 0) ? "1" : "0",
      };

      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }
      final response = await http.post(Uri.parse(updateUserCoinsAndScoreUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }

  /*
    body of this post request
    access_key:8525
    user_id:1
    coins:10      //if deduct coin than set with minus sign -2
    score:2
   */
  Future<dynamic> updateCoins({
    required String userId,
    required String coins,
    required String title,
    String? type, //dashing_debut, clash_winner
  }) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        coinsKey: coins,
        titleKey: title,
        statusKey: (int.parse(coins) < 0) ? "1" : "0",
        typeKey: type ?? "",
      };
      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }

      final response = await http.post(Uri.parse(updateUserCoinsAndScoreUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }

  /*
    body of this post request
    access_key:8525
    user_id:1
    coins:10      //if deduct coin than set with minus sign -2
    score:2
   */
  Future<dynamic> updateScore({
    required String userId,
    required String score,
    String? type,
  }) async {
    try {
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        scoreKey: score,
        typeKey: type ?? ""
      };
      if (body[typeKey]!.isEmpty) {
        body.remove(typeKey);
      }
      final response = await http.post(Uri.parse(updateUserCoinsAndScoreUrl),
          body: body, headers: await ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> removeAdsForUser(bool status) async {
    try {
      final body = <String, String>{
        accessValueKey: accessValue,
        removeAdsKey: status ? '1' : '0',
      };

      final rawRes = await http.post(
        Uri.parse(updateProfileUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final resJson = jsonDecode(rawRes.body);
      if (resJson['error']) {
        throw ProfileManagementException(errorMessageCode: resJson['message']);
      }
    } catch (e) {
      throw ProfileManagementException(
        errorMessageCode: errorCodeDefaultMessage,
      );
    }
  }

  Future<void> updateProfile(
      {required String userId,
      required String email,
      required String name,
      required String mobile}) async {
    try {
      //body of post request
      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        emailKey: email,
        nameKey: name,
        mobileKey: mobile
      };

      final response = await http.post(Uri.parse(updateProfileUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw ProfileManagementException(
            errorMessageCode: responseJson['message']);
      }
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<void> deleteAccount({required String userId}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      await currentUser?.delete();

      Map<String, String> body = {
        accessValueKey: accessValue,
        userIdKey: userId
      };

      await http.post(
        Uri.parse(deleteUserAccountUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on FirebaseAuthException catch (e) {
      throw ProfileManagementException(
          errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<bool> isDailyAdsAvailable() async {
    try {
      final body = <String, String>{accessValueKey: accessValue};

      final rawRes = await http.post(
        Uri.parse(isDailyAdsAvailableUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final jsonRes = jsonDecode(rawRes.body);

      if (jsonRes['error'] as bool) {
        if (jsonRes['message'] == errorCodeDailyAdsLimitSucceeded) {
          return false;
        } else {
          throw ProfileManagementException(
              errorMessageCode: jsonRes['message']);
        }
      }

      return jsonRes['message'] == errorCodeUserCanContinue;
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on FirebaseAuthException catch (e) {
      throw ProfileManagementException(
          errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<bool> watchedDailyAd() async {
    try {
      final body = <String, String>{accessValueKey: accessValue};

      final rawRes = await http.post(
        Uri.parse(watchedDailyAdUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final jsonRes = jsonDecode(rawRes.body);

      if (jsonRes['error'] as bool) {
        throw ProfileManagementException(errorMessageCode: jsonRes['message']);
      }

      return jsonRes['message'] == errorCodeDataUpdateSuccess;
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: errorCodeNoInternet);
    } on FirebaseAuthException catch (e) {
      throw ProfileManagementException(
          errorMessageCode: firebaseErrorCodeToNumber(e.code));
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
