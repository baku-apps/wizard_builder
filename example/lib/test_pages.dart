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
      appBar: AppBar(
        leading: CloseButton(onPressed: () => onPopWizard()),
        title: Text('Page ONE'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text('Go to next page'),
                onPressed: () {
                  onPush();
                },
              ),
              Text('Page One'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onPush() {
    //do something here before navigating
    super.onPush();
  }
}

//-------------------------------------

class PageTwo extends WizardPage {
  const PageTwo({Key key, this.closeOnNavigate = false})
      : super(key: key, closeOnNavigate: closeOnNavigate);

  final bool closeOnNavigate;

  @override
  _PageTwoState createState() => _PageTwoState();
}

class _PageTwoState extends WizardState<PageTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page TWO'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text('Go to next page'),
                onPressed: () {
                  onPush();
                },
              ),
              Text('Page two'),
            ],
          ),
        ),
      ),
    );
  }
}

class PageThree extends WizardPage {
  const PageThree({Key key, this.closeOnNavigate = false})
      : super(key: key, closeOnNavigate: closeOnNavigate);

  final bool closeOnNavigate;

  @override
  _PageThreeState createState() => _PageThreeState();
}

class _PageThreeState extends WizardState<PageThree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page TWO'),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              FlatButton(
                child: Text('Go to next page'),
                onPressed: () {
                  onPush();
                },
              ),
              Text('Page two'),
            ],
          ),
        ),
      ),
    );
  }
}
