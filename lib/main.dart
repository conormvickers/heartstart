import 'dart:ui';
import 'package:flutter/cupertino.dart';
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
        primaryColor: Colors.white,
        accentColor: Colors.blue,
        splashColor: Colors.red,
        indicatorColor: Colors.lightBlueAccent,
        primarySwatch: Colors.lightBlue,
        disabledColor: Colors.grey,
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
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

var askForPulse = false;
var warningDismissed = false;
int timelineEditing;
var nested = NestedTabBar(
  key: nestedKey,
);
var showShock = false;
var _shockType = "No weight documented";
var handFreeColor;

class MyHomePageState extends State<MyHomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin, WidgetsBindingObserver  {
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


  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);
    super.initState();

    nested = NestedTabBar(
      parent: this,
      key: nestedKey,
    );
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd_kk-mm').format(now);
    globals.log = formattedDate + "\tCode Started";
    globals.codeStart = now;

    minPassed = 0;
    secPassed = 0;
    dispSec = 0;
    fraction = 0;

    _triggerUpdate();

    loadPreferences();
    autoStartCascade();
    animCont = AnimationController(vsync: this);

    Future<void>.delayed(
        Duration(seconds: 10),
            () => {
          Wakelock.enable(),
        });
  }


  String getFormatedTime() {
    DateTime a = DateTime.now();
    String formattedDate = DateFormat('kk:mm').format(a);
    return formattedDate;
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

    handsFree = true;
    fraction = 0;
    minPassed = 0;
    secPassed = 0;
    fractionPulse = 0;
    dispSec = 0;
    enterCapno = false;
    player.setVolume(1);
    playerB.setVolume(1);

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd_kk-mm').format(now);
    if (resetlog) {
      nestedKey.currentState.resetEverything();
      globals.log = formattedDate + "\tCode Started";
      globals.codeStart = now;
      globals.info = [
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
      globals.chest = null;
      globals.weightKG = null;
    }
    loadPreferences();

    centerIcon = FlutterIcons.heart_ant;
    inst = "Continue Compressions";

    progressPulseCheck = true;
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
        barColor = Theme.of(context).splashColor;
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
          _shockType = shockDoses[globals.weightIndex];
        }
        _speechThis(
            'Continue compressions while charging. Ensure clear before shock');
      } else if (selected == "pulse") {
        stopAndGoToNextPage();
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

  addToLog(String string) {
    String formattedDate = getFormatedTime();
    String combined = "\n" + formattedDate + "\t" + string;

    globals.log = globals.log + combined;
  }

  stopAndGoToNextPage([String reason = '']) async {
    print('sdf');
    String formattedDate = getFormatedTime();
    String combined = "\n" + formattedDate + "\tCode Stopped: " + reason;

    globals.log = globals.log + combined;
    print('added log');

    player.setVolume(0);
    playerB.setVolume(0);
    progressPulseCheck = false;
    askForPulse = false;
    nested.show = false;


    final reset = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => PageTwo(
      key: pageTwoKey,
    )));
    print('returned ' + reset.toString());
    if (reset == 'true') {
      print('returned reset');
      resetEverything();
    }else{
      print('rearest or continue');
      addToLog('Patient Rearrested');
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
                stopAndGoToNextPage('pulse found');
              },
            ),
            TextButton(
              child: Text('Yes, stop resuscitation'),
              onPressed: () {
                Navigator.of(context).pop();
                stopAndGoToNextPage('resuscitation efforts withdrawn');
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

  sendEmail() async {
    final Email email = Email(
      body:
          'Wow this app is awesome and the team behind it must be so smart!\n\nI was thinking...',
      subject: 'RECOVER APP FEEDBACK/BUG REPORT',
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
      Expanded(
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
        onPressed: () => launch(
            'https://recoverinitiative.org/veterinary-professionals/'),
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

  presentPulseCheckOutcomes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15))),
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
                                          .splashColor,
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
                                          .splashColor,
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
                                          .splashColor,
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
                                          .splashColor,
                                    ),
                                  )),
                            ],
                          )),
                      onTap: () => {_selectedPulse('vtach')},
                    ),
                  ],
                ),
          ],
        ),
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
          onPressed:() => setState(() {
            print('yes pcheck');
            presentPulseCheckOutcomes();
          }),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                askForPulse = false;
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
                          style: TextStyle(color: Colors.white, fontSize: 60),
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
                  askForPulse = false;
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
              )))],
            ),
          ),
        ],
      ),
    );

  }

  Future<String> popupEditor(String info, String current) async {
      TextEditingController temp = TextEditingController();
      temp.text = current;
      temp.selection = TextSelection(baseOffset: 0, extentOffset: temp.text.length);

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
            );}) ;
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
                      setState(() { });
                    }

                },
                child: Row(
                  children: [
                    Expanded(child: Text(rest) ),
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

  Widget timerView() {
    Widget leftBottom() {
      return Column(children: [
        Tooltip(
          message: "Hands Free Mode",
          preferBelow: false,
          child: IconButton(
              icon: Icon(FlutterIcons.hand_ent, color: Colors.lightBlue),
              onPressed: () => {
                print('hand free'),
                setState(() {
                  handsFree = true;
                }),
              }),
        ),
        Tooltip(
          preferBelow: false,
          message: "Misc Event",
          child: IconButton(
              icon: Icon(FlutterIcons.note_add_mdi, color: Colors.lightBlue),
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
        ),
        Tooltip(
          preferBelow: false,
          message: "Record CO2",
          child: IconButton(
            icon: Container(
              width: 100,
              height: 100,

              child: FittedBox(
                  child: Text(
                    'CO\u2082',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  )), //Icon(Chesttypes.co2_1, color: Colors.lightBlue),
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
        ),
      ]);
    }
    return
    Expanded(
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
                        child: Text(
                          inst,
                          key: GlobalObjectKey('inst'),
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
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                children: [Expanded(child: Container(),)],
              )
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
                Tooltip(
                  message: "Stop Code",
                  preferBelow: false,
                  child: IconButton(
                    icon: Icon(FlutterIcons.cancel_mco, color: Colors.lightBlue),
                    onPressed: () => {_ensureStopCode()},
                  ),
                ),
                Tooltip(
                  message: "Change Weight",
                  preferBelow: false,
                  child: IconButton(
                    icon:
                    Icon(FlutterIcons.dog_side_mco, color: Colors.lightBlue),
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
                ),
                Tooltip(
                  message: "Check Pulse",
                  preferBelow: false,
                  child: IconButton(
                    icon: Icon(
                      FlutterIcons.pulse_mco,
                      color: Colors.lightBlue,
                    ),
                    onPressed: () => {
                      setState(
                            () {
                          askForPulse = true;
                        },
                      ),
                    },
                  ),
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
                setState((){}),
                _scaffoldKey.currentState.openEndDrawer(),
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15)),
                  color: Theme.of(context).splashColor,
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
    );
  }
  Widget toolView() {

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
                deferPulseButton(),
                openPulseButton(),
              ],
            ),
          ),
        ],
      ),
    );
    if (showShock) {
      cP = deliverShockButton();
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
      handFreeColor = Colors.white;//Theme.of(context).splashColor;
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
                  //color: Colors.white,
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
                    color: Colors.grey,
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
                            color: Colors.lightBlue,
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
                                                child: Container(),
                                              ),
                                              Expanded(
                                                child: FittedBox(
                                                  child: Icon(
                                                      FlutterIcons.clock_faw5,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Expanded(
                                                child: Container(),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: FittedBox(
                                                  child: Icon(
                                                      FlutterIcons.undo_alt_faw5s,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(),
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
                                  addToLog(
                                      'Timer reset in Hands-Free Mode'),
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
                        color: Theme.of(context).splashColor,
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
                                  color: Colors.white,
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
                                  color: Colors.white,
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

    return Expanded(
      flex: 1,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Stack(
          children: temp,
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    if (globals.reset) {
      print("reseting now");
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd_kk-mm').format(now);
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



    Widget full;
    if (MediaQuery.of(context).size.width > MediaQuery.of(context).size.height ) {
      full = Row(children: <Widget>[
        timerView(),
        Divider(),
        toolView(),
      ]);
    }else{
      full = Column(children: <Widget>[
        timerView(),
        Divider(),
        toolView(),
      ]);
    }

    var warning = Column(
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
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).accentColor,
                                      width: 1.0),
                                ),
                                labelText: addEventString,
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor)),
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

    Scaffold s = Scaffold(
      endDrawerEnableOpenDragGesture: false,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
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
        title: Row(
          children: [
            Expanded(
              child: Container(
                  height: 50,
                  child: Image.asset(
                    'assets/recover-logo-250.png',
                    fit: BoxFit.fitHeight,
                  )),
            )
            // Text(
            //   "RECOVER",
            //   style: TextStyle(color: Colors.lightBlue),
            // ),
            // Icon(
            //   FlutterIcons.ios_medical_ion,
            //   color: Theme.of(context).splashColor,
            // )
          ],
        ),
        leading: Container(
          width: 100,
          child: Builder(
            builder: (context) => IconButton(
              icon: Icon(
                FlutterIcons.ios_options_ion,
                color: Colors.lightBlue,
              ),
              onPressed: () =>
                  {updateDrawer(), Scaffold.of(context).openDrawer()},
            ),
          ),
        ),
      ),
      body: Stack(
        children: fullStack,
      ),
    );
    return s;
  }
}

