import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'Stream'
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
        primarySwatch: Colors.blue,
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
  static const int deviceRSSI = 123131;

  int _counter = 0;
  FlutterBlue btInst;
  BluetoothDevice device;
  List<BluetoothService> services;
  bool _isConnected = false;
  void vibrate() async {
     print("DOES HAVE VIBRATOR? :" + await Vibration.hasVibrator());
      if(await Vibration.hasVibrator()){
        Vibration.vibrate(duration:1000);
      }
  }
  @override
    void initState() {
      super.initState();
      btInst = FlutterBlue.instance;
      btLoop();
  }
  Future<void> findDevice() async{
    var scanSubscription = btInst.scan().listen((scanResult) {
      if( scanResult.rssi == ){
      }
    });
  }

  void btLoop() async{
     await findDevice();
  }
  
  void updateServices(){
    services.forEach((BluetoothService service){

    });
  }
  
  void startConnect(){

  }

  void _onConnect(bool isConnected){
    setState( () => _isConnected = isConnected);
  }

  void _whileConnected(){
      if( _isConnected){
        updateServices();
      }
  }

  void _attemptConnection() {
    setState(() {
      _counter++;
      Vibration.vibrate(duration: 1000);
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
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              _isConnected ? 'Device connected' : 'Device disconnected' ,
              style: Theme.of(context).textTheme.body1,
            ),
            Expanded(
              child: RaisedButton(child: Text("Connect To IP"),
              onPressed: ,
            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: vibrate,//_incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
