import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class bot extends StatefulWidget {
  const bot({super.key});
  @override
  State<bot> createState() => _botState();
}

class _botState extends State<bot> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  getConnectivity() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (!isDeviceConnected && isAlertSet == false) {
      showDialogBox();
      setState(() => isAlertSet = true);
    }
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          showDialogBox();
          setState(() => isAlertSet = true);
        }
      },
    );
  }

  showDialogBox() => showCupertinoDialog<String>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('No Connection'),
          content: const Text('Please check your internet connectivity'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context, 'Cancel');
                setState(() => isAlertSet = false);
                isDeviceConnected =
                    await InternetConnectionChecker().hasConnection;
                if (!isDeviceConnected && isAlertSet == false) {
                  showDialogBox();
                  setState(() => isAlertSet = true);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  ChatUser me = ChatUser(id: '1', firstName: 'You');
  ChatUser bot = ChatUser(id: '2', firstName: 'Shashank');

  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  final url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBRZCjp1rPZuXUweF9ikVYknAofX6dj-j0";

  final header = {'Content-Type': 'application/json'};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getConnectivity();
    ChatMessage m1 = ChatMessage(
        user: bot, createdAt: DateTime.now(), text: 'Hey! how can I help you');
    allMessages.insert(0, m1);
    setState(() {});
  }

  getdata(ChatMessage m) async {
    FocusScope.of(context).unfocus();
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});
    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };
    await http
        .post(Uri.parse(url), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        ChatMessage mm = ChatMessage(
            user: bot,
            createdAt: DateTime.now(),
            text: result['candidates'][0]['content']['parts'][0]['text']);
        allMessages.insert(0, mm);
        setState(() {});
      } else {
        ChatMessage mm = ChatMessage(
            user: bot,
            createdAt: DateTime.now(),
            text: 'Sorry unable to process, please ask again');
        allMessages.insert(0, mm);
        setState(() {});
      }
    }).catchError((e) {
      ChatMessage mm = ChatMessage(
          user: bot,
          createdAt: DateTime.now(),
          text: 'Sorry unable to understand,please explain more.');
      allMessages.insert(0, mm);
    });
    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashChat(
        scrollToBottomOptions: ScrollToBottomOptions(disabled: true),
        typingUsers: typing,
        currentUser: me,
        onSend: (ChatMessage m) {
          getdata(m);
        },
        messages: allMessages,
      ),
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Clipboard.setData(
                    new ClipboardData(text: allMessages.first.text));
                IconSnackBar.show(
                    context: context,
                    snackBarType: SnackBarType.save,
                    snackBarStyle: SnackBarStyle(
                        backgroundColor: Colors.blueGrey,
                        iconColor: Colors.green),
                    label: 'Copied successfully');
              },
              child: Text(
                "Copy",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
              )),
        ],
        backgroundColor: Color(0xff0077FF),
        centerTitle: true,
        title: Row(
          children: [
            Text(
              "ChitBot",
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
            ),
            Image.asset(
              'assets/bobot.png',
              height: 60,
            )
          ],
        ),
        automaticallyImplyLeading: true,
      ),
    );
  }
}
