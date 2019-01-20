import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'PetApi.dart';

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
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int hands_Detected;
  int hands_Raised;
  PetApi api;
  bool _isConnected = false;
  bool isVibrateEnabled = false;
  @override
  void initState() {
    super.initState();
    int hands_Detected = 0;
    int hands_Raised = 0;
    api = PetApi();
    disableVibrate();
  }

  void vibrate() async {
    if (await Vibration.hasVibrator() && isVibrateEnabled) {
      Vibration.vibrate(duration: 1000);
    }
  }

  void disableVibrate() {

  }

  void enableVibrate() {
    
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
              style: Theme.of(context).textTheme.body1,
            ),
            Tooltip(
              message: "Enable Vibrations",
              child: RaisedButton(
                child: Text("Enable Vibration"),
                onPressed: enableVibrate,
              ),
            ),
            Tooltip(
              message: "Disable Vibrations",
              child: RaisedButton(
                child: Text("Disable Vibration"),
                onPressed: disableVibrate,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: vibrate, //_incrementCounter,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
