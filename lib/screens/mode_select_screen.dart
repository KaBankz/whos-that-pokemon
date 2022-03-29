import 'package:flutter/material.dart';
import 'package:whos_that_pokemon/screens/play_screen.dart';

class ModeSelectScreen extends StatefulWidget {
  static const String route = '/home';

  @override
  _ModeSelectScreenState createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Who's That Pokemon?"),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Flex(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          direction: Axis.vertical,
          children: [
            const Text(
              'Choose Your Difficulty',
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/play', arguments: PlayScreenArguments(difficulty: 'easy'));
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.green,
                minimumSize: const Size(100.0, 50.0),
              ),
              child: const Text(
                'Easy',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/play', arguments: PlayScreenArguments(difficulty: 'medium'));
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.blue,
                minimumSize: const Size(100.0, 50.0),
              ),
              child: const Text(
                'Medium',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/play', arguments: PlayScreenArguments(difficulty: 'hard'));
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
                minimumSize: const Size(100.0, 50.0),
              ),
              child: const Text(
                'Hard',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/play', arguments: PlayScreenArguments(difficulty: 'extreme'));
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.orange,
                minimumSize: const Size(100.0, 50.0),
              ),
              child: const Text(
                'Extreme',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/stats');
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.teal,
                minimumSize: const Size(100.0, 50.0),
              ),
              child: const Text(
                'Stats',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
