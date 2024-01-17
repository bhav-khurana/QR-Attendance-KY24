// ignore_for_file: curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'dart:convert';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:qr_attendance/constants/api.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:http/http.dart' as http;
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? result;

  Future<String> getResponse(String data) async {
    final response = await http.post(
      Uri.parse('${Api.baseUrl}/${Api.ticketEndpoint}/'),
      body: {
        'data': data,
      },
    );
    Map res = jsonDecode(response.body);
    return res['msg'];
  }

  @override
  void initState() {
    super.initState();
    result = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kashiyatra 2024',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(
                        isShowFlashIcon: true,
                      ),
                    ),
                  );
                  if (res is String) {
                    result = res;
                    getResponse(res).then((response) {
                      String msg = '';
                      CoolAlertType coolAlertType = CoolAlertType.success;

                      switch (response) {
                        case Api.sucess:
                          coolAlertType = CoolAlertType.success;
                          msg = 'Attendance marked successfully';
                          break;
                        case Api.alreadyDone:
                          coolAlertType = CoolAlertType.warning;
                          msg = 'Attendance already marked';
                          break;
                        case Api.invalidDay:
                          coolAlertType = CoolAlertType.error;
                          msg = 'Ticket is not valid for this day';
                          break;
                        case Api.invalidTicket:
                          coolAlertType = CoolAlertType.error;
                          msg = 'Ticket is not valid';
                          break;
                        default:
                          coolAlertType = CoolAlertType.error;
                          msg = 'Something went wrong';
                          break;
                      }
                      CoolAlert.show(
                        context: context,
                        type: coolAlertType,
                        text: msg,
                      );
                    });
                  }
                  setState(() {});
                },
                child: const Text('Open Scanner'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
