import 'dart:async';
import 'dart:io';
import 'package:flutterheart/main.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:customgauge/customgauge.dart';
import 'globals.dart' as globals;
import 'main.dart' as rootFile;
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:badges/badges.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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
    Entry('Pericardiocentesis, echocardiogram if uncertain'),
  ]),
  Entry('Tension pneumothorax', <Entry>[
    Entry('Needle Thoracostomy 14-16 gauge needle'),
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
  'Naloxone',
  'Flumazenil',
  'Atipamezole'
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

bool needBadge = false;
bool twominbadge = false;
bool tenminbadge = false;

class NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  TabController nestedTabController;
  TabController chestTypeController;
  MyHomePageState parent;

  NestedTabBarState(this.parent);

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

  int breathingValue = 0;
  int breathSeconds = 0;

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
                    progressColor: Theme.of(context).primaryColor,
                    verticalDirection: VerticalDirection.up,
                    currentValue: breathingValue,
                    animatedDuration: Duration(milliseconds: 1000),
                    borderRadius: 0,
                  ),
                ),
                Expanded(
                  child: FAProgressBar(
                    direction: Axis.vertical,
                    progressColor: Theme.of(context).primaryColor,
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

  var tapTimes = <DateTime>[];
  var tapDifs = <int>[];
  var perc1 = 0.0;
  var perc2 = 0.0;
  var perc3 = 0.0;
  var anim1 = true;
  var anim2 = true;
  var anim3 = true;
  double speed = 0;

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

  Timer tapResetTimer;

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

  static final _citems = <String>[
    'IV Access',
    'Monitor',
    'Oxygen',
    'Intubation',
    'Capnography',
  ].map((item) => _ListItem(item, false)).toList();

  stopCode() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm').format(now);
    String combined = "\n" + formattedDate + "\tCode Stopped";
    String full = combined.toString() + "\t";
    globals.log = globals.log + full;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('log', null);
    print('finished code');
    Navigator.push(context, MaterialPageRoute(builder: (context) => PageTwo()));
  }

  List<String> chestTypes = ['round', 'keel', 'flat'];
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
                    Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Icon(
                              MaterialCommunityIcons.dog_side,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(),
                        ),
                      ],
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
                      ),
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Icon(
                              MaterialCommunityIcons.dog_side,
                            ),
                          ),
                        ),
                      ],
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

    final _listTiles = _citems
        .map((item) => CheckboxListTile(
              key: Key(item.value),
              value: item.checked ?? false,
              onChanged: (bool newValue) {
                setState(() => item.checked = newValue);
                if (newValue == true) {
                  DateTime now = DateTime.now();
                  String formattedDate = DateFormat('kk:mm').format(now);
                  globals.log =
                      globals.log + '\n' + formattedDate + '\t' + item.value;
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
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
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
                                            Theme.of(context).primaryColor),
                                        GaugeSegment(
                                            'Medium', 20, Colors.white),
                                        GaugeSegment('High', 50,
                                            Theme.of(context).primaryColor),
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
                                  color: Theme.of(context).primaryColor,
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
  @override
  PageTwoState createState() => PageTwoState();
}

class PageTwoState extends State<PageTwo> {
  List<Widget> timelineTiles = List<Widget>();
  List<String> eventSplit = globals.log.split('\n');
  int timelineEditing = null;
  TextEditingController timelineEditingController = TextEditingController();

  editTimeline(int i) {
    setState(() {
      timelineEditing = i;
    });
  }

  pw.Document pdf;
  Directory appDocDir;
  String appDocPath;
  sendData() async {
    String log = '';
    if (infoController.text != null) {
      log = infoController.text + '\n';
    }
    if (globals.chest != null && globals.weightKG != null) {
      log = log +
          ' ' +
          globals.chest +
          ' chest, ' +
          globals.weightKG.toStringAsPrecision(2) +
          'kg\n';
    }
    log = log + globals.log;

    pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
              child: pw.Text(
            log,
          )); // Center
        })); //

    appDocDir = await getApplicationDocumentsDirectory();

    DateTime now = DateTime.now();
    String date = DateFormat('yyyy_MM_dd').format(now);

    final file = File("${appDocDir.path}/" + date + "log.pdf");
    await file.writeAsBytes(pdf.save());

    Share.shareFiles(['${appDocDir.path}/' + date + 'log.pdf'],
        text: 'PDF log');
  }

  sendText() async {
    appDocDir = await getApplicationDocumentsDirectory();
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy_MM_dd').format(now);

    final file = File("${appDocDir.path}/" + date + "log.txt");
    String log = '';
    if (infoController.text != null) {
      log = infoController.text + '\n';
    }
    if (globals.chest != null && globals.weightKG != null) {
      log = log +
          ' ' +
          globals.chest +
          ' chest, ' +
          globals.weightKG.toStringAsPrecision(2) +
          'kg\n';
    }
    log = log + globals.log;

    await file.writeAsString(log);

    Share.shareFiles(["${appDocDir.path}/" + date + "log.txt"],
        text: "TXT log");
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
    updateDrawer();
  }

  updateDrawer() {
    FocusNode focusEdit = FocusNode();
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
            'Naloxone',
            'Flumazenil',
            'Atipamezole'
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
                      updateDrawer(),
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
                    updateDrawer();
                  });
                },
                child: Row(
                  children: [
                    Expanded(child: endChild),
                    Icon(
                      FlutterIcons.drag_handle_mdi,
                    ),
                  ],
                ),
              ),
            ),
            isFirst: first,
            isLast: last,
            hasIndicator: dot,
            indicatorStyle: IndicatorStyle(
                width: iconSize,
                color: Colors.red,
                padding: EdgeInsets.all(8),
                iconStyle: IconStyle(
                  iconData: icon,
                  color: Colors.white,
                )),
          );
          timelineTiles.add(Slidable(
              key: Key(i.toString() + 'timeline'),
              actionPane: SlidableScrollActionPane(),
              actionExtentRatio: 0.2,
              secondaryActions: [
                IconSlideAction(
                  caption: 'delete',
                  icon: FlutterIcons.delete_mdi,
                  color: Colors.red,
                  onTap: () => {
                    setState(() => {
                          eventSplit.removeAt(i),
                          globals.log = eventSplit.join('\n'),
                          print(globals.log),
                          timelineEditing = null,
                          FocusScope.of(context).unfocus(),
                          updateDrawer(),
                        })
                  },
                )
              ],
              child: add));
        }
      }
      focusEdit.requestFocus();
    });
  }

  @override
  void initState() {
    updateDrawer();
  }

  TextEditingController infoController = TextEditingController();
  ScrollController timelineController = ScrollController();

  @override
  Widget build(BuildContext context) {
    print('build starting');

    for (Widget key in timelineTiles) {
      print('key name ' + key.toString());
      print(key.key);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Code Summary'),
        elevation: 1.0,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.red,
        child: Container(
            color: Colors.red,
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                    child: Text('New Code'),
                    onPressed: () {
                      globals.log = "";
                      globals.stopCodeNow = false;
                      globals.codeStart = DateTime.now();
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
                      globals.reset = true;
                      globals.weightKG = null;
                      globals.weightIndex = null;
                      Navigator.pop(context);
                    }),
                RaisedButton(
                  child: Text('Send Text File'),
                  onPressed: sendText,
                ),
                RaisedButton(
                  child: Text('Send PDF File'),
                  onPressed: sendData,
                ),
              ],
            )),
      ),
      body: Builder(
        builder: (BuildContext context) => Column(
          children: <Widget>[
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
            Container(
              height: 100,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: infoController,
                        decoration:
                            InputDecoration(hintText: 'Patient name, MRN'),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: RaisedButton(
                        child: Text('add event'),
                        onPressed: () => {
                              globals.log = globals.log + '\n??:??\tnew event',
                              updateDrawer(),
                              timelineController.animateTo(
                                timelineController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              ),
                            }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
