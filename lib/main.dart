
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:timeline_tile/timeline_tile.dart';
import 'package:wakelock/wakelock.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}


var askForPulse = false;
var warningDismissed = false;
final _eventScrollController = ScrollController();
int timelineEditing = null;
TextEditingController timelineEditingController = TextEditingController();

var nested = NestedTabBar();
var showShock = false;
var _shockType = " ";
var handFreeColor;

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
        primaryColor: Colors.red,
        accentColor: Colors.blue,
        splashColor: Colors.redAccent,
        indicatorColor: Colors.redAccent,
        primarySwatch: Colors.red,
        disabledColor: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
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

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver, TickerProviderStateMixin {
  static AudioCache player = AudioCache();

  bool handsFree = true;
  double fraction = 0;
  double minPassed = 0;
  double secPassed = 0;
  double fractionPulse = 0;
  double dispSec = 0;
  double _weightValue = 5;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      print(state.toString());
      if (state == AppLifecycleState.paused)  {
        print('saving log...');
        _saveLog();
        print('done');
      }
      if (state == AppLifecycleState.resumed) {

      }
    });
  }
  _saveLog() async {

      var prefs = await SharedPreferences.getInstance();
      prefs.setString('log', globals.log);

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
              child: AutoSizeText(
                'Select Weight',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Expanded(
              child: Row(

                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Expanded(
                          flex: 1,
                          child: FittedBox(
                            child: Icon(
                              MaterialCommunityIcons.dog_side,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Expanded(
                          flex: 2,
                          child: FittedBox(
                            child: Icon(
                              MaterialCommunityIcons.dog_side,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Expanded(
                          flex: 9,
                          child: FittedBox(
                            child: Icon(
                              MaterialCommunityIcons.dog_side,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
                flex: 2,
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

  Color barColor;
  CircularPercentIndicator cycle;
  IconData centerIcon = FlutterIcons.heart_ant;

  String inst = "Continue Compressions";
  DateTime lastSwitchedComp = DateTime.now().add(Duration(minutes: 2));

  currentTime() {

    globals.publicCodeTime =
        _printDuration(Duration(seconds: secPassed.toInt()));

    return globals.publicCodeTime;
  }

  bool progressPulseCheck = true;
  String pulseCheckCountdown = '';
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  _triggerUpdate() {
    print('initializing timer');
    Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) => {
              setState(() {
                secPassed++;

                if (progressPulseCheck) {
                  fractionPulse++;

                  // print(_printDuration(
                  //     Duration(seconds: 120 - fractionPulse.toInt())));
                  pulseCheckCountdown = ' ' +
                      _printDuration(
                          Duration(seconds: 120 - fractionPulse.toInt()));
                  if (120 - fractionPulse.toInt() == 10) {
                    _speechThis('10 seconds to pulse check');
                  }

                  fraction = fractionPulse / 120;

                  if (fractionPulse >= 109) {
                    if (fractionPulse == 120) {
                      print('should open');
                      askForPulse = true;
                      _speechThis(
                          'Stop compressions. Resume compressions within 10 seconds');
                      barColor = Theme.of(context).accentColor;
                      inst = "Pulse Check";
                      centerIcon = Ionicons.ios_pulse;
                      progressPulseCheck = false;
                    }
                  } else {
                    barColor = Theme.of(context).primaryColor;
                    inst = "Continue Compressions";
                    centerIcon = FlutterIcons.heart_ant;
                  }
                  if (fractionPulse >= 120) {
                    fractionPulse = 0;
                  }
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
        _speechThis(
            'Continue compressions while charging. Ensure clear before shock');
      } else if (selected == "vfib" || selected == "tors") {
        showShock = true;
        if (globals.weightIndex != null) {
          _shockType = shockDoses[globals.weightIndex];
        }
        _speechThis(
            'Continue compressions while charging. Ensure clear before shock');
      } else if (selected == "pulse") {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('kk:mm').format(now);
        String combined = "\n" + formattedDate + "\tCode Stopped";
        String full = combined.toString() + "\t" + currentTime();
        globals.log = globals.log + full;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PageTwo()));
        askForPulse = false;
        nested.show = false;
      } else {
        askForPulse = false;
        nested.show = false;
        fractionPulse = 0;
        progressPulseCheck = true;
        _speechThis('Continue compressions');
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

  loadPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    playCompressions = prefs.getBool('playCompressions') ?? true;
    playVoice = prefs.getBool('playVoice') ?? true;
    print('loaded ' + playCompressions.toString() + playVoice.toString());
    if (!playCompressions) {
      setState(() {
        soundIcon = Icon(FlutterIcons.metronome_tick_mco);
        soundColor = Colors.grey;
      });
    }
    if (!playVoice) {
      setState(() {
        voiceIcon = Icon(FlutterIcons.voice_off_mco);
        voiceColor = Colors.grey;
      });
    }
  }

  savePreferences() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('playCompressions', playCompressions);
    prefs.setBool('playVoice', playVoice);
    print('saved ' + playCompressions.toString() + playVoice.toString());
  }

  Future<void> _showMyDialog() async {
    var prefs = await SharedPreferences.getInstance();
    String test = prefs.getString('log') ?? null;
    print('found log ' + test);
    if (test != null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Previous Code Saved'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('An unfunished code was found'),
                  Text('Would you like to resume?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('No start new code'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Yes resume previous code'),
                onPressed: () {
                  Navigator.of(context).pop();
                  globals.log = test;
                },
              ),
            ],
          );
        },
      );
    }
  }
  @override
  void initState() {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    WidgetsBinding.instance.addObserver(this);
    loadPreferences();

    nested = NestedTabBar(
      parent: this,
    );


    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy/MM/dd kk:mm').format(now);
    globals.log = formattedDate + "\tCode Started";
    globals.codeStart = now;
    super.initState();

    minPassed = 0;
    secPassed = 0;
    dispSec = 0;
    fraction = 0;

    _triggerUpdate();

    Future<void>.delayed(
        Duration(seconds: 10),
        () => {
              Wakelock.enable(),
              if (askForTour)
                {
                  switchedCompressor(),
                  askForTour = false,
                }
            });

  }

  bool compressorBadge = false;
  switchedCompressor() {
    setState(() {
      compressorBadge = false;
      lastSwitchedComp = DateTime.now();
    });
  }

  bool askForTour = false;
  int currentCoachWidget = 0;
  List<String> coachInfo = [
    "This is the time since code start",
    "This shows how long until next pulse check",
    "This is the current instructions",
    "Here is your checklist",
    "These are your medications",
    "This will help you track compression and breath rates",
    "This reminds you of common reversible causes of cardiopulmonary arrest",
    "Here are other options"
  ];
  List<GlobalObjectKey> coachKeys = [
    GlobalObjectKey('timerCircle'),
    GlobalObjectKey('circleProgress'),
    GlobalObjectKey('inst'),
    GlobalObjectKey('tab1'),
    GlobalObjectKey('tab2'),
    GlobalObjectKey('tab3'),
    GlobalObjectKey('tab4'),
    GlobalObjectKey('tab5'),
  ];
  showCoach() {
    CoachMark coachMark = CoachMark();
    RenderBox target =
        coachKeys[currentCoachWidget].currentContext.findRenderObject();
    Rect markRect = target.localToGlobal(Offset.zero) & target.size;
    markRect = markRect.inflate(
        5.0); //Rect.fromCircle(center: markRect.center, radius: markRect.longestSide * 0.6);
    coachMark.show(
        targetContext: GlobalObjectKey('timerCircle').currentContext,
        markRect: markRect,
        markShape: BoxShape.rectangle,
        children: [
          Positioned(
              top: markRect.bottom + 15.0,
              width: MediaQuery.of(context).size.width,
              child: Text(coachInfo[currentCoachWidget],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ))),
        ],
        duration: null,
        onClose: () {
          currentCoachWidget++;
          if (currentCoachWidget < coachKeys.length) {
            showCoach();
          } else {
            currentCoachWidget = 0;
            print('done coaching');
          }
        });
  }

  FlutterTts flutterTts = FlutterTts();
  Future _speak() async {
    flutterTts.setVolume(1.0);

    player.play('2.wav', volume: 0);
    await _speechThis("Start compressions right away");
    await player.load('2.wav');

    flutterTts.setCompletionHandler(() {
      print('completion handler');
      if (playCompressions) {
        startMetronome();
      }
      print('finished speaching');
    });


  }

  _speechThis(String string) async {
    if (playVoice) {
      print('about to say: ' + string);
      if (playCompressions) {
        if (metronomeTimer != null) {
          metronomeTimer.cancel();
        }
      }
      var result = await flutterTts.speak(string);
    }
  }

  bool playCompressions = true;
  Timer metronomeTimer;
  startMetronome() async {
    print('start metronome');
    if (metronomeTimer != null) {
      print('tried to start when already running');
      metronomeTimer.cancel();
    }
    metronomeTimer = Timer.periodic(Duration(milliseconds: 545), (timer) {
      print('about to play');
      metronome(player);
    });
  }

  metronome(AudioCache player) {
    if (playCompressions) {
      print('loaded: ' + player.loadedFiles.toString());
      print(DateTime.now());
      player.play('2.wav');
    }
  }

  toggleSound() {
    playCompressions = !playCompressions;
    savePreferences();
    print('play compressions ' + playCompressions.toString());
    if (!playCompressions) {
      if (metronomeTimer != null) {
        metronomeTimer.cancel();
      }
      setState(() {
        soundIcon = Icon(FlutterIcons.metronome_tick_mco);
        soundColor = Colors.grey;
      });
    } else {
      setState(() {
        soundIcon = Icon(FlutterIcons.metronome_mco);
        soundColor = Theme.of(context).primaryColor;
      });
      metronomeTimer = Timer.periodic(Duration(milliseconds: 545), (timer) {
        metronome(player);
      });
    }
  }

  toggleVoice() {
    playVoice = !playVoice;
    savePreferences();
    if (playVoice) {
      setState(() {
        voiceIcon = Icon(FlutterIcons.voice_mco);
        voiceColor = Theme.of(context).primaryColor;
      });
    } else {
      setState(() {
        voiceIcon = Icon(FlutterIcons.voice_off_mco);
        voiceColor = Colors.grey;
      });
    }
  }

  bool playVoice = true;
  Icon soundIcon = Icon(FlutterIcons.metronome_mco);
  Color soundColor = Colors.red;
  List<Widget> timelineTiles = List<Widget>();
  Icon voiceIcon = Icon(FlutterIcons.voice_mco);
  Color voiceColor = Colors.red;

  Widget handsFreeWidget = Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Expanded(
          child: Container(
        child: AutoSizeText(
          'HANDS FREE MODE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 300,
            color: Colors.white,
          ),
        ),
        alignment: Alignment.center,
      )),
      Expanded(
        child: FittedBox(
          alignment: Alignment.center,
          child: Icon(
            FlutterIcons.hand_ent,
            size: 500,
            color: Colors.white,
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    List<String> eventSplit = globals.log.split('\n');
    editTimeline(int i) {
      setState(() => {
            timelineEditing = i,
          });
    }

    if (globals.reset) {
      print("reseting now");
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      globals.log = formattedDate + "\tCode Started\t00:00";
      minPassed = 0;
      secPassed = 0;
      dispSec = 0;
      fraction = 0;
      fractionPulse = 0;
      askForPulse = false;
      globals.reset = false;
      progressPulseCheck = true;
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
                    progressPulseCheck = true;
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
                                      color: Theme.of(context).accentColor,
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
                                                  color: Theme.of(context)
                                                      .primaryColor,
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
                          fractionPulse = 0;
                          progressPulseCheck = true;
                          _speechThis('Continue Compressions');
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
      handFreeColor = Theme.of(context).accentColor;
      temp = pulseStack;
      handsFreeWidget = Column(
        children: [
          Expanded(
            child: FittedBox(
              child: Text(
                'New Cycle',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 200,
                ),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              child: Icon(
                Icons.touch_app_sharp,
                color: Colors.white,
                size: 200,
              ),
            ),
          )
        ],
      );
    } else {
      handFreeColor = Theme.of(context).primaryColor;
      handsFreeWidget = Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              child: Container(
            child: AutoSizeText(
              'HANDS FREE MODE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 300,
                color: Colors.white,
              ),
            ),
            alignment: Alignment.center,
          )),
          Expanded(
            child: FittedBox(
              alignment: Alignment.center,
              child: Icon(
                FlutterIcons.hand_ent,
                size: 500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
    if (handsFree) {
      temp.add(Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => setState(() {
                  if (askForPulse) {
                    print('new cycle hands free');
                    askForPulse = false;
                    nested.show = false;
                    progressPulseCheck = true;
                    _speechThis('Resume Compressions');
                  }
                }),
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: handFreeColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: handsFreeWidget,
                ),
              ),
            ),
            Expanded(
                flex: 1,
                child: Container(
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: TextButton(
                      onPressed: () => {
                        setState(() => {

                              handsFree = false,
                            })
                      },
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Text(
                                'Exit Hands Free',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 300,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: FittedBox(
                            child: Icon(FlutterIcons.notes_medical_faw5s,
                              size: 300,
                              color: Theme.of(context).primaryColor,
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ));
    }

    Widget content =
        Text('Switch compressors!', style: TextStyle(color: Colors.white));
    if (askForTour) {
      content = GestureDetector(
          onTap: () => {
                switchedCompressor(),
                showCoach(),
                askForTour = false,
              },
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Text('Tap for tour',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white))));
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
            String time = '';
            String rest = eventSplit[i];
            if (eventSplit[i].length > 5) {
              time = eventSplit[i].substring(0, 5);
              rest = eventSplit[i].substring(5);
            }
            if (eventSplit[i].contains('Pulse')) {
              icon = Icons.check_circle;
              iconSize = 40;
              height = 120;
            }
            if (eventSplit[i].contains('Shock')) {
              icon = Icons.all_out;
              iconSize = 40;
              height = 120;
            }
            if (eventSplit[i].contains('Code')) {
              icon = Icons.all_out;
              iconSize = 40;
              height = 120;
            }
            if (eventSplit[i].contains('Epinephrine')) {}
            if (i == 0) {
              first = true;
              time = '';
              rest = eventSplit[i];
            }
            if (i == eventSplit.length - 1) {
              last = true;
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
              lineXY: 0.3,
              startChild: Container(
                height: height,
                alignment: Alignment.center,
                child: Text(time),
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
                  color: Theme.of(context).primaryColor,
                  padding: EdgeInsets.all(8),
                  iconStyle: IconStyle(
                    iconData: icon,
                    color: Colors.white,
                  )),
            );
            timelineTiles.add(Slidable(
                key: Key(i.toString() + 'timeline'),
                actionPane: SlidableBehindActionPane(),
                actionExtentRatio: 0.2,
                secondaryActions: [
                  IconSlideAction(
                    caption: 'delete',
                    icon: FlutterIcons.delete_mdi,
                    color: Theme.of(context).primaryColor,
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

    Widget full = Column(children: <Widget>[
      Stack(
        children: [
          Badge(
            borderRadius: 10,
            showBadge: compressorBadge,
            badgeContent: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                content,
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
                      key: GlobalObjectKey('circleProgress'),
                      radius: (MediaQuery.of(context).size.width * 2 / 3),
                      lineWidth: 10.0,
                      percent: fraction,
                      animation: true,
                      animationDuration: 1000,
                      animateFromLastPercent: true,
                      circularStrokeCap: CircularStrokeCap.round,
                      footer: FittedBox(
                        child: AutoSizeText(
                          inst,
                          key: GlobalObjectKey('inst'),
                          style: new TextStyle(
                            fontSize: 40.0,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      center: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            Icon(
                              centerIcon,
                              size: MediaQuery.of(context).size.width / 4,
                              color: barColor,
                            ),
                            Text('pulse check in'),
                            Text(
                              '-' + pulseCheckCountdown,
                              textAlign: TextAlign.center,
                              key: GlobalObjectKey('timerCircle'),
                              style: new TextStyle(
                                fontSize: 40.0,
                              ),
                            ),
                            Text(
                              'time elapsed ' + currentTime(),
                            ),
                          ])),
                      backgroundColor: Colors.grey,
                      progressColor: barColor,
                    ),
                  ]),
            ),
          ),
          Positioned(
            child: Column(
              children: [
                IconButton(
                  icon: soundIcon,
                  color: soundColor,
                  onPressed: () => {toggleSound()},
                ),
                IconButton(
                  icon: voiceIcon,
                  color: voiceColor,
                  onPressed: () => {toggleVoice()},
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 25,
            child: GestureDetector(
              onTap: () => {
                updateDrawer(),
                _scaffoldKey.currentState.openEndDrawer(),
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15)),
                  color: Theme.of(context).primaryColor,
                ),
                alignment: Alignment.center,
                child: Icon(
                  FlutterIcons.timeline_alert_mco,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
                      color: Theme.of(context).primaryColor,
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
                              _speak();
                              _showMyDialog();
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


    //print('event parts ' + eventSplit.toString());
    Scaffold s = Scaffold(
      endDrawerEnableOpenDragGesture: false,
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black54,
              ),
              child: Container(
                height: 80,
                alignment: Alignment.center,
                child: Text(
                  'Code Events',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            Container(
              height: 20,
              color: Colors.black12,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text('Time', textAlign: TextAlign.center),
                  ),
                  VerticalDivider(),
                  Expanded(
                      flex: 10,
                      child: Text('Time Since Code Start',
                          textAlign: TextAlign.center))
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ReorderableListView(
                  onReorder: onReorder,
                  children: timelineTiles,
                  scrollController: ScrollController(),
                ),
              ),
            ),
            Container(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                      child: Text('add event'),
                      onPressed: () => {
                            globals.log = globals.log + '\n??:?? new event',
                            updateDrawer(),
                          })
                ],
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [Container()],
        title: Text(
          "Heart Start",
        ),
        // leading: Builder(
        //   builder: (context) => IconButton(
        //     icon: Icon(FlutterIcons.timeline_alert_mco),
        //     onPressed: () => {
        //       updateDrawer(),
        //       Scaffold.of(context).openDrawer()},
        //   ),
        // ),
      ),
      body: Stack(
        children: fullStack,
      ),
    );
    return s;
    currentScaffold = s;
  }
}

Scaffold currentScaffold;
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

class OpenPulseButton extends StatelessWidget {
  OpenPulseButton({@required this.onPressed});
  final GestureTapCallback onPressed;

  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: RawMaterialButton(
          fillColor: Theme.of(context).accentColor,
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
                        "Yes, Check\nPulse Now",
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
              fillColor: Theme.of(context).primaryColor,
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

class goForCode extends StatelessWidget {
  goForCode({@required this.onPressed});
  final GestureTapCallback onPressed;

  Widget build(BuildContext context) {
    return RawMaterialButton(
      fillColor: Theme.of(context).primaryColor,
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
