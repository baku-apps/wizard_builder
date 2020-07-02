import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wizard_builder/wizard_builder.dart';

abstract class WizardPage extends StatefulWidget {
  const WizardPage({
    Key key,
    this.isModal = false,
    this.closeOnNavigate = false,
  }) : super(key: key);

  final bool isModal;
  final bool closeOnNavigate;
}

abstract class WizardState<Page extends WizardPage> extends State<WizardPage> {
  void onPush() {
    WizardBuilder.of(context).nextPage();
  }

  void onPop() {
    WizardBuilder.of(context).closePage();
  }

  void closeWizard() {
    WizardBuilder.of(context).closeWizard();
  }
}
