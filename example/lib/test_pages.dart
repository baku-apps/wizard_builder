import 'package:flutter/material.dart';
import 'package:wizard_builder/wizard_page.dart';

class PageOne extends WizardPage {
  const PageOne({Key key}) : super(key: key);

  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends WizardState<PageOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
            child: Column(
          children: <Widget>[
            FlatButton(
              child: Text('Go to Page Two'),
              onPressed: () {
                onPush();
              },
            ),
            Text('PageOne'),
          ],
        )),
      ),
    );
  }

  @override
  void onPush() {
    super.onPush();
  }
}

//-------------------------------------

class PageTwo extends WizardPage {
  const PageTwo({Key key}) : super(key: key);

  @override
  _PageTwoState createState() => _PageTwoState();
}

class _PageTwoState extends WizardState<PageTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Center(
          child: Text('PagTwo'),
        ),
      ),
    );
  }
}
