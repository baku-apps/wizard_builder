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
                          HomePage(title: 'Wizard Builder Page')));
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

class HomePage extends StatelessWidget {
  const HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final navigatorKey1 = GlobalKey<NavigatorState>(debugLabel: 'NAV KEY 1111');
    final navigatorKey2 = GlobalKey<NavigatorState>(debugLabel: 'NAV KEY 2222');
    final navigatorKey3 = GlobalKey<NavigatorState>(debugLabel: 'NAV KEY 3333');

    return WizardBuilder(
      navigatorKey: navigatorKey1,
      pages: [
        PageOne(),
        WizardBuilder(
          navigatorKey: navigatorKey2,
          pages: [
            PageTwo(
              closeOnNavigate: true,
            ),
            WizardBuilder(
              navigatorKey: navigatorKey3,
              pages: [
                PageTwo(closeOnNavigate: true),
                PageThree(),
              ],
            ),
            PageThree(closeOnNavigate: true)
          ],
        ),
        PageOne(),
        PageFour(),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final navigatorKey1 = GlobalKey<NavigatorState>();
  final navigatorKey2 = GlobalKey<NavigatorState>();
  final navigatorKey3 = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WizardBuilder(
      navigatorKey: navigatorKey1,
      pages: [
        PageOne(),
        WizardBuilder(
          navigatorKey: navigatorKey2,
          pages: [
            PageTwo(),
            // WizardBuilder(
            //   navigatorKey: navigatorKey3,
            //   pages: [
            //     PageTwo(closeOnNavigate: true),
            //     PageThree(),
            //   ],
            // ),
            PageThree(closeOnNavigate: true)
          ],
        ),
        PageOne(),
        PageFour(),
      ],
    );
  }
}
