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
  })  : controller = StreamController(),
        assert(navigatorKey != null),
        assert(pages != null && pages.isNotEmpty),
        super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;
  final List<Widget> pages;
  final ListQueue<_WizardItem> widgetPageStack = ListQueue();

  @override
  WizardBuilderState createState() => WizardBuilderState();

  static WizardBuilderState of(BuildContext context, {bool nullOk = false}) {
    final WizardBuilderState wizard =
        context.findAncestorStateOfType<WizardBuilderState>();
    assert(() {
      if (wizard == null && !nullOk) {
        throw FlutterError(
            'WizardBuilder operation requested with a context that does not include a WizardBuilder.\n'
            'The context used to push or pop routes from the WizardBuilder must be that of a '
            'widget that is a descendant of a WizardBuilder widget.');
      }
      return true;
    }());
    return wizard;
  }

  final StreamController controller;
}

class WizardBuilderState<T extends StatefulWidget> extends State<WizardBuilder>
    with RouteAware {
  List<_WizardItem> _fullPageStack = List<_WizardItem>();
  ListQueue<_WizardItem> _currentPageStack = ListQueue();

  _WizardItem get currentItem =>
      (widget.widgetPageStack.length > 0) ? widget.widgetPageStack.last : null;

  Widget get currentPage =>
      (currentItem != null) ? currentItem.widget(context) : null;

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    _fullPageStack = _WizardItem.flattenPages(widget.pages);

    widget.widgetPageStack.clear();
    widget.widgetPageStack.addLast(_fullPageStack[0]);
    _currentPageStack = widget.widgetPageStack;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _fullPageStack = _WizardItem.flattenPages(widget.pages);
    _currentPageStack = widget.widgetPageStack;
    return WillPopScope(
      onWillPop: () {
        var currentItem = _currentPageStack.last;
        var currentPage = currentItem.widget(context);
        if (currentPage is WizardBuilder) {
          if (currentPage.widgetPageStack.length > 1) {
            currentPage.navigatorKey.currentState.pop();
            return Future.value(false);
          }

          widget.navigatorKey.currentState.pop();
          return Future.value(false);
        }

        if (currentPage is WizardPage) {
          if (currentItem.isFirst) {
            return Future.value(true);
          }

          widget.navigatorKey.currentState.pop();
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: Navigator(
        key: widget.navigatorKey,
        observers: [routeObserver],
        initialRoute: _fullPageStack.first.route,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => _fullPageStack[0].widget(context),
            settings: RouteSettings(name: _fullPageStack[0].route),
          );
        },
      ),
    );
  }

  Future<bool> nextPage() async {
    _fullPageStack = _WizardItem.flattenPages(widget.pages);
    _currentPageStack = widget.widgetPageStack;
    if (_isLastPage()) {
      closeWizard();
      return true;
    }

    var currentPageIndex =
        _fullPageStack.indexWhere((p) => p.index == currentItem?.index);

    currentPageIndex = currentPageIndex == -1 ? 0 : currentPageIndex;

    widget.widgetPageStack.addLast(_fullPageStack[currentPageIndex + 1]);
    _currentPageStack = widget.widgetPageStack;

    _WizardItem nextPage = _fullPageStack[currentPageIndex + 1];

    await _pushItem(context, nextPage);

    widget.widgetPageStack.removeLast();
    _currentPageStack = widget.widgetPageStack;

    var currentPage = widget.widgetPageStack.last.widget(context);
    if (currentPage is WizardBuilder) {
      var lastPage = currentPage.pages.cast<WizardPage>().last;
      if (lastPage.closeOnNavigate) {
        currentPage.navigatorKey.currentState.pop();
      }
    }

    if (currentPage is WizardPage) {
      if (currentPage.closeOnNavigate) {
        closePage();
      }
    }

    return true;
  }

  void closePage() {
    _pop(context);
  }

  Future closeWizard() async {
    _fullPageStack = _WizardItem.flattenPages(widget.pages);
    _currentPageStack = widget.widgetPageStack;
    var parentWizard = WizardBuilder.of(context, nullOk: true);
    if (parentWizard != null) {
      await parentWizard.nextPage();
      return;
    }

    //reached the end of the wizard and close it all
    var rootNav = Navigator.of(context, rootNavigator: true);
    if (rootNav.canPop()) {
      rootNav.pop();
    } else {
      throw FlutterError(
          'The Wizard cannot be closed, because there is no root navigator. Please start the Wizard from a.\n'
          'root navigator.');
    }
  }

  bool _isLastPage() {
    return widget.widgetPageStack.length == _fullPageStack.length;
  }

  Future _pushItem(BuildContext context, _WizardItem item,
      {bool isModal = false}) {
    return widget.navigatorKey.currentState.push(
      MaterialPageRoute(
        builder: (context) => item.widget(context),
        settings: RouteSettings(name: item.route),
        fullscreenDialog: isModal,
      ),
    );
  }

  void _pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}

class _WizardItem {
  final int index;
  final WidgetBuilder widget;
  final Widget page;
  final String route;
  final bool isModal;
  final bool isFirst;

  static List<_WizardItem> pageStack = List<_WizardItem>();

  _WizardItem(
      {this.index,
      this.widget,
      this.page,
      this.route,
      this.isFirst,
      this.isModal = false});

  static List<_WizardItem> flattenPages(List<Widget> pages) {
    pageStack.clear();

    for (var i = 0; i < pages.length; i++) {
      Widget wizPage = pages[i];
      String route = (i == 0) ? '/' : '/${UniqueKey().toString()}';
      bool isFirst = i == 0;

      pageStack.add(
        _WizardItem(
            index: i,
            widget: (context) => wizPage,
            page: wizPage,
            route: route,
            isFirst: isFirst,
            isModal: (wizPage is WizardPage) ? wizPage.isModal : false),
      );
    }

    return pageStack;
  }

  @override
  String toString() {
    return '$index -> $route : ${page.toString()}';
  }
}
