import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class StatsScreen extends StatefulWidget {
  static const String route = '/stats';

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

TextStyle _style = const TextStyle(
  fontSize: 25.0,
  fontWeight: FontWeight.bold,
);

TextStyle _style2 = const TextStyle(
  fontSize: 25.0,
);

class _StatsScreenState extends State<StatsScreen> {
  final db = Hive.box('stats');
  int easyHighScore = 0;
  int mediumHighScore = 0;
  int hardHighScore = 0;
  int extremeHighScore = 0;
  int easyHints = 0;
  int mediumHints = 0;
  int hardHints = 0;
  int extremeHints = 0;

  void loadData() {
    setState(() {
      if (db.get('easy') != null) {
        easyHighScore = db.get('easy')['score'] as int;
        easyHints = db.get('easy')['hints'] as int;
      }
      if (db.get('medium') != null) {
        mediumHighScore = db.get('medium')['score'] as int;
        mediumHints = db.get('medium')['hints'] as int;
      }
      if (db.get('hard') != null) {
        hardHighScore = db.get('hard')['score'] as int;
        hardHints = db.get('hard')['hints'] as int;
      }
      if (db.get('extreme') != null) {
        extremeHighScore = db.get('extreme')['score'] as int;
        extremeHints = db.get('extreme')['hints'] as int;
      }
    });
  }

  void resetData() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Do you want to reset all data?'),
            content: const Text('Your highscores will be permanently reset!'),
            actions: [
              TextButton(
                onPressed: () async {
                  await db.clear();
                  setState(() {
                    easyHighScore = 0;
                    mediumHighScore = 0;
                    hardHighScore = 0;
                    extremeHighScore = 0;
                    easyHints = 0;
                    mediumHints = 0;
                    hardHints = 0;
                    extremeHints = 0;
                  });
                  Navigator.pop(context);
                },
                child: const Text('RESET'),
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
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => resetData(),
            icon: const Icon(Icons.restore_outlined),
            tooltip: 'Reset Data',
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Easy Mode', style: _style),
            const SizedBox(height: 20.0),
            Text('High Score: $easyHighScore', style: _style2),
            Text('Hints: $easyHints', style: _style2),
            const SizedBox(height: 20.0),
            Text('Medium Mode', style: _style),
            const SizedBox(height: 20.0),
            Text('High Score: $mediumHighScore', style: _style2),
            Text('Hints: $mediumHints', style: _style2),
            const SizedBox(height: 20.0),
            Text('Hard Mode', style: _style),
            const SizedBox(height: 20.0),
            Text('High Score: $hardHighScore', style: _style2),
            Text('Hints: $hardHints', style: _style2),
            const SizedBox(height: 20.0),
            Text('Extreme Mode', style: _style),
            const SizedBox(height: 20.0),
            Text('High Score: $extremeHighScore', style: _style2),
            Text('Hints: $extremeHints', style: _style2),
          ],
        ),
      ),
    );
  }
}
