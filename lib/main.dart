import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timelist_journal/pages/home_page.dart';
import 'package:timelist_journal/pages/opening_page.dart';
import 'package:timelist_journal/services/service_controller.dart';

/*
  ------------------------
  === TIMELIST JOURNAL ===
  ------------------------
  A list-based journaling app for recording the little things in life

  by Logan Giese
 */

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Initialize Firebase
  final Future<FirebaseApp> firebaseInitialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timelist Journal',
      themeMode: ThemeMode.system, // Light or dark mode
      theme: ThemeData(
        //primarySwatch: Colors.deepPurple, // Near-universal primary color without specifying each detail
        appBarTheme: AppBarTheme(color: Colors.deepPurple, textTheme: _textTheme(Colors.white)),
        canvasColor: Color(0xffe2e0ee), // Sidebar background
        scaffoldBackgroundColor: Color(0xfff2f2ff), // Main background
        accentColor: Colors.deepPurpleAccent,
        dividerColor: Colors.black38,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.deepPurple),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2.0)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 1.0)),
        ),
        textTheme: _textTheme(Colors.black87),
        accentTextTheme: TextTheme(button: TextStyle(color: Colors.white, fontSize: 17.0)),
        fontFamily: 'ZillaSlab',
        unselectedWidgetColor: Colors.black45,
        iconTheme: IconThemeData(color: Colors.deepPurpleAccent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        appBarTheme: AppBarTheme(color: Color(0xFF3f1b8f), textTheme: _textTheme(Color(0xFFDFDFDF))),
        canvasColor: Color(0xff413f4f), // Sidebar background
        scaffoldBackgroundColor: Color(0xff232033), // Main background
        accentColor: Color(0xFF9972ed),
        dividerColor: Color(0xFFAAAAAA),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF9972ed)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF9972ed), width: 2.0)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF9972ed), width: 1.0)),
        ),
        textTheme: _textTheme(Color(0xFFDFDFDF)),
        accentTextTheme: TextTheme(button: TextStyle(color: Colors.white, fontSize: 17.0)),
        fontFamily: 'ZillaSlab',
        unselectedWidgetColor: Color(0xFFAAAAAA),
        iconTheme: IconThemeData(color: Color(0xFF9972ed)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Builder(builder: (context) => ListTileTheme(
        iconColor: Theme.of(context).iconTheme.color,
        child: _home(),
      ),),
    );
  }

  // Helper to build the home page with icon theming
  Widget _home() {
    return FutureBuilder<FirebaseApp>(
      future: firebaseInitialization,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('An error occurred'),
            ),
          );
        }
        if (snapshot.hasData) {
          return ServiceController.isSignedIn() ? HomePage() : OpeningPage();
        }
        return Scaffold();
      },
    );
  }

  // Helper method for text theme coloring
  TextTheme _textTheme(Color color) => TextTheme(
    headline1: TextStyle(color: color),
    headline2: TextStyle(color: color),
    headline3: TextStyle(color: color, fontSize: 48.0),
    headline4: TextStyle(color: color),
    headline5: TextStyle(color: color),
    headline6: TextStyle(color: color, fontSize: 22.0),
    subtitle1: TextStyle(color: color, fontSize: 18.0),
    subtitle2: TextStyle(color: color),
    bodyText1: TextStyle(color: color),
    bodyText2: TextStyle(color: color, fontSize: 18.0),
    button: TextStyle(color: color, fontSize: 17.0),
    caption: TextStyle(color: color),
    overline: TextStyle(color: color),
  );
}
