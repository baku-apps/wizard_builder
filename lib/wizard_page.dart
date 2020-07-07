import 'package:flutter/widgets.dart';
import 'package:wizard_builder/wizard_builder.dart';

abstract class WizardPage extends StatefulWidget {
  const WizardPage({
    Key key,
    this.isModal = false,
    this.closeOnNavigate = false,
  }) : super(key: key);

  /// Opens de wizard page in fullscreen mode (default = false)
  final bool isModal;

  /// When true this page will close when the page above in the stack is closed.
  final bool closeOnNavigate;
}

abstract class WizardState<Page extends WizardPage> extends State<WizardPage> {
  /// Push the next page on the wizard page stack
  /// If this is the last page the wizard is closed
  void onPush() {
    //WizardBuilder.of(context).pushController.sink.add(null);
    //TODO: add optional parameters to nextPage() to override the isModal or closeOnNavigation properties.
    //This to give more flexibility on navigation behavior.
    WizardBuilder.of(context).nextPage();
  }

  /// Pop the current page of the wizard page stack
  /// If this is the last page the wizard is closed
  void onPop() {
    WizardBuilder.of(context).closePage();
  }

  /// Closes the wizard and navigates back to the previous navigation stack
  void onPopWizard() {
    WizardBuilder.of(context).closeWizard();
  }
}
