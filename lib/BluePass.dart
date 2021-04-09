

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert' show utf8;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BluePass extends StatefulWidget {
  const BluePass({
    Key key,
    this.startString,

  }) : super(key: key);

  final String startString;

  @override
  _BluePassState createState() => _BluePassState(startString: startString ?? '');
}
class _BluePassState extends State<BluePass> {
  _BluePassState({
    Key key,
    this.startString,
  });

  final String startString;
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  FlutterBlue flutterBlue;
  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';
  Color a = Colors.white;
  Color b = Colors.white;
  Color c = Colors.white;

  Future<void> _methodCallHandler(MethodCall call) async {
    print('INCOMING DATA!!!' + call.method.toString());

    setState(() {
      String t = call.method.toString();
      print(t.substring(0, 10) );
      if (t.length > 3) {
        if (t.substring(0, 3).contains( 'add' ) ){
          print('found add');
          recieved = recieved + t.substring(3);
        }else if (t.substring(0, 3).contains( 'new' ) ){
          print('found new');
          recieved = t.substring(3);
        }else if (t.substring(0, 3).contains( 'las' ) ){
          print('found last');
          recieved = recieved + t.substring(3);

          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
            title:  Text("Caught Some Data!"),
            content:  SingleChildScrollView(child: Text(recieved)),
            actions: [
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context ); },
                child: const Text('Something is wrong try again'),
              ),
              SimpleDialogOption(
                onPressed: () {

                  Navigator.pop(context, recieved);
                  Navigator.pop(context, recieved);


                },
                child: const Text('Looks good, import'),
              ),],);}
          );
        }else if (t.substring(0, 10).contains( 'set colors' ) ) {
          setColorFromString(t);

        }else{
          recieved = t;
        }
      }else{
        recieved = t;
      }

    });
  }

  setColorFromString(String t) {
    if (t.length < 13 ) {
      return 1;
    }
    final chars =  t.substring(12);
    int i = 0;
    print('++++++++ colors ' + chars);
    chars.characters.forEach((e) {
      String element = e.toString();
      Color alter = Colors.white;
      print('checking ' + element);
      if (element == 'r') {
        alter = Colors.red;
      }else if (element == 'o'){
        alter = Colors.orange;
      }else if (element == 'y'){
        alter = Colors.yellow;
      }else if (element == 'g'){
        alter = Colors.green;
      }else if (element == 'b'){
        alter = Colors.blue;
      }else if (element == 'v'){
        alter = Colors.purple;
      }else{
        print('didnt find color');
      }
      print(alter);
      if (i == 0) {
        a = alter;
      }else if (i ==1 ) {
        b = alter;
      }else{
        c = alter;
      }
      i++;
    });
    setState(() {

    });
  }



  TextEditingController sendController = TextEditingController();

  // ignore: must_call_super
  @override initState() {
    platform.setMethodCallHandler(_methodCallHandler);
    flutterBlue = FlutterBlue.instance;
    sendController.text = startString ?? "";

    setupServer();
    scanBLE();
    _getBatteryLevel();
  }
  setupServer() async {
    // final int result = await platform.invokeMethod('getBatteryLevel');
  }
  List<BluetoothDevice> devices = List<BluetoothDevice>();
  List<String> names = List<String>();
  scanBLE(){
    // Start scanning
    print("scanning");
    setState(() {
      scanning = true;
    });
    aimedDevice = null;
    aimedDeviceName = null;
    Fluttertoast.showToast(
        msg: "Looking around...",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.lightBlueAccent,
        textColor: Colors.white,
        fontSize: 16.0
    );
    setState(() {
      devices =  List<BluetoothDevice>();
      names = List<String>();
    });
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    Future.delayed(Duration(milliseconds: 250), () => {
    setState(() {
    devices =  List<BluetoothDevice>();
    names = List<String>();
    })
    });
    Future.delayed(Duration(seconds: 4), () => {
      print('stop scan'),
      setState(() {
        scanning = false;
      }),
    });
// Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {

        if (!devices.contains(r.device)) {
          if (r.device.name.contains(
              "a228b")) {
            print(r.device.name + "||" + r.device.id.id);
            setState(() {
              devices.add(r.device);
              names.add(r.device.name);
            });
          }else if (r.advertisementData.localName.contains(
              "a228b")) {
            print(r.device.id.id + "||" + r.advertisementData.localName);
            setState(() {
              devices.add(r.device);
              names.add(r.advertisementData.localName);
            });
          }
        }
      }
    });/**/


// Stop scanning
    flutterBlue.stopScan();
  }
  String aimedDeviceName = '';
  BluetoothDevice aimedDevice;
  double progress = 0.0;

  Color checkActive(BluetoothDevice a, BluetoothDevice b){
    if (a == b) {
      return Theme.of(context).accentColor;
    }
    return Colors.grey;
  }

  List<Widget> deviceTiles() {
    List<Widget> r = List<Widget>();
    devices.asMap().forEach((key, e) => r.add(GridTile(
      child: GestureDetector(
          child: Container(
            padding: EdgeInsets.all(15),
            child: Stack(
              children: [

                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: checkActive(e, aimedDevice),
                      shape: BoxShape.circle
                  ),

                  child: Center(child: Column(
                    children: [
                      Expanded(child: Container()),
                      Expanded(child: FittedBox(child: Text("Nearby Device", maxLines: 2, style: TextStyle(color: Colors.white),))),
                      Expanded(child: getColorRow( names[key].substring(5))),
                      Expanded(child: Container()),
                    ],
                  )),
                ),
                Column(
                  children: [
                    Expanded(
                      child: FittedBox(
                        child: CircularProgressIndicator(
                          value: progress,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          onTap: () async  => {setState(() => {
            if (aimedDeviceName != e.name) {
              aimedDeviceName = e.name,
              aimedDevice = e,

              print(aimedDevice.name + '||' + aimedDevice.id.id ),
            }else{
              aimedDeviceName = null,
              aimedDevice = null,
            }

          })}
      ),

    )));
    return r;
  }
  connectAndPrepare() async {
    if (aimedDevice != null) {
      BluetoothDevice e = aimedDevice;

      setState(() {
        progress = 0.1;
      });
      print('connecting to::::::' + e.name + '||' + e.id.id);
      if (Platform.isAndroid) {
        await e.disconnect();
        print('closing%%%%%');
      }
      await e.connect(timeout: Duration(seconds: 7), autoConnect: false, );
      e.mtu.listen((event) {print(event);});
      setState(() {
        progress = 0.2;
      });
      await e.discoverServices().then((value) => {
        value.forEach((element) {
          if (element.uuid.toString() == "a228b618-d7a0-4ec7-87a5-a7b4e6b865cf"){
            print('found service');
            element.characteristics.forEach((char) {
              print('found characteristic');
              if (char.uuid.toString() == "a228b618-d7a0-4ec7-87a5-a7b4e6b865cf"){
                passData(char);
              }
            });
          }
        })
      });
    }
  }
  passData(BluetoothCharacteristic characteristic) async {
    print('writing to char');

    if (sendController.text.length > 1) {
      final nob = sendController.text.toString();
      final a = utf8.encode(nob);
      int packetSize = 250;
      aimedDevice.mtu.forEach((element) { print("MTU" + element.toString());});
      if (a.length > 500) {

        int secs = (a.length ~/ 500);
        for (int i = 0; i <= secs; i++){
          print('passing ' + i.toString());
          if (i == 0) {
            await characteristic.write(utf8.encode('new') +
                a.sublist((i * 500), (i + 1) * 500), withoutResponse: false);
          }else if(i < secs){
            await characteristic.write(utf8.encode('add') +
                a.sublist((i * 500), (i + 1) * 500), withoutResponse: false);

          }else{
            await characteristic.write(utf8.encode('las') +
                a.sublist((i * 500)), withoutResponse: false);
          }
          setState(() {
            progress = (0.2 + (0.7 * i / secs));
          });
          // await Future.delayed(Duration(milliseconds: 700));
        }

      }else{
        await characteristic.write(utf8.encode('las') +
            a, withoutResponse: false);
      }
    } else {
      characteristic.write(
          utf8.encode('Testing sending stuffs'), withoutResponse: false);
    }
    setState(() {
      progress = 1.0;
    });
    Future.delayed(Duration(seconds: 5), () => {
      setState(() => {
        progress = 0.0,
      })
    });
  }

  Future<void> _getBatteryLevel() async {

    scanBLE();
    String batteryLevel;
    try {
      final String result = await platform.invokeMethod('getBatteryLevel');
      setColorFromString(result);
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }
    //
    // setState(() {
    //   _batteryLevel = batteryLevel;
    // });
  }

  Color sendButtonFill() {
    if (aimedDevice != null) {
      return Colors.red;
    }
    else{
      return Colors.grey;
    }
  }
  Color sendButtonSplash() {
    if (aimedDevice != null) {
      return Colors.red;
    }
    else{
      return Colors.grey;
    }
  }
  String recieved = '';
  bool scanning = false;
  Widget colorRow() {

    return Row(children: [
      Expanded(child: Container(decoration: BoxDecoration(color: a, border: Border.all(width: 2, color: Colors.grey), borderRadius: BorderRadius.circular(15)),)),
      Expanded(child: Container(decoration: BoxDecoration(color: b, border: Border.all(width: 2, color: Colors.grey), borderRadius: BorderRadius.circular(15)),)),
      Expanded(child: Container(decoration: BoxDecoration(color: c, border: Border.all(width: 2, color: Colors.grey), borderRadius: BorderRadius.circular(15)),))],);
  }
  Widget getColorRow(String a) {
    if (a.length == 3) {
      Color x;
      Color y;
      Color z;
      String chars = a;
      int i = 0;
      print('++++++++ colors ' + chars);
      chars.characters.forEach((e) {
        String element = e.toString();
        Color alter = Colors.white;
        print('checking ' + element);
        if (element == 'r') {
          alter = Colors.red;
        } else if (element == 'o') {
          alter = Colors.orange;
        } else if (element == 'y') {
          alter = Colors.yellow;
        } else if (element == 'g') {
          alter = Colors.green;
        } else if (element == 'b') {
          alter = Colors.blue;
        } else if (element == 'v') {
          alter = Colors.purple;
        } else {
          print('didnt find color');
        }
        print(alter);
        if (i == 0) {
          x = alter;
        } else if (i == 1) {
          y = alter;
        } else {
          z = alter;
        }
        i++;
      });

      return Row(children: [
        Expanded(child: Container(decoration: BoxDecoration(color: x,
            border: Border.all(width: 2, color: Colors.grey),
            borderRadius: BorderRadius.circular(15)),)),
        Expanded(child: Container(decoration: BoxDecoration(color: y,
            border: Border.all(width: 2, color: Colors.grey),
            borderRadius: BorderRadius.circular(15)),)),
        Expanded(child: Container(decoration: BoxDecoration(color: z,
            border: Border.all(width: 2, color: Colors.grey),
            borderRadius: BorderRadius.circular(15)),))
      ],);
    }else{
      return Container();
    }
  }

  Widget refreshOrNah() {
    if (scanning){
      return SpinKitChasingDots(color: Colors.blue,);
    }
    return ElevatedButton(
      child: Text('Refresh'),
      onPressed: _getBatteryLevel,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FlutterIcons.md_bluetooth_ion, color: Colors.blue,),
            Text('Blue-Pass '),
            Icon(FlutterIcons.handshake_faw5, color: Colors.red,)
          ],
        ),
        actions: [
          Column(

            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(flex: 2, child: FittedBox(child: Icon(FlutterIcons.lighthouse_on_mco, color: Colors.blue))),

              Expanded(
                child: Text(
                  "Beacon ON ",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              Expanded(child: Container(width: 100,child: colorRow()))
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Container(height: 150,
          padding: EdgeInsets.all(15),
          child: Center(
            child:

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                RawMaterialButton(
                  fillColor: sendButtonFill(),
                  splashColor: sendButtonSplash(),

                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children:  <Widget>[
                        FittedBox(child: Icon(FlutterIcons.handshake_faw5, color: Colors.white,)),
                        Text(
                          "Pass",
                          maxLines: 1,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () => {
                    connectAndPrepare(),
                  },
                  shape: const StadiumBorder(),
                ),
              ],
            ),
          ),
        ),

      ),
      body:  Material(
        child: Center(
          child: Column(

            children: [

              Container(
                color: Colors.black12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    refreshOrNah(),
                  ],
                ),
              ),
              Expanded(child: Container(
                color: Colors.black12,
                child: GridView.count(
                  crossAxisCount: 3,
                  children: deviceTiles(),
                ),
              )),
              Container(
                height: 70,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15) ),
                    color: Colors.blue
                ),
                child: Row(
                  children: [
                    Icon(FlutterIcons.arrow_up_ent, color: Colors.white,),
                    Expanded(
                      child: FittedBox(
                        child: Text('Pick a nearby device to pass data', style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    Icon(FlutterIcons.arrow_up_ent, color: Colors.white,),
                  ],
                ),
              ),
              Divider(),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: TextField(
                      keyboardType: TextInputType.text,
                      controller: sendController,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: 'Data to pass',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                          ),),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),),

            ],
          ),

        ),
      ),
    );
  }

}
