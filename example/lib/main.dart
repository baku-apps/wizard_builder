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
    return WizardBuilder(
      pages: [
        PageOne(),
        WizardBuilder(
          pages: [
            PageTwo(),
            WizardBuilder(
              pages: [
                PageThree(),
                PageFour(closeOnNavigate: true),
              ],
            ),
            PageTwo()
          ],
        ),
        PageOne(),
        PageFour(),
      ],
    );
  }
}
