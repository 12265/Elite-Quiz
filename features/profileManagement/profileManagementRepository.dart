import 'dart:io';

import 'package:flutterquiz/features/profileManagement/profileManagementException.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRemoteDataSource.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';

import 'models/userProfile.dart';

class ProfileManagementRepository {
  static final ProfileManagementRepository _profileManagementRepository =
      ProfileManagementRepository._internal();
  late ProfileManagementLocalDataSource _profileManagementLocalDataSource;
  late ProfileManagementRemoteDataSource _profileManagementRemoteDataSource;

  factory ProfileManagementRepository() {
    _profileManagementRepository._profileManagementLocalDataSource =
        ProfileManagementLocalDataSource();
    _profileManagementRepository._profileManagementRemoteDataSource =
        ProfileManagementRemoteDataSource();

    return _profileManagementRepository;
  }

  ProfileManagementRepository._internal();

  ProfileManagementLocalDataSource get profileManagementLocalDataSource =>
      _profileManagementLocalDataSource;

  Future<void> deleteAccount({required String userId}) async {
    try {
      await _profileManagementRemoteDataSource.deleteAccount(userId: userId);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<void> setUserDetailsLocally(UserProfile userProfile) async {
    await profileManagementLocalDataSource.setUserUId(userProfile.userId!);
    await profileManagementLocalDataSource.setCoins(userProfile.coins!);
    await profileManagementLocalDataSource
        .serProfileUrl(userProfile.profileUrl!);
    await profileManagementLocalDataSource.setEmail(userProfile.email!);
    await profileManagementLocalDataSource
        .setFirebaseId(userProfile.firebaseId!);
    await profileManagementLocalDataSource.setName(userProfile.name!);
    await profileManagementLocalDataSource.setRank(userProfile.allTimeRank!);
    await profileManagementLocalDataSource.setScore(userProfile.allTimeScore!);
    await profileManagementLocalDataSource
        .setMobileNumber(userProfile.mobileNumber!);
    await profileManagementLocalDataSource.setFCMToken(userProfile.fcmToken!);
    await profileManagementLocalDataSource.setReferCode(userProfile.referCode!);
  }
  Future<Map> updateAdminCoins(
      {required String userId,
        required int? coins,
        required bool addCoin,
        required String title,
        String? type}) async {
    try {
      final result = await _profileManagementRemoteDataSource.updateAdminCoins(
          title: title,
          userId: userId,
          coins: addCoin ? coins.toString() : (coins! * -1).toString(),
          type: type);
      return Map.from(result);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }
  Future<UserProfile> getUserDetails() async {
    try {
      return UserProfile(
        fcmToken: _profileManagementLocalDataSource.getFCMToken(),
        referCode: _profileManagementLocalDataSource.getReferCode(),
        allTimeRank: _profileManagementLocalDataSource.getRank(),
        allTimeScore: _profileManagementLocalDataSource.getScore(),
        coins: _profileManagementLocalDataSource.getCoins(),
        email: _profileManagementLocalDataSource.getEmail(),
        firebaseId: _profileManagementLocalDataSource.getFirebaseId(),
        mobileNumber: _profileManagementLocalDataSource.getMobileNumber(),
        name: _profileManagementLocalDataSource.getName(),
        profileUrl: _profileManagementLocalDataSource.getProfileUrl(),
        registeredDate: "",
        status: _profileManagementLocalDataSource.getStatus(),
        userId: _profileManagementLocalDataSource.getUserUID(),
      );
    } catch (e) {
      throw ProfileManagementException(
          errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<UserProfile> getUserDetailsById() async {
    try {
      final result =
          await _profileManagementRemoteDataSource.getUserDetailsById();

      print("UserDetails ${UserProfile.fromJson(result).toString()}");
      return UserProfile.fromJson(result);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<String> uploadProfilePicture(File? file, String? userId) async {
    try {
      final result = await _profileManagementRemoteDataSource.addProfileImage(
          file, userId);
      return result['profile'].toString();
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<Map> updateCoinsAndScore(
      {required String userId,
      required int? score,
      required int coins,
      required bool addCoin,
      required String title,
      String? type}) async {
    try {
      final result =
          await _profileManagementRemoteDataSource.updateCoinsAndScore(
              userId: userId,
              title: title,
              coins: addCoin ? coins.toString() : (coins * -1).toString(),
              score: score.toString(),
              type: type);
      print("Result of coins and score update : $result");
      return Map.from(result);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<Map> updateCoins(
      {required String userId,
      required int? coins,
      required bool addCoin,
      required String title,
      String? type}) async {
    try {
      final result = await _profileManagementRemoteDataSource.updateCoins(
          title: title,
          userId: userId,
          coins: addCoin ? coins.toString() : (coins! * -1).toString(),
          type: type);
      return Map.from(result);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<Map> updateScore(
      {required String userId, required int? score, String? type}) async {
    try {
      final result = await _profileManagementRemoteDataSource.updateScore(
          type: type, userId: userId, score: score.toString());
      return Map.from(result);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<void> removeAdsForUser(bool status) async {
    try {
      await _profileManagementRemoteDataSource.removeAdsForUser(status);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  //update profile method in remote data source
  Future<void> updateProfile(
      {required String userId,
      required String email,
      required String name,
      required String mobile}) async {
    try {
      await _profileManagementRemoteDataSource.updateProfile(
          userId: userId, email: email, mobile: mobile, name: name);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<bool> isDailyAdsAvailable() async {
    return await _profileManagementRemoteDataSource.isDailyAdsAvailable();
  }

  Future<bool> watchedDailyAd() async {
    return await _profileManagementRemoteDataSource.watchedDailyAd();
  }
}
