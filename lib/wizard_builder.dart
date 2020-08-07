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
    @required this.pages,
  })  : controller = StreamController(),
        navigatorKey = GlobalKey<NavigatorState>(),
        assert(pages != null && pages.isNotEmpty),
        super(key: key);

  final GlobalKey<NavigatorState> navigatorKey;
  final List<WidgetBuilder> pages;
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

class WizardBuilderState<T extends StatefulWidget>
    extends State<WizardBuilder> {
  List<_WizardItem> _fullPageStack = List<_WizardItem>();

  _WizardItem get currentItem =>
      (widget.widgetPageStack.length > 0) ? widget.widgetPageStack.last : null;

  Widget get currentPage =>
      (currentItem != null) ? currentItem.widget(context) : null;

  @override
  void initState() {
    _fullPageStack = _WizardItem.flattenPages(widget.pages);

    widget.widgetPageStack.clear();
    widget.widgetPageStack.addLast(_fullPageStack[0]);

    super.initState();
  }

  WizardBuilderState currentWizardBuilder;

  //TODO: let child WizardBuilders be aware of their parents (have a property of their parents so we can quickly traverse back)
  NavigatorState _traverseCurrentContext(WizardBuilder widget) {
    var page = widget.widgetPageStack.last.widget(context);
    if (page is WizardBuilder) {
      if (page.widgetPageStack.length > 1) {
        return _traverseCurrentContext(page);
      } else {
        return widget.navigatorKey.currentState;
      }
    } else {
      return widget.navigatorKey.currentState;
    }
  }

  @override
  Widget build(BuildContext context) {
    currentWizardBuilder = this;
    _fullPageStack = _WizardItem.flattenPages(widget.pages);
    return WillPopScope(
      onWillPop: () {
        var currentNavigator = _traverseCurrentContext(widget);
        currentNavigator.pop();
        return Future.value(false);
      },
      child: Navigator(
        key: widget.navigatorKey,
        pages: List<Page>(),
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
    if (_isLastPage()) {
      closeWizard();
      return true;
    }

    var currentPageIndex =
        _fullPageStack.indexWhere((p) => p.index == currentItem?.index);

    currentPageIndex = currentPageIndex == -1 ? 0 : currentPageIndex;

    widget.widgetPageStack.addLast(_fullPageStack[currentPageIndex + 1]);

    _WizardItem nextPage = _fullPageStack[currentPageIndex + 1];

    await _pushItem(context, nextPage);

    widget.widgetPageStack.removeLast();

    var currentPage = widget.widgetPageStack.last.widget(context);
    if (currentPage is WizardBuilder) {
      var lastPage = currentPage.pages.last(context);
      if (lastPage is WizardPage) {
        if (lastPage.closeOnNavigate) {
          currentPage.navigatorKey.currentState.pop();
        }
      }
    }

    if (currentPage is WizardPage) {
      if (currentPage.closeOnNavigate) {
        _pop();
      }
    }

    return true;
  }

  void closePage() {
    _pop();
  }

  Future closeWizard() async {
    _fullPageStack = _WizardItem.flattenPages(widget.pages);
    var parentWizard = WizardBuilder.of(context, nullOk: true);
    if (parentWizard != null) {
      await parentWizard.nextPage();
      return;
    }

    var navigator = _traverseWizardBuilder(this, rootNavigator: true);
    navigator.pop();
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

  void _pop() async {
    var navigator = _traverseWizardBuilder(this);
    navigator.pop();
    return;
  }

  NavigatorState _traverseWizardBuilder(WizardBuilderState state,
      {bool rootNavigator = false}) {
    if (rootNavigator) {
      var parent = WizardBuilder.of(state.context, nullOk: true);
      if (parent != null) {
        return _traverseWizardBuilder(parent);
      } else {
        return Navigator.of(state.context);
      }
    }

    if (state.currentItem != null && !state.currentItem.isFirst) {
      return state.widget.navigatorKey.currentState;
    } else {
      var parent = WizardBuilder.of(state.context, nullOk: true);
      if (parent != null) {
        return _traverseWizardBuilder(parent);
      } else {
        return Navigator.of(state.context);
      }
    }
  }
}

class _WizardItem {
  final int index;
  final WidgetBuilder widget;
  final Widget page;
  final String route;
  final bool isFirst;

  static List<_WizardItem> pageStack = List<_WizardItem>();

  _WizardItem({
    this.index,
    this.widget,
    this.page,
    this.route,
    this.isFirst,
  });

  static List<_WizardItem> flattenPages(List<WidgetBuilder> pages) {
    pageStack.clear();

    for (var i = 0; i < pages.length; i++) {
      WidgetBuilder wizPage = pages[i];
      String route = (i == 0) ? '/' : '/${UniqueKey().toString()}';
      bool isFirst = i == 0;

      pageStack.add(
        _WizardItem(
          index: i,
          widget: (context) => wizPage(context),
          route: route,
          isFirst: isFirst,
        ),
      );
    }

    return pageStack;
  }

  @override
  String toString() {
    return '$index -> $route : ${widget.toString()}';
  }
}
