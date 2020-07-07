import 'package:example/test_pages.dart';
import 'package:flutter/material.dart';
import 'package:wizard_builder/wizard_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  RootPage({Key key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Root Page'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text('Go to wizard builder page'),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          MyHomePage(title: 'Wizard Builder Page')));
                },
              ),
              Text('This is the ROOT page'),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final navigatorKey1 = GlobalKey<NavigatorState>(debugLabel: 'NAV LEVEL-1');
final navigatorKey2 = GlobalKey<NavigatorState>(debugLabel: 'NAV LEVEL-2');
final navigatorKey3 = GlobalKey<NavigatorState>(debugLabel: 'NAV LEVEL-3');

final one = GlobalKey<WizardBuilderState>(debugLabel: 'WIZ LEVEL-1');
final two = GlobalKey<WizardBuilderState>(debugLabel: 'WIZ LEVEL-2');
final three = GlobalKey<WizardBuilderState>(debugLabel: 'WIZ LEVEL-3');

Widget buildWizardBuilder() {
  return WizardBuilder(
    key: one,
    navigatorKey: navigatorKey1,
    pages: [
      PageOne(),
      WizardBuilder(
        key: two,
        navigatorKey: navigatorKey2,
        pages: [
          PageTwo(
            debugLabel: 'PAGE 1',
          ),
          PageThree(
            debugLabel: 'PAGE 1',
            closeOnNavigate: true,
          )
        ],
      ),
      PageFour(),
      WizardBuilder(
        key: three,
        navigatorKey: navigatorKey3,
        pages: [
          PageTwo(
            closeOnNavigate: true,
            debugLabel: 'PAGE 2',
          ),
          PageThree(
            debugLabel: 'PAGE 2',
          )
        ],
      ),
    ],
  );
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return buildWizardBuilder();
  }
}
