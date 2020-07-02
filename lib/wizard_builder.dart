library wizard_builder;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wizard_builder/wizard_page.dart';

class WizardBuilder extends StatefulWidget {
  WizardBuilder({
    Key key,
    this.navigatorKey,
    this.pages,
  }) : super(key: key);

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

  @override
  void initState() {
    _fullPageStack = _WizardItem.flattenPages([widget.pages]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);

    return Navigator(
      key: widget.navigatorKey,
      initialRoute: routeBuilders.keys.first,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name](context),
        );
      },
    );
  }

  int get currentStep => _currentPageStack.last.step;

  _WizardItem get currentItem =>
      (_currentPageStack.length > 0) ? _currentPageStack.last : null;

  WizardPage get currentPage => (currentItem != null) ? currentItem.page : null;

  //List<WizardPage> get wizardSteps => wizardPagesList;
  Future<bool> nextPage() async {
    final routeBuilders = _routeBuilders(context);

    if (_isLastPage()) {
      _pop(context);
      return true;
    }

    var currentPageIndex = _fullPageStack.indexWhere(
        (p) => p.index == currentItem?.index && p.step == currentItem?.step);

    currentPageIndex = currentPageIndex == -1 ? 0 : currentPageIndex;

    if (currentPage != null && currentPage.closeOnNavigate) {
      //Todo: use removeBelowRoute to remove the page
      //https://api.flutter.dev/flutter/widgets/NavigatorState/removeRouteBelow.html
      closePage(); //close current first before adding new page to stack
    }

    _currentPageStack.addLast(_fullPageStack[currentPageIndex + 1]);

    await _push(
      context,
      routeBuilders.keys.toList()[currentPageIndex + 1],
      isModal: currentPage.isModal,
    );

    return true;
  }

  void closePage() {
    _pop(context);
    _currentPageStack.removeLast();
  }

  void closeWizard() {
    Navigator.of(context).pop();
  }

  bool _isLastPage() {
    return _currentPageStack.length == _fullPageStack.length;
  }

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    var routes = <String, WidgetBuilder>{};
    for (var i = 0; i < widget.pages.length; i++) {
      if (i == 0) {
        routes['/'] = (context) => widget.pages[i];
      } else {
        routes['/{i}'] = (context) => widget.pages[i];
      }
    }
    return routes;
  }

  Future _push(BuildContext context, String route, {bool isModal}) {
    final routeBuilders = _routeBuilders(context);

    return widget.navigatorKey.currentState.push(
      MaterialPageRoute(
        builder: (context) => routeBuilders[route](context),
        fullscreenDialog: isModal,
      ),
    );
  }

  void _pop(BuildContext context) {
    widget.navigatorKey.currentState.pop();
  }
}

class _WizardItem {
  int step;
  int index;
  Widget page;

  static List<_WizardItem> pageStack = List<_WizardItem>();

  _WizardItem(int step, int index, Widget page) {
    this.step = step;
    this.index = index;
    this.page = page;
  }

  static List<_WizardItem> flattenPages(List<List<Widget>> pages) {
    pageStack.clear();

    for (var i = 0; i < pages.length; i++) {
      for (var y = 0; y < pages[i].length; y++) {
        pageStack.add(_WizardItem(i, y, pages[i][y]));
      }
    }

    return pageStack;
  }
}
