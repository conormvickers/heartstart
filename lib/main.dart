import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'nestedTabBarView.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'globals.dart' as globals;
import 'package:intl/intl.dart' as intl;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:wakelock/wakelock.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:just_audio/just_audio.dart';
import 'package:transparent_image/transparent_image.dart'
    show kTransparentImage;
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'dart:math' as math;
import 'package:customgauge/customgauge.dart';
import 'package:flutterheart/chesttypes_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mailto/mailto.dart';

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
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.blue,
        splashColor: Colors.red,
        indicatorColor: Colors.lightBlueAccent,
        primarySwatch: Colors.lightBlue,
        disabledColor: Colors.black,
        accentTextTheme: TextTheme(bodyText2: TextStyle(color: Colors.white)),
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

GlobalKey<NestedTabBarState> nestedKey = GlobalKey<NestedTabBarState>();
Scaffold currentScaffold;

int timelineEditing;
var nested = NestedTabBar(
  key: nestedKey,
);
var showShock = false;
var _shockType = "No weight documented";
var handFreeColor;

class MyHomePageState extends State<MyHomePage>
    with
        WidgetsBindingObserver,
        TickerProviderStateMixin,
        WidgetsBindingObserver {
  bool handsFree = true;
  double fraction = 0;
  double minPassed = 0;
  double secPassed = 0;
  double fractionPulse = 0;
  double dispSec = 0;
  bool enterCapno = false;
  FocusNode capnoNode = FocusNode();
  TextEditingController capnoController = TextEditingController();
  MaterialColor barColor;
  IconData centerIcon = FlutterIcons.heart_ant;
  String inst = "Continue Compressions";
  bool progressPulseCheck = true;
  String pulseCheckCountdown = '';
  TextEditingController doctorController = TextEditingController();
  FocusNode doctorNode = FocusNode();
  int autoStart = 5;

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  IconData chestIcon;
  List<String> shockTypes = [
    'External mono',
    'External bi',
    'Internal mono',
    'Internal bi'
  ];
  List<List<String>> shockDoses = [
    [
      '20',
      '30',
      '50',
      '100',
      '200',
      '200',
      '200',
      '300',
      '300',
      '300',
      "300",
    ],
    ['6', '15', '30', '50', '75', '75', '100', '150', '150', '150', '150'],
    [
      '2',
      '3',
      '5',
      '10',
      '20',
      '20',
      '20',
      '30',
      '30',
      '30',
      '50',
    ],
    ["1", '2', '3', '5', '6', '8', '9', '10', '15', '15', '15'],
  ];

  IconData checkChestType() {
    if (chestIcon != null) {
      return chestIcon;
    }
    return FlutterIcons.heart_ant;
  }

  FlutterTts flutterTts = FlutterTts();
  bool playCompressions = true;
  Timer metronomeTimer;
  AudioPlayer player = AudioPlayer();
  AudioPlayer playerB = AudioPlayer();
  bool animate = true;
  bool run = true;
  AnimationController animCont;
  bool playVoice = true;
  Icon soundIcon = Icon(FlutterIcons.metronome_mco);
  MaterialColor soundColor = Colors.lightBlue;
  List<Widget> timelineTiles = [];
  Icon voiceIcon = Icon(FlutterIcons.voice_mco);
  MaterialColor voiceColor = Colors.lightBlue;
  String addEventString = 'End Tidal CO2';
  String addEventStringlog = 'etCO2 (mmHg): ';
  TextInputType eventKeyboard =
      TextInputType.numberWithOptions(signed: true, decimal: true);

  LinkedScrollControllerGroup _controllers;
  ScrollController _letters;
  ScrollController _numbers;

  AnimationController _timerAnimCont;
  Animation timerCurve;

  @override
  void initState() {
    chestTypeController = TabController(
      length: 3,
      vsync: this,
    );
    _controllers = LinkedScrollControllerGroup();

    _letters = _controllers.addAndGet();
    _numbers = _controllers.addAndGet();

    Timer.periodic(
        Duration(milliseconds: 1000),
        (Timer timer) => {
              setState(() {
                resetBreathingTimer();
              })
            });

    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _kOptions = <String>[...medNames, ...otherOptions];
    medDoses = [
      epilow,
      epihigh,
      vaso,
      atro,
      amio,
      lido,
      nalo,
      flum,
      atip,
    ];

    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation = IntTween(begin: 5, end: 100).animate(_animationController);
    _animation.addListener(() => setState(() {}));

    _timerAnimCont =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    timerCurve =
        CurvedAnimation(parent: _timerAnimCont, curve: Curves.easeOutExpo);
    timerCurve.addListener(() => setState(() {}));
    _timerAnimCont.value = 1;

    nested = NestedTabBar(
      parent: this,
      key: nestedKey,
    );

    globals.log = getTime() + " Code Started";

    minPassed = 0;
    secPassed = 0;
    dispSec = 0;
    fraction = 0;

    _triggerUpdate();

    loadPreferences();
    autoStartCascade();
    animCont = AnimationController(vsync: this);

    if (!kIsWeb) {
      Future<void>.delayed(
          Duration(seconds: 10),
          () => {
                Wakelock.enable(),
              });
    }
  }

  String getFormatedTime() {
    return DateTime.now().toIso8601String();
  }

  addCapnoToLog() {
    if (capnoController.text.length > 0) {
      String formattedDate = getFormatedTime();
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

  GlobalKey<PageTwoState> pageTwoKey = GlobalKey<PageTwoState>();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      print(state.toString());
      if (state == AppLifecycleState.paused) {
        print('saving log...');
        _saveLog();
        print('done');
        if (pageTwoKey != null) {
          if (pageTwoKey.currentState != null) {
            pageTwoKey.currentState.saveGlobalLog();
          }
        }
      }
      if (state == AppLifecycleState.resumed) {}
    });
  }

  resetEverything([bool resetlog = true]) {
    fraction = 0;
    minPassed = 0;
    secPassed = 0;
    fractionPulse = 0;
    dispSec = 0;

    if (!kIsWeb) {
      player.setVolume(1);
      playerB.setVolume(1);

      loadPreferences();
    }

    centerIcon = FlutterIcons.heart_ant;
    chestIcon = FlutterIcons.heart_ant;
    inst = "Continue Compressions";

    progressPulseCheck = true;

    if (resetlog) {
      globals.log = getTime() + ' Code Started';
      globals.weightKG = null;
      globals.weightIndex = null;
      globals.chest = null;
    } else {
      addLog('Rearrest');
    }

    return;
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

  int countDownFraction = 9;
  bool countDown = false;
  _triggerUpdate() {
    print('initializing timer');
    Timer.periodic(
        Duration(seconds: 1),
        (Timer timer) => {
              secPassed++,
              if (progressPulseCheck)
                {
                  fractionPulse++,
                },
              if (countDown) {countDownFraction--},
              updateCircle(),
            });
  }

  checkIfNeedDismissPulseAsk() {
    if (askingPulseCheck) {
      Navigator.of(context).pop();
    }
  }

  bool askingPulseCheck = false;
  askPulseCheck() async {
    if (showingFeedback) {
      return;
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        askingPulseCheck = true;
        return AlertDialog(
          title: Text('See Rhythm Options?'),
          actions: <Widget>[
            Container(
              constraints:
                  BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('No', style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
                      child: Text('Yes'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        selected = 'pulse';

                        openRecorder(true);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    askingPulseCheck = false;
  }

  updateCircle() {
    if (countDownFraction < 0) {
      countDownFraction = 9;
      countDown = false;
      progressPulseCheck = true;
      checkIfNeedDismissPulseAsk();
      autoRestartCycle();
    }

    if (countDown) {
      fraction = countDownFraction / 10;
    } else {
      pulseCheckCountdown =
          ' ' + _printDuration(Duration(seconds: 120 - fractionPulse.toInt()));
      if (120 - fractionPulse.toInt() == 10) {
        _speechThis('10 seconds to pulse check');
      }

      fraction = fractionPulse / 120;

      if (fractionPulse == 120) {
        print('should open');
        if (awaitingShock) {
          Navigator.of(context).pop();
        }
        askPulseCheck();

        _speechThis(
            'Stop compressions. Restart compressions within 10 seconds');
        barColor = Theme.of(context).accentColor;
        inst = "Pulse Check";
        centerIcon = Ionicons.ios_pulse;
        progressPulseCheck = false;
        countDown = true;
        player.setVolume(0);
        playerB.setVolume(0);
        vibrate();
        // if (handsFree) {
        //   print('starting auto reset timer');
        //   Future.delayed(Duration(seconds: 10), () {
        //     autoRestartCycle();
        //   });
        // }
      } else {
        barColor = Theme.of(context).splashColor;
        inst = "Continue Compressions";
        centerIcon = checkChestType();
      }
      if (fractionPulse >= 120) {
        fractionPulse = 0;
      }
    }
    setState(() {});
  }

  autoRestartCycle() {
    _speechThis('Restart Compressions');
  }

  _selectedPulse(String selected) {
    Navigator.of(context).pop();
    String formattedDate = getFormatedTime();
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
          // _shockType = shockDoses[globals.weightIndex];
        }
        _speechThis(
            'Continue compressions while charging. Ensure clear before shock');
      } else if (selected == "pulse") {
        stopAndGoToNextPage();
      } else {
        nested.show = false;
        fractionPulse = 0;
        progressPulseCheck = true;
        player.setVolume(1);
        playerB.setVolume(1);
        _speechThis('Continue compressions');
      }
    });
  }

  addToLog(String string) {
    String formattedDate = getFormatedTime();
    String combined = "\n" + formattedDate + "\t" + string;

    globals.log = globals.log + combined;
  }

  stopAndGoToNextPage([String reason = '']) async {
    addLog('Code Stopped');

    if (!kIsWeb) {
      player.setVolume(0);
      playerB.setVolume(0);
      progressPulseCheck = false;

      nested.show = false;
    }

    final reset = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PageTwo(
                  key: pageTwoKey,
                )));
    print('returned ' + reset.toString());
    if (reset == 'true') {
      print('returned reset');
      resetEverything();
    } else {
      print('rearest or continue');

      resetEverything(false);
    }
  }

  loadPreferences() async {
    var prefs = await SharedPreferences.getInstance();
    playCompressions = prefs.getBool('playCompressions') ?? true;
    playVoice = prefs.getBool('playVoice') ?? true;
    doctorController.text = prefs.getString('doctor') ?? '';
    globals.info[1] = doctorController.text;
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
    prefs.setString('doctor', doctorController.text);
    print('saved ' + playCompressions.toString() + playVoice.toString());
  }

  Future<void> _showMyDialog() async {
    var prefs = await SharedPreferences.getInstance();
    String test = prefs.getString('log') ?? null;

    if (test != null) {
      print('found log ' + test);

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
        // user must tap button!
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
      // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Stop Code Now?'),
          content: Text('Are you sure you want to stop the code now?'),
          actions: <Widget>[
            Container(
              constraints:
                  BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('No', style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
                      child: Text('Yes'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        stopAndGoToNextPage('');
                      },
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

  autoStartCascade() async {
    if (autoStart > 0) {
      setState(() {
        autoStart--;
      });
      Future.delayed(Duration(seconds: 1), () => {autoStartCascade()});
    } else {
      setState(() {
        warningDismissed = true;
      });
    }
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
      soundColor = Theme.of(context).splashColor;
    });

    await player.setLoopMode(LoopMode.one);
    await playerB.setLoopMode(LoopMode.one);

    if (kIsWeb) {
      return;
    }
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
        voiceColor = Theme.of(context).splashColor;
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

  sendEmail(String string) async {

    if (kIsWeb) {
      final mailtoLink = Mailto(
        to: ['recoverfeedback@gmail.com'],
        subject: 'RECOVER APP FEEDBACK/BUG REPORT',
        body: string,
      );
      await launch('$mailtoLink');
    }else{
      final Email email = Email(
        body: string,
        subject: 'RECOVER APP FEEDBACK/BUG REPORT',
        recipients: ['recoverfeedback@gmail.com'],
      );

      await FlutterEmailSender.send(email);
    }

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
      kIsWeb
          ? Container()
          : ElevatedButton(
              onPressed: () => {
                globals.ignoreCurrentLog = true,
                stopAndGoToNextPage(),
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Go To Files',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Icon(FlutterIcons.folder_ent, color: Colors.white),
                ],
              ),
            ),
      ElevatedButton(
        onPressed: () => {startFeedback()},
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
      ElevatedButton(
        style:
            ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
        onPressed: () async {
          String ret = await makeSure('start a new code?');
          if (ret == 'yes') {
            resetEverything(true);
            Navigator.of(context).pop();
          }
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Reset Code',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Icon(FlutterIcons.new_box_mco, color: Colors.white),
          ],
        ),
      ),
     Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 100),
                child: Image.asset('ad.jpeg'),
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

  Future<String> makeSure(String ask) async {
    var a = await showDialog<String>(
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
                Navigator.of(context).pop('no');
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop('yes');
              },
            ),
          ],
        );
      },
    );
    return a;
  }

  // presentPulseCheckOutcomes() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(15), topRight: Radius.circular(15))),
  //       child: ListView(
  //         children: [
  //           Column(
  //             children: <Widget>[
  //               ListTile(
  //                 title: Container(
  //                   decoration: BoxDecoration(
  //                     color: Theme.of(context).accentColor,
  //                     borderRadius: BorderRadius.circular(8.0),
  //                   ),
  //                   height: 100,
  //                   child: AutoSizeText(
  //                     'GOT PULSE',
  //                     style: TextStyle(
  //                       fontSize: 40,
  //                       color: Colors.white,
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                   alignment: Alignment.center,
  //                 ),
  //                 onTap: () => {_selectedPulse('pulse')},
  //               ),
  //               ListTile(
  //                 title: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.black54,
  //                       borderRadius: BorderRadius.circular(8.0),
  //                     ),
  //                     height: 100,
  //                     child: Row(
  //                       children: <Widget>[
  //                         Expanded(
  //                           flex: 5,
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: <Widget>[
  //                               Expanded(
  //                                 flex: 4,
  //                                 child: Column(
  //                                   children: [
  //                                     Expanded(
  //                                       child: Container(),
  //                                     ),
  //                                     Expanded(
  //                                       child: Container(
  //                                         decoration: BoxDecoration(
  //                                           border: Border(
  //                                               top: BorderSide(
  //                                                   width: 2,
  //                                                   color: Colors.white)),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                               Expanded(
  //                                 child: FittedBox(
  //                                   fit: BoxFit.fitWidth,
  //                                   child: Container(
  //                                     width: 1000,
  //                                     alignment: Alignment.center,
  //                                     child: AutoSizeText(
  //                                       'Asystole - no shock',
  //                                       style: TextStyle(
  //                                           fontSize: 40, color: Colors.white),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     )),
  //                 onTap: () => {_selectedPulse('asystole')},
  //               ),
  //               ListTile(
  //                 title: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.black54,
  //                       borderRadius: BorderRadius.circular(8.0),
  //                     ),
  //                     height: 100,
  //                     child: Row(
  //                       children: <Widget>[
  //                         Expanded(
  //                           flex: 5,
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: <Widget>[
  //                               Expanded(
  //                                 flex: 4,
  //                                 child: Container(
  //                                   width: 1000,
  //                                   child: SvgPicture.asset(
  //                                     ('assets/pea.png'),
  //                                     fit: BoxFit.fill,
  //                                   ),
  //                                 ),
  //                               ),
  //                               Expanded(
  //                                 child: FittedBox(
  //                                   fit: BoxFit.fitWidth,
  //                                   child: Container(
  //                                     width: 1000,
  //                                     alignment: Alignment.center,
  //                                     child: AutoSizeText(
  //                                       'PEA - no shock',
  //                                       style: TextStyle(
  //                                           fontSize: 40, color: Colors.white),
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     )),
  //                 onTap: () => {_selectedPulse('pea')},
  //               ),
  //               ListTile(
  //                 title: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.black54,
  //                       borderRadius: BorderRadius.circular(8.0),
  //                     ),
  //                     height: 100,
  //                     child: Row(
  //                       children: <Widget>[
  //                         Flexible(
  //                             flex: 1,
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               child: Icon(
  //                                 FontAwesome.bolt,
  //                                 size: 50,
  //                                 color: Theme.of(context).splashColor,
  //                               ),
  //                             )),
  //                         Expanded(
  //                           flex: 5,
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: <Widget>[
  //                               Expanded(
  //                                 flex: 4,
  //                                 child: Container(
  //                                   width: 1000,
  //                                   child: Image.asset(
  //                                     ('assets/vfib.png'),
  //                                     fit: BoxFit.fill,
  //                                   ),
  //                                 ),
  //                               ),
  //                               Expanded(
  //                                 child: AutoSizeText(
  //                                   'Ventricular Fibrillation',
  //                                   style: TextStyle(
  //                                       fontSize: 40, color: Colors.white),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Flexible(
  //                             flex: 1,
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               child: Icon(
  //                                 FontAwesome.bolt,
  //                                 size: 50,
  //                                 color: Theme.of(context).splashColor,
  //                               ),
  //                             )),
  //                       ],
  //                     )),
  //                 onTap: () => {_selectedPulse('vfib')},
  //               ),
  //               ListTile(
  //                 title: Container(
  //                     decoration: BoxDecoration(
  //                       color: Colors.black54,
  //                       borderRadius: BorderRadius.circular(8.0),
  //                     ),
  //                     height: 100,
  //                     child: Row(
  //                       children: <Widget>[
  //                         Flexible(
  //                             flex: 1,
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               child: Icon(
  //                                 FontAwesome.bolt,
  //                                 size: 50,
  //                                 color: Theme.of(context).splashColor,
  //                               ),
  //                             )),
  //                         Expanded(
  //                           flex: 5,
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: <Widget>[
  //                               Expanded(
  //                                 flex: 4,
  //                                 child: Container(
  //                                   width: 1000,
  //                                   child: Image.asset(
  //                                     ('assets/vtach.png'),
  //                                     fit: BoxFit.fill,
  //                                   ),
  //                                 ),
  //                               ),
  //                               Expanded(
  //                                 child: AutoSizeText(
  //                                   'Pulseless Ventricular Tachycardia',
  //                                   style: TextStyle(
  //                                       fontSize: 40, color: Colors.white),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Flexible(
  //                             flex: 1,
  //                             child: Container(
  //                               alignment: Alignment.center,
  //                               child: Icon(
  //                                 FontAwesome.bolt,
  //                                 size: 50,
  //                                 color: Theme.of(context).splashColor,
  //                               ),
  //                             )),
  //                       ],
  //                     )),
  //                 onTap: () => {_selectedPulse('vtach')},
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget pulseOptions(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      child: ListView(
        children: [
          Column(
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
                onTap: () {
                  controller.text = 'Got Pulse';
                },
              ),
              ListTile(
                title: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    height: 100,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                        decoration: BoxDecoration(
                                          border: Border(
                                              top: BorderSide(
                                                  width: 2,
                                                  color: Colors.white)),
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
                                    alignment: Alignment.center,
                                    child: AutoSizeText(
                                      'Asystole - no shock',
                                      style: TextStyle(
                                          fontSize: 40, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                onTap: () {
                  controller.text = 'Asystole';
                },
              ),
              ListTile(
                title: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    height: 100,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Container(
                                  width: 1000,
                                  child: SvgPicture.asset(
                                    (kIsWeb ? 'pea.svg' : 'assets/pea.svg'),
                                    fit: BoxFit.fill,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.fitWidth,
                                  child: Container(
                                    width: 1000,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'PEA - no shock',
                                      style: TextStyle(
                                          fontSize: 40, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                onTap: () {
                  controller.text = 'PEA';
                },
              ),
              ListTile(
                title: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8.0),
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
                                color: Theme.of(context).splashColor,
                              ),
                            )),
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Container(
                                  width: 1000,
                                  child: SvgPicture.asset(
                                    (kIsWeb ? 'vfib.svg' : 'assets/vfib.svg'),
                                    fit: BoxFit.fill,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  'Ventricular Fibrillation',
                                  style: TextStyle(
                                      fontSize: 40, color: Colors.white),
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
                                color: Theme.of(context).splashColor,
                              ),
                            )),
                      ],
                    )),
                onTap: () => {controller.text = 'V Fib'},
              ),
              ListTile(
                title: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8.0),
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
                                color: Theme.of(context).splashColor,
                              ),
                            )),
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Container(
                                  width: 1000,
                                  child: SvgPicture.asset(
                                    (kIsWeb ? 'vtach.svg' : 'assets/vtach.svg'),
                                    fit: BoxFit.fill,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: AutoSizeText(
                                  'Pulseless Ventricular Tachycardia',
                                  style: TextStyle(
                                      fontSize: 40, color: Colors.white),
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
                                color: Theme.of(context).splashColor,
                              ),
                            )),
                      ],
                    )),
                onTap: () {
                  controller.text = 'Pulseless V Tach';
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget openPulseButton() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: RawMaterialButton(
          fillColor: Theme.of(context).splashColor,
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
          onPressed: () => setState(() {
            print('yes pcheck');
            // presentPulseCheckOutcomes();
          }),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget deferPulseButton() {
    return Expanded(
        child: Padding(
            padding: EdgeInsets.all(15),
            child: RawMaterialButton(
              fillColor: Colors.lightBlue,
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
              onPressed: () => setState(() {
                print('no pcheck');
                addToLog('pulse check deferred');

                nested.show = false;
                progressPulseCheck = true;
                player.setVolume(1);
                playerB.setVolume(1);
              }),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            )));
  }

  Widget deliverShockButton() {
    return Container(
      color: Colors.black54,
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
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
                Expanded(
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: RawMaterialButton(
                          fillColor: Theme.of(context).splashColor,
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
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 60),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onPressed: () => setState(() {
                            String formattedDate = getFormatedTime();
                            String combined =
                                "\n" + formattedDate + "\tShock Delivered";
                            String full = combined.toString() + "\t";
                            globals.log = globals.log + full;
                            print('Shock Delivered');

                            nested.show = false;
                            showShock = false;
                            fractionPulse = 0;
                            progressPulseCheck = true;
                            player.setVolume(1);
                            playerB.setVolume(1);
                            _speechThis('Continue Compressions');
                          }),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        )))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> popupEditor(String info, String current) async {
    TextEditingController temp = TextEditingController();
    temp.text = current;
    temp.selection =
        TextSelection(baseOffset: 0, extentOffset: temp.text.length);

    String r;

    var response = await showDialog(
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
              TextButton(
                child: Text('done'),
                onPressed: () => {Navigator.pop(context, temp.text)},
              )
            ],
          );
        });
    print('response: ' + response.toString());
    if (response is String) {
      print('response is a string');
      r = response;
    }
    return r;
  }

  updateDrawer() {
    print('updating drawer');
    List<String> eventSplit = globals.log.split('\n');
    timelineTiles = [];
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
              onTap: () async {
                print('tapped' + i.toString());
                String returned = await popupEditor("Edit event", rest);
                if (returned != null) {
                  eventSplit[i] = returned;
                  globals.log = eventSplit.join('\n');
                  updateDrawer();
                  setState(() {});
                }
              },
              child: Row(
                children: [
                  Expanded(child: Text(rest)),
                ],
              ),
            ),
          ),
          isFirst: first,
          isLast: last,
          hasIndicator: dot,
          indicatorStyle: IndicatorStyle(
              width: iconSize,
              color: Theme.of(context).splashColor,
              padding: EdgeInsets.all(8),
              iconStyle: IconStyle(
                iconData: icon,
                color: Colors.white,
              )),
        );
        timelineTiles.add(add);
      }
    }
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
            child: FittedBox(
                child: Container(
                    alignment: Alignment.center, child: Text('Breaths'))),
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

  int breathSeconds = 0;
  double speed = 0;
  int breathingValue = 0;
  var tapTimes = <DateTime>[];
  var tapDifs = <int>[];
  var perc1 = 0.0;
  var perc2 = 0.0;
  var perc3 = 0.0;
  var anim1 = true;
  var anim2 = true;
  var anim3 = true;
  Timer tapResetTimer;
  bool showTapper = false;
  // Widget gauge = Container();
  Widget gauge() {
    return Stack(
      children: [
        showTapper
            ? GestureDetector(
                onTap: () {
                  showTapper = false;
                  _timerAnimCont.forward();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.black12,
                  ),
                ),
              )
            : Container(),
        Container(
          child: Row(
            children: [
              Expanded(
                child: Container(),
              ),
              Expanded(
                child: Container(
                  transform: Matrix4.translationValues(
                      _timerAnimCont.value *
                          MediaQuery.of(context).size.width /
                          2,
                      0,
                      0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Container(),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: new LayoutBuilder(builder:
                              (BuildContext context,
                                  BoxConstraints constraints) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: FittedBox(
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
                                        GaugeSegment('Medium', 20,
                                            Colors.lightBlueAccent),
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
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: FittedBox(
                                        child: Text(
                                          'Tap With Compressions',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: FittedBox(
                                        child: Icon(
                                          FlutterIcons.hand_pointer_faw5s,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            onPressed: _handleTap,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _handleTap() {
    print('tap');
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

  Widget timerView(bool vertical) {
    return Expanded(
      flex: 100,
      child: Stack(
        children: [
          Center(
            child: Column(
              children: [
                Expanded(
                  child: FittedBox(
                    child: CircularPercentIndicator(
                      key: GlobalObjectKey('circleProgress'),
                      radius: 200,
                      lineWidth: 10.0,
                      percent: fraction,
                      animation: true,
                      animationDuration: 1000,
                      animateFromLastPercent: true,
                      circularStrokeCap: CircularStrokeCap.round,
                      footer: FittedBox(
                        child: Column(
                          children: [
                            Text(
                              inst,
                              key: GlobalObjectKey('inst'),
                              maxLines: 1,
                            ),
                            Container(
                              height: 40,
                            )
                          ],
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
                                    Row(
                                      children: [
                                        Text(
                                          '-' + pulseCheckCountdown,
                                          textAlign: TextAlign.right,
                                          key: GlobalObjectKey('timerCircle'),
                                          style: new TextStyle(
                                            fontSize: 40.0,
                                          ),
                                        ),
                                        Container(
                                          child: IconButton(
                                              icon: FittedBox(
                                                child: Column(
                                                  children: [
                                                    Icon(FlutterIcons
                                                        .rewind_fea),
                                                    Text(
                                                      'reset',
                                                      style: TextStyle(
                                                          fontSize: 8),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              onPressed: () {
                                                addLog('Timer Manually Reset');
                                                fractionPulse = 0;
                                                updateCircle();
                                              }),
                                        ),
                                      ],
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
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FittedBox(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Toggle Metronome',
                        icon: soundIcon,
                        color: soundColor,
                        onPressed: () => {toggleSound()},
                      ),
                      IconButton(
                        tooltip: 'Toggle Voice',
                        icon: voiceIcon,
                        color: voiceColor,
                        onPressed: () => {toggleVoice()},
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(flex: 6, child: Container())
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                textDirection:
                    !vertical ? TextDirection.ltr : TextDirection.rtl,
                children: [
                  Expanded(
                    child: FittedBox(
                      child: IconButton(
                        tooltip: 'Speed Check',
                        icon: Icon(FlutterIcons.gauge_ent),
                        color: Colors.red,
                        onPressed: () {
                          showTapper = true;
                          _timerAnimCont.reverse();
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(),
                  )
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(),
                  ),
                  Expanded(
                    child: FittedBox(
                      child: Tooltip(
                        message: "Stop Code",
                        preferBelow: false,
                        child: IconButton(
                          icon: Icon(FlutterIcons.alert_octagon_fea,
                              color: Colors.red),
                          onPressed: () => {_ensureStopCode()},
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          sizeButton(vertical),
        ],
      ),
    );
  }

  addLog(String string) {
    globals.log = globals.log + '\n' + getTime() + ' ' + string;
  }

  bool warningDismissed = false;
  AnimationController _animationController;
  Animation _animation;
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
  final medNames = <String>[
    'Epinephrine Low ',
    'Epinephrine High ',
    'Vasopressin ',
    'Atropine ',
    'Amiodarone ',
    'Lidocaine ',
    'Naloxone ',
    'Flumazenil ',
    'Atipamezole ',
  ];

  final otherOptions = <String>[
    'CO2',
    'Carbon Dioxide',
    'Pulse Check',
    'Shock Delivered',
    'Super Ventricular Tachycardia',
    'SVT',
    'V Fib',
    'Ventricular Fibrillation',
    'PEA',
    'Pulseless Electrical Activity',
    'V Tach',
    'Ventricular Tachycardia',
  ];
  List<List<String>> medDoses = [];

  List<String> _kOptions = [];
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

  List<Widget> logTiles() {
    List<Widget> toReturn = [];
    List<String> retSplit = globals.log.split('\n').reversed.toList();
    List<Widget> minAgo = [];

    retSplit.asMap().forEach((key, value) {
      Color col = Colors.transparent;
      Color textCol = Colors.black;
      medNames.forEach((element) {
        if (value.contains(element)) {
          col = Colors.red;
          textCol = Colors.white;
        }
      });

      try {
        final parsedTime =
            DateTime.parse(value.substring(0, value.indexOf(' ')));
        final now = DateTime.now();
        String min = now.difference(parsedTime).inMinutes.toStringAsFixed(0);
        minAgo.add(Text(
          min + ' min ago',
          style: TextStyle(color: textCol),
        ));
      } catch (error) {
        minAgo.add(Container());
      }

      toReturn.add(Container(
        padding: EdgeInsets.all(4),
        color: col,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
                child: Text(
              cutDisplay(value),
              style: TextStyle(color: textCol),
            )),
            FittedBox(child: minAgo[key])
          ],
        ),
      ));
    });

    return toReturn;
  }

  String cutDisplay(String value) {
    String a = value.substring(value.indexOf('T') + 1, value.indexOf(' '));
    String b = value.substring(value.indexOf(' '));
    return a + ' ' + b;
  }

  PageController pageController = PageController(
    initialPage: 0,
  );

  String selected = '';
  double medOffset = 0;
  Widget helperOptions(TextEditingController controller, StateSetter build) {
    madeMeds = false;
    if (selected == 'medications') {
      madeMeds = true;
      return Stack(
        children: [
          SingleChildScrollView(
              child: Row(
            children: [
              Column(
                children: [
                  Container(
                    height: 40,
                  ),
                  ...medNames
                      .map((e) => Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1)),
                          height: 40,
                          width: 150,
                          child: Center(child: Text(e))))
                      .toList(),
                ],
              ),
              Expanded(
                child: Container(
                  child: SingleChildScrollView(
                    controller: _letters,
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                        ),
                        ...medDoses
                            .map(
                              (e) => Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1)),
                                child: Row(
                                  children: e
                                      .asMap()
                                      .map((i, f) => MapEntry(
                                          i,
                                          Container(
                                              height: 40,
                                              width: 60,
                                              color: e.indexOf(f) ==
                                                      globals.weightIndex
                                                  ? Colors.red.withAlpha(100)
                                                  : Colors.white,
                                              child: Center(
                                                  child: TextButton(
                                                      onPressed: () {
                                                        if (globals.weightKG ==
                                                            null) {
                                                          setWeight(
                                                              i.toDouble());
                                                        }
                                                        controller.text =
                                                            _kOptions[medDoses
                                                                    .indexOf(
                                                                        e)] +
                                                                ' ' +
                                                                f +
                                                                'mL';
                                                      },
                                                      child: Text(f))))))
                                      .values
                                      .toList(),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
          Row(
            children: [
              Container(
                width: 150,
                height: 40,
                color: Colors.white,
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _numbers,
                  child: Row(
                    children: weightOptions
                        .map((e) => Container(
                            width: 60,
                            height: 40,
                            decoration: BoxDecoration(color: Colors.lightBlue),
                            child: Center(
                                child: Text(
                              e,
                              style: TextStyle(color: Colors.white),
                            ))))
                        .toList(),
                  ),
                ),
              ),
            ],
          )
        ],
      );
    } else if (selected == 'pulse') {
      return pulseOptions(controller);
    } else if (selected == 'co2') {
    } else if (selected == 'info') {
      return patientInfoWidget(build);
    } else if (selected == 'shock') {
      return shockWidget(controller, build);
    }
    return Container();
  }

  Widget patientInfoWidget(StateSetter build) {
    print('building with ' +
        globals.weightKG.toString() +
        globals.weightIndex.toString());
    double valueWeight = 5;
    if (globals.weightIndex != null) {
      valueWeight = globals.weightIndex.toDouble();
    }

    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Row(
                children: [
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
                        value: valueWeight,
                        label: globals.weightKG == null
                            ? 'none'
                            : weightOptions[globals.weightIndex],
                        onChanged: (value) {
                          build(
                            () {
                              setWeight(value);
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
                Expanded(
                  child: TabBar(
                    controller: chestTypeController,
                    onTap: (tabby) {
                      globals.chest = chestTypes[chestTypeController.index];

                      centerIcon = chestIcons[chestTypeController.index];
                      chestIcon = chestIcons[chestTypeController.index];

                      for (MedListItem item in medItems) {
                        item.buildSubtitle(context);
                      }
                      setState(() {});
                    },
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
        ],
      ),
    );
  }

  setWeight(double value) {
    globals.weightIndex = value.toInt();
    globals.weightKG = weightkgOptions[value.toInt()];
    medOffset = 60 * globals.weightIndex.toDouble();
  }

  getMedOffset(StateSetter build) async {
    Future.delayed(Duration(milliseconds: 400), () {
      build(() {
        _controllers.animateTo(medOffset,
            curve: Curves.easeOut, duration: Duration(milliseconds: 300));
      });
    });
  }

  List<String> chestTypes = ['round', 'keel', 'flat'];
  List<IconData> chestIcons = [
    Chesttypes.flat,
    Chesttypes.keel,
    Chesttypes.round,
  ];

  List<double> weightkgOptions = [2.5, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50];
  TabController chestTypeController;
  TextInputType keyboardType = TextInputType.text;
  bool showHelpers = true;
  bool madeMeds = false;
  bool showingRecorder = false;
  openRecorder([bool secondPage = false]) async {
    if (showingRecorder) {
      Navigator.of(context).pop();
    }
    TextEditingController controller = TextEditingController();
    FocusNode focusHere = FocusNode();
    keyboardType = TextInputType.text;
    bool autoFocusOnBuild = false;
    if (secondPage) {
      pageController = PageController(
        initialPage: 1,
      );
    } else {
      pageController = PageController(
        initialPage: 0,
      );
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        showingRecorder = true;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 8),
          child: StatefulBuilder(builder: (context, StateSetter build) {
            focusHere.addListener(() {
              print('focused ' + focusHere.hasFocus.toString());
              print('building with ' + keyboardType.toString());
              build(() {});
            });
            if (autoFocusOnBuild) {
              autoFocusOnBuild = false;
              focusHere.requestFocus();
            }

            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  focusHere.hasFocus
                      ? Container()
                      : Container(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height / 4),
                          child: PageView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: pageController,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: FittedBox(
                                            child: IconButton(
                                                tooltip: 'Patient Info',
                                                icon: Icon(
                                                  FlutterIcons.dog_faw5s,
                                                  color: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  build(() {
                                                    keyboardType =
                                                        TextInputType.text;
                                                    selected = 'info';
                                                  });
                                                  pageController.animateToPage(
                                                      1,
                                                      duration: Duration(
                                                          milliseconds: 300),
                                                      curve: Curves.easeOut);
                                                }),
                                          ),
                                        ),
                                        Expanded(
                                          child: FittedBox(
                                            child: IconButton(
                                                tooltip: 'Carbon Dioxide',
                                                icon: FittedBox(
                                                  child: Text(
                                                    'CO2',
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  keyboardType =
                                                      TextInputType.number;
                                                  build(() {
                                                    selected = 'co2';
                                                    controller.text =
                                                        'CO2  mmHg';
                                                    controller.selection =
                                                        TextSelection(
                                                            baseOffset: 4,
                                                            extentOffset: 4);
                                                    autoFocusOnBuild = true;
                                                  });
                                                  // pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: FittedBox(
                                            child: Row(
                                              children: [
                                                IconButton(
                                                    tooltip: 'Medications',
                                                    icon: Icon(
                                                      FlutterIcons.pill_mco,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      build(() {
                                                        keyboardType =
                                                            TextInputType.text;
                                                        selected =
                                                            'medications';
                                                      });
                                                      pageController
                                                          .animateToPage(1,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      300),
                                                              curve: Curves
                                                                  .easeOut);
                                                      getMedOffset(build);
                                                    }),
                                                IconButton(
                                                    tooltip: 'Pulse Check',
                                                    icon: Icon(
                                                      FlutterIcons.pulse_mco,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      build(() {
                                                        keyboardType =
                                                            TextInputType.text;
                                                        selected = 'pulse';
                                                      });
                                                      pageController
                                                          .animateToPage(1,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      300),
                                                              curve: Curves
                                                                  .easeOut);
                                                    }),
                                                IconButton(
                                                    tooltip: 'Shock',
                                                    icon: Icon(
                                                      FlutterIcons
                                                          .wi_lightning_wea,
                                                      color: Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      build(() {
                                                        keyboardType =
                                                            TextInputType.text;
                                                        selected = 'shock';
                                                      });
                                                      pageController
                                                          .animateToPage(1,
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      300),
                                                              curve: Curves
                                                                  .easeOut);
                                                      getMedOffset(build);
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Stack(
                                children: [
                                  helperOptions(controller, build),
                                  IconButton(
                                      color: Colors.grey,
                                      icon: Icon(
                                        FlutterIcons.left_ant,
                                        color: Colors.lightBlue,
                                      ),
                                      onPressed: () {
                                        if (selected == 'medications') {
                                          medOffset = _controllers.offset;
                                          print('saved offset ' +
                                              medOffset.toString());
                                        }
                                        pageController.animateToPage(0,
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeOut);
                                      }),
                                ],
                              ),
                            ],
                          ),
                        ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: TypeAheadField(
                                  hideOnEmpty: true,
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                    autofocus: false,
                                    keyboardType: keyboardType,
                                    focusNode: focusHere,
                                    controller: controller,
                                    decoration: InputDecoration(
                                      focusColor: Colors.lightBlue,
                                      hoverColor: Colors.lightBlue,
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.lightBlue)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.lightBlue)),
                                      hintText: 'Start typing...',
                                      labelText: 'Record Something',
                                      labelStyle:
                                          TextStyle(color: Colors.lightBlue),
                                    ),
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    List<String> ret = [];
                                    medNames.asMap().forEach((num, medName) {
                                      if (pattern.toLowerCase().contains(
                                              medName.toLowerCase()) &&
                                          pattern.length < medName.length + 4) {
                                        print(pattern.toLowerCase() +
                                            medName.toLowerCase());
                                        print(medDoses[num]);

                                        ret = medDoses[num]
                                            .map((e) =>
                                                e +
                                                ' ml (' +
                                                weightOptions[medDoses[num]
                                                        .indexOf(e)]
                                                    .replaceAll('\n', '/') +
                                                ')')
                                            .toList();
                                      }
                                    });

                                    if (ret.length > 0) {
                                      return ret;
                                    }
                                    return _kOptions.where((element) =>
                                        element
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()) &&
                                        element.length != pattern.length);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    Widget a = Icon(FlutterIcons.test_tube_mco);
                                    if (medNames.contains(suggestion)) {
                                      a = Icon(Icons.medical_services);
                                    } else if (otherOptions
                                        .contains(suggestion)) {
                                      a = Icon(Icons.warning);
                                    }
                                    return ListTile(
                                      leading: a,
                                      title: Text(suggestion),
                                    );
                                  },
                                  transitionBuilder:
                                      (context, suggestionsBox, controller) {
                                    return suggestionsBox;
                                  },
                                  keepSuggestionsOnSuggestionSelected: true,
                                  onSuggestionSelected: (suggestion) {
                                    String old = '';
                                    _kOptions.forEach((element) {
                                      if (controller.text
                                          .toLowerCase()
                                          .contains(element.toLowerCase())) {
                                        old = controller.text;
                                      }
                                    });
                                    String sug = suggestion;
                                    if (sug.contains('(')) {
                                      sug = sug.substring(0, sug.indexOf('('));
                                    }
                                    controller.text = old + sug;
                                    print(sug);
                                    focusHere.requestFocus();

                                    controller.selection =
                                        TextSelection.fromPosition(TextPosition(
                                            offset: controller.text.length));
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                FlutterIcons.backspace_faw5s,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                controller.text = '';
                              },
                            )
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: TextButton(
                                child: Text(
                                  'cancel',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            Expanded(
                              child: Tooltip(
                                message: 'Record',
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                  ))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FittedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'RECORD',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          Icon(FlutterIcons.pen_plus_mco,
                                              color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context, controller.text);
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    ).then((val) {
      showingRecorder = false;
      if (selected == 'medications' && pageController.page == 1) {
        medOffset = _controllers.offset;
        print('saved offset ' + medOffset.toString());
      }

      setState(() {
        if (val == null) {
          return;
        }
        addLog(val);
        if (val.toString().toLowerCase().contains('v fib') ||
            val.toString().toLowerCase().contains('v tach')) {
          showWaitingForShock();
        }
        if (val.toString().toLowerCase().contains('got pulse')) {
          _ensureStopCode();
        }
      });
    });
  }

  Widget shockWidget(TextEditingController controller, StateSetter build) {
    return Stack(
      children: [
        SingleChildScrollView(
            child: Row(
          children: [
            Column(
              children: [
                Container(
                  height: 40,
                ),
                ...shockTypes
                    .map((e) => Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1)),
                        height: 40,
                        width: 150,
                        child: Center(child: Text(e))))
                    .toList(),
              ],
            ),
            Expanded(
              child: Container(
                child: SingleChildScrollView(
                  controller: _letters,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                      ),
                      ...shockDoses
                          .asMap()
                          .map((j, e) => MapEntry(
                                j,
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black, width: 1)),
                                  child: Row(
                                    children: e
                                        .asMap()
                                        .map((i, f) => MapEntry(
                                            i,
                                            Container(
                                                height: 40,
                                                width: 60,
                                                color: i == globals.weightIndex
                                                    ? Colors.red.withAlpha(100)
                                                    : Colors.white,
                                                child: Center(
                                                    child: TextButton(
                                                        onPressed: () {
                                                          if (globals
                                                                  .weightKG ==
                                                              null) {
                                                            setWeight(
                                                                i.toDouble());
                                                          }
                                                          if (controller !=
                                                              null) {
                                                            controller.text =
                                                                'Shock: ' +
                                                                    shockTypes[
                                                                        j] +
                                                                    ' ' +
                                                                    f +
                                                                    ' J';
                                                          }
                                                        },
                                                        child: Text(f))))))
                                        .values
                                        .toList(),
                                  ),
                                ),
                              ))
                          .values
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
        Row(
          children: [
            Container(
              width: 150,
              height: 40,
              color: Colors.white,
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _numbers,
                child: Row(
                  children: weightOptions
                      .map((e) => Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(color: Colors.lightBlue),
                          child: Center(
                              child: Text(
                            e,
                            style: TextStyle(color: Colors.white),
                          ))))
                      .toList(),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  bool awaitingShock = false;

  showWaitingForShock() async {
    bool first = true;
    TextEditingController displayCont = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        awaitingShock = true;
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 8),
          title: Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 3, ), borderRadius: BorderRadius.circular(15)),
            constraints:
                BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(FlutterIcons.wi_lightning_wea, color: Colors.black),
                Text('Shock Indicated', style: TextStyle(color: Colors.black)),
                Icon(FlutterIcons.wi_lightning_wea, color: Colors.black),
              ],
            ),
          ),
          content: StatefulBuilder(builder: (context, StateSetter build) {
            if (first) {
              first = false;
              getMedOffset(build);
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(child: Text('Continue compressions while charging')),
                shockWidget(displayCont, build),
                TextField(
                  controller: displayCont,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                  enabled: false,
                )
              ],
            );
          }),
          actions: <Widget>[
            Container(
              constraints:
                  BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child:
                          Text('Cancel', style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
                      child: FittedBox(
                        child: Text('Shock Delivered',
                            maxLines: 1, style: TextStyle(color: Colors.white)),
                      ),
                      onPressed: () {
                        addLog(displayCont.text);
                        fractionPulse = 0;
                        updateCircle();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    awaitingShock = false;
  }

  bool showingFeedback = false;
  startFeedback() async {
    TextEditingController cont = TextEditingController();
    bool yes = false;
    bool no = false;
    int helpful = 0;
    int easy = 0;
    ScrollController _scrollController = new ScrollController(
      initialScrollOffset: 400,
    );
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        showingFeedback = true;
        return AlertDialog(
          title: Text('Feedback'),
          content: StatefulBuilder(builder: (context, StateSetter build) {
            return SingleChildScrollView(
              reverse: true,
              controller: _scrollController,
              child: Center(
                child: Column(
                  children: [
                    Text('Have you used this during a real code event?'),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Checkbox(
                                value: yes,
                                onChanged: (val) {
                                  build(() {
                                    yes = val;
                                    if (val) {
                                      no = false;
                                    }
                                  });
                                },
                              ),
                              Text(
                                'yes',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Checkbox(
                                value: no,
                                onChanged: (val) {
                                  build(() {
                                    no = val;
                                    if (val) {
                                      yes = false;
                                    }
                                  });
                                },
                              ),
                              Text(
                                'no',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Text('How helpful was it?'),
                    Slider(
                        min: 0,
                        max: 5,
                        divisions: 5,
                        value: helpful.toDouble(),
                        onChanged: (val) {
                          build(() {
                            print(val);
                            helpful = val.toInt();
                          });
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'not helpful',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'helpful',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        )
                      ],
                    ),
                    Divider(),
                    Text('How easy was it?'),
                    Slider(
                        min: 0,
                        max: 5,
                        divisions: 5,
                        value: easy.toDouble(),
                        onChanged: (val) {
                          build(() {
                            print(val);
                            easy = val.toInt();
                          });
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'not easy',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'easy',
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Text('Let us know any other thoughts!\n'),
                    TextField(
                      keyboardType: TextInputType.text,
                      maxLines: null,
                      decoration: InputDecoration(
                        focusColor: Colors.lightBlue,
                        hoverColor: Colors.lightBlue,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.lightBlue)),
                        hintText: 'Start typing...',
                        labelText: 'Feedback',
                        labelStyle: TextStyle(color: Colors.lightBlue),
                      ),
                      controller: cont,
                    )
                  ],
                ),
              ),
            );
          }),
          actions: <Widget>[
            Container(
              constraints:
                  BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child:
                          Text('cancel', style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ))),
                      child: Text('Email'),
                      onPressed: () {
                        String a = yes ? 'yes' : 'no';
                        String b = helpful.toString();
                        String c = helpful.toString();
                        String d = cont.text ?? 'none';
                        sendEmail('Used During Code?: ' +
                            a +
                            '\nHelpful: ' +
                            b +
                            '\nEasy: ' +
                            c +
                            '\nFeedback: ' +
                            d);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    showingFeedback = false;
  }

  Widget toolView(BuildContext context) {
    return Expanded(
      flex: _animation.value,
      child: Container(
        decoration: BoxDecoration(color: Colors.lightBlueAccent.withAlpha(70)),
        child: _animation.value < 50
            ? Container()
            : Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Stack(
                        children: [
                          SingleChildScrollView(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(children: logTiles()),
                          )),
                        ],
                      )),
                    ],
                  ),
                  Center(
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(15),
                                child: ElevatedButton(
                                  onPressed: startFeedback,
                                  style: ButtonStyle(
                                      elevation:
                                          MaterialStateProperty.all<double>(0),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.white),
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18.0),
                                      ))),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: FittedBox(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FittedBox(
                                            child: Text(
                                              'Feedback  ',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                          FittedBox(
                                              child: Icon(
                                                  FlutterIcons.speech_sli,
                                                  color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(15),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ))),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: FittedBox(
                                          child: Row(
                                        children: [
                                          FittedBox(
                                            child: Text('Record  ',
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          ),
                                          FittedBox(
                                            child: Icon(
                                              FlutterIcons.pen_plus_mco,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )),
                                    ),
                                    onPressed: () {
                                      openRecorder();
                                    }),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: MediaQuery.of(context).padding.bottom,
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String getTime() {
    String d = DateTime.now().toIso8601String();
    return d.substring(
        0,
        d.lastIndexOf(
            ':')); //.substring(d.indexOf('T') + 1, d.lastIndexOf(':') );
  }

  Widget warning() {
    if (warningDismissed || kIsWeb) {
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Container(
              alignment: Alignment.center,
              color: Colors.black87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: GestureDetector(
                          onTap: () => setState(() {
                                print('dismiss warning');
                                warningDismissed = true;
                                _speak();
                                _showMyDialog();
                              }),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).splashColor,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                    child: Container(
                                  child: FittedBox(
                                    child: Icon(FlutterIcons.heart_ant,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                )),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: FittedBox(
                                      child: Text(
                                        'Start Code',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                      'auto starting in ' +
                                          autoStart.toString() +
                                          ' seconds',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor)),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(30),
                      child: GestureDetector(
                          onTap: () => setState(() {
                                print('going to files');
                                globals.ignoreCurrentLog = true;
                                stopAndGoToNextPage('pulse found');
                              }),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).accentColor,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                    child: Container(
                                  child: FittedBox(
                                    child: Icon(FlutterIcons.folderopen_ant,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                )),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: FittedBox(
                                      child: Text('Edit Files',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  Widget sizeButton(bool vertical) {
    return Positioned(
      left: vertical ? 25 : null,
      top: null,
      right: vertical ? null : 0,
      bottom: vertical ? 0 : 25,
      child: Transform.rotate(
        angle: !vertical ? 0 : math.pi / 2,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
            color: Colors.lightBlueAccent.withAlpha(200),
          ),
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: !vertical ? 0 : -math.pi / 2,
            child: IconButton(
              onPressed: () {
                if (_animationController.value == 0.0) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              },
              icon: Icon(
                FlutterIcons.notes_medical_faw5s,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget mainScreen(BuildContext context) {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      return Stack(children: [
        Row(children: <Widget>[
          timerView(false),
          toolView(context),
        ]),
        gauge()
      ]);
    }
    return Stack(
      children: [
        Column(children: <Widget>[
          timerView(true),
          toolView(context),
        ]),
        gauge()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (globals.reset) {
      print("reseting now");

      addLog("Code Started");
      minPassed = 0;
      secPassed = 0;
      dispSec = 0;
      fraction = 0;
      fractionPulse = 0;

      globals.reset = false;
      progressPulseCheck = true;
      player.setVolume(1);
      playerB.setVolume(1);
    }

    Scaffold s = Scaffold(
      endDrawerEnableOpenDragGesture: false,
      resizeToAvoidBottomInset: true,
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
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        actions: [
          Container(
            width: 100,
          )
        ],
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
                height: 50,
                child: Image.asset(
                  kIsWeb
                      ? 'recover-logo-250.png'
                      : 'assets/recover-logo-250.png',
                  fit: BoxFit.fitHeight,
                )),
          ],
        ),
        leading: Container(
          width: 100,
          child: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                FlutterIcons.settings_mco,
                color: Colors.lightBlue,
              ),
              onPressed: () =>
                  {updateDrawer(), Scaffold.of(context).openDrawer()},
            ),
          ),
        ),
      ),
      body: Stack(
        children: [mainScreen(context), warning()],
      ),
    );
    return s;
  }
}
