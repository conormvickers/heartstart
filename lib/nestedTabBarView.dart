import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutterheart/chesttypes_icons.dart';
import 'package:flutterheart/main.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:customgauge/customgauge.dart';
import 'globals.dart' as globals;
import 'BluePass.dart' as bluepass;
import 'main.dart' as rootFile;
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:badges/badges.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:transparent_image/transparent_image.dart'
    show kTransparentImage;

class NestedTabBar extends StatefulWidget {
  var show = false;
  final pass;
  rootFile.MyHomePageState parent;

  NestedTabBar({Key key, this.show, this.pass, this.parent}) : super(key: key);

  @override
  NestedTabBarState createState() => NestedTabBarState(parent);
}

class _ListItem {
  _ListItem(this.value, this.checked);

  final String value;
  bool checked;
}

class InfoBit {
  InfoBit(this.stageName, this.value);

  final String stageName;

  String value;
}

class Entry {
  const Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

const List<Entry> data = <Entry>[
  Entry('Hypovolemia', <Entry>[
    Entry('Give Fluid'),
  ]),
  Entry('Hypoxia', <Entry>[
    Entry('Oxygen/intubation'),
  ]),
  Entry('Hydrogen ions (acidosis)', <Entry>[
    Entry('Give bicarb'),
  ]),
  Entry('Hyper/hypo kalemia', <Entry>[
    Entry('Check most recent labs, dialysis/replete'),
  ]),
  Entry('Hypothermmia', <Entry>[
    Entry('Bair hugger, warmed fluids'),
  ]),
  Entry('Toxins', <Entry>[
    Entry('Cocain, Digoxin, TCA, CCB, review medications review history'),
  ]),
  Entry('Tamponade (cardiac)', <Entry>[
    Entry('Pericardiocentesis, echocardiogram if uncertain, open chest CPR'),
  ]),
  Entry('Tension pneumothorax', <Entry>[
    Entry('Needle Thoracostomy 14-16 gauge needle, open chest CPR'),
  ]),
  Entry('Thrombosis', <Entry>[
    Entry('Consider PE and anticoagulation'),
  ]),
];
//"Hypovolemia", "Hypoxia", "Hydrogen ions (acidosis)",
//"Hyper/hypokalemia",
//"Hypothermia", "Toxins",
//"Tamponade (cardiac)", "Tension pneumothorax", "Thrombosis"
var tapLabel = '';
double _weightValue = 5;
List<double> weightkgOptions = [2.5, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
List<String> weightOptions = [
  "2.5kg\n5lbs",
  "5kg\n10lbs",
  "10kg\n20lbs",
  "15kg\n30lbs",
  "20kg\n40lbs",
  "25kg\n50lbs",
  "30kg\n60lbs",
  "35kg\n70lbs",
  "40kg\n80lbs",
  "45kg\n90lbs",
  "50kg\n100lbs"
];
final _medStrings = <String>[
  'Epinephrine Low',
  'Epinephrine High',
  'Vasopressin',
  'Atropine',
  'Amiodarone',
  'Lidocaine',
  'Naloxone (Reverse Opiods)',
  'Flumazenil (Reverse Benzodiazepines)',
  'Atipamezole (Reverse Alpha-2 Agonists)'
];
final _doses = <String>[
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
];
final epilow = <String>[
  '0.03',
  '0.05',
  '0.1',
  '0.15',
  '0.2',
  '0.25',
  '0.3',
  '0.35',
  '0.4',
  '0.45',
  '0.5'
];
final epihigh = <String>[
  '0.25',
  '0.5',
  '1',
  '1.5',
  '2',
  '2.5',
  '3',
  '3.5',
  '4',
  '4.5',
  '5'
];
final vaso = <String>[
  '0.1',
  '0.2',
  '0.4',
  '0.6',
  '0.8',
  '1',
  '1.2',
  '1.4',
  '1.6',
  '1.8',
  '2'
];
final atro = <String>[
  '0.25',
  '0.5',
  '1',
  '1.5',
  '2',
  '2.5',
  '3',
  '3.5',
  '4',
  '4.5',
  '5'
];
final amio = <String>[
  '0.25',
  '0.5',
  '1',
  '1.5',
  '2',
  '2.5',
  '3',
  '3.5',
  '4',
  '4.5',
  '5'
];
final lido = <String>[
  '0.25',
  '0.5',
  '1',
  '1.5',
  '2',
  '2.5',
  '3',
  '3.5',
  '4',
  '4.5',
  '5'
];
final nalo = <String>[
  '0.25',
  '0.5',
  '1',
  '1.5',
  '2',
  '2.5',
  '3',
  '3.5',
  '4',
  '4.5',
  '5'
];
final flum = <String>[
  '0.25',
  '0.5',
  '1',
  '1.5',
  '2',
  '2.5',
  '3',
  '3.5',
  '4',
  '4.5',
  '5'
];
final atip = <String>[
  '0.03',
  '0.05',
  '0.1',
  '0.15',
  '0.2',
  '0.25',
  '0.3',
  '0.35',
  '0.4',
  '0.45',
  '0.5'
];
List<List<String>> mlPerDose = [
  epilow,
  epihigh,
  vaso,
  atro,
  amio,
  lido,
  nalo,
  flum,
  atip
];
final mgPerKg = <String>[
  '0.01 mg/kg',
  '0.1 mg/kg',
  '0.8 U/kg',
  '0.05 mg/kg',
  '5 mg/kg',
  '2-8 mg/kg',
  '0.04 mg/kg',
  '0.01 mg/kg',
  '50 ug/kg',
  '',
  '',
  ''
];
var timesGiven = <int>[
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
];
var _lastGiven = <DateTime>[
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
  DateTime.now(),
];
bool needBadge = false;
bool twominbadge = false;
bool tenminbadge = false;
final medItems = List<MedListItem>.generate(_medStrings.length, (i) {
  return MedMessageItem(_medStrings[i], _doses[i],
      'last given' + _lastGiven[i].toString() + 'min ago');
});

abstract class MedListItem {
  /// The title line to show in a list item.
  Widget buildTitle(BuildContext context);

  /// The subtitle line, if any, to show in a list item.
  Widget buildSubtitle(BuildContext context);

  Widget buildTrailing(BuildContext context);
}

class MedMessageItem implements MedListItem {
  final String sender;
  final String body;
  final String trailing;

  MedMessageItem(this.sender, this.body, this.trailing);

  Widget buildTitle(BuildContext context) => Text(sender);

  Widget buildSubtitle(BuildContext context) => Text(body);

  Widget buildTrailing(BuildContext context) => Text(trailing);
}

class NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  TabController nestedTabController;
  TabController chestTypeController;
  MyHomePageState parent;

  NestedTabBarState(this.parent);

  int breathingValue = 0;
  int breathSeconds = 0;
  var tapTimes = <DateTime>[];
  var tapDifs = <int>[];
  var perc1 = 0.0;
  var perc2 = 0.0;
  var perc3 = 0.0;
  var anim1 = true;
  var anim2 = true;
  var anim3 = true;
  double speed = 0;
  Timer tapResetTimer;
  static final _citems = <String>[
    'IV Access',
    'Monitor',
    'Oxygen',
    'Intubation',
    'Capnography',
    'Consider Anesthesia Reversal (Naloxone)'
  ].map((item) => _ListItem(item, false)).toList();
  List<String> chestTypes = ['round', 'keel', 'flat'];
  List<IconData> chestIcons = [
    Chesttypes.flat,
    Chesttypes.keel,
    Chesttypes.round,
  ];

  resetEverything() {
    print('reseting everything from nested tab bar');
    for (_ListItem l in _citems) {
      l.checked = false;
    }
    parent.centerIcon = FlutterIcons.heart_ant;
    globals.weightKG = null;
    globals.chest = null;
    timesGiven = <int>[
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ];
    _lastGiven = <DateTime>[
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
      DateTime.now(),
    ];
  }

  @override
  void initState() {
    super.initState();

    nestedTabController = new TabController(length: 4, vsync: this);
    chestTypeController = TabController(
      length: 3,
      vsync: this,
    );

    Timer.periodic(
        Duration(milliseconds: 1000),
        (Timer timer) => {
              setState(() {
                resetBreathingTimer();

                if (int.parse(globals.publicCodeTime.substring(0, 2)) >= 2) {
                  if (!twominbadge) {
                    twominbadge = true;
                    needBadge = true;
                    print('badge needed');
                  }
                }
                if (int.parse(globals.publicCodeTime.substring(0, 2)) >= 10) {
                  if (!tenminbadge) {
                    tenminbadge = true;
                    needBadge = true;
                    print('10 min badge needed');
                  }
                }
              })
            });
  }

  breathingBar() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: FAProgressBar(
                    direction: Axis.vertical,
                    progressColor: Theme.of(context).accentColor,
                    verticalDirection: VerticalDirection.up,
                    currentValue: breathingValue,
                    animatedDuration: Duration(milliseconds: 1000),
                    borderRadius: 0,
                  ),
                ),
                Expanded(
                  child: FAProgressBar(
                    direction: Axis.vertical,
                    progressColor: Theme.of(context).accentColor,
                    verticalDirection: VerticalDirection.down,
                    currentValue: breathingValue,
                    animatedDuration: Duration(milliseconds: 1000),
                    borderRadius: 0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                Container(alignment: Alignment.center, child: Text('Breaths')),
          )
        ],
      ),
    );
  }

  resetBreathingTimer() {
    if (breathSeconds == 0) {
      breathSeconds++;
      breathingValue = 100;
    } else if (breathSeconds >= 5) {
      breathSeconds = 0;
      breathingValue = 0;
    } else {
      breathSeconds++;
      breathingValue = 100 - (breathSeconds * 15);
    }
  }

  @override
  void dispose() {
    super.dispose();
    nestedTabController.dispose();
  }

  _launchURL() async {
    const url = 'https://recoverinitiative.org/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _handleTap() {
    tapTimes.add(DateTime.now());
    if (tapTimes.length > 4) {
      tapTimes.removeAt(0);
    }

    if (tapTimes.length >= 2) {
      DateTime a;
      tapDifs = [];

      tapTimes.forEach((element) => {
            if (tapTimes.indexOf(element) < tapTimes.length - 1)
              {
                a = tapTimes[tapTimes.indexOf(element) + 1],
                tapDifs.add(a.difference(element).inMilliseconds),
              }
          });

      print(tapDifs);
      double ave = (tapDifs.reduce((value, element) => value + element) /
          tapDifs.length);
      print(ave);
      setState(() {
        tapLabel = (60000 / ave).toStringAsFixed(0) + " /min";
      });
      speed = 60000 / ave;
      print(speed);
      if (speed < 100) {
        perc1 = (speed - 60) / 40;
        if (perc1 < 0) {
          perc1 = 0;
        }
        perc2 = 0;
        perc3 = 0;
        anim1 = true;
        anim2 = true;
        anim3 = true;
      } else if (speed > 120) {
        perc3 = (speed - 120) / 40;
        if (perc3 > 1) {
          perc3 = 1;
        }
        perc2 = 1;
        perc1 = 1;
        anim1 = false;
        anim2 = false;
        anim3 = true;
      } else {
        perc2 = (speed - 100) / 20;

        perc1 = 1;
        perc3 = 0;
        anim1 = false;
        anim2 = true;
        anim3 = false;
      }
    }
    if (tapResetTimer != null) {
      tapResetTimer.cancel();
    }

    tapResetTimer = new Timer(
        Duration(seconds: 3),
        () => {
              print('resetting tap timer'),
              _resetTapper(),
            });
  }

  _resetTapper() {
    anim1 = false;
    anim2 = false;
    anim3 = false;
    tapTimes = [];
    setState(() {
      tapLabel = '';
      speed = 0;
    });
    perc1 = 0.0;
    perc2 = 0.0;
    perc3 = 0.0;
  }

  _giveMed(int index) {
    //print('global code time' + globals.publicCodeTime);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm').format(now);
    String combined =
        "\n" + formattedDate + "\t" + _medStrings[index].toString();
    String full = combined.toString() + ' ' + mgPerKg[index];
    globals.log = globals.log + full;
    setState(() => {
          _lastGiven[index] = DateTime.now(),
          timesGiven[index]++,
        });
  }

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
                flex: 1,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: FittedBox(
                        child: Text(
                          'Weight',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    VerticalDivider(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Container()),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Icon(
                                    MaterialCommunityIcons.dog_side,
                                  ),
                                ),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.lightBlue,
                          inactiveTrackColor: Colors.grey,
                          // trackShape: RoundedRectSliderTrackShape(),
                          trackHeight: 4.0,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          thumbColor: Colors.lightBlue,
                          overlayColor: Colors.blue,
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                          tickMarkShape: RoundSliderTickMarkShape(),
                          activeTickMarkColor: Colors.white,
                          inactiveTickMarkColor: Colors.white,
                          valueIndicatorShape:
                              RectangularSliderValueIndicatorShape(), //PaddleSliderValueIndicatorShape(),
                          valueIndicatorColor: Colors.red,
                          valueIndicatorTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
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
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Icon(
                                MaterialCommunityIcons.dog_side,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: FittedBox(
                      child: Text(
                        'Chest',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  VerticalDivider(),
                  Expanded(
                    child: TabBar(
                      controller: chestTypeController,
                      tabs: [
                        Tab(
                          child: Text(chestTypes[0]),
                        ),
                        Tab(child: Text(chestTypes[1])),
                        Tab(
                          child: Text(chestTypes[2]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ButtonBar(
                alignment: MainAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: () => {
                      setState(() {
                        globals.weightKG =
                            weightkgOptions[_weightValue.round()];
                        globals.weightIndex = _weightValue.round();
                        globals.chest = chestTypes[chestTypeController.index];
                        parent.setState(() {
                          parent.centerIcon =
                              chestIcons[chestTypeController.index];
                          parent.chestIcon =
                              chestIcons[chestTypeController.index];
                        });
                        print('set weight to: ' +
                            weightkgOptions[_weightValue.round()].toString());
                        for (MedListItem item in medItems) {
                          item.buildSubtitle(context);
                        }
                        parent.setState(() {});
                      })
                    },
                    child: Text('DONE'),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }
    return Container();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    // print("current log:" + globals.log);

    List<Widget> _listTiles = _citems
        .map((item) => CheckboxListTile(
              key: Key(item.value),
              value: item.checked ?? false,
              onChanged: (bool newValue) {
                setState(() => item.checked = newValue);
                if (newValue == true) {
                  if (item.value == 'Consider Anesthesia Reversal (Naloxone)') {
                    print("don't add to log");
                  } else {
                    DateTime now = DateTime.now();
                    String formattedDate = DateFormat('kk:mm').format(now);
                    globals.log =
                        globals.log + '\n' + formattedDate + '\t' + item.value;
                  }
                }
              },
              title: Text('${item.value}'),
            ))
        .toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TabBar(
          controller: nestedTabController,
          indicatorColor: Theme.of(context).accentColor,
          labelColor: Theme.of(context).accentColor,
          unselectedLabelColor: Colors.black54,
          isScrollable: true,
          onTap: (index) {
            print(index);
            if (index == 1) {
              setState(() {
                print('remove badge');
                needBadge = false;
              });
            }
          },
          tabs: <Widget>[
            Tab(
              icon: Icon(
                MaterialCommunityIcons.format_list_checks,
                key: GlobalObjectKey('tab1'),
              ),
            ),
            Tab(
              icon: Badge(
                  showBadge: false,
                  badgeContent: Text('!'),
                  badgeColor: Theme.of(context).accentColor,
                  child: Icon(
                    FlutterIcons.medicinebox_ant,
                    key: GlobalObjectKey('tab2'),
                  )),
            ),
            Tab(
              icon: Icon(
                MaterialCommunityIcons.metronome,
                key: GlobalObjectKey('tab3'),
              ),
            ),
            Tab(
              icon: Icon(
                AntDesign.questioncircleo,
                key: GlobalObjectKey('tab4'),
              ),
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: TabBarView(
              controller: nestedTabController,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.black12,
                    ),
                    child: ListView(
                      children: _listTiles,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.black12,
                    ),
                    child: Stack(
                      children: [
                        ListView.builder(
                          // Let the ListView know how many items it needs to build.
                          itemCount: medItems.length,
                          // Provide a builder function. This is where the magic happens.
                          // Convert each item into a widget based on the type of item it is.
                          itemBuilder: (context, index) {
                            final item = medItems[index];
                            var tx = Text('');
                            var color = Colors.transparent;
                            var waitTime = 2;
                            var longTime = 10;
                            // if (globals.codeStart
                            //         .difference(DateTime.now())
                            //         .inMinutes
                            //         .abs() >
                            //     9) {
                            //   longTime = 3;
                            // }
                            // if (timesGiven[index] != 0) {
                            //   waitTime = 3;
                            // }
                            final dif = DateTime.now()
                                .difference(_lastGiven[index])
                                .inMinutes
                                .toString();
                            // if (int.parse(dif) >= waitTime) {
                            //   if (index != 1) {
                            //     color = Colors.transparent;
                            //     tx = Text('');
                            //   } else {
                            //     if (int.parse(dif) >= longTime) {
                            //       color = Colors.transparent;
                            //       tx = Text('');
                            //     }
                            //   }
                            // }
                            if (timesGiven[index] != 0) {
                              tx = Text(
                                'given ' +
                                    timesGiven[index].toString() +
                                    ' doses\nlast given ' +
                                    dif +
                                    ' min ago',
                              );
                            }
                            if (globals.weightIndex != null) {
                              _doses[index] = mlPerDose[index]
                                      [globals.weightIndex] +
                                  'mL DOSE' +
                                  " (" +
                                  mgPerKg[index] +
                                  ")";
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                title: item.buildTitle(context),
                                subtitle: Text(_doses[index]),
                                trailing: tx,
                                onTap: () {
                                  print("med index tapped:" + index.toString());
                                  _giveMed(index);
                                },
                              ),
                            );
                          },
                        ),
                        _checkForWeight()
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: new LayoutBuilder(builder:
                              (BuildContext context,
                                  BoxConstraints constraints) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: CustomGauge(
                                      gaugeSize: constraints.maxHeight,
                                      //MediaQuery.of(context).size.width * 2 / 5 ,
                                      maxValue: 170,
                                      minValue: 50,
                                      showMarkers: false,
                                      valueWidget: Container(),
                                      segments: [
                                        GaugeSegment('Low', 50,
                                            Theme.of(context).splashColor),
                                        GaugeSegment(
                                            'Medium', 20, Colors.white),
                                        GaugeSegment('High', 50,
                                            Theme.of(context).splashColor),
                                      ],
                                      currentValue: speed,
                                      displayWidget: Text(tapLabel,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 20,
                                          )),
                                    ),
                                  ),
                                ),
                                Expanded(child: breathingBar()),
                              ],
                            );
                          }),
                        ),
                        Flexible(
                          flex: 1,
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).splashColor,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: AutoSizeText(
                                  'Tap With Compressions',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 40),
                                  maxLines: 1,
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _handleTap, // handle your onTap here
                                  child: Container(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.black12,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16),
                  child: Container(
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) =>
                          EntryItem(data[index]),
                      itemCount: data.length,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.black12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

class PageTwo extends StatefulWidget {
  PageTwo({Key key}) : super(key: key);
  @override
  PageTwoState createState() => PageTwoState();
}

StateSetter stateSetter;
final Disease = <String>{
  'Medical cardiac or non-cardiac',
  'Surgical elective or emergency',
  'Trauma',
  'DOA',
  'Unknown'
}.map((e) => _ListItem(e, false)).toList();
final Location = <String>{
  'Out of hospital',
  'Emergency Room',
  "Intensive Care Unit",
  "Wards",
  "Anesthesia or Surgery",
  "Consult Room",
  "Diagnostic Procedures Area",
  "Waiting Room",
  "Other"
}.map((e) => _ListItem(e, false)).toList();
final ComorbidConditions = <String>{
  "Arrhythmia",
  "Sepsis",
  "Congestive Heart Failure (prior admit)",
  "Congestive Heart Failure (this admit)",
  "Infectious disease",
  "Diabetes mellitus",
  "Metabolic/electrolyte abnormality",
  "Pericardial effusion/tamponade",
  'Hypotension/Hypoperfusion',
  "Malignancy",
  "Respiratory insufficiency",
  "Major trauma",
  "Pneumonia",
  "Envenomation",
  'Renal insufficiency',
  "Post-operative",
  "Hepatic insufficiency",
  "Coagulopathy",
  "CNS disease",
  "None",
  "SIRS",
  "Unknown",
  "IMHA/ITP"
}.map((e) => _ListItem(e, false)).toList();
final SuspectedCause = <String>{
  "Non-perfusing rhythm",
  "Sepsis/Septic shock",
  "Respiratory failure",
  "CNS disease",
  "Heart failure",
  "MODS",
  "Truama",
  "Metabolic/Electrolyte",
  "Hemorrhage",
  "Toxicosis/Overdose",
  "Hypovolemia (non-hemorrhagic",
  "Thromboembolic disease",
  "Unknown",
  "Other"
}.map((e) => _ListItem(e, false)).toList();
final PreviousCPA = <String>{
  'No',
  'Yes once',
  'Yes twice',
  'Yes three times',
  'Yes four times',
  'Yes five or more times',
}.map((e) => _ListItem(e, false)).toList();
final PreviousMeasures = <String>{
  'Venous access, peripheral',
  'Venous access central',
  'Tracheal intubation',
  'ECG monitoring',
  'Arterial catheterization'
}.map((e) => _ListItem(e, false)).toList();
final GeneralAnesthesia = <String>{
  "General Anesthesia at time of CPA",
  "Induction",
  "Recovery",
  "Procedural"
}.map((e) => _ListItem(e, false)).toList();
final MechanicalVentilation = <String>{
  "Mechanical Ventilation at time of CPA",
}.map((e) => _ListItem(e, false)).toList();
final ROSC = <String>{
  'ROSC achieved',
  'Extubated after ROSC',
}.map((e) => _ListItem(e, false)).toList();
final ROSCDuration = <String>{'>20 min', '>24 hours', '>30 days'}
    .map((e) => _ListItem(e, false))
    .toList();
final Euthanasia = <String>{
  "Euthenasia performed",
  "Severity of illness",
  "Terminal illness",
  "Economic reasons"
}.map((e) => _ListItem(e, false)).toList();
final Rearrest = <String>{
  "Re-arrest without CPR",
  "Re-arrest w/ CPR, but without sustained ROSC",
}.map((e) => _ListItem(e, false)).toList();
final Outcome = <String>{
  "Hospital Discharge",
  "In-hospital Death",
}.map((e) => _ListItem(e, false)).toList();
List<String> partNames = [
  'Disease category at admission:',
  'Location of CPA:',
  'Comorbid conditions:',
  'Suspected cause:',
  'Previous CPA:',
  'Measures in place:',
  'Anesthesia:',
  'Ventilation:',
  'ROSC:',
  'ROSC duration:',
  'Euthanasia:',
  'Rearrest:',
  'Outcome:'
];

class PageTwoState extends State<PageTwo> {
  List<Widget> timelineTiles = [];
  List<String> eventSplit = globals.log.split('\n');
  int timelineEditing = null;
  TextEditingController timelineEditingController = TextEditingController();
  pw.Document pdf;
  Directory appDocDir;
  String appDocPath;
  TextEditingController infoController = TextEditingController();
  ScrollController timelineController = ScrollController();
  bool editing = false;
  TextEditingController finalController = TextEditingController();
  String currentDocPath = 'Auto_Save';
  List<String> savedFileString = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget> fileTiles = List<Widget>();
  List<String> previousLogs = List<String>();
  int currentHistoryIndex = 0;
  FocusNode focusEdit = FocusNode();
  int initTabIndex = 1;
  List<List<_ListItem>> surveyParts = List<List<_ListItem>>();
  List<InfoBit> infoBits = [
    'Event date',
    'Doctor',
    'Patient name',
    'MRN',
    'Client name',
    'Sex',
    'Date of birth',
    'Weight',
    'Chest',
    'Breed'
  ].map((e) => InfoBit(e, '')).toList();

  List<String> codeNameRef;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print('saving file...');
      saveGlobalLog();
    }
  }

  @override
  void initState() {
    focusEdit.addListener(() {
      if (focusEdit.hasFocus) {
        timelineEditingController.selection = TextSelection(
            baseOffset: 0, extentOffset: timelineEditingController.text.length);
      }
    });
    surveyParts = [
      Disease,
      Location,
      ComorbidConditions,
      SuspectedCause,
      PreviousCPA,
      PreviousMeasures,
      GeneralAnesthesia,
      MechanicalVentilation,
      ROSC,
      ROSCDuration,
      Euthanasia,
      Rearrest,
      Outcome
    ];

    setup();
    loadPref();
  }

  loadPref() async {
    var prefs = await SharedPreferences.getInstance();
    doctorController.text = prefs.getString('doctor') ?? '';
  }

  setup() {
    if (globals.ignoreCurrentLog) {
      initTabIndex = 0;
      globals.ignoreCurrentLog = false;
      loadLastFile();
    } else {
      asyncSetup();
    }
  }

  loadLastFile() async {
    print('ignore flag found');
    await updateDirectory();
    if (savedFileString.length > 0) {
      await loadFile(savedFileString[0]);
    }
  }

  asyncSetup() async {
    await updateName();
    await globalToInfo();
    await updateTimeline();
    await updateSurvey(true, false);
    await saveGlobalLog();
    updateDirectory();
  }

  Future<void> makeSure(String ask, Function function) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Just checking'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to'),
                Text(ask),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                function();
              },
            ),
          ],
        );
      },
    );
  }

  askRearrest() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Re-Arrest'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Did the SAME PATIENT arrest again?'),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('Nevermind',
                          style: TextStyle(color: Colors.grey)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ))),
                                child: Text('YES',
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  print('reset hit');
                                  Navigator.pop(context, 'false');
                                },
                              ),
                            ),
                          ],
                        ),
                        Container(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ))),
                                child: Column(
                                  children: [
                                    Text('NO',
                                        style: TextStyle(color: Colors.white)),
                                    Text('new patient',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 10))
                                  ],
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  print('rearrest hit');
                                  Navigator.pop(context, 'true');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _simplePopup(int i) => PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Text("Delete"),
          ),
          PopupMenuItem(
            value: 2,
            child: Text("Add"),
          ),
        ],
        onSelected: (int s) => {
          print(s),
          if (s == 1)
            {
              makeSure(
                  'delete this item?',
                  () => {
                        setState(() => {
                              eventSplit.removeAt(i),
                              globals.log = eventSplit.join('\n'),
                              print(globals.log),
                              timelineEditing = null,
                              FocusScope.of(context).unfocus(),
                              updateTimeline(),
                              updateTextField(),
                              puntAutosave(),
                              updateHistory(),
                            })
                      })
            }
          else
            {
              setState(() => {
                    eventSplit.insert(i, 'unknown event'),
                    globals.log = eventSplit.join('\n'),
                    print(globals.log),
                    timelineEditing = null,
                    FocusScope.of(context).unfocus(),
                    updateTimeline(),
                    updateTextField(),
                    puntAutosave(),
                    updateHistory()
                  })
            }
        },
      );

  editTimeline(int i) {
    setState(() {
      timelineEditing = i;
    });
  }

  sendData() async {
    String log = '';
    if (finalController.text != null) {
      log = finalController.text + '\n';
    }
    //
    // log = log.replaceAll(',', '');
    // log = log.replaceAll("'", '');

    pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Text(
            log,
          )); // Center
        })); //

    if (kIsWeb) {
      return;
    }
    appDocDir = await getApplicationDocumentsDirectory();

    DateTime now = DateTime.now();
    String date = DateFormat('yyyy_MM_dd').format(now);

    final file = File("${appDocDir.path}/" + date + "log.pdf");
    await file.writeAsBytes(pdf.save());

    Share.shareFiles(['${appDocDir.path}/' + date + 'log.pdf'],
        text: 'PDF log');
  }

  sendText() async {
    if (kIsWeb) {
      return;
    }
    appDocDir = await getApplicationDocumentsDirectory();

    final file = File("${appDocDir.path}/" + "temp_log.txt");
    String log = '';
    if (finalController.text != null) {
      log = finalController.text + '\n';
    }

    await file.writeAsString(log);

    Share.shareFiles(["${appDocDir.path}/" + "temp_log.txt"], text: "TXT log");
  }

  onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final String item = eventSplit.removeAt(oldIndex);
      eventSplit.insert(newIndex, item);
      globals.log = eventSplit.join('\n');
    });
    updateTimeline();
    updateTextField();
    updateHistory();
    puntAutosave();
  }

  updateTimeline() {
    setState(() {
      print('updating drawer');
      eventSplit = globals.log.split('\n');
      timelineTiles = List<Widget>();
      for (int i = 0; i < eventSplit.length; i++) {
        if (eventSplit[i] != '') {
          bool first = false;
          bool last = false;
          bool dot = true;
          IconData icon = Icons.arrow_downward;
          double iconSize = 20;
          double height = 50;
          String rest = eventSplit[i];

          if (i == 0) {
            first = true;

            rest = eventSplit[i];
          }
          if (i == eventSplit.length - 1) {
            last = true;
          }
          for (String string in ['Pulse', 'Shock', 'Code']) {
            if (eventSplit[i].contains(string)) {
              icon = Icons.access_alarm;
              iconSize = 40;
              height = 120;
            }
          }
          for (String string in [
            'Epinephrine Low',
            'Epinephrine High',
            'Vasopressin',
            'Atropine',
            'Amiodarone',
            'Lidocaine',
            'Naloxone (Reverse Opiods)',
            'Flumazenil (Reverse Benzodiazepines)',
            'Atipamezole (Reverse Alpha-2 Agonists)'
          ]) {
            if (eventSplit[i].contains(string)) {
              icon = Icons.medical_services;
            }
          }
          for (String string in [
            'IV Access',
            'Monitor',
            'Oxygen',
            'Intubation',
            'Capnography',
          ]) {
            if (eventSplit[i].contains(string)) {
              icon = Icons.check;
            }
          }
          Widget endChild = Text(rest);
          if (i == timelineEditing) {
            TextField txt = TextField(
              maxLines: null,
              focusNode: focusEdit,
              keyboardType: TextInputType.text,
              controller: timelineEditingController,
              onEditingComplete: () => {
                setState(() => {
                      eventSplit[i] = timelineEditingController.text,
                      globals.log = eventSplit.join('\n'),
                      print(globals.log),
                      timelineEditing = null,
                      FocusScope.of(context).unfocus(),
                      updateTimeline(),
                      updateTextField(),
                      puntAutosave(),
                      updateHistory()
                    })
              },
            );

            endChild = Container(
              child: Row(
                children: [Expanded(child: txt)],
              ),
            );
          }
          TimelineTile add = TimelineTile(
            key: Key(i.toString() + rest),
            alignment: TimelineAlign.manual,
            lineXY: 0.1,
            startChild: Container(
              height: height,
            ),
            endChild: Container(
              color: Colors.white,
              height: height,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    print('tapped' + i.toString());
                    timelineEditingController.text = eventSplit[i];
                    editTimeline(i);
                    updateTimeline();
                  });
                },
                child: Row(
                  children: [Expanded(child: endChild), _simplePopup(i)],
                ),
              ),
            ),
            isFirst: first,
            isLast: last,
            hasIndicator: dot,
            indicatorStyle: IndicatorStyle(
                width: iconSize,
                color: Colors.lightBlue,
                padding: EdgeInsets.all(8),
                iconStyle: IconStyle(
                  iconData: icon,
                  color: Colors.white,
                )),
          );
          timelineTiles.add(add);
        }
      }
      focusEdit.requestFocus();
    });
  }

  Widget closeButton() {
    if (editing) {
      return TextButton(
        child: Text(
          'done',
          style: TextStyle(color: Colors.lightBlue),
        ),
        onPressed: () => {
          parseData(finalController.text),
          saveGlobalLog(),
          editing = false,
          FocusScope.of(context).unfocus(),
        },
      );
    }
    return Container();
  }

  List<Widget> undoButtons() {
    List<Widget> r = List<Widget>();

    if (previousLogs.length > 1 &&
        currentHistoryIndex < previousLogs.length - 1) {
      r.add(
        IconButton(
          icon: Icon(FlutterIcons.undo_alt_faw5s, size: 15),
          onPressed: () => {
            if (currentHistoryIndex < previousLogs.length - 1)
              {
                currentHistoryIndex++,
              },
            print('increasing index now on ' +
                currentHistoryIndex.toString() +
                'out of ' +
                previousLogs.length.toString()),
            parseData(previousLogs[currentHistoryIndex]),
            puntAutosave(),
          },
        ),
      );
    } else {
      r.add(
        IconButton(
          icon: Icon(FlutterIcons.undo_alt_faw5s, size: 15),
        ),
      );
    }
    if (currentHistoryIndex > 0) {
      r.add(
        IconButton(
          icon: Icon(FlutterIcons.redo_alt_faw5s, size: 15),
          onPressed: () => {
            if (currentHistoryIndex > 0)
              {
                currentHistoryIndex--,
              },
            print('now on ' +
                currentHistoryIndex.toString() +
                'out of ' +
                previousLogs.length.toString()),
            parseData(previousLogs[currentHistoryIndex]),
            puntAutosave(),
          },
        ),
      );
    } else {
      r.add(
        IconButton(
          icon: Icon(FlutterIcons.redo_alt_faw5s, size: 15),
        ),
      );
    }

    return r;
  }

  updateTextField() {
    setState(() {
      finalController.text =
          globals.log + '\n\n-Case Information-\n\n' + globals.survey;
    });
  }

  updateHistory() {
    String full = finalController.text;

    if (currentHistoryIndex > 0) {
      previousLogs.removeRange(0, currentHistoryIndex);
      currentHistoryIndex = 0;
    }
    if (previousLogs.length > 0) {
      if (previousLogs[0] != full) {
        previousLogs.insert(0, full);
      } else {
        print('not added, the same');
      }
    } else {
      previousLogs.add(full);
    }
  }

  saveGlobalLog() {
    updateTextField();
    String full = finalController.text;
    print('starting save...');
    saveFile(full);
  }

  saveFile(String string) async {
    if (kIsWeb) {
      return;
    }
    Fluttertoast.showToast(
        msg: "saving...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.lightBlueAccent,
        textColor: Colors.white,
        fontSize: 16.0);
    print('getting directory...');
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;

    File tobesaved = File(appDocPath + '/' + currentDocPath + '.txt');

    string = getPercentDone().toString() + ']' + string;
    // print(' saving  ' + string);
    await tobesaved.writeAsString(string);
    print('sucess');
    updateDirectory();
  }

  deleteFile(String string) async {
    if (kIsWeb) {
      return;
    }
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    print('folder: ' + appDocPath.toString());

    File tobesaved = File(appDocPath + '/' + string + '.txt');
    print('deleting ' + tobesaved.path + ' ...');
    await tobesaved.delete();
    print('sucess');
    updateDirectory();
  }

  resetHistory() {
    previousLogs = [];
    currentHistoryIndex = 0;
  }

  loadFile(String string) async {
    resetHistory();
    if (kIsWeb) {
      return;
    }
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File toLoad = File(appDocPath + '/' + string + '.txt');
    print('loading ' + toLoad.path + ' ...');

    String full = toLoad.readAsStringSync();
    if (full.contains(']')) {
      if (full.indexOf(']') < 30) {
        full = full.substring(full.indexOf(']') + 1);
      }
    }
    if (full.contains('\n\n-Case Information-\n\n')) {
      List<String> split = full.split('\n\n-Case Information-\n\n');
      globals.log = split[0];
      globals.survey = split[1];
    } else {
      globals.log = full;
    }
    print('loaded: ' + globals.log + '||||||||' + globals.survey);
    updateName();
    updateDirectory();

    parseData(full);
    updateSurvey(true, false);
  }

  List<String> unsafe = [';', ':', ' ', '.', '/', '\n'];
  updateName() {
    if (globals.log.contains('Code Started')) {
      currentDocPath = globals.log.substring(0, globals.log.indexOf('\t'));
      if (currentDocPath.contains('\n')) {
        currentDocPath =
            currentDocPath.substring(currentDocPath.lastIndexOf('\n'));
      }
      unsafe.forEach((element) {
        if (currentDocPath.contains(element)) {
          currentDocPath = currentDocPath.replaceAll(element, '_');
        }
      });

      print('naming current file: ' + currentDocPath + '.');
    } else {
      print('did not find date to name file');
      currentDocPath = "Unknown_Date";
    }
  }

  List<double> statuses = List<double>();
  void updateDirectory() async {
    savedFileString = [];
    statuses = [];
    if (kIsWeb) {
      return;
    }
    Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = Directory(directory.path).listSync();
    for (FileSystemEntity f in files) {
      if (f.path.endsWith('.txt')) {
        String a = f.path
            .substring(f.path.lastIndexOf('/') + 1, f.path.indexOf('.txt'));
        if (!savedFileString.contains(a) && !a.contains('temp')) {
          savedFileString.add(a);
        }
      }
    }
    savedFileString.sort((a, b) => b.toString().compareTo(a.toString()));
    print('finished sorting');
    savedFileString.forEach((element) {
      double a = loadFileStatus(element, directory);
      statuses.add(a);
    });
    print('got statuses' + statuses.toString());
    createFileTiles();
  }

  double loadFileStatus(String string, Directory appDocDir) {
    String appDocPath = appDocDir.path;
    File toLoad = File(appDocPath + '/' + string + '.txt');
    String full = toLoad.readAsStringSync();
    if (full.contains(']')) {
      double r = double.parse(full.substring(0, full.indexOf(']')));
      return r;
    }
    print(full);
    return 0.69;
  }

  Color checkSelectedColor(String e) {
    if (e == currentDocPath) {
      return Colors.lightBlueAccent;
    }
    return Colors.transparent;
  }

  List<Widget> checkSelectedIcon(String e) {
    if (e == currentDocPath) {
      return [
        Icon(FlutterIcons.arrow_right_thick_mco),
        Container(
          width: 10,
        )
      ];
    }
    return [Container()];
  }

  createFileTiles() async {
    if (savedFileString.length > 0) {
      List<Widget> a = List<Widget>();
      savedFileString.asMap().forEach((key, e) {
        a.add(Container(
            color: checkSelectedColor(e),
            child: ListTile(
              trailing: IconButton(
                  icon: Icon(FlutterIcons.delete_mdi),
                  onPressed: () => {
                        makeSure('permanently delete this file?',
                            () => {deleteFile(e)})
                      }),
              title: Row(
                children: [
                  ...checkSelectedIcon(e),
                  Expanded(
                      child: Text(
                    e,
                    maxLines: 1,
                  )),
                  Expanded(
                    child: Container(
                      child: CircularPercentIndicator(
                        radius: 30,
                        percent: statuses[key],
                      ),
                    ),
                  )
                ],
              ),
              onTap: () => {loadFile(e)},
            )));
      });
      setState(() {
        fileTiles = a;
      });
    } else {
      fileTiles = List<Widget>();
    }
  }

  updateSurvey([bool addHistory = false, bool puntSave = true]) {
    print('updating survey...');
    String survey = '';
    infoBits.asMap().forEach((key, value) {
      survey = survey + '\n' + value.stageName + ':' + value.value;
    });
    survey = survey + '\n' + partNames[0];
    for (_ListItem l in Disease) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[1];
    for (_ListItem l in Location) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[2];
    for (_ListItem l in ComorbidConditions) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[3];
    for (_ListItem l in SuspectedCause) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[4];
    for (_ListItem l in PreviousCPA) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[5];
    for (_ListItem l in PreviousMeasures) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[6];
    for (_ListItem l in GeneralAnesthesia) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[7];
    for (_ListItem l in MechanicalVentilation) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[8];
    for (_ListItem l in ROSC) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[9];
    for (_ListItem l in ROSCDuration) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[10];
    for (_ListItem l in Euthanasia) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[11];
    for (_ListItem l in Rearrest) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }
    survey = survey + '\n' + partNames[12];
    for (_ListItem l in Outcome) {
      if (l.checked) {
        survey = survey + l.value + '/';
      }
    }

    globals.survey = survey;
    updateTextField();
    if (puntSave) {
      puntAutosave();
    }

    if (addHistory) {
      updateHistory();
    }
  }

  parseData(String full) {
    if (full.contains('\n\n-Case Information-\n\n')) {
      List<String> split = full.split('\n\n-Case Information-\n\n');
      globals.log = split[0];
      globals.survey = split[1];
    } else {
      globals.log = full;
    }

    List<String> lineSplit = globals.survey.split('\n');
    infoBits.asMap().forEach((i, infoBit) {
      lineSplit.asMap().forEach((j, line) {
        if (line.contains(infoBit.stageName)) {
          infoBit.value = line.substring(infoBit.stageName.length + 1);
        }
      });
    });

    surveyParts.asMap().forEach((e, a) {
      a.asMap().forEach((f, b) {
        b.checked = false;
      });
    });

    print('survey split');
    lineSplit.asMap().forEach((i, split) {
      partNames.asMap().forEach((j, name) {
        if (split.contains(name)) {
          surveyParts[j].asMap().forEach((k, part) {
            if (split.contains(part.value)) {
              part.checked = true;
            }
          });
        }
      });
    });

    setState(() {
      updateTimeline();
      updateSurvey(false);
      updateTextField();
    });
  }

  Timer autoSaveTimer;
  puntAutosave() {
    if (autoSaveTimer != null) {
      autoSaveTimer.cancel();
    }
    autoSaveTimer = Timer(
        Duration(seconds: 6),
        () => {
              print('autosaving...'),
              saveGlobalLog(),
            });
  }

  filePickerFunction() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'txt',
      ],
    );

    if (result != null) {
      File file = File(result.files.single.path);
      String st = await file.readAsString();
      await parseData(st);
      await updateName();
      print('current doc ' + currentDocPath);
      await updateTimeline();
      await updateSurvey(true, false);
      await saveGlobalLog();
      updateDirectory();
      if (_scaffoldKey.currentContext != null) {
        _scaffoldKey.currentState.removeCurrentSnackBar();
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('loaded file auto named: ' + currentDocPath),
          duration: Duration(seconds: 3),
        ));
      }
    } else {
      // User canceled the picker
    }
  }

  globalToInfo() {
    globals.info[0] = currentDocPath;
    globals.info[7] = (globals.weightKG ?? '').toString();
    globals.info[8] = globals.chest ?? '';
    infoBits.asMap().forEach((key, value) {
      value.value = globals.info[key];
    });
    surveyParts.asMap().forEach((e, a) {
      a.asMap().forEach((f, b) {
        b.checked = false;
      });
    });
  }

  showInfoButton(String info, String current) async {
    TextEditingController temp = TextEditingController();
    temp.text = current;
    temp.selection =
        TextSelection(baseOffset: 0, extentOffset: temp.text.length);

    String r = '';
    if (info.toUpperCase().contains('DATE OF')) {
      await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime.now())
          .then((value) => {
                if (value != null)
                  {
                    r = DateFormat.yMMMMd().format(value),
                  }
              });
    } else {
      r = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(info),
                  content: TextField(
                    controller: temp,
                    autofocus: true,
                    onEditingComplete: () => {
                      Navigator.pop(context, temp.text),
                    },
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('done'),
                      onPressed: () => {Navigator.pop(context, temp.text)},
                    )
                  ],
                );
              }) ??
          '';
    }

    return r;
  }

  double getPercentDone() {
    int i = surveyParts.length + infoBits.length;
    int p = 0;
    surveyParts.asMap().forEach((key, value) {
      bool done = false;
      if (value.first.value.contains("General Anesthesia") ||
          value.first.value.contains("Ventilation") ||
          value.first.value.contains("ROSC") ||
          value.first.value.contains("20 min") ||
          value.first.value.contains("arrest") ||
          value.first.value.contains("Euthenasia") ||
          value.first.value.contains("Venous")) {
        done = true;
      }
      value.forEach((element) {
        if (element.checked) {
          done = true;
        }
      });
      if (done) {
        p++;
      } else {}
    });
    infoBits.asMap().forEach((key, value) {
      if (value.value != '') {
        p++;
      }
    });
    return p / i;
  }

  String doctor;
  String chest;
  String survey = "";
  String patientName;
  String mrn;
  String clientName;
  String sex;
  String dob;
  String breed;
  double weightKG;

  moveToBluePass() async {
    final reset = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => bluepass.BluePass(
                  startString: finalController.text,
                )));
    if (reset != null) {
      print('received back on main::: ' + reset);
      if (reset != null) {
        parseData(reset);
        updateSurvey(true, false);
        updateName();
        saveGlobalLog();
        resetHistory();
      }
    }
  }

  TextEditingController doctorController = TextEditingController();
  FocusNode doctorNode = FocusNode();
  savePreferences() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('doctor', doctorController.text);
  }

  sendEmail() async {
    final Email email = Email(
      body:
          'Wow this app is awesome and the team behind it must be so smart\nBUT...\n',
      subject: 'RECOVER APP FEEDBACK',
      recipients: ['conormvickers@gmail.com'],
    );

    await FlutterEmailSender.send(email);
  }

  List<Widget> settingItems() {
    return [
      DrawerHeader(
        child: Column(
          children: [
            Expanded(
              child: Container(),
            ),
            Expanded(
              child: Text(
                'OPTIONS',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(child: Icon(FlutterIcons.md_options_ion))
          ],
        ),
      ),
      Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: doctorController,
                focusNode: doctorNode,
                onEditingComplete: () => {
                  doctorNode.unfocus(),
                  globals.info[1] = doctorController.text,
                  savePreferences(),
                },
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).accentColor, width: 1.0),
                    ),
                    labelText: 'Doctor/user',
                    labelStyle:
                        TextStyle(color: Theme.of(context).accentColor)),
              ),
            ),
          ),
        ],
      ),
      ElevatedButton(
        onPressed: () => {sendEmail()},
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Feedback',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Icon(FlutterIcons.speech_sli, color: Colors.white),
          ],
        ),
      ),
      Expanded(
        child: Container(),
      ),
      kIsWeb
          ? Container()
          : Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 100),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image:
                      'https://recoverinitiative.org/wp-content/uploads/2018/11/intubating_dog_compressions.jpg',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
      ElevatedButton(
        onPressed: () =>
            launch('https://recoverinitiative.org/veterinary-professionals/'),
        child: Container(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Text('Become RECOVER certified',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
              ),
              Icon(FlutterIcons.graduation_cap_ent, color: Colors.white)
            ],
          ),
        ),
      ),
      Divider(),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Text(
            "Created by Conor Vickers, MD and Alexandra Hartzell, VMD in cooperation with Recover Initiative"),
      ),
      Divider()
    ];
  }

  List<Widget> getInfoBits;
  List<Widget> diseaseL;
  List<Widget> locationL;
  List<Widget> previousCPAL;
  List<Widget> previousMeasuresL;
  List<Widget> ROSCL;
  List<Widget> ROSCdurationL;
  List<Widget> comorbidConditionsL;
  List<Widget> suspectedCauseL;
  List<Widget> generalAnesthesiaL;
  List<Widget> mechanicalVentilationL;
  List<Widget> euthanasiaL;
  List<Widget> rearrestL;
  List<Widget> outcomeL;
  Widget roscOpener;
  Widget anesthesiaOpener;
  Widget euthanasiaOpener;

  @override
  Widget build(BuildContext context) {
    print('build starting');
    if (kIsWeb) {
      print('on web-----');
      return Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        drawer: Drawer(
          child: Column(
            children: settingItems(),
          ),
        ),
        appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(width: 8),
                    Container(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ))),
                        child: Row(
                          children: [
                            Icon(
                              FlutterIcons.chevron_left_ent,
                              color: Colors.white,
                            ),
                            Text('RE-ARREST',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        onPressed: () => {askRearrest()},
                      ),
                    ),
                  ],
                ),
              ],
            ),
            title: Container(
                height: 50,
                child: Image.asset(
                  'assets/recover-logo-250.png',
                  fit: BoxFit.fitHeight,
                )),
            elevation: 1.0,
            actions: [
              Builder(
                builder: (context) => Container(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          FlutterIcons.ios_options_ion,
                          color: Colors.lightBlue,
                        ),
                        onPressed: () => {Scaffold.of(context).openDrawer()},
                      ),
                      ...undoButtons(),
                      closeButton()
                    ],
                  ),
                ),
              )
            ]),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Builder(
                    builder: (BuildContext context) => Column(
                      children: <Widget>[
                        LinearPercentIndicator(
                          animateFromLastPercent: true,
                          animation: true,
                          animationDuration: 2,
                          percent: getPercentDone(),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            color: Colors.white,
                            child: ReorderableListView(
                              onReorder: onReorder,
                              children: timelineTiles,
                              scrollController: timelineController,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(35),
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                                onPressed: () async => {
                                      showMaterialModalBottomSheet(
                                        context: context,
                                        closeProgressThreshold: 0.8,
                                        builder: (context) => StatefulBuilder(
                                            builder: (BuildContext context,
                                                StateSetter
                                                    setModState /*You can rename this!*/) {
                                          print(
                                              '-----------------------------------===============');
                                          getInfoBits = infoBits
                                              .map((value) => GestureDetector(
                                                    onTap: () async => {
                                                      print(value.value),
                                                      value.value =
                                                          await showInfoButton(
                                                              value.stageName,
                                                              value.value),
                                                      setModState(() => {
                                                            print(value.value),
                                                            updateSurvey(true),
                                                          })
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15)),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(value
                                                                              .stageName +
                                                                          ": "),
                                                                      Text(value
                                                                          .value)
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                    width: 25,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    child: FittedBox(
                                                                        child: Icon(
                                                                      FlutterIcons
                                                                          .edit_ant,
                                                                    )))
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                              .toList();

                                          diseaseL = Disease.map(
                                            (e) => GestureDetector(
                                              onTap: () => {
                                                setModState(() => {
                                                      e.checked = !e.checked,
                                                      updateSurvey(true),
                                                    }),
                                              },
                                              child: Chip(
                                                backgroundColor: Colors.white,
                                                key: Key(e.value),
                                                label: Text(e.value),
                                                avatar: Checkbox(
                                                  value: e.checked ?? false,
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          locationL = Location.map(
                                            (e) => GestureDetector(
                                              onTap: () => {
                                                setModState(() => {
                                                      for (_ListItem l
                                                          in Location)
                                                        {
                                                          l.checked = false,
                                                        },
                                                      e.checked = !e.checked,
                                                      updateSurvey(true),
                                                    }),
                                              },
                                              child: Chip(
                                                backgroundColor: Colors.white,
                                                key: Key(e.value),
                                                label: Text(e.value),
                                                avatar: Checkbox(
                                                  value: e.checked ?? false,
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          previousCPAL = PreviousCPA.map(
                                            (e) => GestureDetector(
                                              onTap: () => {
                                                setModState(() => {
                                                      for (_ListItem l
                                                          in PreviousCPA)
                                                        {
                                                          l.checked = false,
                                                        },
                                                      e.checked = !e.checked,
                                                      updateSurvey(true),
                                                    }),
                                              },
                                              child: Chip(
                                                backgroundColor: Colors.white,
                                                key: Key(e.value),
                                                label: Text(e.value),
                                                avatar: Checkbox(
                                                  value: e.checked ?? false,
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          previousMeasuresL =
                                              PreviousMeasures.map(
                                            (e) => GestureDetector(
                                              onTap: () => {
                                                setModState(() => {
                                                      e.checked = !e.checked,
                                                      updateSurvey(true),
                                                    }),
                                              },
                                              child: Chip(
                                                backgroundColor: Colors.white,
                                                key: Key(e.value),
                                                label: Text(e.value),
                                                avatar: Checkbox(
                                                  value: e.checked ?? false,
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          ROSCL = ROSC
                                              .map(
                                                (e) => Container(
                                                  padding: EdgeInsets.all(5),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                    ),
                                                    child: CheckboxListTile(
                                                      key: Key(e.value),
                                                      value: e.checked ?? false,
                                                      onChanged:
                                                          (bool newValue) {
                                                        setModState(() =>
                                                            e.checked =
                                                                newValue);
                                                        updateSurvey(true);
                                                      },
                                                      title: Text(e.value),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList();
                                          ROSCdurationL = ROSCDuration.map(
                                            (e) => Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: CheckboxListTile(
                                                  key: Key(e.value),
                                                  value: e.checked ?? false,
                                                  onChanged: (bool newValue) {
                                                    setModState(() => {
                                                          for (_ListItem a
                                                              in ROSCDuration)
                                                            {
                                                              a.checked = false,
                                                            },
                                                          e.checked = newValue
                                                        });
                                                    updateSurvey(true);
                                                  },
                                                  title: Text(e.value),
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          comorbidConditionsL =
                                              ComorbidConditions.map(
                                            (e) => GestureDetector(
                                              onTap: () => {
                                                setModState(() => {
                                                      e.checked = !e.checked,
                                                      updateSurvey(true),
                                                    }),
                                              },
                                              child: Chip(
                                                backgroundColor: Colors.white,
                                                key: Key(e.value),
                                                label: Text(e.value),
                                                avatar: Checkbox(
                                                  value: e.checked ?? false,
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          suspectedCauseL = SuspectedCause.map(
                                            (e) => GestureDetector(
                                              onTap: () => {
                                                setModState(() => {
                                                      e.checked = !e.checked,
                                                      updateSurvey(true),
                                                    }),
                                              },
                                              child: Chip(
                                                backgroundColor: Colors.white,
                                                key: Key(e.value),
                                                label: Text(e.value),
                                                avatar: Checkbox(
                                                  value: e.checked ?? false,
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          generalAnesthesiaL =
                                              GeneralAnesthesia.map(
                                            (e) => Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: CheckboxListTile(
                                                  key: Key(e.value),
                                                  value: e.checked ?? false,
                                                  onChanged: (bool newValue) {
                                                    setModState(() =>
                                                        e.checked = newValue);
                                                    updateSurvey(true);
                                                  },
                                                  title: Text(e.value),
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          mechanicalVentilationL =
                                              MechanicalVentilation.map(
                                            (e) => Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: CheckboxListTile(
                                                  key: Key(e.value),
                                                  value: e.checked ?? false,
                                                  onChanged: (bool newValue) {
                                                    setModState(() =>
                                                        e.checked = newValue);
                                                    updateSurvey(true);
                                                  },
                                                  title: Text(e.value),
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          euthanasiaL = Euthanasia.map(
                                            (e) => Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: CheckboxListTile(
                                                  key: Key(e.value),
                                                  value: e.checked ?? false,
                                                  onChanged: (bool newValue) {
                                                    setModState(() =>
                                                        {e.checked = newValue});
                                                    updateSurvey(true);
                                                  },
                                                  title: Text(e.value),
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          rearrestL = Rearrest.map(
                                            (e) => Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: CheckboxListTile(
                                                  key: Key(e.value),
                                                  value: e.checked ?? false,
                                                  onChanged: (bool newValue) {
                                                    print('starting...');
                                                    setModState(() => {
                                                          for (_ListItem b
                                                              in Rearrest)
                                                            {
                                                              b.checked = false,
                                                            },
                                                          for (_ListItem a
                                                              in Euthanasia)
                                                            {
                                                              a.checked = false,
                                                            },
                                                          e.checked = newValue
                                                        });
                                                    updateSurvey(true);
                                                  },
                                                  title: Text(e.value),
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          outcomeL = Outcome.map(
                                            (e) => Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: CheckboxListTile(
                                                  key: Key(e.value),
                                                  value: e.checked ?? false,
                                                  onChanged: (bool newValue) {
                                                    print('starting...');
                                                    setModState(() => {
                                                          for (_ListItem b
                                                              in Outcome)
                                                            {
                                                              b.checked = false,
                                                            },
                                                          e.checked = newValue
                                                        });
                                                    updateSurvey(true);
                                                  },
                                                  title: Text(e.value),
                                                ),
                                              ),
                                            ),
                                          ).toList();
                                          roscOpener = Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: ExpansionTile(
                                                  key: GlobalKey(),
                                                  title: Text(
                                                      "Was ROSC acheived?"),
                                                  initiallyExpanded:
                                                      ROSC.first.checked,
                                                  trailing: Checkbox(
                                                    value: ROSC.first.checked,
                                                    onChanged:
                                                        (bool newValue) => {
                                                      setModState(() => {
                                                            ROSC.first.checked =
                                                                newValue,
                                                            if (newValue ==
                                                                true)
                                                              {
                                                                setModState(
                                                                    () => {})
                                                              }
                                                          })
                                                    },
                                                  ),
                                                  children: [
                                                    ...ROSCL,
                                                    ...ROSCdurationL
                                                  ],
                                                ),
                                              ));
                                          anesthesiaOpener = Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: ExpansionTile(
                                                  key: GlobalKey(),
                                                  title: Text(
                                                      "General Anesthesia at time of CPA?"),
                                                  initiallyExpanded:
                                                      GeneralAnesthesia
                                                          .first.checked,
                                                  trailing: Checkbox(
                                                    value: GeneralAnesthesia
                                                        .first.checked,
                                                    onChanged:
                                                        (bool newValue) => {
                                                      setModState(() => {
                                                            GeneralAnesthesia
                                                                    .first
                                                                    .checked =
                                                                newValue,
                                                            if (newValue ==
                                                                true)
                                                              {
                                                                setModState(
                                                                    () => {})
                                                              }
                                                          })
                                                    },
                                                  ),
                                                  children: [
                                                    ...generalAnesthesiaL
                                                  ],
                                                ),
                                              ));
                                          euthanasiaOpener = Container(
                                              padding: EdgeInsets.all(5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                ),
                                                child: ExpansionTile(
                                                  key: GlobalKey(),
                                                  title: Text("Euthanasia"),
                                                  initiallyExpanded:
                                                      Euthanasia.first.checked,
                                                  trailing: Checkbox(
                                                    value: Euthanasia
                                                        .first.checked,
                                                    onChanged:
                                                        (bool newValue) => {
                                                      setModState(() => {
                                                            for (_ListItem b
                                                                in Rearrest)
                                                              {
                                                                b.checked =
                                                                    false,
                                                              },
                                                            Euthanasia.first
                                                                    .checked =
                                                                newValue,
                                                          })
                                                    },
                                                  ),
                                                  children: [
                                                    euthanasiaL.first,
                                                    Text('decission based on:'),
                                                    ...euthanasiaL.sublist(
                                                        1, euthanasiaL.length)
                                                  ],
                                                ),
                                              ));
                                          return Container(
                                            constraints: BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.8),
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue,
                                            ),
                                            child: SingleChildScrollView(
                                              controller:
                                                  ModalScrollController.of(
                                                      context),
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: Column(
                                                        children: getInfoBits),
                                                  ),
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        'Disease Category at admission (all that apply)',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  Wrap(
                                                    children: diseaseL,
                                                    spacing: 8.0,
                                                    runSpacing: 4.0,
                                                  ),
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        'Location of CPA (select one)',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  Wrap(
                                                    children: locationL,
                                                    spacing: 8.0,
                                                    runSpacing: 4.0,
                                                  ),
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        'Comorbid conditions',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  Wrap(
                                                    children:
                                                        comorbidConditionsL,
                                                    spacing: 8.0,
                                                    runSpacing: 4.0,
                                                  ),
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        'Suspected cause of CPA',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  Wrap(
                                                    children: suspectedCauseL,
                                                    spacing: 8.0,
                                                    runSpacing: 4.0,
                                                  ),
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text('Previous CPA',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  Wrap(
                                                    children: previousCPAL,
                                                    spacing: 8.0,
                                                    runSpacing: 4.0,
                                                  ),
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        'CPR measures ALREADY in place',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  Wrap(
                                                    children: previousMeasuresL,
                                                    spacing: 8.0,
                                                    runSpacing: 4.0,
                                                  ),
                                                  Divider(),
                                                  anesthesiaOpener,
                                                  Divider(),
                                                  ...mechanicalVentilationL,
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text('ROSC',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  roscOpener,
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        'Mode of Death after ROSC >20 min',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  euthanasiaOpener,
                                                  ...rearrestL,
                                                  Divider(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Text('Outcome',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20)),
                                                  ),
                                                  ...outcomeL,
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    },
                                child: Icon(FlutterIcons.briefcase_edit_mco,
                                    color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
    return DefaultTabController(
      length: 3,
      initialIndex: initTabIndex,
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          key: _scaffoldKey,
          drawer: Drawer(
            child: Column(
              children: settingItems(),
            ),
          ),
          appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: IconButton(
                      icon: Icon(
                        FlutterIcons.alert_decagram_mco,
                        color: Theme.of(context).splashColor,
                      ),
                      onPressed: () => {askRearrest()},
                    ),
                  ),
                ],
              ),
              title: Container(
                  height: 50,
                  child: Image.asset(
                    'assets/recover-logo-250.png',
                    fit: BoxFit.fitHeight,
                  )),
              elevation: 1.0,
              actions: [
                Builder(
                  builder: (context) => Container(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            FlutterIcons.ios_options_ion,
                            color: Colors.lightBlue,
                          ),
                          onPressed: () => {Scaffold.of(context).openDrawer()},
                        ),
                        ...undoButtons(),
                        closeButton()
                      ],
                    ),
                  ),
                )
              ]),
          bottomNavigationBar: ConvexAppBar.badge(
            const <int, dynamic>{3: '2'},
            style: TabStyle.reactCircle,
            backgroundColor: Colors.lightBlue,
            items: <TabItem>[
              TabItem(icon: FlutterIcons.folder_ent, title: 'Saved'),
              TabItem(icon: FlutterIcons.edit_3_fea, title: 'Edit'),
              TabItem(icon: FlutterIcons.send_faw, title: 'Send'),
            ],
            onTap: (int i) => {
              print(i),
              if (i == 0)
                {
                  updateDirectory(),
                  createFileTiles(),
                }
            },
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: fileTiles,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.black))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => launch(
                                    'https://recoverinitiative.org/veterinary-professionals/'),
                                child: Container(
                                  constraints: BoxConstraints(maxHeight: 100),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: FadeInImage.memoryNetwork(
                                          placeholder: kTransparentImage,
                                          image:
                                              'https://recoverinitiative.org/wp-content/uploads/2018/11/intubating_dog_compressions.jpg',
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Become\ncertified',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.lightBlue)),
                                            Row(
                                              children: [
                                                Icon(
                                                  FlutterIcons.left_ant,
                                                  color: Colors.lightBlue,
                                                ),
                                                Icon(
                                                    FlutterIcons
                                                        .graduation_cap_ent,
                                                    color: Colors.lightBlue)
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => filePickerFunction(),
                          child: Container(
                              padding: EdgeInsets.all(15),
                              child: Container(
                                  padding: EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.lightBlue,
                                  ),
                                  child: Icon(
                                    FlutterIcons.folder_search_outline_mco,
                                    color: Colors.white,
                                    size: 40,
                                  )
                                  //Text('Load', style: TextStyle(color: Colors.white, fontSize: 30),),
                                  )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (BuildContext context) => Column(
                            children: <Widget>[
                              LinearPercentIndicator(
                                animateFromLastPercent: true,
                                animation: true,
                                animationDuration: 2,
                                percent: getPercentDone(),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  color: Colors.white,
                                  child: ReorderableListView(
                                    onReorder: onReorder,
                                    children: timelineTiles,
                                    scrollController: timelineController,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(35),
                                  alignment: Alignment.bottomRight,
                                  child: FloatingActionButton(
                                      onPressed: () async => {
                                            showMaterialModalBottomSheet(
                                              context: context,
                                              closeProgressThreshold: 0.8,
                                              builder: (context) =>
                                                  StatefulBuilder(builder:
                                                      (BuildContext context,
                                                          StateSetter
                                                              setModState /*You can rename this!*/) {
                                                print(
                                                    '-----------------------------------===============');
                                                getInfoBits = infoBits
                                                    .map((value) =>
                                                        GestureDetector(
                                                          onTap: () async => {
                                                            print(value.value),
                                                            value.value =
                                                                await showInfoButton(
                                                                    value
                                                                        .stageName,
                                                                    value
                                                                        .value),
                                                            setModState(() => {
                                                                  print(value
                                                                      .value),
                                                                  updateSurvey(
                                                                      true),
                                                                })
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15)),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Text(value.stageName +
                                                                                ": "),
                                                                            Text(value.value)
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                          width:
                                                                              25,
                                                                          padding:
                                                                              EdgeInsets.all(5),
                                                                          child: FittedBox(
                                                                              child: Icon(
                                                                            FlutterIcons.edit_ant,
                                                                          )))
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ))
                                                    .toList();

                                                diseaseL = Disease.map(
                                                  (e) => GestureDetector(
                                                    onTap: () => {
                                                      setModState(() => {
                                                            e.checked =
                                                                !e.checked,
                                                            updateSurvey(true),
                                                          }),
                                                    },
                                                    child: Chip(
                                                      backgroundColor:
                                                          Colors.white,
                                                      key: Key(e.value),
                                                      label: Text(e.value),
                                                      avatar: Checkbox(
                                                        value:
                                                            e.checked ?? false,
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                locationL = Location.map(
                                                  (e) => GestureDetector(
                                                    onTap: () => {
                                                      setModState(() => {
                                                            for (_ListItem l
                                                                in Location)
                                                              {
                                                                l.checked =
                                                                    false,
                                                              },
                                                            e.checked =
                                                                !e.checked,
                                                            updateSurvey(true),
                                                          }),
                                                    },
                                                    child: Chip(
                                                      backgroundColor:
                                                          Colors.white,
                                                      key: Key(e.value),
                                                      label: Text(e.value),
                                                      avatar: Checkbox(
                                                        value:
                                                            e.checked ?? false,
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                previousCPAL = PreviousCPA.map(
                                                  (e) => GestureDetector(
                                                    onTap: () => {
                                                      setModState(() => {
                                                            for (_ListItem l
                                                                in PreviousCPA)
                                                              {
                                                                l.checked =
                                                                    false,
                                                              },
                                                            e.checked =
                                                                !e.checked,
                                                            updateSurvey(true),
                                                          }),
                                                    },
                                                    child: Chip(
                                                      backgroundColor:
                                                          Colors.white,
                                                      key: Key(e.value),
                                                      label: Text(e.value),
                                                      avatar: Checkbox(
                                                        value:
                                                            e.checked ?? false,
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                previousMeasuresL =
                                                    PreviousMeasures.map(
                                                  (e) => GestureDetector(
                                                    onTap: () => {
                                                      setModState(() => {
                                                            e.checked =
                                                                !e.checked,
                                                            updateSurvey(true),
                                                          }),
                                                    },
                                                    child: Chip(
                                                      backgroundColor:
                                                          Colors.white,
                                                      key: Key(e.value),
                                                      label: Text(e.value),
                                                      avatar: Checkbox(
                                                        value:
                                                            e.checked ?? false,
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                ROSCL = ROSC
                                                    .map(
                                                      (e) => Container(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          child:
                                                              CheckboxListTile(
                                                            key: Key(e.value),
                                                            value: e.checked ??
                                                                false,
                                                            onChanged: (bool
                                                                newValue) {
                                                              setModState(() =>
                                                                  e.checked =
                                                                      newValue);
                                                              updateSurvey(
                                                                  true);
                                                            },
                                                            title:
                                                                Text(e.value),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList();
                                                ROSCdurationL =
                                                    ROSCDuration.map(
                                                  (e) => Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: CheckboxListTile(
                                                        key: Key(e.value),
                                                        value:
                                                            e.checked ?? false,
                                                        onChanged:
                                                            (bool newValue) {
                                                          setModState(() => {
                                                                for (_ListItem a
                                                                    in ROSCDuration)
                                                                  {
                                                                    a.checked =
                                                                        false,
                                                                  },
                                                                e.checked =
                                                                    newValue
                                                              });
                                                          updateSurvey(true);
                                                        },
                                                        title: Text(e.value),
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                comorbidConditionsL =
                                                    ComorbidConditions.map(
                                                  (e) => GestureDetector(
                                                    onTap: () => {
                                                      setModState(() => {
                                                            e.checked =
                                                                !e.checked,
                                                            updateSurvey(true),
                                                          }),
                                                    },
                                                    child: Chip(
                                                      backgroundColor:
                                                          Colors.white,
                                                      key: Key(e.value),
                                                      label: Text(e.value),
                                                      avatar: Checkbox(
                                                        value:
                                                            e.checked ?? false,
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                suspectedCauseL =
                                                    SuspectedCause.map(
                                                  (e) => GestureDetector(
                                                    onTap: () => {
                                                      setModState(() => {
                                                            e.checked =
                                                                !e.checked,
                                                            updateSurvey(true),
                                                          }),
                                                    },
                                                    child: Chip(
                                                      backgroundColor:
                                                          Colors.white,
                                                      key: Key(e.value),
                                                      label: Text(e.value),
                                                      avatar: Checkbox(
                                                        value:
                                                            e.checked ?? false,
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                generalAnesthesiaL =
                                                    GeneralAnesthesia.map(
                                                  (e) => Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: CheckboxListTile(
                                                        key: Key(e.value),
                                                        value:
                                                            e.checked ?? false,
                                                        onChanged:
                                                            (bool newValue) {
                                                          setModState(() =>
                                                              e.checked =
                                                                  newValue);
                                                          updateSurvey(true);
                                                        },
                                                        title: Text(e.value),
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                mechanicalVentilationL =
                                                    MechanicalVentilation.map(
                                                  (e) => Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: CheckboxListTile(
                                                        key: Key(e.value),
                                                        value:
                                                            e.checked ?? false,
                                                        onChanged:
                                                            (bool newValue) {
                                                          setModState(() =>
                                                              e.checked =
                                                                  newValue);
                                                          updateSurvey(true);
                                                        },
                                                        title: Text(e.value),
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                euthanasiaL = Euthanasia.map(
                                                  (e) => Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: CheckboxListTile(
                                                        key: Key(e.value),
                                                        value:
                                                            e.checked ?? false,
                                                        onChanged:
                                                            (bool newValue) {
                                                          setModState(() => {
                                                                e.checked =
                                                                    newValue
                                                              });
                                                          updateSurvey(true);
                                                        },
                                                        title: Text(e.value),
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                rearrestL = Rearrest.map(
                                                  (e) => Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: CheckboxListTile(
                                                        key: Key(e.value),
                                                        value:
                                                            e.checked ?? false,
                                                        onChanged:
                                                            (bool newValue) {
                                                          print('starting...');
                                                          setModState(() => {
                                                                for (_ListItem b
                                                                    in Rearrest)
                                                                  {
                                                                    b.checked =
                                                                        false,
                                                                  },
                                                                for (_ListItem a
                                                                    in Euthanasia)
                                                                  {
                                                                    a.checked =
                                                                        false,
                                                                  },
                                                                e.checked =
                                                                    newValue
                                                              });
                                                          updateSurvey(true);
                                                        },
                                                        title: Text(e.value),
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                outcomeL = Outcome.map(
                                                  (e) => Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: CheckboxListTile(
                                                        key: Key(e.value),
                                                        value:
                                                            e.checked ?? false,
                                                        onChanged:
                                                            (bool newValue) {
                                                          print('starting...');
                                                          setModState(() => {
                                                                for (_ListItem b
                                                                    in Outcome)
                                                                  {
                                                                    b.checked =
                                                                        false,
                                                                  },
                                                                e.checked =
                                                                    newValue
                                                              });
                                                          updateSurvey(true);
                                                        },
                                                        title: Text(e.value),
                                                      ),
                                                    ),
                                                  ),
                                                ).toList();
                                                roscOpener = Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: ExpansionTile(
                                                        key: GlobalKey(),
                                                        title: Text(
                                                            "Was ROSC acheived?"),
                                                        initiallyExpanded:
                                                            ROSC.first.checked,
                                                        trailing: Checkbox(
                                                          value: ROSC
                                                              .first.checked,
                                                          onChanged:
                                                              (bool newValue) =>
                                                                  {
                                                            setModState(() => {
                                                                  ROSC.first
                                                                          .checked =
                                                                      newValue,
                                                                  if (newValue ==
                                                                      true)
                                                                    {
                                                                      setModState(
                                                                          () =>
                                                                              {})
                                                                    }
                                                                })
                                                          },
                                                        ),
                                                        children: [
                                                          ...ROSCL,
                                                          ...ROSCdurationL
                                                        ],
                                                      ),
                                                    ));
                                                anesthesiaOpener = Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: ExpansionTile(
                                                        key: GlobalKey(),
                                                        title: Text(
                                                            "General Anesthesia at time of CPA?"),
                                                        initiallyExpanded:
                                                            GeneralAnesthesia
                                                                .first.checked,
                                                        trailing: Checkbox(
                                                          value:
                                                              GeneralAnesthesia
                                                                  .first
                                                                  .checked,
                                                          onChanged:
                                                              (bool newValue) =>
                                                                  {
                                                            setModState(() => {
                                                                  GeneralAnesthesia
                                                                          .first
                                                                          .checked =
                                                                      newValue,
                                                                  if (newValue ==
                                                                      true)
                                                                    {
                                                                      setModState(
                                                                          () =>
                                                                              {})
                                                                    }
                                                                })
                                                          },
                                                        ),
                                                        children: [
                                                          ...generalAnesthesiaL
                                                        ],
                                                      ),
                                                    ));
                                                euthanasiaOpener = Container(
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                      ),
                                                      child: ExpansionTile(
                                                        key: GlobalKey(),
                                                        title:
                                                            Text("Euthanasia"),
                                                        initiallyExpanded:
                                                            Euthanasia
                                                                .first.checked,
                                                        trailing: Checkbox(
                                                          value: Euthanasia
                                                              .first.checked,
                                                          onChanged:
                                                              (bool newValue) =>
                                                                  {
                                                            setModState(() => {
                                                                  for (_ListItem b
                                                                      in Rearrest)
                                                                    {
                                                                      b.checked =
                                                                          false,
                                                                    },
                                                                  Euthanasia
                                                                          .first
                                                                          .checked =
                                                                      newValue,
                                                                })
                                                          },
                                                        ),
                                                        children: [
                                                          euthanasiaL.first,
                                                          Text(
                                                              'decission based on:'),
                                                          ...euthanasiaL
                                                              .sublist(
                                                                  1,
                                                                  euthanasiaL
                                                                      .length)
                                                        ],
                                                      ),
                                                    ));
                                                return Container(
                                                  constraints: BoxConstraints(
                                                      maxHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.lightBlue,
                                                  ),
                                                  child: SingleChildScrollView(
                                                    controller:
                                                        ModalScrollController
                                                            .of(context),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          child: Column(
                                                              children:
                                                                  getInfoBits),
                                                        ),
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              'Disease Category at admission (all that apply)',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        Wrap(
                                                          children: diseaseL,
                                                          spacing: 8.0,
                                                          runSpacing: 4.0,
                                                        ),
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              'Location of CPA (select one)',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        Wrap(
                                                          children: locationL,
                                                          spacing: 8.0,
                                                          runSpacing: 4.0,
                                                        ),
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              'Comorbid conditions',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        Wrap(
                                                          children:
                                                              comorbidConditionsL,
                                                          spacing: 8.0,
                                                          runSpacing: 4.0,
                                                        ),
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              'Suspected cause of CPA',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        Wrap(
                                                          children:
                                                              suspectedCauseL,
                                                          spacing: 8.0,
                                                          runSpacing: 4.0,
                                                        ),
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              'Previous CPA',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        Wrap(
                                                          children:
                                                              previousCPAL,
                                                          spacing: 8.0,
                                                          runSpacing: 4.0,
                                                        ),
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              'CPR measures ALREADY in place',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        Wrap(
                                                          children:
                                                              previousMeasuresL,
                                                          spacing: 8.0,
                                                          runSpacing: 4.0,
                                                        ),
                                                        Divider(),
                                                        anesthesiaOpener,
                                                        Divider(),
                                                        ...mechanicalVentilationL,
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text('ROSC',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        roscOpener,
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text(
                                                              'Mode of Death after ROSC >20 min',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        euthanasiaOpener,
                                                        ...rearrestL,
                                                        Divider(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(8),
                                                          child: Text('Outcome',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      20)),
                                                        ),
                                                        ...outcomeL,
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          },
                                      child: Icon(
                                          FlutterIcons.briefcase_edit_mco,
                                          color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  Expanded(
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: TextField(
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  focusedBorder: InputBorder.none,
                                  labelText: 'Text File'),
                              maxLines: null,
                              controller: finalController,
                              enabled: false,
                              onTap: () => {
                                if (!editing)
                                  {
                                    setState(() => {editing = true})
                                  }
                              },
                            ),
                          ),
                        )),
                  ),
                  Container(
                      padding: EdgeInsets.only(bottom: 20),
                      color: Colors.lightBlue,
                      child: ButtonBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            child: Container(
                                child: Column(
                              children: [
                                Icon(
                                  FlutterIcons.text_ent,
                                  color: Colors.blue,
                                ),
                                Text('Text'),
                              ],
                            )),
                            onPressed: sendText,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                            ),
                            child: Container(
                              child: Column(
                                children: [
                                  FittedBox(
                                      child: Icon(
                                    FlutterIcons.file_pdf_faw5,
                                    color: Colors.blue,
                                  )),
                                  Text('PDF'),
                                ],
                              ),
                            ),
                            onPressed: sendData,
                          ),
                          // ElevatedButton(
                          //   child: Container(
                          //       child: Column(
                          //     children: [
                          //       Icon(
                          //         FlutterIcons.cloud_upload_alt_faw5s,
                          //         color: Colors.blue,
                          //       ),
                          //       Text('Cloud'),
                          //     ],
                          //   )),
                          //   onPressed: () => {},
                          // ),
                          // ElevatedButton(
                          //   child: Container(
                          //       child: Column(
                          //     children: [
                          //       Icon(
                          //         FlutterIcons.handshake_faw5,
                          //         color: Colors.blue,
                          //       ),
                          //       Text('Blue-Pass'),
                          //     ],
                          //   )),
                          //   onPressed: () => {
                          //     moveToBluePass(),
                          //   },
                          // ),
                        ],
                      )),
                ],
              ),
            ],
          )),
    );
  }
}
