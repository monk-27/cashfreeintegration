// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:math';

import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _amountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          child: Text('Cashfree Payment gateway integration'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 20,
            ),
            child: TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
                hintText: "Enter amount",
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          ElevatedButton(
            onPressed: payClickHandle,
            child: const Text("Pay"),
            // {
            //   FocusScope.of(context).requestFocus(FocusNode());
            //   final amount = _amountController.text.trim();
            //   if (amount.isEmpty) {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         content: Text("Enter amount"),
            //       ),
            //     );
            //     return;
            //   }
            // },
          ),
        ],
      ),
    );
  }

  void payClickHandle() {
    FocusScope.of(context).requestFocus(FocusNode());
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter amount"),
        ),
      );
      return;
    }
    num orderId = Random().nextInt(1000);

    num payableAmount = num.parse(amount);
    getAccessToken(payableAmount, orderId).then((tokenData) {
      Map<String, String> _params = {
        'stage': 'TEST',
        'orderAmount': amount,
        'orderId': '$orderId',
        'orderCurrency': 'INR',
        'userId': 'USER123',
        'customerName': 'Shashi Bhushan Jha',
        'customerPhone': '8130236844',
        'customerEmail': 'exquisiteshashi@gmail.com',
        'tokenData': tokenData,
        'appId': 'TEST10031658b00cc7850281096485c085613001',
      };
      CashfreePGSDK.doPayment(_params).then((value) {
        print(value);
        if (value != null) {
          if (value['txStatus'] == 'SUCCESS') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Payment Success"),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Payment Failed"),
              ),
            );
          }
        }
      });
    });
  }


Future<String> getAccessToken(num amount, num orderId) async {
  var res = await http.post(
    Uri.https("test.cashfree.com", "api/v2/cftoken/order"),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'x-client-id': 'TEST10031658b00cc7850281096485c085613001',
      'x-client-secret': 'TEST79950dc3fbb7a47ee1d5acd5c80e401c2fb806b8',
    },
    body: jsonEncode(
      {
        "orderId": '$orderId',
        "orderAmount": amount,
        "orderCurrency": "INR",
        
        
      },
    ),
  );
  if (res.statusCode == 200) {
    var jsonResponse = jsonDecode(res.body);
    if (jsonResponse['status'] == 'OK') {
      return jsonResponse['cftoken'];
    }
  }
  return '';
}}
