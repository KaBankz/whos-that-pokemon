import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //   // systemNavigationBarColor: Color.fromRGBO(250, 250, 250, 1.0),
  //   // systemNavigationBarColor: Color(0x00010000),
  // ));
  // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  await Hive.initFlutter();
  await Hive.openBox('stats');
  runApp(WTP());
}

class WTP extends StatefulWidget {
  @override
  _WTPState createState() => _WTPState();
}

class _WTPState extends State<WTP> {
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Who's That Pokemon?",
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: const AppBarTheme(
          brightness: Brightness.dark,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: const AppBarTheme(
          brightness: Brightness.dark,
        ),
      ),
      home: const Play(),
      initialRoute: '/',
      routes: {
        ModeSelectScreen.route: (context) => ModeSelectScreen(),
        PlayScreen.route: (context) => PlayScreen(ModalRoute.of(context)!.settings.arguments as PlayScreenArguments),
        StatsScreen.route: (context) => StatsScreen(),
        // '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
