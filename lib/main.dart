import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'dart:math';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO(prometheus42): For a better solution see: https://aschilken.medium.com/flutter-conditional-import-for-web-and-native-9ae6b5a5cd39
//import '' if (dart.library.html) 'dart:html' as html;

void main() {
  initSettings().then((_) {
    runApp(const MundaneQuest());
  });
}

// Initialize the settings provider, see https://pub.dev/packages/flutter_settings_screens/example
Future<void> initSettings() async {
  await Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
}

class MundaneQuest extends StatelessWidget {
  const MundaneQuest({Key? key}) : super(key: key);

  Color loadConfiguration() {
    Future f = SharedPreferences.getInstance();
    Color appBarColor = Colors.cyan;
    f.then((prefs) => {appBarColor = prefs.getString('appBarColor') ?? Colors.cyan});
    return appBarColor;
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = loadConfiguration();
    return MaterialApp(
      title: 'Mundane Quest',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('de', ''),
      ],
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: Colors.lightGreenAccent,
      ),
      home: const MundaneQuestHomePage(title: 'Mundane Quest'),
    );
  }
}

class MundaneQuestHomePage extends StatefulWidget {
  const MundaneQuestHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MundaneQuestHomePage> createState() => _MundaneQuestHomePageState();
}

class _MundaneQuestHomePageState extends State<MundaneQuestHomePage> {
  @override
  void initState() {
    developer.log('Starting Mundane Quest...');

    if (!kIsWeb && Platform.isLinux) {
      DesktopWindow.setWindowSize(const Size(1400, 800));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (RawKeyEvent keyEvent) {
          //developer.log('${keyEvent.isAltPressed ? 'Alt' : ''} ${keyEvent.isControlPressed ? 'Ctrl' : ''} ${keyEvent.isShiftPressed ? 'Shift' : ''} ${keyEvent.physicalKey} ${keyEvent.character} ${keyEvent.physicalKey} ${keyEvent.logicalKey}');
          if (keyEvent.character == 'q') {
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          } else if (keyEvent.character == 'h') {
            developer.log('Help menu called by key press.');
          } else if (keyEvent.character == 's') {
            developer.log('Settings menu called by key press.');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsWidget()),
            );
          } else if (keyEvent.character == 'g') {
            developer.log('Solo game menu called by key press.');
          } else if (keyEvent.character == 'p') {
            developer.log('Game started by key press.');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StartGameDialogWidget()),
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Image(image: AssetImage('assets/logo.png')),
              Text(
                'Mundane Quest',
                style: Theme.of(context).textTheme.headline2,
              ),
              const SizedBox(height: 50),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 400),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                    ),
                    child: Text(AppLocalizations.of(context)!.playGameMenu, style: Theme.of(context).textTheme.headline5),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StartGameDialogWidget()),
                      );
                    },
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 400),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                    ),
                    child: Text(AppLocalizations.of(context)!.playSoloGame, style: Theme.of(context).textTheme.headline5),
                    onPressed: () {},
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 400),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                    ),
                    child: Text(AppLocalizations.of(context)!.changeSettings, style: Theme.of(context).textTheme.headline5),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsWidget()),
                      );
                    },
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 400),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                    ),
                    child: Text(AppLocalizations.of(context)!.getHelp, style: Theme.of(context).textTheme.headline5),
                    onPressed: () {},
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 400),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                    ),
                    child: Text(AppLocalizations.of(context)!.quitGame, style: Theme.of(context).textTheme.headline5),
                    // exit app programmatically: https://stackoverflow.com/a/49067313
                    onPressed: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return SettingsScreen(title: AppLocalizations.of(context)!.applicationSettings, children: [
      SettingsGroup(title: 'Game', children: [
        SliderSettingsTile(
          settingKey: 'gameTime',
          title: 'Answer Time',
          subtitle: 'How long should the players have to answer questions?',
          defaultValue: 30,
          min: 1.0,
          max: 60.0,
          step: 5,
          leading: const Icon(Icons.timer),
        ),
        SliderSettingsTile(
          settingKey: 'defaultDelayTime',
          title: 'Delay Time',
          subtitle: 'How long should the correct answer be shown?',
          defaultValue: 4,
          min: 1.0,
          max: 20.0,
          step: 1,
          leading: const Icon(Icons.timer),
        ),
        SliderSettingsTile(
          settingKey: 'defaultReadyTime',
          title: 'Ready Time',
          subtitle: 'How long should players have to ready themselves before answering?',
          defaultValue: 8,
          min: 1.0,
          max: 20.0,
          step: 1,
          leading: const Icon(Icons.timer),
        ),
        SliderSettingsTile(
          settingKey: 'roundsPerGame',
          title: 'Rounds per Game',
          subtitle: 'How many rounds should a game have?',
          defaultValue: 7,
          min: 1.0,
          max: 10.0,
          step: 1,
          leading: const Icon(Icons.replay_circle_filled),
        ),
        RadioSettingsTile(
            title: 'Difficulty',
            settingKey: 'defaultQuestionDifficulty',
            selected: 'easy',
            leading: const Icon(Icons.star_border),
            values: const {'easy': 'easy', 'medium': 'medium', 'hard': 'hard'}),
        // DropDownSettingsTile(title: 'Difficulty', settingKey: 'defaultQuestionDifficulty', selected: 'easy',
        //     //leading: const Icon(Icons.star_border),
        //     values: const {'easy': 'easy', 'medium': 'medium', 'hard': 'hard'}),
        TextInputSettingsTile(
          title: 'Points per Question',
          settingKey: 'pointsPerQuestion',
          initialValue: '100',
          //leading: const Icon(Icons.plus_one),
          keyboardType: TextInputType.number,
          //autoValidateMode: ,
        ),
      ]),
      SettingsGroup(
        title: 'User Interface',
        children: [
          ColorPickerSettingsTile(
            title: 'What color should the app bar have?',
            defaultValue: Colors.cyan,
            settingKey: 'appBarColor',
          ),
        ],
      ),
      SettingsGroup(
        title: 'Control',
        children: [
          SwitchSettingsTile(
            settingKey: 'gamepadSupport',
            defaultValue: true,
            title: 'Should gamepad support be activated?',
            leading: const Icon(Icons.sports_esports_outlined), //const Icon(Icons.gamepad),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Audio',
        children: [
          SwitchSettingsTile(
            settingKey: 'audioActivated',
            defaultValue: true,
            title: 'Should audio be activated?',
            leading: const Icon(Icons.audiotrack),
          ),
        ],
      )
    ]);
  }
}

class StartGameDialogWidget extends StatefulWidget {
  const StartGameDialogWidget({Key? key}) : super(key: key);

  @override
  State<StartGameDialogWidget> createState() => _StartGameDialogState();
}

class _StartGameDialogState extends State<StartGameDialogWidget> {
  var listOfPlayerNameControllers = <TextEditingController>[];
  final QuestionBank questionBank = QuestionBank();

  void _incrementPlayerCount() {
    setState(() {
      if (listOfPlayerNameControllers.length < 5) {
        developer.log('Adding new player to the roster...', name: 'org.freenono.mundaneQuest.main');
        TextEditingController newController = TextEditingController();
        listOfPlayerNameControllers.add(newController);
      } else {
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.maximumNumberOfPlayers),
            action: SnackBarAction(label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      }
    });
  }

  void _handleStartGame(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    developer.log('Checking whether enough player are given...', name: 'org.freenono.mundaneQuest.main');
    if (listOfPlayerNameControllers.length < 2) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.atLeastTwoPlayers),
          action: SnackBarAction(label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
        ),
      );
    } else {
      var listOfPlayerNames = listOfPlayerNameControllers.map((e) => e.text);

      if (listOfPlayerNames.toSet().length != listOfPlayerNames.length) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.doublePlayerName),
            action: SnackBarAction(label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      } else if (listOfPlayerNames.any((element) => element.isEmpty)) {
        scaffold.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.playerNamesEmpty),
            action: SnackBarAction(label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlayGameWidget(
                    listOfPlayerNames: listOfPlayerNames,
                    questionBank: questionBank,
                  )),
        );
      }
    }
  }

  @override
  void initState() {
    _incrementPlayerCount();
    _incrementPlayerCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    var textFields = <Padding>[];
    for (var element in listOfPlayerNameControllers) {
      var no = listOfPlayerNameControllers.indexOf(element) + 1;
      textFields.add(Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            SizedBox(
                width: 500,
                child: TextField(
                  autofocus: no == 1 ? true : false,
                  controller: element,
                  maxLength: 20,
                  decoration:
                      InputDecoration(border: const OutlineInputBorder(), hintText: AppLocalizations.of(context)!.enterPlayerName(no)),
                )),
            const SizedBox(width: 20),
            ElevatedButton(
                onPressed: () {
                  // prevent user from deleting players so that less than two players remain
                  if (listOfPlayerNameControllers.length > 2) {
                    setState(() {
                      listOfPlayerNameControllers.remove(element);
                    });
                    developer.log('Removing player from roster...', name: 'org.freenono.mundaneQuest.main');
                  } else {
                    scaffold.showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!.atLeastTwoPlayers),
                      action: SnackBarAction(label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
                    ));
                  }
                },
                child: Text(AppLocalizations.of(context)!.delete))
          ])));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.startNewGame),
      ),
      body: Row(children: [
        Expanded(child: Container()),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(AppLocalizations.of(context)!.addPlayerToGame, style: Theme.of(context).textTheme.headline3),
            ),
            const SizedBox(height: 60),
            Column(
              children: textFields,
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
              ),
              child: Text(AppLocalizations.of(context)!.startGame, style: Theme.of(context).textTheme.headline4),
              onPressed: () => _handleStartGame(context),
            )
          ],
        ),
        Expanded(child: Container()),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementPlayerCount,
        tooltip: AppLocalizations.of(context)!.addPlayer,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// TODO(prometheus42): Move data classes to separate file.
class Question {
  final String questionText;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  // category for a single question is a String containing the name of the category
  final String category;
  final String difficulty;
  final String type;

  static int pointsPerQuestion = 0;

  Question(
    this.questionText,
    this.correctAnswer,
    this.incorrectAnswers,
    this.category,
    this.difficulty,
    this.type,
  ) {
    if (pointsPerQuestion == 0) {
      Future prefs = SharedPreferences.getInstance();
      prefs.then((value) => {pointsPerQuestion = int.parse(value.getString('pointsPerQuestion') ?? '100')});
    }
  }

  @override
  String toString() {
    const int maxLength = 25;
    if (questionText.length < maxLength) {
      return questionText;
    } else {
      return questionText.substring(0, maxLength) + '...';
    }
  }

  int getPoints() {
    if (difficulty == 'easy') {
      return pointsPerQuestion;
    } else if (difficulty == 'medium') {
      return 2 * pointsPerQuestion;
    } else if (difficulty == 'hard') {
      return 3 * pointsPerQuestion;
    } else {
      return pointsPerQuestion;
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    /// developer.log('Creating question from API response: $json', name: 'org.freenono.mundaneQuest.main');
    var unescape = HtmlUnescape();

    var incorrectAnswers = <String>[];
    for (var x in json['incorrect_answers']) {
      incorrectAnswers.add(unescape.convert(x.toString()));
    }
    return Question(unescape.convert(json['question']), unescape.convert(json['correct_answer']), incorrectAnswers, json['category'],
        json['difficulty'], json['type']);
  }
}

class QuestionBundle {
  final List<Question> questions;

  QuestionBundle(this.questions);

  Question pop() {
    Question q = questions.elementAt(0);
    questions.removeAt(0);
    return q;
  }
}

enum ReturnCode {
  /// Provides return codes used by the API of OpenTrivialDB.
  ///
  /// Source: https://opentdb.com/api_config.php
  success,
  noResult,
  invalidParameters,
  tokenNotFound,
  tokenEmpty
}

// TODO(prometheus42): Implement two question bank classes, one online, the other one offline.
class QuestionBank {
  String sessionToken = '';
  late QuestionBundle currentBundle;
  Map<int, String> categories = {};
  int currentCategory = 0;
  static const amountQuestionsFromAPI = 6; // maximum number of players is 5
  String defaultQuestionDifficulty = 'easy';
  String token = '';

  QuestionBank() {
    loadConfiguration();

    // fetch token for API, so that questions won't be send twice
    _fetchSessionToken()
        .then((value) => {
              if (value.statusCode == 200) {_parseTokenData(value.body)} else {throw Exception('Failed to fetch token from API!')}
            })
        .whenComplete(() => {
              // fetch categories from API (does not need the token!)
              _fetchCategoriesList().then((value) => {
                    if (value.statusCode == 200) {_parseCategoryData(value.body)} else {throw Exception('Failed to fetch token from API!')}
                  })
            });
  }

  void loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    defaultQuestionDifficulty = prefs.getString('defaultQuestionDifficulty') ?? 'easy';
  }

  Future<Response> _fetchSessionToken() {
    developer.log('Getting token from OpenTDB API...', name: 'org.freenono.mundaneQuest.main');
    const String url = 'https://opentdb.com/api_token.php?command=request';
    Future<http.Response> response = http.get(Uri.parse(url));
    return response;
  }

  Future<Response> _fetchCategoriesList() {
    developer.log('Getting categories from OpenTDB API...', name: 'org.freenono.mundaneQuest.main');
    const String url = 'https://opentdb.com/api_category.php';
    Future<Response> response = http.get(Uri.parse(url));
    return response;
  }

  Future<QuestionBundle> _fetchQuestions(int amount, int category, {String difficulty = '', String type = 'multiple'}) {
    // use default value for difficulty, that has been loaded from file
    if (difficulty.isEmpty) {
      difficulty = defaultQuestionDifficulty;
    }
    // the category parameter is the id of the category, in the response each question contains the name of the category!
    var url =
        'https://opentdb.com/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=$type&token=$token'; // &encode=url3986
    developer.log('Fetching questions from API: $url', name: 'org.freenono.mundaneQuest.main');
    Future response = http.get(Uri.parse(url));
    return response.then((value) => _parseQuestionData(value.body));
  }

  void _parseTokenData(String text) {
    developer.log('Parsing token from OpenTDB API...', name: 'org.freenono.mundaneQuest.main');
    Map<String, dynamic> jsonInput = jsonDecode(text);
    if (jsonInput['response_code'] == 0) {
      token = jsonInput['token'];
    } else {
      developer.log('Got error code from OpenTDB API!', name: 'org.freenono.mundaneQuest.main');
    }
  }

  void _parseCategoryData(String text) {
    developer.log('Parsing categories from OpenTDB API...', name: 'org.freenono.mundaneQuest.main');
    Map<String, dynamic> jsonInput = jsonDecode(text);
    for (var c in jsonInput['trivia_categories']) {
      // data from API: {"id":9,"name":"General Knowledge"}
      categories[c['id']] = c['name'];
    }
  }

  QuestionBundle _parseQuestionData(String text) {
    developer.log('Parsing questions from API: $text', name: 'org.freenono.mundaneQuest.main');

    List<Question> newQuestions = <Question>[];
    Map<String, dynamic> jsonInput = jsonDecode(text);
    if (jsonInput['response_code'] == 0) {
      var results = jsonInput['results'];
      for (var question in results) {
        newQuestions.add(Question.fromJson(question));
      }
    } else if (jsonInput['response_code'] == 1) {
      developer.log('Got error code 1 from OpenTDB API while parsing questions!', name: 'org.freenono.mundaneQuest.main');
    } else {
      developer.log('Got some error code from OpenTDB API while parsing questions!', name: 'org.freenono.mundaneQuest.main');
    }
    currentBundle = QuestionBundle(newQuestions);
    return currentBundle;
  }

  Future<QuestionBundle> switchCategory({String difficulty = '', String type = ''}) {
    var rng = Random();
    int newCategory = categories.keys.elementAt(rng.nextInt(categories.keys.length));
    currentCategory = newCategory;
    developer.log('Switched category to: ${categories[currentCategory]}', name: 'org.freenono.mundaneQuest.main');
    return _fetchQuestions(amountQuestionsFromAPI, currentCategory, type: 'multiple');
  }
}

class PlayGameWidget extends StatefulWidget {
  const PlayGameWidget({Key? key, required this.listOfPlayerNames, required this.questionBank}) : super(key: key);

  final Iterable<String> listOfPlayerNames;
  final QuestionBank questionBank;

  @override
  State<PlayGameWidget> createState() => _PlayGameState();
}

enum GameState {
  readyPlayers,
  showQuestion,
  evalAnswer,
  gameEnded,
}

class _PlayGameState extends State<PlayGameWidget> with TickerProviderStateMixin {
  late QuestionBundle currentQuestionBundle;

  // information about players and the current player
  final Map<String, int> playerPoints = {};
  final List<String> playerReady = [];
  String currentPlayer = '';
  int currentRound = 1;
  final List<String> currentRoundPlayers = [];

  // current question and the list of answers for that question
  Question? currentQuestion;
  List<String> answers = [];

  // current state and constants
  GameState gameState = GameState.readyPlayers;
  int gameTime = 30;
  int roundsPerGame = 8;
  int defaultDelayTime = 4;
  int defaultReadyTime = 8;
  bool audioActivated = false;
  bool gamepadSupport = false;

  // UI parameters and helper variables
  Color currentBackgroundColor = Colors.lightGreenAccent.shade100;
  final List<Color> listOfColors = [
    Colors.amberAccent.shade100,
    Colors.lightBlueAccent.shade100,
    Colors.lightGreenAccent.shade100,
    Colors.limeAccent.shade100,
    Colors.greenAccent.shade100,
    Colors.tealAccent.shade100,
    Colors.deepOrangeAccent.shade100
  ];
  String readyPlayersMessage = '';
  int readyPlayersMessageCounter = 0;
  double gameProgress = 0.0;

  // members concerning timing and delays
  int currentQuestionStartTime = 0;
  late Future readyDelay;
  late Future waitAfterAnswerDelay;
  Timer? gamepadTimer;
  late Timer gameTimer;
  var rng = Random();

  //final List<html.Gamepad> listOfGamepads = [];
  final List<bool> gamePadButtons = [];
  bool gamepadPresent = false;

  late AudioPlayer soundEffects;
  late AudioPlayer backgroundMusic;

  @override
  void initState() {
    developer.log('Initializing state of PlayGameWidget.', name: 'org.freenono.mundaneQuest.main');

    // set points for all player to zero at begin of game
    for (var player in widget.listOfPlayerNames) {
      playerPoints[player] = 0;
    }
    gameState = GameState.readyPlayers;

    loadConfiguration().then((value) => initializeEverything());

    super.initState();
  }

  void initializeEverything() {
    // prepare audio support, source: https://stackoverflow.com/a/50744481
    if (audioActivated && (kIsWeb || !Platform.isLinux)) {
      soundEffects = AudioPlayer();
      // TODO(prometheus42): Fix background music.
      // backgroundMusic = AudioPlayer();
      // backgroundMusic.setAsset('assets/audio/bgm.mp3').whenComplete(() => {
      //   backgroundMusic.play()
      // });
    }

    // wait for some time to allow all players to get ready...
    readyDelay = Future.delayed(Duration(seconds: defaultReadyTime), () {
      setState(() {
        gameState = GameState.showQuestion;
        _loadNextQuestion();
      });
    });

    // run game timer
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) => _handleGameTimer(timer));

    // load a bundle of questions for the first round from a random category
    _loadQuestionBundle();

    if (gamepadSupport) {
      initializeGamepad();
    }
  }

  void initializeGamepad() {
    //   html.GamepadEvent gpe;
    //   html.window.addEventListener(
    //       "gamepadconnected",
    //       (e) => {
    //             gpe = e as html.GamepadEvent,
    //             print('New gamepad found: ${gpe.gamepad!.id}'),
    //             if (gpe.gamepad != null) {listOfGamepads.add(gpe.gamepad!), gamepadPresent = true}
    //           });
    //   html.window.addEventListener(
    //       "gamepaddisconnected",
    //       (e) => {
    //             gpe = e as html.GamepadEvent,
    //             print('Gamepad was disconnected: ${gpe.gamepad!.id}'),
    //             if (gpe.gamepad != null) {listOfGamepads.remove(gpe.gamepad!)}
    //           });
    //
    //   gamepadTimer = Timer.periodic(const Duration(milliseconds: 200), (Timer timer) {
    //     if (gamepadPresent) {
    //       var gamepads = html.window.navigator.getGamepads();
    //       for (var gamepad in gamepads) {
    //         if (gamepad != null) {
    //           gamepadPresent = true;
    //           if (!gamePadButtons[0] && (gamepad.buttons![0].pressed ?? false)) {
    //             _checkGivenAnswer(answers[0]);
    //             gamePadButtons[0] = true;
    //           } else {
    //             gamePadButtons[0] = false;
    //           }
    //           if (!gamePadButtons[1] && (gamepad.buttons![1].pressed ?? false)) {
    //             _checkGivenAnswer(answers[1]);
    //             gamePadButtons[1] = true;
    //           } else {
    //             gamePadButtons[1] = false;
    //           }
    //           if (!gamePadButtons[2] && (gamepad.buttons![2].pressed ?? false)) {
    //             _checkGivenAnswer(answers[2]);
    //             gamePadButtons[2] = true;
    //           } else {
    //             gamePadButtons[2] = false;
    //           }
    //           if (!gamePadButtons[3] && (gamepad.buttons![3].pressed ?? false)) {
    //             _checkGivenAnswer(answers[3]);
    //             gamePadButtons[3] = true;
    //           } else {
    //             gamePadButtons[3] = false;
    //           }
    //         }
    //       }
    //     }
    //   });
  }

  void _handleGameTimer(Timer timer) {
    developer.log('Current game state: $gameState');

    if (gameState == GameState.showQuestion) {
      setState(() {
        // calculate number for progress bar if question is active
        if (currentQuestionStartTime != 0) {
          gameProgress = (gameTimer.tick - currentQuestionStartTime) / gameTime;
          if (timer.tick - currentQuestionStartTime > gameTime) {
            currentQuestionStartTime = 0;
            _showCorrectAnswer();
          }
        }
      });
    }
    if (gameState == GameState.readyPlayers) {
      setState(() {
        if (readyPlayersMessage.isEmpty) {
          readyPlayersMessage = AppLocalizations.of(context)!.readyPlayers;
        }
        int countdown = defaultReadyTime - 1 - readyPlayersMessageCounter;
        if (countdown <= 3 && countdown >= 1) {
          readyPlayersMessage += '$countdown...';
        }
        readyPlayersMessageCounter++;
      });
    }
    if (gameState == GameState.evalAnswer) {
      setState(() {
        // reset message to be shown before next questions
        readyPlayersMessage = AppLocalizations.of(context)!.readyPlayers;
        readyPlayersMessageCounter = 0;
      });
    }
  }

  Future loadConfiguration() async {
    return SharedPreferences.getInstance().then((prefs) => {
          defaultReadyTime = prefs.getDouble('defaultReadyTime')?.toInt() ?? 8,
          defaultDelayTime = prefs.getDouble('defaultDelayTime')?.toInt() ?? 4,
          gameTime = prefs.getDouble('gameTime')?.toInt() ?? 30,
          roundsPerGame = prefs.getDouble('roundsPerGame')?.toInt() ?? 7,
          audioActivated = prefs.getBool('audioActivated') ?? true,
          gamepadSupport = prefs.getBool('gamepadSupport') ?? true
        });
  }

  void _loadQuestionBundle() async {
    // if new questions have to be fetched, load the next own after loading has finished
    do {
      await widget.questionBank.switchCategory().whenComplete(() => {
            developer.log('Switching of category completed.', name: 'org.freenono.mundaneQuest.main'),
            currentQuestionBundle = widget.questionBank.currentBundle,
          });
    } while (currentQuestionBundle.questions.isEmpty);
    developer.log('After while loop!!!', name: 'org.freenono.mundaneQuest.main');
  }

  void _loadNextQuestion() {
    developer.log('Starting to load next question...', name: 'org.freenono.mundaneQuest.main');

    setState(() {
      // fill out question and answers
      currentQuestion = currentQuestionBundle.pop();
      // create list with the correct and all incorrect answers and shuffle the answers
      answers.clear();
      answers.add(currentQuestion!.correctAnswer);
      answers.addAll(currentQuestion!.incorrectAnswers);
      answers.shuffle();

      // find next random player, that has not played in this round yet
      String nextPlayer = '';
      do {
        nextPlayer = widget.listOfPlayerNames.elementAt(rng.nextInt(widget.listOfPlayerNames.length));
      } while (currentRoundPlayers.contains(nextPlayer));
      currentPlayer = nextPlayer;
      currentRoundPlayers.add(currentPlayer);

      // set start time for current question
      currentQuestionStartTime = gameTimer.tick;
      gameState = GameState.showQuestion;
    });
  }

  void _playNextQuestion() {
    developer.log('Starting to play next question...', name: 'org.freenono.mundaneQuest.main');

    // do nothing anymore, if game has ended already
    if (gameState == GameState.gameEnded) {
      gameTimer.cancel();
      gamepadTimer?.cancel();
      return;
    }

    // check whether the last round was played
    if (currentRound == roundsPerGame && currentRoundPlayers.length == widget.listOfPlayerNames.length) {
      developer.log('Last round ended!', name: 'org.freenono.mundaneQuest.main');
      setState(() {
        gameState = GameState.gameEnded;
      });

      // output game score at end on score board widget
      Future.delayed(Duration(seconds: defaultDelayTime), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ScoreBoardWidget(playerPoints: playerPoints)),
        );
      });
    } else {
      // check whether the first round begins or the last round has been finished
      if (currentRoundPlayers.length == widget.listOfPlayerNames.length) {
        // reset round, change category and start next round
        var availableColors = listOfColors.where((element) => element != currentBackgroundColor).toList();
        availableColors.shuffle();
        // TODO(prometheus42): Make background color dependent on category.
        currentBackgroundColor = availableColors.first;
        currentRoundPlayers.clear();
        currentRound++;
        // load questions for next round
        _loadQuestionBundle();
        // set state and wait for next question
        setState(() {
          gameState = GameState.readyPlayers;
        });
        readyDelay = Future.delayed(Duration(seconds: defaultReadyTime), () {
          setState(() {
            gameState = GameState.showQuestion;
            _loadNextQuestion();
          });
        });
      } else {
        // if no new questions have to be fetched, just get load the next own into GUI
        setState(() {
          gameState = GameState.showQuestion;
          _loadNextQuestion();
        });
      }
    }
  }

  void _showCorrectAnswer() {
    // wait for some time and start next question only after that time
    setState(() {
      gameState = GameState.evalAnswer;
    });
    waitAfterAnswerDelay = Future.delayed(Duration(seconds: defaultDelayTime), () {
      _playNextQuestion();
    });
  }

  void _checkGivenAnswer(String chosenAnswer) {
    if (gameState == GameState.showQuestion) {
      if (chosenAnswer == currentQuestion!.correctAnswer) {
        if (audioActivated && (kIsWeb || !Platform.isLinux)) {
          soundEffects.setAsset('assets/audio/success.mp3').whenComplete(() => {soundEffects.play()});
        }
        setState(() {
          playerPoints[currentPlayer] = playerPoints[currentPlayer]! + currentQuestion!.getPoints();
        });
      } else {
        if (audioActivated && (kIsWeb || !Platform.isLinux)) {
          soundEffects.setAsset('assets/audio/failure.mp3').whenComplete(() => {soundEffects.play()});
        }
      }
    }
    currentQuestionStartTime = 0;
    _showCorrectAnswer();
  }

  List<Widget> _buildPlayerButtons() {
    List<Widget> playerButtons = [];
    int i = 0;

    playerButtons.add(Expanded(child: Container()));
    for (var player in widget.listOfPlayerNames) {
      var pb = Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(AppLocalizations.of(context)!.player + ' ${i + 1}', style: Theme.of(context).textTheme.headline5),
          const SizedBox(
            height: 25,
          ),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              child: Text(player, style: Theme.of(context).textTheme.headline4),
              onPressed: !(currentPlayer == player) ? null : () => {},
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          AnimatedFlipCounter(
            value: playerPoints[player]!.toDouble(),
            duration: const Duration(seconds: 2),
            prefix: AppLocalizations.of(context)!.points + ': ',
            textStyle: const TextStyle(
              fontSize: 40,
              color: Colors.black45,
            ),
          ),
        ]),
      );
      i++;
      playerButtons.add(pb);
      playerButtons.add(Expanded(child: Container()));
    }

    return playerButtons;
  }

  String getAnswerButtonText(i, answer) {
    var buttonChar = '';
    if (gamepadSupport && gamepadPresent) {
      switch (i) {
        case 0:
          buttonChar = '\u{2297}';
          break;
        case 1:
          buttonChar = '\u{229A}';
          break;
        case 2:
          buttonChar = '\u{1F7D7}'; // \u{1F7D8}
          break;
        case 3:
          buttonChar = '\u{1F7D5}'; // \u{1F7D6}
          break;
      }
    } else {
      switch (i) {
        case 0:
          buttonChar = '1';
          break;
        case 1:
          buttonChar = '2';
          break;
        case 2:
          buttonChar = '3';
          break;
        case 3:
          buttonChar = '4';
          break;
      }
    }
    return '$buttonChar: $answer';
  }

  List<Widget> _buildAnswerButtons() {
    List<Widget> answerButtons = [];
    int i = 0;

    // build list with widgets for all answers
    answerButtons.add(Expanded(child: Container()));
    for (var answer in answers) {
      Padding pb;
      if (answer == currentQuestion!.correctAnswer) {
        pb = Padding(
          padding: const EdgeInsets.all(20),
          child: gameState == GameState.readyPlayers
              ? Container()
              : ElevatedButton(
                  child: SizedBox(
                    width: 200,
                    child: Text(getAnswerButtonText(i, answer), style: Theme.of(context).textTheme.headline5),
                  ),
                  style: gameState == GameState.evalAnswer || gameState == GameState.gameEnded
                      ? ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        )
                      : const ButtonStyle(),
                  onPressed: () => _checkGivenAnswer(answer),
                ),
        );
      } else {
        pb = Padding(
          padding: const EdgeInsets.all(20),
          child: gameState == GameState.readyPlayers
              ? Container()
              : ElevatedButton(
                  child: SizedBox(
                    width: 200,
                    child: Text(getAnswerButtonText(i, answer), style: Theme.of(context).textTheme.headline5),
                  ),
                  style: gameState == GameState.evalAnswer || gameState == GameState.gameEnded
                      ? ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        )
                      : const ButtonStyle(),
                  onPressed: () => _checkGivenAnswer(answer),
                ),
        );
      }
      answerButtons.add(pb);
      i++;
    }
    answerButtons.add(Expanded(child: Container()));

    return answerButtons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.letsPlayMundaneQuest),
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKey: (RawKeyEvent keyEvent) {
          if (keyEvent.character == '1') {
            _checkGivenAnswer(answers[0]);
          } else if (keyEvent.character == '2') {
            _checkGivenAnswer(answers[1]);
          } else if (keyEvent.character == '3') {
            _checkGivenAnswer(answers[2]);
          } else if (keyEvent.character == '4') {
            _checkGivenAnswer(answers[3]);
          }
        },
        child: AnimatedContainer(
          color: currentBackgroundColor,
          duration: const Duration(seconds: 2),
          child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.category + ': ${currentQuestion?.category ?? ''}',
                    style: Theme.of(context).textTheme.headline5),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.currentRound + ': $currentRound', style: Theme.of(context).textTheme.headline5),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppLocalizations.of(context)!.difficulty + ': ${currentQuestion?.difficulty ?? ''}',
                    style: Theme.of(context).textTheme.headline5),
              ),
            ]),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.all(20),
              // TODO(prometheus42): Make questions fly into the screen.
              child: Text(
                  gameState != GameState.readyPlayers
                      ? AppLocalizations.of(context)!.question + ':\n' + (currentQuestion?.questionText ?? '')
                      : readyPlayersMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3),
            ),
            Row(children: _buildAnswerButtons()),
            Expanded(child: Container()),
            Row(children: _buildPlayerButtons()),
            LinearProgressIndicator(
              value: gameProgress,
              minHeight: 20,
              semanticsLabel: 'Linear progress indicator',
            ),
          ])),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (audioActivated && (kIsWeb || !Platform.isLinux)) {
      soundEffects.dispose();
    }
    gameTimer.cancel();
    gamepadTimer?.cancel();
    super.dispose();
  }
}

class ScoreBoardWidget extends StatefulWidget {
  const ScoreBoardWidget({Key? key, required this.playerPoints}) : super(key: key);

  final Map<String, int> playerPoints;

  @override
  State<ScoreBoardWidget> createState() => _ScoreBoardWidgetState();
}

class _ScoreBoardWidgetState extends State<ScoreBoardWidget> {
  var sortedPoints = [];

  @override
  void initState() {
    sortedPoints = widget.playerPoints.values.toList();
    sortedPoints.sort();
    sortedPoints = sortedPoints.reversed.toList();
    super.initState();
  }

  Color _getColorForPlayer(player) {
    if (sortedPoints.isNotEmpty) {
      if (widget.playerPoints[player] == sortedPoints[0]) {
        return Colors.yellowAccent.shade400;
      } else if (widget.playerPoints[player] == sortedPoints[1]) {
        return Colors.grey.shade300;
      } else if (sortedPoints.length > 2 && widget.playerPoints[player] == sortedPoints[2]) {
        return Colors.brown.shade200;
      } else {
        return Colors.white;
      }
    } else {
      return Colors.white;
    }
  }

  List<Widget> _buildScoreFields() {
    List<Widget> scoreFields = [];

    for (var player in widget.playerPoints.keys) {
      scoreFields.add(Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                child: Container(),
                height: (sortedPoints.indexOf(widget.playerPoints[player]).toDouble()) * 100,
              ),
              OutlinedButton(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Column(children: [
                      Expanded(child: Container()),
                      Text(player,
                          style: Theme.of(context).textTheme.headline3!.apply(
                            backgroundColor: _getColorForPlayer(player),
                            //fontSize: 50,
                            //fontWeightDelta: 1,
                            //letterSpacing: -8.0,
                            //color: Colors.blueGrey,
                            shadows: [
                              const BoxShadow(
                                color: Colors.black38,
                                offset: Offset(4, 4),
                                blurRadius: 4,
                              ),
                            ],
                          )),
                      Expanded(child: Container()),
                      OutlinedButton(
                          child: Text('${widget.playerPoints[player]} ' + AppLocalizations.of(context)!.points,
                              style: Theme.of(context).textTheme.headline3!),
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0), side: const BorderSide(color: Colors.white, width: 10.0))),
                          )),
                      Expanded(child: Container()),
                    ]),
                  ),
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(_getColorForPlayer(player)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0), side: BorderSide(color: _getColorForPlayer(player)))),
                  )),
            ],
          )));
    }

    return scoreFields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.scoreBoard),
          //automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName("/"));
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.scoreBoard, style: Theme.of(context).textTheme.headline2),
              Row(children: [
                Expanded(child: Container()),
                Row(children: _buildScoreFields()),
                Expanded(child: Container()),
              ]),
              ConstrainedBox(
                constraints: const BoxConstraints.tightFor(width: 400),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                    ),
                    child: Text(AppLocalizations.of(context)!.backToMainMenu, style: Theme.of(context).textTheme.headline5),
                    onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName("/")),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
