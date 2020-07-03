library wizard_builder;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wizard_builder/wizard_page.dart';

typedef WizardPageBuilder = WizardPage Function(BuildContext context);

class WizardBuilder extends StatefulWidget {
  WizardBuilder({
    Key key,
    @required this.navigatorKey,
    @required this.pages,
  })  : assert(navigatorKey != null),
        assert(pages != null && pages.isNotEmpty),
        super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;
  final List<WizardPage> pages;

  @override
  WizardBuilderState createState() => WizardBuilderState();

  static WizardBuilderState of(BuildContext context) {
    final WizardBuilderState wizard =
        context.findAncestorStateOfType<WizardBuilderState>();
    assert(() {
      if (wizard == null) {
        throw FlutterError(
            'WizardBuilder operation requested with a context that does not include a WizardBuilder.\n'
            'The context used to push or pop routes from the WizardBuilder must be that of a '
            'widget that is a descendant of a WizardBuilder widget.');
      }
      return true;
    }());
    return wizard;
  }
}

class WizardBuilderState extends State<WizardBuilder> {
  List<_WizardItem> _fullPageStack = List<_WizardItem>();
  ListQueue<_WizardItem> _currentPageStack = ListQueue();

  int get currentStep => _currentPageStack.last.step;

  _WizardItem get currentItem =>
      (_currentPageStack.length > 0) ? _currentPageStack.last : null;

  WizardPage get currentPage =>
      (currentItem != null) ? currentItem.widget(context) : null;

  @override
  void initState() {
    _fullPageStack = _WizardItem.flattenPages([widget.pages]);
    _currentPageStack.addLast(_fullPageStack[0]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      initialRoute: _fullPageStack.first.route,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => _fullPageStack[0].widget(context),
        );
      },
    );
  }

  Future<bool> nextPage() async {
    if (_isLastPage()) {
      closeWizard();
      return true;
    }

    var currentPageIndex = _fullPageStack.indexWhere(
        (p) => p.index == currentItem?.index && p.step == currentItem?.step);

    currentPageIndex = currentPageIndex == -1 ? 0 : currentPageIndex;

    _currentPageStack.addLast(_fullPageStack[currentPageIndex + 1]);

    await _pushItem(
      context,
      _fullPageStack[currentPageIndex + 1],
      isModal: currentPage.isModal,
    );

    _currentPageStack.removeLast();
    if (_currentPageStack.last.widget(context).closeOnNavigate) {
      closePage();
    }

    return true;
  }

  void closePage() {
    _pop(context);
  }

  void closeWizard() {
    //TODO: give option to define continuing route...
    Navigator.of(context).maybePop().then((canPop) {
      if (!canPop) {
        throw FlutterError(
            'The Wizard cannot be closed, because there is no root navigator. Please start the Wizard from a.\n'
            'root navigator.');
      }
    });
  }

  bool _isLastPage() {
    return _currentPageStack.length == _fullPageStack.length;
  }

  Future _pushItem(BuildContext context, _WizardItem item, {bool isModal}) {
    return widget.navigatorKey.currentState.push(
      MaterialPageRoute(
        builder: (context) => item.widget(context),
        fullscreenDialog: isModal,
      ),
    );
  }

  void _pop(BuildContext context) {
    widget.navigatorKey.currentState.pop();
  }
}

class _WizardItem {
  final int step;
  final int index;
  final WizardPageBuilder widget;
  final String route;

  static List<_WizardItem> pageStack = List<_WizardItem>();

  _WizardItem({this.step, this.index, this.widget, this.route});

  static List<_WizardItem> flattenPages(List<List<Widget>> pages) {
    pageStack.clear();

    for (var i = 0; i < pages.length; i++) {
      for (var y = 0; y < pages[i].length; y++) {
        //add first route
        if (i == 0 && y == 0) {
          pageStack.add(
            _WizardItem(
              step: i,
              index: y,
              widget: (context) => pages[i][y],
              route: '/',
            ),
          );
        } else {
          var uuid = UniqueKey().toString();
          pageStack.add(
            _WizardItem(
              step: i,
              index: y,
              widget: (context) => pages[i][y],
              route: '/$uuid',
            ),
          );
        }
      }
    }

    return pageStack;
  }
}
