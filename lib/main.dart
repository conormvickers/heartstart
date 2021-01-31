import 'dart:ui';
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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:undo/undo.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

var askForPulse = false;
var warningDismissed = false;
final _eventScrollController = ScrollController();
int timelineEditing = null;
TextEditingController timelineEditingController = TextEditingController();
final GlobalKey<NestedTabBarState> nestedKey = GlobalKey<NestedTabBarState>();
Scaffold currentScaffold;
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
var nested = NestedTabBar(
  key: nestedKey,
);
var showShock = false;
var _shockType = "No weight documented";
var handFreeColor;

class MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  bool handsFree = true;
  double fraction = 0;
  double minPassed = 0;
  double secPassed = 0;
  double fractionPulse = 0;
  double dispSec = 0;
  double _weightValue = 5;
  bool enterCapno = false;
  FocusNode capnoNode = FocusNode();
  TextEditingController capnoController = TextEditingController();
  Color barColor;
  CircularPercentIndicator cycle;
  IconData centerIcon = FlutterIcons.heart_ant;
  String inst = "Continue Compressions";
  DateTime lastSwitchedComp = DateTime.now().add(Duration(minutes: 2));
  bool progressPulseCheck = true;
  String pulseCheckCountdown = '';
  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  IconData chestIcon;
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
  IconData checkChestType() {
    if (chestIcon != null) {
      return chestIcon;
    }

    return FlutterIcons.heart_ant;
  }

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
  FlutterTts flutterTts = FlutterTts();
  bool playCompressions = true;
  Timer metronomeTimer;
  AudioPlayer player = AudioPlayer();
  AudioPlayer playerB = AudioPlayer();

  bool playVoice = true;
  Icon soundIcon = Icon(FlutterIcons.metronome_mco);
  Color soundColor = Colors.red;
  List<Widget> timelineTiles = List<Widget>();
  Icon voiceIcon = Icon(FlutterIcons.voice_mco);
  Color voiceColor = Colors.red;
  String addEventString = 'End Tidal CO2';
  String addEventStringlog = 'etCO2 (mmHg): ';
  TextInputType eventKeyboard =
      TextInputType.numberWithOptions(signed: true, decimal: true);

  addCapnoToLog() {
    if (capnoController.text.length > 0) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('kk:mm').format(now);
      String combined = "\n" +
          formattedDate +
          "\t" +
          addEventStringlog +
          ' ' +
          capnoController.text;

      globals.log = globals.log + combined;
      capnoController.text = '';
    }
  }

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

  currentTime() {
    globals.publicCodeTime =
        _printDuration(Duration(seconds: secPassed.toInt()));

    return globals.publicCodeTime;
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
              secPassed++,
              if (progressPulseCheck) {fractionPulse++, updateCircle()}
            });
  }

  updateCircle() {
    setState(() {
      pulseCheckCountdown =
          ' ' + _printDuration(Duration(seconds: 120 - fractionPulse.toInt()));
      if (120 - fractionPulse.toInt() == 10) {
        _speechThis('10 seconds to pulse check');
      }

      fraction = fractionPulse / 120;

      if (fractionPulse == 120) {
        print('should open');
        askForPulse = true;
        _speechThis(
            'Stop compressions. Restart compressions within 10 seconds');
        barColor = Theme.of(context).accentColor;
        inst = "Pulse Check";
        centerIcon = Ionicons.ios_pulse;
        progressPulseCheck = false;
        player.setVolume(0);
        playerB.setVolume(0);
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
    });
  }

  autoRestartCycle() {
    if (!progressPulseCheck) {
      setState(() {
        if (askForPulse) {
          print('new cycle hands free');
          askForPulse = false;
          nested.show = false;
          progressPulseCheck = true;
          player.setVolume(1);
          playerB.setVolume(1);
          _speechThis('Restart Compressions');
        }
      });
    }
  }

  _selectedPulse(String selected) {
    Navigator.of(context).pop();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm').format(now);
    String combined = "\n" +
        formattedDate +
        "\tPulse check: " +
        selected.toString() +
        " identified";
    String full = combined.toString() + "\t";
    globals.log = globals.log + full;
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
        player.setVolume(1);
        playerB.setVolume(1);
        _speechThis('Continue compressions');
      }
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
    } else {
      startMetronome();
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

  Future<void> _ensureStopCode() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Stop Code Now?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to stop the code now?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes, got pulse'),
              onPressed: () {
                Navigator.of(context).pop();
                globals.log = globals.log + '\n Code stopped: pulse found';
                nestedKey.currentState.stopCode();
              },
            ),
            TextButton(
              child: Text('Yes, stop resuscitation'),
              onPressed: () {
                Navigator.of(context).pop();
                globals.log = globals.log +
                    '\n Code stopped: resuscitation efforts withdrawn';
                nestedKey.currentState.stopCode();
              },
            ),
            TextButton(
              child: Text('No resume code'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addObserver(this);

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

    loadPreferences();

    Future<void>.delayed(
        Duration(seconds: 10),
        () => {
              Wakelock.enable(),
            });
  }

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

  Future _speak() async {
    flutterTts.setVolume(1.0);

    flutterTts.setCompletionHandler(() {
      print('completion handler');

      print('finished speaching');
    });
  }

  _speechThis(String string) async {
    if (playVoice) {
      print('about to say: ' + string);

      var result = await flutterTts.speak(string);
    }
  }

  startMetronome() async {
    setState(() {
      soundIcon = Icon(FlutterIcons.metronome_mco);
      soundColor = Theme.of(context).primaryColor;
    });

    await player.setLoopMode(LoopMode.one);
    await playerB.setLoopMode(LoopMode.one);

    var duration = await player.setAsset('assets/longmp.mp3');
    player.play();

    var durationB = await playerB.setAsset('assets/breath.mp3');
    playerB.play();
  }

  stopMetronome() async {
    player.stop();
    playerB.stop();
    setState(() {
      soundIcon = Icon(FlutterIcons.metronome_tick_mco);
      soundColor = Colors.grey;
    });
  }

  toggleSound() async {
    playCompressions = !playCompressions;
    savePreferences();
    print('play compressions ' + playCompressions.toString());
    if (!playCompressions) {
      stopMetronome();
    } else {
      startMetronome();
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
      player.setVolume(1);
      playerB.setVolume(1);
    }

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
                    player.setVolume(1);
                    playerB.setVolume(1);
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
        child: Column(
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
                      String formattedDate = DateFormat('kk:mm').format(now);
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
                      player.setVolume(1);
                      playerB.setVolume(1);
                      _speechThis('Continue Compressions');
                    }),
                  ),
                ],
              ),
            ),
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
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FittedBox(
                  alignment: Alignment.center,
                  child: Icon(
                    FlutterIcons.hand_ent,
                    size: 500,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: Center(
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                            ),
                                          ),
                                          Expanded(
                                            child: FittedBox(
                                              child: Icon(
                                                  FlutterIcons.clock_faw5,
                                                  color: Colors.red),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: FittedBox(
                                              child: Icon(
                                                  FlutterIcons.undo_alt_faw5s,
                                                  color: Colors.red),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() => {
                                      fractionPulse = 0,
                                      updateCircle(),
                                    }), // handle your onTap here
                                child: Container(),
                              ),
                            ),
                          ],
                        )),
                    Container(
                      width: 10,
                    )
                  ],
                )
              ],
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
                    player.setVolume(1);
                    playerB.setVolume(1);
                    _speechThis('Restart Compressions');
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

    Widget leftBottom() {
      return Column(children: [
        IconButton(
            icon: Icon(FlutterIcons.note_add_mdi, color: Colors.red),
            onPressed: () => {
                  print('enter other data'),
                  setState(() {
                    addEventString = 'Miscellaneous Event';
                    addEventStringlog = '';
                    eventKeyboard = TextInputType.text;
                    enterCapno = true;
                    // Future.delayed(Duration(seconds: 10), () {
                    print('requesting focus');
                    capnoNode.requestFocus();
                    // });
                  }),
                }),
        IconButton(
          icon: Container(
            width: 100,
            height: 100,

            child: FittedBox(
                child: Text(
              'CO\u2082',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )), //Icon(Chesttypes.co2_1, color: Colors.red),
          ),
          onPressed: () => {
            print('enter etco2 data'),
            addEventString = 'End Tidal CO2',
            addEventStringlog = 'etCO2: (mmHg)',
            eventKeyboard =
                TextInputType.numberWithOptions(signed: true, decimal: true),
            setState(() {
              enterCapno = true;
              // Future.delayed(Duration(seconds: 10), () {
              print('requesting focus');
              capnoNode.requestFocus();
              // });
            }),
          },
        ),
      ]);
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
          Container(
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
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Container(
                                width: 1000,
                                child: Icon(
                                  centerIcon,
                                  color: barColor,
                                  size: MediaQuery.of(context).size.width / 4,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: FittedBox(
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
            child: leftBottom(),
          ),
          Positioned(
            right: 0,
            bottom: 40,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(FlutterIcons.cancel_mco, color: Colors.red),
                  onPressed: () => {_ensureStopCode()},
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

    Widget units() {
      if (addEventString.contains('CO2')) {
        return Column(
          children: [
            Container(
              height: 20,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '   mmHg',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      }

      return Container();
    }

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
                    height: 100,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            textAlign: TextAlign.right,
                            focusNode: capnoNode,
                            decoration: InputDecoration(
                              labelText: addEventString,
                            ),
                            controller: capnoController,
                            keyboardType: eventKeyboard,
                            onEditingComplete: () => {
                              addCapnoToLog(),
                              setState(() => {
                                    enterCapno = false,
                                  }),
                            },
                          ),
                        ),
                        units()
                      ],
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
            _ensureStopCode();
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
  }
}

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
