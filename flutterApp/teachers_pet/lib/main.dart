import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audio_cache.dart';

import 'PetApi.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  int handsDetected = 0;
  //int _hands_Raised = 1;
  PetApi api;
  bool _isConnected = false;
  bool _isAwaitingCall = false;
  Timer time;
  static AudioCache audioPlayer = new AudioCache();

  static const String soundPath = "alert.mp3";
  static const int vibLong = 200;
  static const int vibShort = 1000;
  static const List<int> vibSpatialLeft = [1000,100,100];
  static const List<int> vibSpatialMid = [100,1000,100];
  static const List<int> vibSpatialRight =[100,100,1000];
  static const vibrateFrame = 1000;
  @override
  void initState() {
    super.initState();
    handsDetected = 0;
   // handsRaised = 0;
    api = PetApi();
    audioPlayer.play('alert.mp3');    
    //audioPlayer = new AudioCache();
    // audioPlayer.fetchToMemory(soundPath);
    time = Timer.periodic(Duration(seconds: 2), checkPet);
    print("Timer started");
  }

   void checkPetSpatial(Timer time) async {
    int i = -1;
   // int location = -1;
    if (!_isAwaitingCall) {
      print("checking pet");
      _isAwaitingCall = true;
      i = await api.getIsHandRaised();
      setState(() {
        _isConnected = true;
      });
      _isAwaitingCall = false;
    } else {
      print("Awaiting last call");
    }
    print("The Value obtained:");
    print(i);
    if (i == 1) //1 Means a hand is raised
    {
      // playAlertSpatial(int spatial);
    }
    else if(i == 0){// Means no hand is raised 
      setState(() {
        _isConnected = true;
      });
    }
    else if (i == null || i == -1)// No connection response available.
    {
      setState(() {
        _isConnected = false;
      });
    } 
  }

  void checkPet(Timer time) async {
    int i = -1;
    if (!_isAwaitingCall) {
      print("checking pet");
      _isAwaitingCall = true;
      i = await api.getIsHandRaised();
      setState(() {
        _isConnected = true;
      });
      _isAwaitingCall = false;
    } else {
      print("Awaiting last call");
    }
    print("The Value obtained");
    print(i);
    if (i == 1) //1 Means a hand is raised
    {
      playAlert();
    }
    else if(i == 0){// Means no hand is raised 
      setState(() {
        _isConnected = true;
      });
    }
    else if (i == null || i == -1)// No connection response available.
    {
      setState(() {
        _isConnected = false;
      });
    } 
  }

  void playAlert() async{
    handsDetected += 1;
    switch (alertState) {
      case AlertState.BOTH:
        vibrate();
        playSound();
        //timer.cancel();
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

   audioPlayer.play(soundPath);
   print("played sound");
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
    playAlert();
  }

  void _setAlertSound() {
    setState(() {
      alertState = AlertState.SOUND;
    });
    playAlert();
  }

  void _setAlertVibrate() {
    setState(() {
      alertState = AlertState.VIBRATE;
    });
    playAlert();
  }

  void _disableAlert() {
    setState(() {
      alertState = AlertState.SILENT;
    });
    playAlert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            children: <Widget>[
              Tooltip(
                  child: Text(
                  _isConnected ? 'Device Connected' : 'Device disconnected',
                  style: Theme.of(context).textTheme.display1,
                ),
                message: _isConnected ? 'Device Connected' : 'Device disconnected',
              ),
              Text("Total Hands detected: $handsDetected")
            ],
          ),
          Tooltip(
            message: "Vibrate and Sound",
            child: MaterialButton(
              child: Text("Vibrate and Sound"),
              onPressed: _setAlertBoth,
            ),
          ),
          Tooltip(
            message: "Sound Only",
            child: MaterialButton(
              child: Text("Sound Only"),
              onPressed: _setAlertSound,
            ),
          ),
          Tooltip(
            message: "Vibration Only",
            child: MaterialButton(
              child: Text("Vibration Only"),
              onPressed: _setAlertVibrate,
            ),
          ),
          Tooltip(
            message: "Disable Alerts",
              child: MaterialButton(
                child: Text("Disable Alerts"),
                onPressed: _disableAlert,
            ),
          ),
        ],
      ),
    );
  }
}
