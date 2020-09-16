import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'nestedTabBarView.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:badges/badges.dart';
import 'package:highlighter_coachmark/highlighter_coachmark.dart';

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
      title: 'Heart Start Vet',
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1,
            boldText: false,
          ),
          child: child,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  double fraction = 0;
  double minPassed = 0;
  double secPassed = 0;
  double dispSec = 0;
  double _weightValue = 5;
  _checkForWeight() {
    if (globals.weightKG == null) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: AutoSizeText(
                'Select Weight',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    MaterialCommunityIcons.dog_side,
                    size: 20,
                  ),
                  Icon(MaterialCommunityIcons.dog_side, size: 30),
                  Icon(
                    MaterialCommunityIcons.dog_side,
                    size: 40,
                  ),
                ],
              ),
            ),
            Expanded(
                child: Slider(
              min: 0,
              max: 10,
              divisions: 10,
              value: _weightValue,
              label: weightOptions[_weightValue.round()],
              onChanged: (value) {
                setState(
                  () {
                    _weightValue = value;
                  },
                );
              },
            )),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  onPressed: () => {
                    setState(() {
                      globals.weightKG = weightkgOptions[_weightValue.round()];
                      globals.weightIndex = _weightValue.round();
                      _shockType = shockDoses[globals.weightIndex];
                      print('set weight to: ' +
                          weightkgOptions[_weightValue.round()].toString());
                      for (MedListItem item in medItems) {
                        item.buildSubtitle(context);
                      }
                    })
                  },
                  child: Text('DONE'),
                )
              ],
            )
          ],
        ),
      );
    }
    return Container();
  }

  Color barColor = Colors.red;
  CircularPercentIndicator cycle;
  IconData centerIcon = FlutterIcons.heart_ant;

  String inst = "Continue Compressions";
  DateTime lastSwitchedComp = DateTime.now();

  currentTime() {
    if (DateTime.now().difference(lastSwitchedComp).inMinutes >= 2) {
      compressorBadge = true;
    }

    if (minPassed < 10) {
      if (dispSec < 10) {
        globals.publicCodeTime = "0" +
            minPassed.toStringAsFixed(0) +
            " : 0" +
            dispSec.toStringAsFixed(0);
        return "0" +
            minPassed.toStringAsFixed(0) +
            " : 0" +
            dispSec.toStringAsFixed(0);
      }
      globals.publicCodeTime = "0" +
          minPassed.toStringAsFixed(0) +
          " : " +
          dispSec.toStringAsFixed(0);
      return "0" +
          minPassed.toStringAsFixed(0) +
          " : " +
          dispSec.toStringAsFixed(0);
    }
    if (dispSec < 10) {
      globals.publicCodeTime =
          minPassed.toStringAsFixed(0) + " : 0" + dispSec.toStringAsFixed(0);
      return minPassed.toStringAsFixed(0) + " : 0" + dispSec.toStringAsFixed(0);
    }
    globals.publicCodeTime =
        minPassed.toStringAsFixed(0) + " : " + dispSec.toStringAsFixed(0);

    return globals.publicCodeTime;
  }

  _triggerUpdate() {
    print('initializing timer');
    Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) => {
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

                  if (secPassed == 110) {
                    print('should open');
                    askForPulse = true;
                  }
                } else {
                  barColor = Colors.red;
                  inst = "Continue Compressions";
                  centerIcon = FlutterIcons.heart_ant;
                }
              }),
            });
  }

  List<String> shockDoses = [
    'EXTERNAL: 20J mono, 6J bi\nINTERNAL:l 2J mono, 1J bi',
    'EXTERNAL: 30J mono, 15J bi\nINTERNAL: 3J mono, 2J bi',
    'EXTERNAL: 50J mono, 30J bi\nINTERNAL: 5J mono, 3J bi',
    'EXTERNAL: 100J mono, 50J bi\nINTERNAL: 10J mono, 5J bi',
    'EXTERNAL: 200J mono, 75J bi\nINTERNAL: 20J mono, 6J bi',
    'EXTERNAL: 200J mono, 75J bi\nINTERNAL: 20J mono, 8J bi',
    'EXTERNAL: 200J mono, 100J bi\nINTERNAL: 20J mono, 9J bi',
    'EXTERNAL: 300J mono, 150J bi\nINTERNAL: 30J mono, 10J bi',
    'EXTERNAL: 300J mono, 150J bi\nINTERNAL: 30J mono, 15J bi',
    'EXTERNAL: 300J mono, 150J bi\nINTERNAL: 30J mono, 15J bi',
    'EXTERNAL: 360J mono, 150J bi\nINTERNAL: 50J mono, 15J bi',
  ];
  _selectedPulse(String selected) {
    Navigator.of(context).pop();
    setState(() {
      if (selected == "vtach" || selected == "svt") {
        showShock = true;
        _shockType = "SYNCRONIZED SHOCK DELIVERED";
      } else if (selected == "vfib" || selected == "tors") {
        showShock = true;
        if (globals.weightIndex != null) {
          _shockType = shockDoses[globals.weightIndex];
        }
      } else if (selected == "pulse") {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('kk:mm').format(now);
        String combined = "\n" + formattedDate + "\tCode Stopped";
        String full = combined.toString() + "\t" + currentTime();
        globals.log = globals.log + full;
        Navigator.push(context, PageTwo(""));
        askForPulse = false;
        nested.show = false;
      } else {
        askForPulse = false;
        nested.show = false;
      }
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('kk:mm').format(now);
      String combined = "\n" +
          formattedDate +
          "\tPulse check: " +
          selected.toString() +
          " identified";
      String full = combined.toString() + "\t" + currentTime();
      globals.log = globals.log + full;
    });
  }

  @override
  void initState() {
    nested = NestedTabBar(
      parent: this,
    );

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    globals.log = formattedDate + "\tCode Started\t00:00";
    globals.codeStart = now;
    super.initState();

    minPassed = 0;
    secPassed = 0;
    dispSec = 0;
    fraction = 0;

    _triggerUpdate();
    Future<void>.delayed(
        Duration(seconds: 1),
        () => {
              print('show coach'),
              showCoach(),
            });
  }

  bool compressorBadge = false;
  switchedCompressor() {
    compressorBadge = false;
    lastSwitchedComp = DateTime.now();
  }

  showCoach() {
    CoachMark coachMark = CoachMark();
    RenderBox target =
        GlobalObjectKey('timerCircle').currentContext.findRenderObject();
    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = Rect.fromCircle(
        center: markRect.center, radius: markRect.longestSide * 0.6);
    coachMark.show(
        targetContext: GlobalObjectKey('timerCircle').currentContext,
        markRect: markRect,
        children: [
          Positioned(
              top: markRect.bottom + 15.0,
              width: MediaQuery.of(context).size.width,
              child: Text("Time since code start",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ))),
        ],
        duration: null,
        onClose: () {});
  }

  @override
  Widget build(BuildContext context) {
    if (globals.reset) {
      print("reseting now");
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      globals.log = formattedDate + "\tCode Started\t00:00";
      minPassed = 0;
      secPassed = 0;
      dispSec = 0;
      fraction = 0;
      askForPulse = false;
      globals.reset = false;
    }
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
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Container(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              'Check Pulse Now?',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
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
                                    child: AutoSizeText(
                                      'GOT A PULSE',
                                      style: TextStyle(
                                        fontSize: 40,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    alignment: Alignment.center,
                                  ),
                                  onTap: () => {_selectedPulse('pulse')},
                                ),
                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  FontAwesome.close,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                              )),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    width: 1000,
                                                    child: Image.asset(
                                                      ('assets/pea.png'),
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Container(
                                                      width: 1000,
                                                      alignment:
                                                          Alignment.center,
                                                      child: AutoSizeText(
                                                        'PEA - no shock',
                                                        style: TextStyle(
                                                            fontSize: 40),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  onTap: () => {_selectedPulse('pea')},
                                ),
                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  FontAwesome.bolt,
                                                  size: 50,
                                                  color: Colors.red,
                                                ),
                                              )),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    width: 1000,
                                                    child: Image.asset(
                                                      ('assets/vfib.png'),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Container(
                                                      width: 1000,
                                                      alignment:
                                                          Alignment.center,
                                                      child: AutoSizeText(
                                                        'V FIB - SHOCK INDICATED',
                                                        style: TextStyle(
                                                            fontSize: 40),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  onTap: () => {_selectedPulse('vfib')},
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (showShock) {
      cP = Container(
        color: Colors.black54,
        child: Stack(
          children: [
            Column(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: AutoSizeText(
                        'Continue Compressions\nWhile Charging',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Row(
                    children: <Widget>[
                      deliveredShock(
                        onPressed: () => setState(() {
                          DateTime now = DateTime.now();
                          String formattedDate =
                              DateFormat('kk:mm').format(now);
                          String combined =
                              "\n" + formattedDate + "\tShock Delivered";
                          String full =
                              combined.toString() + "\t" + currentTime();
                          globals.log = globals.log + full;
                          print('Shock Delivered');
                          askForPulse = false;
                          nested.show = false;
                          showShock = false;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _checkForWeight()
          ],
        ),
      );
    }
    var pulseStack = <Widget>[
      nested,
      cP,
    ];
    var lowStack = <Widget>[nested];

    var temp = lowStack;
    if (nested.show != null) {
      if (nested.show) {
        askForPulse = true;
      }
    }
    if (askForPulse) {
      temp = pulseStack;
    }

    var full = Column(children: <Widget>[
      Badge(
        borderRadius: 10,
        showBadge: compressorBadge,
        badgeContent: Row(
          children: [
            Text('Switch compressors!', style: TextStyle(color: Colors.white)),
            IconButton(
              icon: Icon(
                FlutterIcons.x_circle_fea,
                color: Colors.white,
              ),
              onPressed: switchedCompressor,
            )
          ],
        ),
        shape: BadgeShape.square,
        position: BadgePosition.bottomRight(bottom: 50, right: 20),
        child: Container(
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
                  footer: Padding(
                    padding: EdgeInsets.all(5),
                    child: AutoSizeText(
                      inst,
                      style: new TextStyle(
                        fontSize: 40.0,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  center: Center(
                      child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(20.0),
                          children: <Widget>[
                        Icon(
                          centerIcon,
                          size: MediaQuery.of(context).size.width / 3,
                          color: barColor,
                        ),
                        Center(
                            child: new Text(
                          currentTime(),
                          key: GlobalObjectKey('timerCircle'),
                          style: new TextStyle(
                            fontSize: 40.0,
                          ),
                        )),
                      ])),
                  backgroundColor: Colors.grey,
                  progressColor: barColor,
                ),
              ]),
        ),
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
    ]);

    _launchURL() async {
      const url = 'https://recoverinitiative.org/';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

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
                  child: AutoSizeText(
                    'THIS IS INTENDED FOR TRAINING PURPOSES ONLY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 100,
                      color: Colors.red,
                    ),
                  ),
                ))),
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
                      child: AutoSizeText(
                        'Ensure code status for the patient by referencing chart ',
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
                        )),
                    Flexible(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: _launchURL,
                        child: Text('Open Source Information'),
                      ),
                    )
                  ],
                ))),
      ],
    );

    var fullStack = <Widget>[full];
    if (!warningDismissed) {
      fullStack = <Widget>[full, warning];
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
        children: fullStack,
      ),
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
              children: const <Widget>[
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(
                      MaterialCommunityIcons.pulse,
                      size: 400,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: FittedBox(
                      child: AutoSizeText(
                        "Yes\nCheck Pulse Now",
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          onPressed: onPressed,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}

class NoCeck extends StatelessWidget {
  NoCeck({@required this.onPressed});
  final GestureTapCallback onPressed;

  Widget build(BuildContext context) {
    return Expanded(
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
                        child: Icon(
                          MaterialCommunityIcons.stop_circle_outline,
                          size: 400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(0),
                        child: FittedBox(
                          child: AutoSizeText(
                            "No, Defer\nPulse Check",
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 60),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: onPressed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            )));
  }
}

class deliveredShock extends StatelessWidget {
  deliveredShock({@required this.onPressed});
  final GestureTapCallback onPressed;

  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.all(5),
            child: RawMaterialButton(
              fillColor: Colors.red,
              splashColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Icon(
                          FontAwesome.bolt,
                          size: 400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: AutoSizeText(
                        _shockType,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(color: Colors.white, fontSize: 60),
                      ),
                    ),
                  ],
                ),
              ),
              onPressed: onPressed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            )));
  }
}

var _shockType = " ";

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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: AutoSizeText(
                "UNDERSTOOD",
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: FittedBox(
                child: SpinKitPumpingHeart(
                  color: Colors.white,
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
