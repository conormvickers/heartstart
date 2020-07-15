import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'nestedTabBarView.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'dart:io';
import 'package:flutterheart/globals.dart' as globals;
//https://oblador.github.io/react-native-vector-icons/

void main() {
  runApp(MyApp());
}
var askForPulse = false;
var warningDismissed = false;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        primarySwatch: Colors.red,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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


class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {


  double fraction = 0;
  double minPassed = 0;
  double secPassed = 0;
  double dispSec = 0;
  Color barColor = Colors.red;
  CircularPercentIndicator cycle;
  IconData centerIcon = Icons.arrow_downward;

  String inst = "Continue Compressions";

  _currentTime() {
    if (minPassed < 10) {
      if (dispSec < 10) {
        return "0" + minPassed.toStringAsFixed(0) + " : 0" + dispSec.toStringAsFixed(0);

      }
      return "0" + minPassed.toStringAsFixed(0) + " : " + dispSec.toStringAsFixed(0);

    }
    if (dispSec < 10) {
      return minPassed.toStringAsFixed(0) + " : 0" + dispSec.toStringAsFixed(0);
    }
    return minPassed.toStringAsFixed(0) + " : " + dispSec.toStringAsFixed(0);
  }

  _triggerUpdate() {
    Timer.periodic(
        Duration(seconds: 1),
            (Timer timer) =>
            {
                setState(() {
                    secPassed++;
                    dispSec = secPassed;
                    if (secPassed == 60) {
                      minPassed++;
                    }
                    if (secPassed >= 120) {
                      secPassed = 0;
                      minPassed++;
                    }
                    if (secPassed >= 60) {
                      dispSec = secPassed - 60;

                    }
                    fraction = secPassed / 120;

                    if (secPassed >= 109) {
                      barColor = Colors.blueAccent;
                      inst = "Pulse Check";
                      centerIcon = Ionicons.ios_pulse;
                      print('pulse check time');
                      if (secPassed == 110){
                        print('should open');
                        askForPulse = true;
                      }
                    }else{
                      barColor = Colors.red;
                      inst = "Continue Compressions";
                      centerIcon = FontAwesome.angle_double_down;
                    }
                }),
            }
    );
  }
  var showingPulse = false;


  _selectedPulse(String selected) {
    Navigator.of(context).pop();
    showingPulse = false;
  }

  @override
  void initState() {
    super.initState();

    minPassed = 0;
    secPassed = 0;
    dispSec = 0;
    fraction = 0;
    _triggerUpdate();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    var cP = Container(
      color: Colors.black54,
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(15),
              child: Container(

                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Container(
                          child: AutoSizeText('Check Pulse Now?',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ]
                ),
              ),
            ),
          ),

          Flexible(
            flex: 2,
            child: Row(
              children: <Widget>[
                NoCeck(
                  onPressed: () => setState(() {
                    print('no pcheck');
                    askForPulse = false;
                    nested.show = false;
                  }),
                ),
                OpenPulseButton(
                  onPressed: () => setState(() {
                    print('yes pcheck');
                    askForPulse = false;
                    nested.show = false;
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          color: Colors.white,
                          child: ListView.builder(

                            itemCount: 1,

                            itemBuilder: (context, index) {
                            return Column(
                              children: <Widget>[
                                ListTile(
                                  title: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    height: 100,
                                    child: AutoSizeText('GOT A PULSE',
                                              style: TextStyle(
                                                  fontSize: 40,
                                              ),
                                            textAlign: TextAlign.center,
                                          ),
                                    alignment: Alignment.center,
                                  ),
                                  onTap: () => { _selectedPulse('pulse') },
                                ),
                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Icon(FontAwesome.close,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                              )
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    width: 1000,
                                                    child: Image.asset(('assets/pea.png'),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Container(
                                                      width: 1000,
                                                      alignment: Alignment.center,
                                                      child: AutoSizeText('PEA - no shock',
                                                        style: TextStyle(
                                                            fontSize: 40
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                  onTap: () => { _selectedPulse('pea') },
                                ),

                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Icon(FontAwesome.bolt,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                              )
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    width: 1000,
                                                    child: Image.asset(('assets/vfib.png'),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Container(
                                                      width: 1000,
                                                      alignment: Alignment.center,
                                                      child: AutoSizeText('V FIB - UNSYNCRONIZED SHOCK',
                                                        style: TextStyle(
                                                            fontSize: 40
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                  onTap: () => { _selectedPulse('pea') },
                                ),
                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Icon(FontAwesome.bolt,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                              )
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    width: 1000,
                                                    child: Image.asset(('assets/vtach.png'),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Container(
                                                      width: 1000,
                                                      alignment: Alignment.center,
                                                      child: AutoSizeText('V TACH - SYNCRONIZED SHOCK',
                                                        style: TextStyle(
                                                            fontSize: 40
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                  onTap: () => { _selectedPulse('vtach') },
                                ),
                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Icon(FontAwesome.bolt,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                              )
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    width: 1000,
                                                    child: Image.asset(('assets/tors.png'),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Container(
                                                      width: 1000,
                                                      alignment: Alignment.center,
                                                      child: AutoSizeText('Torsades de Pointes - UNSYNCRONIZED SHOCK + Magnesium',
                                                        style: TextStyle(
                                                            fontSize: 40
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                  onTap: () => { _selectedPulse('tors') },
                                ),
                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Icon(FontAwesome.bolt,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                              )
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    width: 1000,
                                                    child: Image.asset(('assets/svt.png'),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Container(
                                                      width: 1000,
                                                      alignment: Alignment.center,
                                                      child: AutoSizeText('Pulseless SVT - SYNCRONIZED SHOCK',
                                                        style: TextStyle(
                                                            fontSize: 40
                                                        ),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                  onTap: () => { _selectedPulse('svt') },
                                ),

                              ],
                            );},
                        ),),);
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var pulseStack = <Widget>[ nested, cP, ];
    var lowStack = <Widget>[nested];

    print([nested.show, askForPulse]);
    var temp = lowStack;
    if (nested.show != null){
      if (nested.show) {
        askForPulse = true;
      }
    }
    if (askForPulse) {
      temp = pulseStack;
    }
    var full = Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.width * 2 / 3 + 50,
            child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  cycle = CircularPercentIndicator(
                    radius: (MediaQuery.of(context).size.width * 2 / 3),
                    lineWidth: 10.0,
                    percent: fraction,
                    animation: true,
                    animationDuration: 1000,
                    animateFromLastPercent: true,
                    circularStrokeCap: CircularStrokeCap.round,
                    footer: new AutoSizeText(inst, style: new TextStyle(
                      fontSize: 40.0,
                    ),
                      maxLines: 1,

                    ),
                    center: Center(
                        child: ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(20.0),
                            children: <Widget>[
                              Icon(centerIcon,
                                size: MediaQuery.of(context).size.width / 3,
                                color: barColor,
                              ),

                              Center( child:
                              new Text(_currentTime(),
                                style: new TextStyle(
                                  fontSize: 40.0,

                                ),
                              )
                              ),
                            ]
                        )
                    ),
                    backgroundColor: Colors.grey,
                    progressColor: barColor,
                  ),

                ]),
          ),
          Divider(),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: temp,
              ),
            ),
          ),
        ]
    );
    var warning = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Container(
                alignment: Alignment.center,
                color: Colors.black87,
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: AutoSizeText('THIS IS INTENDED FOR TRAINING PURPOSES ONLY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 100,
                      color: Colors.red,

                    ),
                  ),
                )
            )
        ),
        Expanded(
            flex: 1,
            child: Container(
                alignment: Alignment.center,
                color: Colors.black87,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: AutoSizeText('Has the CODE STATUS been confirmed?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 100,
                          color: Colors.white,

                        ),
                      ),

                    ),
                    Flexible(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          alignment: Alignment.center,
                          child: goForCode(
                            onPressed: () => setState(() {
                              print('dismiss warning');
                              warningDismissed = true;
                            }),

                          ),
                        )
                    )

                  ],
                )
            )
        ),
      ],
    );
    if (showShock) {
      warning = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(

              child: AutoSizeText('CONTINUE COMPRESSIONS WHILE CHARGING')
          ),
        ],
      );

    }
    var fullStack = <Widget> [full];
    if (!warningDismissed) {
      fullStack = <Widget> [full, warning];
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0), // here the desired height
        child: AppBar(
            title: Text("Heart Start"),
          leading: Icon(FontAwesome.exclamation),
        ),
      ),

      body: Stack(
        children: fullStack,),


    );
  }
}
var nested = NestedTabBar();
var showShock = false;

class OpenPulseButton extends StatelessWidget {
  OpenPulseButton({@required this.onPressed});
  final GestureTapCallback onPressed;

  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: RawMaterialButton(
          fillColor: Colors.blue,
          splashColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: const <Widget>[
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(MaterialCommunityIcons.pulse,
                      size: 400,
                      color: Colors.white,),
                        ),
                ),
                Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    "Yes",
                    maxLines: 1,
                    style: TextStyle(color: Colors.white,
                        fontSize: 60
                    ),
                  ),
                ),

              ],
            ),
          ),
          onPressed: onPressed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
class NoCeck extends StatelessWidget {
  NoCeck({@required this.onPressed});
  final GestureTapCallback onPressed;

  Widget build(BuildContext context) {
    return Expanded (
      child: Padding(
        padding: EdgeInsets.all(15),
        child: RawMaterialButton(
        fillColor: Colors.red,
        splashColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: const <Widget>[
              Expanded(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Icon(MaterialCommunityIcons.stop_circle_outline,
                    size: 400,
                    color: Colors.white,),
                ),
              ),
              Expanded(
                child: AutoSizeText(
                  "No",
                  maxLines: 1,
                  style: TextStyle(color: Colors.white,
                      fontSize: 60
                  ),
                ),
              ),
            ],
          ),
        ),
        onPressed: onPressed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      )
      )
    );
  }
}
class goForCode extends StatelessWidget {
  goForCode({@required this.onPressed});
  final GestureTapCallback onPressed;

  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: Colors.red,
      splashColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Expanded(
              child: AutoSizeText(
                "Yes or Unknown",
                maxLines: 1,
                style: TextStyle(color: Colors.white,
                    fontSize: 60
                ),
              ),
            ),
          ],
        ),
      ),
      onPressed: onPressed,
      shape: const StadiumBorder(),
    );
  }
}
