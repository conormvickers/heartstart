import 'dart:async';
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

class NestedTabBar extends StatefulWidget {
  var show = false;
  final pass;
  rootFile.MyHomePageState parent;

  NestedTabBar({Key key,this.show,this.pass,this.parent}) : super(key: key);

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
  Entry('Hypovolemia',
    <Entry>[
      Entry('Give Fluid'),
    ]
  ),
  Entry('Hypoxia',
      <Entry>[
        Entry('Oxygen/intubation'),
      ]

  ),
  Entry('Hydrogen ions (acidosis)',
      <Entry>[
        Entry('Give bicarb'),
      ]
  ),
  Entry('Hyper/hypo kalemia',
      <Entry>[
        Entry('Check most recent labs, dialysis/replete'),
      ]
  ),
  Entry('Hypothermmia',
      <Entry>[
        Entry('Bair hugger, warmed fluids'),
      ]
  ),
  Entry('Toxins',
      <Entry>[
        Entry('Cocain, Digoxin, TCA, CCB, review medications review history'),
      ]
  ),
  Entry('Tamponade (cardiac)',
      <Entry>[
        Entry('Pericardiocentesis, echocardiogram if uncertain'),
      ]
  ),
  Entry('Tension pneumothorax',
      <Entry>[
        Entry('Needle Thoracostomy 14-16 gauge needle'),
      ]
  ),
  Entry('Thrombosis',
      <Entry>[
        Entry('Consider PE and anticoagulation'),
      ]
  ),
];
//"Hypovolemia", "Hypoxia", "Hydrogen ions (acidosis)",
//"Hyper/hypokalemia",
//"Hypothermia", "Toxins",
//"Tamponade (cardiac)", "Tension pneumothorax", "Thrombosis"
var tapLabel = '';


final _medStrings = <String> [
  'Epinephrine',
  'Amiodarone',
  'Magnesium',
  'Bicarbonate',
  'Fluid',
];
final _doses = <String> [
  '1mg every 2-3 min',
  '300mg first dose, 150mg second dose',
  '1-2g',
  '1 ampule',
  '500-1000mL bolus'
];
var timesGiven = <int> [
  0,0,0,0,0,0,0,0,
];
var _lastGiven = <DateTime> [
  DateTime.now(), DateTime.now(),DateTime.now(),DateTime.now(),DateTime.now(),DateTime.now(),
];

final medItems = List<MedListItem>.generate(
  _medStrings.length,
      (i) {
        return MedMessageItem(_medStrings[i], _doses[i], 'last given' + _lastGiven[i].toString() + 'min ago');
      }
);
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
  TabController _nestedTabController;
  MyHomePageState parent;

  NestedTabBarState(this.parent);

  @override
  void initState() {
    super.initState();

    _nestedTabController = new TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
  }

  var tapTimes = <DateTime> [];
  var tapDifs = <int> [];
  var perc1 = 0.0;
  var perc2 = 0.0;
  var perc3 = 0.0;
  var anim1 = true;
  var anim2 = true;
  var anim3 = true;
  double speed = 0;

  _handleTap() {

    tapTimes.add(DateTime.now());
    if (tapTimes.length > 4 ) {
      tapTimes.removeAt(0);
    }

    if (tapTimes.length >= 2) {
      DateTime a;
      tapDifs = [];

      tapTimes.forEach((element) => {
        if (tapTimes.indexOf(element)  < tapTimes.length - 1) {
          a =  tapTimes[tapTimes.indexOf(element) + 1],

          tapDifs.add(a.difference(element).inMilliseconds),
        }
      });

      print(tapDifs);
      double ave = (tapDifs.reduce((value, element) => value + element) / tapDifs.length);
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
      }else if (speed > 120){
        perc3 = (speed - 120) / 40;
        if (perc3 > 1) {
          perc3 = 1;
        }
        perc2 = 1;
        perc1 = 1;
        anim1 = false;
        anim2 = false;
        anim3 = true;
      }else{
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

    tapResetTimer = new Timer(Duration(seconds: 3), ()  => {

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
    String combined = "\n" + formattedDate + "\t" + _medStrings[index].toString();
    String full = combined.toString() + "\t" + this.parent.currentTime();
    globals.log = globals.log + full;
    setState( () => {
      _lastGiven[index] = DateTime.now(),
      timesGiven[index]++,

    } );

  }



  static final _citems = <String> [
    'IV Access',
    'Monitor',
    'Oxygen',
    'Intubation',
    'Capnography',
  ].map((item) => _ListItem(item, false)).toList();
  stopCode() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm').format(now);
    String combined = "\n" + formattedDate + "\tCode Stopped";
    String full = combined.toString() + "\t" + this.parent.currentTime();
    globals.log = globals.log + full;
    Navigator.push(context, PageTwo(""));

  }


  @override
  Widget build(BuildContext context) {
    
    print("current log:" + globals.log);

    final _listTiles = _citems.map((item) => CheckboxListTile(
      key: Key(item.value),
      value: item.checked ?? false,
      onChanged: (bool newValue) {
        setState(() => item.checked = newValue);
      },
      title: Text('${item.value}'),

    )).toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[

        TabBar(
          controller: _nestedTabController,
          indicatorColor: Colors.red,
          labelColor: Colors.red,
          unselectedLabelColor: Colors.black54,
          isScrollable: true,
          tabs: <Widget>[
            Tab(
              icon: Icon(MaterialCommunityIcons.format_list_checks),
            ),
            Tab(
              icon: Icon(AntDesign.medicinebox) ,
            ),
            Tab(
              icon: Icon(MaterialCommunityIcons.metronome),
            ),
            Tab(
              icon: Icon(AntDesign.questioncircleo),
            ),
            Tab(
              icon: Icon(Octicons.stop),
            ),
          ],
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: TabBarView(
              controller: _nestedTabController,
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
                      child: ListView.builder(
                        // Let the ListView know how many items it needs to build.
                        itemCount: medItems.length,
                        // Provide a builder function. This is where the magic happens.
                        // Convert each item into a widget based on the type of item it is.
                        itemBuilder: (context, index) {
                          final item = medItems[index];
                          var tx = Text('');
                          var color = Colors.black54;
                          final dif = DateTime.now().difference(_lastGiven[index]).inMinutes.toString();
                          if ( timesGiven[index] != 0 ) {
                            tx = Text('given ' + timesGiven[index].toString() + ' doses\nlast given ' + dif + ' min ago',

                            );
                          }
                          if (int.parse(dif) >= 2) {
                            color = Colors.transparent;
                          }
                          return Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              title: item.buildTitle(context),
                              subtitle: item.buildSubtitle(context),
                              trailing: tx,
                              onTap: () {
                                print("med index tapped:" + index.toString());
                                _giveMed(index);
                              },
                            ),
                          );
                        },
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
                                child: new LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          CustomGauge(
                                            gaugeSize: constraints.maxHeight,  //MediaQuery.of(context).size.width * 2 / 5 ,
                                            maxValue: 170,
                                            minValue: 50,
                                            showMarkers: false,
                                            valueWidget: Container(),
                                            segments: [
                                              GaugeSegment('Low', 50, Colors.red),
                                              GaugeSegment('Medium', 20, Colors.white),
                                              GaugeSegment('High', 50, Colors.red),
                                            ],
                                            currentValue: speed,
                                            displayWidget: Text(tapLabel,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 20,
                                                )),
                                          ),
                                        ],
                                      );
                                    }
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    AutoSizeText('tap with compressions',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 40
                                      ),
                                      maxLines: 1,
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
                      child: ListView.builder(itemBuilder: (BuildContext context, int index) => EntryItem(data[index]),
                      itemCount: data.length,),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ButtonBar(
                            mainAxisSize: MainAxisSize.min,
                            alignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                child: Text('Check Pulse Now'),
                                onPressed: (){
                                  this.parent.setState(() {
                                    askForPulse = true;
                                  });
                                  },
                              ),
                              RaisedButton(
                                child: Text('Stop Code Now'),
                                onPressed: () {
                                    stopCode();
                                  },
                                      
                              ),
                            ],
                          ),
                        ],
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
class PageTwo extends MaterialPageRoute<Null> {

  final String log;

  PageTwo(this.log) : super(builder: (BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Code Summary'),
        elevation: 1.0,
      ),
      body: Builder(
        builder: (BuildContext context) => Column(
          children: <Widget>[
            Expanded(
              flex: 9,
              child: SingleChildScrollView(child: Text(
              globals.log,
            ),),
            ),
            Expanded(
              flex: 1,
              
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
                        timesGiven = <int> [
                          0,0,0,0,0,0,0,0,
                        ];
                        _lastGiven = <DateTime> [
                          DateTime.now(), DateTime.now(),DateTime.now(),DateTime.now(),DateTime.now(),DateTime.now(),
                        ];
                        globals.reset = true;
                        Navigator.pop(context);
                      }
                    ),
                     RaisedButton(
                       child: Text('Send'),
                       onPressed: () =>  Share.share(globals.log),
                     )


                  ],)
                    
              
              ), 
            ),
          ],
        ),
      ),
    );
  });
}