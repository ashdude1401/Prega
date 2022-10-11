import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prega/colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Share extends StatefulWidget {
  const Share({Key? key}) : super(key: key);

  @override
  State<Share> createState() => _ShareState();
}

class _ShareState extends State<Share> {
  final user = FirebaseAuth.instance.currentUser!;
  final timeList = ['1 hour', '2 hour'];
  late var time = '1 hour';
  var actualTime = 3600;
  var link = '';
  final success = const SnackBar(
    content: Text('Copied to clipboard'),
  );

  Future<http.Response> getLink() async {
    String url =
        "https://us-central1-test-project-019.cloudfunctions.net/makeExpiryCopy";
    return await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'uid': user.uid, 'ttl': actualTime}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 55,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 15,
                ),
                Image.asset(
                  'assets/icons/icon.png',
                  height: 45,
                  width: 45,
                ),
                const SizedBox(
                  width: 15,
                ),
                const Text(
                  "Share your Health",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 47, 46, 65),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Set Expiry Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                      hint: Text(time),
                      items: timeList.map((String items) {
                        return DropdownMenuItem(
                          value: items,
                          child: Text(items),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          time = newValue!;
                          if (newValue == '1 hour') {
                            actualTime = 3600;
                          } else {
                            actualTime = 7200;
                          }
                        });
                      }),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                http.Response response = await getLink();
                Map<String, dynamic> data = jsonDecode(response.body);
                setState(() {
                  link = data['expirable_link'];
                });
              },
              style: ElevatedButton.styleFrom(
                primary: buttonColor,
              ),
              child: const Text("Get Link"),
            ),
            const SizedBox(
              height: 10,
            ),
            link == ""
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Click on above button to get link for sharing your health wiht doctor",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Color.fromARGB(255, 78, 76, 76),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: InkWell(
                          child: Text(link),
                          onTap: () {
                            FlutterClipboard.copy(link).then(
                              (value) => ScaffoldMessenger.of(context)
                                  .showSnackBar(success),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      QrImage(
                        data: link,
                        size: 300,
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
