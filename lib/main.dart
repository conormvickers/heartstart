import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterheart/chesttypes_icons.dart';
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
import 'package:vibration/vibration.dart';
import 'package:quiver/async.dart';

void main() {
  runApp(MyApp());
}

var askForPulse = false;
var warningDismissed = false;
final _eventScrollController = ScrollController();
int timelineEditing = null;
TextEditingController timelineEditingController = TextEditingController();

final GlobalKey<NestedTabBarState> nestedKey = GlobalKey<NestedTabBarState>();
var nested = NestedTabBar(
  key: nestedKey,
);
var showShock = false;
var _shockType = "No weight documented";
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

class MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  static AudioCache player = AudioCache();
  static AudioPlayer cutg = AudioPlayer();

  bool enterCapno = false;
  FocusNode capnoNode = FocusNode();
  TextEditingController capnoController = TextEditingController();
  addCapnoToLog() {
    if (capnoController.text.length > 0) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('kk:mm').format(now);
      String combined =
          "\n" + formattedDate + "\tEtCO2 measured: " + capnoController.text;
      globals.log = globals.log + combined;
      capnoController.text = '';
    }
  }

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
      if (state == AppLifecycleState.paused) {
        print('saving log...');
        _saveLog();
        print('done');
      }
      if (state == AppLifecycleState.resumed) {}
    });
  }

  _saveLog() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('log', globals.log);
    String now = DateTime.now().toIso8601String();
    prefs.setString('logSaveTime', now);
  }

  _checkForWeight() {
    return Container();

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

  vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate();
    }
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

                  if (fractionPulse == 120) {
                    print('should open');
                    askForPulse = true;
                    _speechThis(
                        'Stop compressions. Resume compressions within 10 seconds');
                    barColor = Theme.of(context).accentColor;
                    inst = "Pulse Check";
                    centerIcon = Ionicons.ios_pulse;
                    progressPulseCheck = false;
                    vibrate();
                    if (handsFree) {
                      print('starting auto reset timer');
                      Future.delayed(Duration(seconds: 10), () {
                        autoRestartCycle();
                      });
                    }
                  } else {
                    barColor = Theme.of(context).primaryColor;
                    inst = "Continue Compressions";
                    centerIcon = checkChestType();
                  }
                  if (fractionPulse >= 120) {
                    fractionPulse = 0;
                  }
                }
              }),
            });
  }

  IconData chestIcon;
  IconData checkChestType() {
    if (chestIcon != null) {
      return chestIcon;
    }

    return FlutterIcons.heart_ant;
  }

  autoRestartCycle() {
    if (!progressPulseCheck) {
      setState(() {
        if (askForPulse) {
          print('new cycle hands free');
          askForPulse = false;
          nested.show = false;
          progressPulseCheck = true;
          _speechThis('Resume Compressions');
        }
      });
    }
  }

  List<String> shockDoses = [
    'EXTERNAL: 20 J mono, 6 J bi\nINTERNAL:l 2 J mono, 1 J bi',
    'EXTERNAL: 30 J mono, 15 J bi\nINTERNAL: 3 J mono, 2 J bi',
    'EXTERNAL: 50 J mono, 30 J bi\nINTERNAL: 5 J mono, 3 J bi',
    'EXTERNAL: 100 J mono, 50 J bi\nINTERNAL: 10 J mono, 5 J bi',
    'EXTERNAL: 200 J mono, 75 J bi\nINTERNAL: 20 J mono, 6 J bi',
    'EXTERNAL: 200 J mono, 75 J bi\nINTERNAL: 20 J mono, 8 J bi',
    'EXTERNAL: 200 J mono, 100 J bi\nINTERNAL: 20 J mono, 9 J bi',
    'EXTERNAL: 300 J mono, 150 J bi\nINTERNAL: 30 J mono, 10 J bi',
    'EXTERNAL: 300 J mono, 150 J bi\nINTERNAL: 30 J mono, 15 J bi',
    'EXTERNAL: 300 J mono, 150 J bi\nINTERNAL: 30 J mono, 15 J bi',
    'EXTERNAL: 360 J mono, 150 J bi\nINTERNAL: 50 J mono, 15 J bi',
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
        String full = combined.toString() + "\t";
        globals.log = globals.log + full;
        if (playCompressions) {
          toggleSound();
        }
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
      String full = combined.toString() + "\t";
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

    if (test != null) {
      print('found log ' + test);
    }
    if (test != null) {
      String st = prefs.getString('logSaveTime') ?? null;
      DateTime dt;
      if (st == null) {
        return;
      } else {
        dt = DateTime.parse(st);
      }

      if (dt.difference(DateTime.now()).inMinutes.abs() > 30) {
        return;
      }
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
      key: nestedKey,
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
    "This is the time until next pulse check",
    "When this ring fills completely, it is time for a pulse check",
    "This displays the current place in the cycle",
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
      // metronome(player);
    });
  }

  metronome(AudioCache player) async {
    if (playCompressions) {
      print(DateTime.now());
      //player.play('2.wav');
      cutg = await player.play('longmp.mp3');
    }
  }

  toggleSound() async {
    playCompressions = !playCompressions;
    savePreferences();
    print('play compressions ' + playCompressions.toString());
    if (!playCompressions) {
      cutg.stop();
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
      metronome(player);
      // Metronome.periodic(Duration(milliseconds: 545)).listen((event) {
      //   print('metronome ' + event.toString());
      //   metronome(player);
      // });
      metronomeTimer = Timer.periodic(Duration(minutes: 5), (timer) {
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
                      backgroundColor: Colors.transparent,
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
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
                                        color: Colors.white,
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
                                        color: Colors.black54,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: Container(),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border(
                                                                top: BorderSide(
                                                                    width: 2,
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
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
                                                        'Asystole - no shock',
                                                        style: TextStyle(
                                                            fontSize: 40,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  onTap: () => {_selectedPulse('asystole')},
                                ),
                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      height: 100,
                                      child: Row(
                                        children: <Widget>[
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
                                                    child: ShaderMask(
                                                      child: Image.asset(
                                                        ('assets/pea.png'),
                                                        fit: BoxFit.fill,
                                                      ),
                                                      shaderCallback:
                                                          (Rect bounds) {
                                                        return LinearGradient(
                                                          colors: [
                                                            Colors.white,
                                                            Colors.white
                                                          ],
                                                          stops: [0.0, 0.0],
                                                        ).createShader(bounds);
                                                      },
                                                      blendMode:
                                                          BlendMode.srcATop,
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
                                                            fontSize: 40,
                                                            color:
                                                                Colors.white),
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
                                        color: Colors.black54,
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
                                                    child: ShaderMask(
                                                      child: Image.asset(
                                                        ('assets/vfib.png'),
                                                        fit: BoxFit.fill,
                                                      ),
                                                      shaderCallback:
                                                          (Rect bounds) {
                                                        return LinearGradient(
                                                          colors: [
                                                            Colors.white,
                                                            Colors.white
                                                          ],
                                                          stops: [0.0, 0.0],
                                                        ).createShader(bounds);
                                                      },
                                                      blendMode:
                                                          BlendMode.srcATop,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: AutoSizeText(
                                                    'Ventricular Fibrillation',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                        ],
                                      )),
                                  onTap: () => {_selectedPulse('vfib')},
                                ),
                                ListTile(
                                  title: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
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
                                                    child: ShaderMask(
                                                      child: Image.asset(
                                                        ('assets/vtach.png'),
                                                        fit: BoxFit.fill,
                                                      ),
                                                      shaderCallback:
                                                          (Rect bounds) {
                                                        return LinearGradient(
                                                          colors: [
                                                            Colors.white,
                                                            Colors.white
                                                          ],
                                                          stops: [0.0, 0.0],
                                                        ).createShader(bounds);
                                                      },
                                                      blendMode:
                                                          BlendMode.srcATop,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: AutoSizeText(
                                                    'Pulseless Ventricular Tachycardia',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                        ],
                                      )),
                                  onTap: () => {_selectedPulse('vtach')},
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
                          String full = combined.toString() + "\t";
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
          ),
          Text('tap', style: TextStyle(color: Colors.white)),
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
                          Expanded(
                              child: FittedBox(
                            child: Icon(
                              FlutterIcons.notes_medical_faw5s,
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

    Widget checkIfWeightChest() {
      return Container();
      if (globals.chest != null && globals.weightKG != null) {
        return GestureDetector(
          onTap: () => {
            print('change weight'),
            setState(() {
              globals.weightKG = null;
              globals.weightIndex = null;
              globals.chest = null;
              print('reset weight ' + globals.weightKG.toString());
              nestedKey.currentState.setState(() {
                nestedKey.currentState.nestedTabController.animateTo(1);
              });
            }),
          },
          child: Container(
            width: 100,
            height: 50,
            child: Text(
              'weight: ' +
                  globals.weightKG.toStringAsPrecision(2) +
                  'kg\nchest: ' +
                  globals.chest,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
                border: Border.all(color: Colors.red, width: 3),
                color: Colors.red),
          ),
        );
      }
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
                      // Icon(
                      //   FlutterIcons.drag_handle_mdi,
                      // ),
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
            timelineTiles.add(
                // Slidable(
                // key: Key(i.toString() + 'timeline'),
                // actionPane: SlidableBehindActionPane(),
                // actionExtentRatio: 0.2,
                // secondaryActions: [
                //   IconSlideAction(
                //     caption: 'delete',
                //     icon: FlutterIcons.delete_mdi,
                //     color: Theme.of(context).primaryColor,
                //     onTap: () => {
                //       setState(() => {
                //             eventSplit.removeAt(i),
                //             globals.log = eventSplit.join('\n'),
                //             print(globals.log),
                //             timelineEditing = null,
                //             FocusScope.of(context).unfocus(),
                //             updateDrawer(),
                //           })
                //     },
                //   )
                // ],
                // child:
                add
                // )
                );
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
                            Container(
                              height: 30,
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                width: 1000,
                                child: Icon(
                                  centerIcon,
                                  color: barColor,
                                  size: MediaQuery.of(context).size.width / 4,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
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
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(),
                            )
                          ])),
                      backgroundColor: Colors.grey,
                      progressColor: barColor,
                    ),
                  ]),
            ),
          ),
          Column(
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
          Positioned(
            left: 0,
            bottom: 40,
            child: checkIfWeightChest(),
          ),
          Positioned(
            right: 0,
            bottom: 40,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(FlutterIcons.gas_cylinder_mco, color: Colors.red),
                  onPressed: () => {
                    print('enter etco2 data'),
                    setState(() {
                      enterCapno = true;
                      // Future.delayed(Duration(seconds: 10), () {
                      print('requesting focus');
                      capnoNode.requestFocus();
                      // });
                    }),
                  },
                ),
                IconButton(
                  icon: Icon(FlutterIcons.dog_side_mco, color: Colors.red),
                  onPressed: () => {
                    print('change weight'),
                    setState(() {
                      globals.weightKG = null;
                      globals.weightIndex = null;
                      globals.chest = null;
                      print('reset weight ' + globals.weightKG.toString());
                      nestedKey.currentState.setState(() {
                        nestedKey.currentState.nestedTabController.animateTo(1);
                      });
                    }),
                  },
                ),
                IconButton(
                  icon: Icon(
                    FlutterIcons.pulse_mco,
                    color: Colors.red,
                  ),
                  onPressed: () => {
                    setState(
                      () {
                        askForPulse = true;
                      },
                    ),
                  },
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

    Widget enterCapnographyData() {
      if (enterCapno) {
        return GestureDetector(
          onTap: () => {
            setState(() => {
                  enterCapno = false,
                })
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(30),
                  color: Colors.black38,
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      focusNode: capnoNode,
                      // autofocus: false,
                      decoration: InputDecoration(
                        labelText: 'End-Title CO2 Measurement',
                      ),
                      controller: capnoController,
                      keyboardType: TextInputType.number,
                      onEditingComplete: () => {
                        addCapnoToLog(),
                        setState(() => {
                              enterCapno = false,
                            }),
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        );
      }

      return Container();
    }

    var fullStack = <Widget>[full, enterCapnographyData()];
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
                  'Options',
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(child: Icon(FlutterIcons.md_options_ion))
            ],
          ),
        ),
        RaisedButton(
          child: Text('Check Pulse Now'),
          onPressed: () {
            setState(() {
              askForPulse = true;
              Navigator.pop(context);
            });
          },
        ),
        RaisedButton(
          child: Text('Change Weight'),
          onPressed: () {
            setState(() {
              globals.weightKG = null;
              globals.weightIndex = null;
              globals.chest = null;
              print('reset weight ' + globals.weightKG.toString());
              nestedKey.currentState.setState(() {
                nestedKey.currentState.nestedTabController.animateTo(1);
              });

              Navigator.pop(context);
            });
          },
        ),
        RaisedButton(
          child: Text('Stop Code Now'),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
            nestedKey.currentState.stopCode();
          },
        ),
        RaisedButton(
          onPressed: _launchURL,
          child: Text('Open Source Information'),
        ),
        RaisedButton(
          onPressed: () => {
            setState(() => {
                  Navigator.pop(context),
                }),
            handsFree = true
          },
          child: Text('Hands Free Mode'),
        ),
        RaisedButton(
          onPressed: () => {
            setState(() => {
                  Navigator.pop(context),
                }),
            showCoach()
          },
          child: Text('Start tour'),
        ),
      ];
    }

    Scaffold s = Scaffold(
      endDrawerEnableOpenDragGesture: false,
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      drawer: Drawer(
        child: Column(
          children: settingItems(),
        ),
      ),
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
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  //ReorderableListView(
                  //onReorder: onReorder,
                  children: timelineTiles,
                  //scrollController: ScrollController(),
                ),
              ),
            ),
            // Container(
            //   height: 100,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       RaisedButton(
            //           child: Text('add event'),
            //           onPressed: () => {
            //                 globals.log = globals.log + '\n??:?? new event',
            //                 updateDrawer(),
            //               })
            //     ],
            //   ),
            // )
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
