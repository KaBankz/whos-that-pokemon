import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whos_that_pokemon/models/pokemon_model.dart';

class Play extends StatefulWidget {
  const Play({Key? key}) : super(key: key);

  static const String route = '/play';

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  final Random _random = Random();
  int _score = 0;
  int _hints = 0;
  bool _hintsUsed = false;
  bool _guessed = false;
  bool _correct = false;
  List<int> _pokemonHistory = [];
  List<Pokemon>? _allPokemon;
  Pokemon? _currentPokemon;
  List<String>? _randomNames;
  List<String>? _randomTypes;
  bool loaded = false;
  late String _difficulty;
  List<String> _buttons = [];

  @override
  void initState() {
    super.initState();
    loadAllFutures();
  }

  Future loadAllFutures() async {
    _allPokemon = await _loadPokemonData();
    _currentPokemon = await _getRandomPokemon();
    _randomNames = await _getRandomPokemonNames();
    _randomTypes = await _getRandomPokemonTypes();
    setState(() {
      loaded = true;
    });
  }

  Future<List<Pokemon>> _loadPokemonData() async {
    final String jsonString = await rootBundle.loadString('assets/data.json');
    final List<Pokemon> allPokemon = pokemonFromJson(jsonString);
    return allPokemon;
  }

  Future<Pokemon> _getRandomPokemon() async {
    final int totalPkm = _allPokemon!.length;
    int randomIndex = _random.nextInt(totalPkm);
    while (_pokemonHistory.contains(randomIndex)) {
      randomIndex = _random.nextInt(totalPkm);
    }
    _pokemonHistory.add(randomIndex);
    debugPrint(_allPokemon![randomIndex].toString());
    return _allPokemon![randomIndex];
  }

  Future<List<String>> _getRandomPokemonNames() async {
    List<String> pokemonNames = [];
    pokemonNames.add(_currentPokemon!.names.en);
    final int totalPkm = _allPokemon!.length;
    while (pokemonNames.length != 4) {
      int randomIndex = _random.nextInt(totalPkm);
      final String pokemonName = _allPokemon![randomIndex].names.en;
      if (pokemonNames.contains(pokemonName)) continue;
      pokemonNames.add(pokemonName);
    }
    debugPrint(pokemonNames.toString());
    return pokemonNames;
  }

  Future<List<String>> _getRandomPokemonTypes() async {
    List<String> pokemonTypes = [];
    pokemonTypes.add(_currentPokemon!.types.toString());
    final int totalPkm = _allPokemon!.length;
    while (pokemonTypes.length != 4) {
      int randomIndex = _random.nextInt(totalPkm);
      final String pokemonType = _allPokemon![randomIndex].types.toString();
      if (pokemonTypes.contains(pokemonType)) continue;
      pokemonTypes.add(pokemonType);
    }
    debugPrint(pokemonTypes.toString());
    return pokemonTypes;
  }

  Future<void> _checkAnswer(String answer) async {
    if (answer == _currentPokemon!.names.en.toUpperCase()) {
      setState(() {
        _guessed = true;
        _correct = true;
        _score++;
      });
      // await Future.delayed(const Duration(seconds: 2), () {});
      // setState(() {
      //   _guessed = false;
      //   _correct = false;
      //   _buttons = [];
      // });
      // await loadAllFutures();
      debugPrint('Correct!');
    } else {
      _guessed = true;
      _correct = false;
      _score = 0;
      debugPrint('Wrong!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Who's That Pokemon?"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              '$_score',
              style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: loaded
            ? Flex(
                direction: Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image.asset(
                    'assets/artwork/${_currentPokemon!.id}.png',
                    height: MediaQuery.of(context).size.height / 4,
                  ),
                  Text(_currentPokemon!.names.en.toUpperCase()),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: true,
                    crossAxisCount: 2,
                    childAspectRatio: 2.0,
                    children: buildButtons(_randomNames!),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  List<Widget> buildButtons(List<String> choices) {
    // ? Nevermind have to rework this fix because this does not let the button
    // state update to disable on guessed. :sadge:
    //
    // Jank fix to stop rebuild
    // Save buttons to variable and return them if they exist
    // this makes sure that their position does not change on rebuild
    // if the buttons do not exist, create them then save them

    List<Widget> buttons = [];
    choices.asMap().forEach((index, value) {
      String answer = value.toUpperCase().replaceAll(RegExp(r'[\[\]]'), '');
      // TODO Find a way to add hint feature without it being rebuilt everytime setstate is called
      // Select 1 or 2 buttons to be hints
      buttonClick() {
        // Hard Mode +
        if (_difficulty == 'hard' || _difficulty == 'extreme') {
          if (index > 0 && index < 2) return false;
        }
        // Everything else
        if (index > 0 && index < 3) return false;
        return true;
      }

      buttons.add(
        TextButton(
          // Hint Logic
          // If hints are not used return answerchecker, else return null
          onPressed: _guessed
              ? null
              : (!_hintsUsed)
                  ? () => _checkAnswer(answer)
                  : buttonClick()
                      ? () => _checkAnswer(answer)
                      : null,
          child: Text(answer),
        ),
      );
    });
    // Randomize buttons
    buttons.shuffle();
    return buttons;
  }
}
