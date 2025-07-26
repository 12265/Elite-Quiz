import 'dart:convert';
import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:circle_flags/circle_flags.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;


import '../../../app/routes.dart';
import '../../../features/wallet/walletException.dart';
import '../../../utils/api_utils.dart';
import '../../../utils/constants/api_body_parameter_labels.dart';
import '../../../utils/constants/constants.dart';
import '../../../utils/constants/error_message_keys.dart';

class DepositScreen extends StatefulWidget {
  List<String> user;
  DepositScreen({super.key, required this.user});

  static Route route(RouteSettings deposit) {
    return CupertinoPageRoute(
        builder: (_) => DepositScreen(user: deposit.arguments as List<String>));
  }


  @override
  State<DepositScreen> createState() => _DepositScreen();
}

class _DepositScreen extends State<DepositScreen> {
  final textEditingController = TextEditingController(text: "10");
  Future<dynamic> makePaymentRequest({
    required String userId,
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        paymentTypeKey: paymentType,
        paymentAddressKey: paymentAddress,
        paymentAmountKey: paymentAmount,
        coinUsedKey: coinUsed,
        detailsKey: details,
      };


      final response = await http.post(Uri.parse(makePaymentRequestUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        print("${responseJson['message'].toString()} thats the error ");
        throw WalletException(
          errorMessageCode: responseJson['message'].toString() == "126"
              ? errorCodeAccountHasBeenDeactivated
              : responseJson['message'].toString() == "127"
              ? errorCodeCanNotMakeRequest
              : responseJson['message'].toString(),
        );
      }

      return responseJson;
    } on SocketException catch (_) {
      throw WalletException(errorMessageCode: errorCodeNoInternet);
    } on WalletException catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    } catch (e) {
      throw WalletException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05),
            child: ListView(
              children: [
                Container(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Row(
                    children: [
                      Text(
                          style: TextStyle(
                              color: Colors.deepPurple[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                          "Deposite"),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.04,
                      ),
                      Container(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.grey[200], // Background color
                            ),
                            onPressed: () {},
                            child: Row(children: [
                              SizedBox(
                                child: CircleFlag('us'),
                                width: MediaQuery.of(context).size.width * 0.07,
                                height: MediaQuery.of(context).size.width * 0.07,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.02,
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width * 0.09,
                                  child: TextField(
                                      controller: textEditingController,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(color: Colors.deepPurple[900]))),
                              Text(
                                "USD",
                                style: TextStyle(
                                    color: Colors.deepPurple[900], fontSize: 14),
                              ),
                            ]),
                          )),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.07),
                      Spacer(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                        child: FloatingActionButton(
                          elevation: 0,
                          child: Icon(Icons.clear),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(Routes.home, arguments: false);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    "METHOD",
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(decoration: BoxDecoration(color: Colors.black12,
                        border: Border.all(
                          color: Colors.black26,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Center(
                          child: Text(
                            "USDC\nUSDT",
                            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                          )),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    "Network",
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ),
                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.grey[100]),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.05),
                    child: Text(
                      "ALGO",
                      style: TextStyle(fontSize: 20, color: Colors.indigo[900]),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01),
                  child: Text(
                    "Username",
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.grey[100]),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05),
                        child: Text("${widget.user[0]}",
                            style:
                            TextStyle(fontSize: 20, color: Colors.indigo[900])),
                      ),Spacer(),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: FloatingActionButton(
                          elevation: 0,
                          child: Icon(Icons.copy),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          onPressed: () async {
                            await FlutterClipboard.copy(widget.user[0]);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01),
                  child: Row(
                    children: [
                      Text(
                        "Wallet Address",
                        style: TextStyle(
                          color: Colors.black45,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.006),
                        color: Colors.yellow[100],
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: Center(
                            child: Text(
                              "IMPORTANT",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800]),
                            )),
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.grey[100]),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05),
                        child: Text(
                            "SP6P5OBWMKO45C7MM...",
                            style:
                            TextStyle(fontSize: 20, color: Colors.indigo[900])),
                      ),Spacer(),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: FloatingActionButton(
                          elevation: 0,
                          child: Icon(Icons.copy),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          onPressed: () async {
                            await FlutterClipboard.copy(
                                "SP6P5OBWMKO45C7MM6VRI6XD35FLFIPORXZLM5LOAX22ZZJ3LILVRSWAU4");
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.02),
                  child: Center(
                    child: Text("OR"),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.grey[100]),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05),
                        child: Text("game.coop.algo",
                            style:
                            TextStyle(fontSize: 20, color: Colors.indigo[900])),
                      ),Spacer(),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: FloatingActionButton(
                          elevation: 0,
                          child: Icon(Icons.copy),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue,
                          onPressed: () async {
                            await FlutterClipboard.copy("game.coop.algo");
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03),
                  child: Text(
                      "Note: Please don't forget to add your username in the wallet's note section when you send your asset, Otherwise this process will take longer than what it should and you may lose your asset.",
                      style: TextStyle(
                        color: Colors.red,
                      )),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.04),
                  child: SizedBox(
                    width: double.maxFinite,height: MediaQuery.of(context).size.height * 0.05,
                    child: ElevatedButton(
                      onPressed: () async{
                        Navigator.of(context)
                            .pushNamed(Routes.home, arguments: false);
                        Fluttertoast.showToast(msg: "transaction is processing...");
                        await FirebaseFirestore.instance.collection("Deposit").add({
                          'username': widget.user[0],
                          'amount': "${textEditingController.text}\$"
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          primary: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height * 0.1)),
                          textStyle: const TextStyle(color: Colors.white)),
                      child: Text(
                        'SEND',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
