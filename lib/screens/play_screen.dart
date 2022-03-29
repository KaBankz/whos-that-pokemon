import 'dart:convert';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';

class PlayScreenArguments {
  PlayScreenArguments({required this.difficulty});

  final String difficulty;
}

class PlayScreen extends StatefulWidget {
  const PlayScreen(this.arguments);

  final PlayScreenArguments arguments;

  static const String route = '/play';

  static AudioCache player = AudioCache();

  @override
  PlayScreenState createState() => PlayScreenState();
}

class PlayScreenState extends State<PlayScreen> {
  bool loaded = false;
  PokemonData? randomPokemon;
  List<String> randomNames = [];
  List<String> randomTypes = [];
  bool guessed = false;
  bool hintUsed = false;
  bool correct = false;
  int streak = 0;
  int hints = 0;
  int highScore = 0;
  final db = Hive.box('stats');

  @override
  void initState() {
    super.initState();
    if (db.get(widget.arguments.difficulty) != null) highScore = db.get(widget.arguments.difficulty)['score'] as int;
    getRandomPokemon().then((pokemon) => randomPokemon = pokemon).then((data) {
      getRandomPokemonNames(data.names.en).then((names) => randomNames = names);
      getRandomPokemonTypes(data.types).then((types) => randomTypes = types);
    }).then((value) {
      setState(() {
        loaded = true;
      });
    });
  }

  List<int> history = [];

  Future<PokemonData> getRandomPokemon() async {
    final rawJson = await rootBundle.loadString('assets/data.json');
    final decodedJson = json.decode(rawJson);
    final totalPkm = decodedJson.length as int;
    final random = Random();
    int randomNumber = random.nextInt(totalPkm);
    while (history.contains(randomNumber)) {
      randomNumber = random.nextInt(totalPkm);
    }
    history.add(randomNumber);
    final data = PokemonData.fromJson(decodedJson[randomNumber] as Map<String, dynamic>);
    return data;
  }

  Future<List<String>> getRandomPokemonTypes(List<String> initialTypes) async {
    final exp = RegExp(r'[\[\]]');
    final List<String> types = [];
    types.add(initialTypes.toString().replaceAll(exp, ''));
    final rawJson = await rootBundle.loadString('assets/data.json');
    final decodedJson = json.decode(rawJson);
    final totalPkm = decodedJson.length as int;
    final random = Random();
    while (types.length != 4) {
      final int randomNumber = random.nextInt(totalPkm);
      final type = PokemonData.fromJson(decodedJson[randomNumber] as Map<String, dynamic>).types;
      final stringType = type.toString().replaceAll(exp, '');
      if (types.contains(stringType)) continue;
      if (type.length != initialTypes.length) continue;
      types.add(stringType);
    }
    types.shuffle();
    return types;
  }

  Future<List<String>> getRandomPokemonNames(String initialName) async {
    final List<String> names = [];
    final List<String> indexes = [];
    names.add(initialName);
    indexes.add(initialName[0]);
    final rawJson = await rootBundle.loadString('assets/data.json');
    final decodedJson = json.decode(rawJson);
    final totalPkm = decodedJson.length as int;
    final random = Random();
    while (names.length != 4) {
      final int randomNumber = random.nextInt(totalPkm);
      final name = PokemonData.fromJson(decodedJson[randomNumber] as Map<String, dynamic>).names.en;
      if (names.contains(name)) continue;
      if (widget.arguments.difficulty == 'hard') {
        if (indexes.contains(name[0])) continue;
      }
      names.add(name);
      indexes.add(name[0]);
    }
    names.shuffle();
    return names;
  }

  Future<void> reset() async {
    final newPkm = await getRandomPokemon();
    final newNames = await getRandomPokemonNames(newPkm.names.en);
    final newTypes = await getRandomPokemonTypes(newPkm.types);
    setState(() {
      guessed = false;
      hintUsed = false;
      correct = false;
      randomPokemon = newPkm;
      randomNames = newNames;
      randomTypes = newTypes;
    });
  }

  Future<void> clickHandler(String choice) async {
    final exp = RegExp(r'[\[\]]');
    if (choice == randomPokemon!.names.en || choice == randomPokemon!.types.toString().replaceAll(exp, '')) {
      await PlayScreen.player.play('sounds/cries/${randomPokemon!.id}.mp3');
      PlayScreen.player.clear('sounds/cries/${randomPokemon!.id}.mp3');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Correct! 😆'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ));
      setState(() {
        guessed = true;
        correct = true;
        streak++;
      });
      if (streak > highScore) {
        await db.put(widget.arguments.difficulty, {'score': streak, 'hints': hints});
      }
      await Future.delayed(const Duration(seconds: 2), () {});
      await reset();
    } else {
      await PlayScreen.player.play('sounds/error.mp3');
      setState(() {
        guessed = true;
        correct = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Wrong! 😞'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ));
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Wrong 😞'),
              content: Text('Streak: $streak'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  },
                  child: const Text('Quit'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Future.delayed(const Duration(seconds: 2), () {});
                    setState(() {
                      streak = 0;
                    });
                    await reset();
                  },
                  child: const Text('Retry'),
                ),
              ],
            );
          });
    }
  }

  Future<bool> confirmQuit() async {
    bool quit = false;
    if (streak == 0) return true;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Do you want to quit?'),
            content: Text('Your streak will end at $streak, hints $hints'),
            actions: [
              TextButton(
                onPressed: () {
                  quit = true;
                  Navigator.pop(context);
                },
                child: const Text('Quit'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        });
    return quit;
  }

  List<Widget> generateButtons() {
    final String difficulty = widget.arguments.difficulty;
    final exp = RegExp(r'[\[\]]');
    int hintChoices = 0;
    List<Widget> buttons;
    if (difficulty == 'extreme') {
      buttons = randomTypes.map((e) {
        if (e == randomPokemon!.types.toString().replaceAll(exp, '')) {
          return TextButton(
            onPressed: guessed ? null : () => clickHandler(e),
            child: Text(e.toUpperCase()),
          );
        }
        if (hintChoices != 1) {
          hintChoices++;
          return TextButton(
            onPressed: (guessed || hintUsed) ? null : () => clickHandler(e),
            child: Text(e.toUpperCase()),
          );
        }
        return TextButton(
          onPressed: guessed ? null : () => clickHandler(e),
          child: Text(e.toUpperCase()),
        );
      }).toList();
    } else {
      buttons = randomNames.map((e) {
        if (e == randomPokemon!.names.en) {
          return TextButton(
            onPressed: guessed ? null : () => clickHandler(e),
            child: difficulty == 'easy'
                ? Text(e.toUpperCase())
                : difficulty == 'medium'
                    ? Text(e.toUpperCase()[0] + e.toUpperCase()[1] + e.toUpperCase()[3])
                    : Text(e.toUpperCase()[0]),
          );
        }
        if (hintChoices != 2) {
          hintChoices++;
          return TextButton(
            onPressed: (guessed || hintUsed) ? null : () => clickHandler(e),
            child: difficulty == 'easy'
                ? Text(e.toUpperCase())
                : difficulty == 'medium'
                    ? Text(e.toUpperCase()[0] + e.toUpperCase()[1] + e.toUpperCase()[3])
                    : Text(e.toUpperCase()[0]),
          );
        }
        return TextButton(
          onPressed: guessed ? null : () => clickHandler(e),
          child: difficulty == 'easy'
              ? Text(e.toUpperCase())
              : difficulty == 'medium'
                  ? Text(e.toUpperCase()[0] + e.toUpperCase()[1] + e.toUpperCase()[3])
                  : Text(e.toUpperCase()[0]),
        );
      }).toList();
    }
    return buttons;
  }

  void hint() {
    setState(() {
      hintUsed = true;
      hints++;
    });
  }

  Color getTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'NORMAL':
        return const Color.fromRGBO(170, 170, 152, 100);
      case 'FIRE':
        return const Color.fromRGBO(217, 76, 41, 100);
      case 'WATER':
        return const Color.fromRGBO(104, 154, 251, 100);
      case 'ELECTRIC':
        return const Color.fromRGBO(239, 204, 71, 100);
      case 'GRASS':
        return const Color.fromRGBO(151, 202, 95, 100);
      case 'ICE':
        return const Color.fromRGBO(147, 203, 253, 100);
      case 'FIGHTING':
        return const Color.fromRGBO(163, 88, 70, 100);
      case 'POISON':
        return const Color.fromRGBO(150, 88, 151, 100);
      case 'GROUND':
        return const Color.fromRGBO(210, 187, 94, 100);
      case 'FLYING':
        return const Color.fromRGBO(145, 154, 251, 100);
      case 'PSYCHIC':
        return const Color.fromRGBO(219, 93, 151, 100);
      case 'BUG':
        return const Color.fromRGBO(174, 186, 56, 100);
      case 'ROCK':
        return const Color.fromRGBO(181, 170, 107, 100);
      case 'GHOST':
        return const Color.fromRGBO(104, 103, 184, 100);
      case 'DRAGON':
        return const Color.fromRGBO(118, 105, 234, 100);
      case 'DARK':
        return const Color.fromRGBO(109, 86, 69, 100);
      case 'STEEL':
        return const Color.fromRGBO(170, 170, 186, 100);
      case 'FAIRY':
        return const Color.fromRGBO(217, 156, 235, 100);
      default:
        return const Color.fromRGBO(183, 183, 169, 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String difficulty = widget.arguments.difficulty;
    Color appBarColor = Colors.green;
    if (difficulty == 'easy') {
      appBarColor = Colors.green;
    } else if (difficulty == 'medium') {
      appBarColor = Colors.blue;
    } else if (difficulty == 'hard') {
      appBarColor = Colors.red;
    } else if (difficulty == 'extreme') {
      appBarColor = Colors.orange;
    }

    return WillPopScope(
      onWillPop: () => confirmQuit(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Who's That Pokemon?"),
          centerTitle: true,
          backgroundColor: appBarColor,
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Current Streak: $streak | Hints: $hints | High Score: $highScore'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  action: (guessed || hintUsed)
                      ? null
                      : SnackBarAction(
                          label: 'Hint',
                          onPressed: () => hint(),
                        ),
                ));
              },
              child: Text(
                '${streak > highScore ? '+' : ''}$streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
        body: loaded
            ? Container(
                alignment: Alignment.center,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: GestureDetector(
                          onTap: () async {
                            if (difficulty == 'hard' || difficulty == 'medium' || difficulty == 'extreme') return;
                            await PlayScreen.player.play('sounds/cries/${randomPokemon!.id}.mp3');
                          },
                          child: Image.asset(
                            'assets/artwork/${randomPokemon!.id}.png',
                            color: guessed ? null : Colors.black,
                            height: MediaQuery.of(context).size.height / 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      Text(
                        guessed ? randomPokemon!.names.en.toUpperCase() : '???',
                        style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: randomPokemon!.types.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Chip(
                              backgroundColor: guessed ? getTypeColor(e) : getTypeColor(''),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              label: Text(
                                guessed ? e.toUpperCase() : '???',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(blurRadius: 7.0),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10.0),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        primary: true,
                        crossAxisCount: 2,
                        childAspectRatio: 2.0,
                        children: generateButtons(),
                      ),
                    ],
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
