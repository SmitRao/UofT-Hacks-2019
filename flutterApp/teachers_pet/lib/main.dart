import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'PetApi.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Teacher's Pet",
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: MyHomePage(title: "Teacher's Pet"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AlertState { SILENT, VIBRATE, SOUND, BOTH }

class _MyHomePageState extends State<MyHomePage> {
  AlertState alertState = AlertState.SILENT;
  int hands_Detected = 0;
  int hands_Raised = 1;
  PetApi api;
  bool _isConnected = false;
  bool _isAwaitingCall = false;
  Timer time;

  @override
  void initState() {
    super.initState();
    hands_Detected = 0;
    hands_Raised = 0;
    api = PetApi();
    time = Timer.periodic(Duration(seconds: 1), checkPet);
    print("Timer started");
  }

  void checkPet(Timer time) async {
    int i = -1;
    if (!_isAwaitingCall) {
      print("checking pet");
      _isAwaitingCall = true;
      i = await api.getIsHandRaised();
      _isAwaitingCall = false;
    } else {
      print("Awaiting last call");
    }
    print("The Value obtained");
    print(i);
    if (i == 1) {
      playAlert();
    }
  }

  void playAlert() async{
    switch (alertState) {
      case AlertState.BOTH:
        vibrate();
        playSound();
        break;
      case AlertState.SOUND:
        playSound();
        break;

      case AlertState.VIBRATE:
        vibrate();
        break;

      case AlertState.SILENT:
        break;
    }
  }

  void playSound(){

  }

  void vibrate() async {
    if ((alertState == AlertState.VIBRATE ||
        (alertState == AlertState.BOTH) && await Vibration.hasVibrator())) {
      Vibration.vibrate(duration: 1000);
    }
  }

  void _setAlertBoth() {
    setState(() {
      alertState = AlertState.BOTH;
    });
  }

  void _setAlertSound() {
    setState(() {
      alertState = AlertState.SOUND;
    });
  }

  void _setAlertVibrate() {
    setState(() {
      alertState = AlertState.VIBRATE;
    });
  }

  void _disableAlert() {
    setState(() {
      alertState = AlertState.SILENT;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _isConnected ? 'Device connected' : 'Device disconnected',
              style: Theme.of(context).textTheme.display1,
            ),
            Tooltip(
              message: "Vibrate and Sound",
              child: RaisedButton(
                child: Text("Vibrate and Sound"),
                onPressed: _setAlertBoth,
              ),
            ),
            Tooltip(
              message: "Sound Only",
              child: RaisedButton(
                child: Text("Sound Only"),
                onPressed: _setAlertSound,
              ),
            ),
            Tooltip(
              message: "Vibration Only",
              child: RaisedButton(
                child: Text("Vibration Only"),
                onPressed: _setAlertVibrate,
              ),
            ),
            Tooltip(
              message: "Disable Alerts",
              child: RaisedButton(
                child: Text("Disable Alerts"),
                onPressed: _disableAlert,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
