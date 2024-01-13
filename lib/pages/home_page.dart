import 'dart:convert';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
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
                  var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ),
                  );
                  if (res is String) {
                    result = res;
                    getResponse(res).then((response) {
                      String msg = '', title = '';
                      ContentType contentType = ContentType.help;

                      switch (response) {
                        case Api.sucess:
                          title = 'Success';
                          msg = 'Attendance marked successfully';
                          contentType = ContentType.success;
                          break;
                        case Api.alreadyDone:
                          title = 'Already Marked';
                          msg = 'Attendance already marked';
                          contentType = ContentType.warning;
                          break;
                        case Api.invalidDay:
                          title = 'Invalid Day';
                          msg = 'Ticket is not valid for this day';
                          contentType = ContentType.failure;
                          break;
                        case Api.invalidTicket:
                          title = 'Invalid Ticket';
                          msg = 'Ticket is not valid';
                          contentType = ContentType.failure;
                          break;
                        default:
                          title = 'Aw Snap :(';
                          msg = 'Something went wrong';
                          contentType = ContentType.failure;
                          break;
                      }
                      final snackBar = SnackBar(
                        elevation: 0,
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.transparent,
                        content: AwesomeSnackbarContent(
                          title: title,
                          message: msg,
                          contentType: contentType,
                        ),
                      );
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(snackBar);
                    });
                    setState(() {});
                  }
                },
                child: const Text('Open Scanner'),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            result != null
                ? Text('Scanned Data = $result')
                : const Text('Scanned data will appear here')
          ],
        ),
      ),
    );
  }
}
