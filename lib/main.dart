import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MundaneQuest());
}

class MundaneQuest extends StatelessWidget {
  const MundaneQuest({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mundane Quest',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Image(image: AssetImage('assets/logo.png')),
            Text(
              'Mundane Quest',
              style: Theme.of(context).textTheme.headline2,
            ),
            const SizedBox(height: 60),
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 400),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.00, bottom: 10.00),
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.yellow),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(20)),
                  ),
                  child: Text('Start standard game...',
                      style: Theme.of(context).textTheme.headline5),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StartGameDialogWidget()),
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
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.yellow),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(20)),
                  ),
                  child: Text('Change settings...',
                      style: Theme.of(context).textTheme.headline5),
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
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.yellow),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(20)),
                  ),
                  child: Text('Get help...',
                      style: Theme.of(context).textTheme.headline5),
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
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.yellow),
                    padding:
                        MaterialStateProperty.all(const EdgeInsets.all(20)),
                  ),
                  child: Text('Quit game...',
                      style: Theme.of(context).textTheme.headline5),
                  // exit app programmatically: https://stackoverflow.com/a/49067313
                  onPressed: () => SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StartGameDialogWidget extends StatefulWidget {
  const StartGameDialogWidget({Key? key}) : super(key: key);

  @override
  State<StartGameDialogWidget> createState() => _StartGameDialogState();
}

class _StartGameDialogState extends State<StartGameDialogWidget> {
  var listOfPlayerNameControllers = <TextEditingController>[];

  void _incrementPlayerCount() {
    setState(() {
      if (listOfPlayerNameControllers.length < 5) {
        TextEditingController newController = TextEditingController();
        listOfPlayerNameControllers.add(newController);
      } else {
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: const Text('The maximum number of players is 5!'),
            action: SnackBarAction(
                label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      }
    });
  }

  void _handleStartGame(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);

    developer.log('Checking whether enough player are given...',
        name: 'org.freenono.mundaneQuest.main');
    if (listOfPlayerNameControllers.length < 2) {
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('You need at least 2 players!'),
          action: SnackBarAction(
              label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
        ),
      );
    } else {
      var listOfPlayerNames = listOfPlayerNameControllers.map((e) => e.text);

      if (listOfPlayerNames.toSet().length != listOfPlayerNames.length) {
        scaffold.showSnackBar(
          SnackBar(
            content: const Text('No player name shall be used twice!'),
            action: SnackBarAction(
                label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      } else if (listOfPlayerNames.any((element) => element.isEmpty)) {
        scaffold.showSnackBar(
          SnackBar(
            content: const Text('Some player names are empty!'),
            action: SnackBarAction(
                label: 'ERROR', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlayGameWidget(
                    listOfPlayerNames: listOfPlayerNames,
                  )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var textFields = <Padding>[];
    for (var element in listOfPlayerNameControllers) {
      var no = listOfPlayerNameControllers.indexOf(element) + 1;
      textFields.add(Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            SizedBox(
                width: 500,
                child: TextField(
                  controller: element,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Enter name for player $no'),
                )),
            const SizedBox(width: 20),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    listOfPlayerNameControllers.remove(element);
                  });
                },
                child: const Text('Delete'))
          ])));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start a new game'),
      ),
      body: Row(children: [
        Expanded(child: Container()),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Add players to the game',
                  style: Theme.of(context).textTheme.headline3),
            ),
            const SizedBox(height: 60),
            Column(
              children: textFields,
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.yellow),
              ),
              child: Text('Start game...',
                  style: Theme.of(context).textTheme.headline4),
              onPressed: () => _handleStartGame(context),
            )
          ],
        ),
        Expanded(child: Container()),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementPlayerCount,
        tooltip: 'Add player',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Question {
  final String questionText;
  final String correctAnswer;
  final List<String> incorrectAnswers;

  // category for a single question is a String containing the name of the category
  final String category;
  final String difficulty;
  final String type;

  Question(
    this.questionText,
    this.correctAnswer,
    this.incorrectAnswers,
    this.category,
    this.difficulty,
    this.type,
  );

  @override
  String toString() {
    const int maxLength = 25;
    if (questionText.length < maxLength) {
      return questionText;
    } else {
      return questionText.substring(0, maxLength) + '...';
    }
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    developer.log('Creating question from API response: $json',
        name: 'org.freenono.mundaneQuest.main');
    var incorrectAnswers = <String>[];
    for (var x in json['incorrect_answers']) {
      incorrectAnswers.add(x.toString());
    }
    return Question(json['question'], json['correct_answer'], incorrectAnswers,
        json['category'], json['difficulty'], json['type']);
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

class QuestionBank {
  String sessionToken = '';
  late QuestionBundle newQuestions;
  Map<int, String> categories = {};
  int currentCategory = 0;
  static const amountQuestionsFromAPI = 10;
  String token = '';

  QuestionBank() {
    _fetchSessionToken();
    _fetchCategoriesList();
  }

  void _fetchSessionToken() async {
    developer.log('Getting token from OpenTDB API...',
        name: 'org.freenono.mundaneQuest.main');
    const String url = 'https://opentdb.com/api_token.php?command=request';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      _parseTokenData(response.body);
    } else {
      throw Exception('Failed to fetch token from API!');
    }
  }

  void _fetchCategoriesList() async {
    const String url = 'https://opentdb.com/api_category.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      _parseCategoryData(response.body);
    } else {
      throw Exception('Failed to fetch categories from API!');
    }
    switchCategory();
  }

  Future<QuestionBundle> _fetchQuestions(int amount, int category,
      {String difficulty = 'easy', String type = 'multiple'}) async {
    // the category parameter is the id of the category, in the response each question contains the name of the category!
    var url =
        'https://opentdb.com/api.php?amount=$amount&category=$category&difficulty=$difficulty&type=$type&token=$token'; // &encode=url3986
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      //Future<QuestionBundle> future = Future<QuestionBundle>();
      return _parseQuestionData(response.body);
    } else {
      throw Exception('Failed to fetch questions from API!');
    }
  }

  Future<QuestionBundle> switchCategory() {
    var rng = Random();
    int newCategory =
        categories.keys.elementAt(rng.nextInt(categories.keys.length));
    currentCategory = newCategory;
    developer.log('Switched category to: ${categories[currentCategory]}',
        name: 'org.freenono.mundaneQuest.main');
    return _fetchQuestions(amountQuestionsFromAPI, currentCategory,
        difficulty: 'easy', type: 'multiple');
  }

  QuestionBundle _parseQuestionData(String text) {
    developer.log('Parsing questions from API: $text',
        name: 'org.freenono.mundaneQuest.main');
    List<Question> newQuestions = <Question>[];
    Map<String, dynamic> jsonInput = jsonDecode(text);
    if (jsonInput['response_code'] == 0) {
      var results = jsonInput['results'];
      for (var question in results) {
        newQuestions.add(Question.fromJson(question));
      }
    } else if (jsonInput['response_code'] == 1) {
      switchCategory();
    } else {
      developer.log('Got error code from OpenTDB API while parsing questions!',
          name: 'org.freenono.mundaneQuest.main');
    }
    return QuestionBundle(newQuestions);
  }

  void _parseCategoryData(String text) {
    developer.log('Parsing categories from OpenTDB API...',
        name: 'org.freenono.mundaneQuest.main');
    Map<String, dynamic> jsonInput = jsonDecode(text);
    for (var c in jsonInput['trivia_categories']) {
      // data from API: {"id":9,"name":"General Knowledge"}
      categories[c['id']] = c['name'];
    }
  }

  void _parseTokenData(String text) {
    developer.log('Parsing token from OpenTDB API...',
        name: 'org.freenono.mundaneQuest.main');
    Map<String, dynamic> jsonInput = jsonDecode(text);
    if (jsonInput['response_code'] == 0) {
      token = jsonInput['token'];
    } else {
      developer.log('Got error code from OpenTDB API!',
          name: 'org.freenono.mundaneQuest.main');
    }
  }
}

class PlayGameWidget extends StatefulWidget {
  const PlayGameWidget({Key? key, required this.listOfPlayerNames})
      : super(key: key);

  final Iterable<String> listOfPlayerNames;

  @override
  State<PlayGameWidget> createState() => _PlayGameState();
}

enum GameState {
  readyPlayers,
  showQuestion,
  evalAnswer,
}

class _PlayGameState extends State<PlayGameWidget>
    with TickerProviderStateMixin {
  final QuestionBank questionBank = QuestionBank();
  late QuestionBundle currentQuestionBundle;

  final Map<String, int> playerPoints = {};
  final List<String> playerReady = [];
  String currentPlayer = '';
  int currentRound = 0;
  final List<String> currentRoundPlayers = [];

  Question? currentQuestion;
  List<String> answers = [];
  int currentQuestionStartTime = 0;
  double gameProgress = 0.0;

  GameState gameState = GameState.readyPlayers;
  late Timer gameTimer;
  bool _isRunning = true;
  static const int gameTime = 15;
  static const int roundsPerGame = 3;

  late AnimationController controller;

  @override
  void initState() {
    // create controller for flashing the correct answer
    // Source: https://api.flutter.dev/flutter/material/LinearProgressIndicator-class.html
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(() {
        setState(() {});
      });
    // set points for all player to zero at begin of game
    for (var player in widget.listOfPlayerNames) {
      playerPoints[player] = 0;
    }
    // run game timer
    gameTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!_isRunning) {
        timer.cancel();
      }
      if (gameState == GameState.showQuestion) {
        setState(() {
          gameProgress = (gameTimer.tick - currentQuestionStartTime) / gameTime;
          if (timer.tick - currentQuestionStartTime > gameTime) {
            _showCorrectAnswer();
          }
        });
      }
    });

    super.initState();
  }

  void _showDialog(BuildContext context, String message) {
    // Source: https://googleflutter.com/flutter-alertdialog/
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert!!"),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _playNextQuestion() {
    var rng = Random();

    setState(() {
      gameState = GameState.showQuestion;
    });
    setState(() {
      // check whether the round has been finished
      if (currentRoundPlayers.length == widget.listOfPlayerNames.length) {
        // check whether the last round was played
        if (currentRound >= roundsPerGame) {
          // output game score at end on score board widget
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ScoreBoardWidget(playerPoints: playerPoints)),
          );
        }

        // reset round, change category and start next round
        currentRoundPlayers.clear();
        currentRound++;
        currentQuestionBundle = questionBank.switchCategory() as QuestionBundle;
      }

      // find next random player, that has not played in this round yet
      String nextPlayer = '';
      do {
        nextPlayer = widget.listOfPlayerNames
            .elementAt(rng.nextInt(widget.listOfPlayerNames.length));
      } while (currentRoundPlayers.contains(nextPlayer));
      currentPlayer = nextPlayer;
      currentRoundPlayers.add(currentPlayer);

      // fill out question and answers
      currentQuestion = currentQuestionBundle.pop();
      // create list with the correct and all incorrect answers and shuffle the answers
      answers.clear();
      answers.add(currentQuestion!.correctAnswer);
      answers.addAll(currentQuestion!.incorrectAnswers);
      answers.shuffle();

      // set start time for current question
      currentQuestionStartTime = gameTimer.tick;
    });
  }

  void _playerReady(String player) {
    setState(() {
      if (!playerReady.contains(player)) {
        playerReady.add(player);
      }
    });
    if (playerReady.length == widget.listOfPlayerNames.length) {
      gameState = GameState.showQuestion;
      currentRound = 1;
      _playNextQuestion();
    }
  }

  List<Widget> _buildPlayerButtons() {
    List<Widget> playerButtons = [];
    int i = 0;

    for (var player in widget.listOfPlayerNames) {
      var pb = Padding(
        padding: const EdgeInsets.all(50),
        child: Column(children: [
          Text('Spieler ${i + 1}'),
          ElevatedButton(
            child: Text(player),
            onPressed:
                playerReady.contains(player) && !(currentPlayer == player)
                    ? null
                    : () => _playerReady(player),
          ),
          Text('Punkte: ${playerPoints[player]}'),
        ]),
      );
      i++;
      playerButtons.add(pb);
      playerButtons.add(Expanded(child: Container()));
    }
    // remove last Expanded object, which would move everything to the left
    playerButtons.removeLast();

    return playerButtons;
  }

  void _showCorrectAnswer() {
    // TODO: Wait for some time and start next question only after that time!
    //_playNextQuestion();
    gameState = GameState.evalAnswer;
    Future.delayed(const Duration(seconds: 5), () {
      controller.repeat(reverse: true);
      setState(() {
        _playNextQuestion();
      });
    });
  }

  void _checkAnswer(String chosenAnswer) {
    _showCorrectAnswer();
    if (chosenAnswer == currentQuestion!.correctAnswer) {
      setState(() {
        playerPoints[currentPlayer] = playerPoints[currentPlayer]! + 100;
      });
    }
  }

  List<Widget> _buildAnswerButtons() {
    List<Widget> answerButtons = [];

    // build list with widgets for all answers
    answerButtons.add(Expanded(child: Container()));
    for (var answer in answers) {
      Padding pb;
      if (answer == currentQuestion!.correctAnswer) {
        pb = Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            child: Text(answer),
            style: gameState == GameState.evalAnswer
                ? ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  )
                : const ButtonStyle(),
            onPressed: () => _checkAnswer(answer),
          ),
        );
      } else {
        pb = Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            child: Text(answer),
            style: gameState == GameState.evalAnswer
                ? ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  )
                : const ButtonStyle(),
            onPressed: () => _checkAnswer(answer),
          ),
        );
      }
      answerButtons.add(pb);
    }
    answerButtons.add(Expanded(child: Container()));

    return answerButtons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Let\'s play Mundane Quest!'),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(50),
            child: Text('Category: ${currentQuestion?.category ?? ''}',
                style: Theme.of(context).textTheme.headline5),
          ),
          Expanded(child: Container()),
          /*Padding(
            padding: EdgeInsets.all(50),
            child: Text('Current player: ${currentPlayer}', style: Theme.of(context).textTheme.headline5),
          ),
          Expanded(child: Container()),*/
          Padding(
            padding: const EdgeInsets.all(50),
            child: Text('Current round: $currentRound',
                style: Theme.of(context).textTheme.headline5),
          ),
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.all(50),
            child: Text('Difficulty: ${currentQuestion?.difficulty ?? ''}',
                style: Theme.of(context).textTheme.headline5),
          ),
        ]),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
              gameState != GameState.readyPlayers
                  ? 'Question:\n' + (currentQuestion?.questionText ?? '')
                  : '',
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
    );
  }

  @override
  void dispose() {
    _isRunning = false;
    controller.dispose();
    super.dispose();
  }
}

class ScoreBoardWidget extends StatefulWidget {
  const ScoreBoardWidget({Key? key, required this.playerPoints})
      : super(key: key);

  final Map<String, int> playerPoints;

  @override
  State<ScoreBoardWidget> createState() => _ScoreBoardWidgetState();
}

class _ScoreBoardWidgetState extends State<ScoreBoardWidget> {
  List<Widget> _buildScoreFields() {
    List<Widget> scoreFields = [];

    for (var player in widget.playerPoints.keys) {
      scoreFields.add(Column(children: [
        Text('Player: $player', style: Theme.of(context).textTheme.headline3),
        Text('Points: ${widget.playerPoints[player]}',
            style: Theme.of(context).textTheme.headline4),
      ]));
    }

    return scoreFields;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Score Board'),
      ),
      body: Center(child: Row(children: _buildScoreFields())),
    );
  }
}
