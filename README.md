# Wizard Builder Widget

A Flutter widget for building a wizards UI.

## Usage

- Create a wizard page by extending a widget from a WizardPage and WizardState. These exposes a onPush(), onPop() and onCloseWizard() method, which can be used in the wizard page.
- Next create a WizardBuilder
- Inject a navigation key
- Inject the list of wizard pages
- The WizardBuilder wil navigate to the firt wizard page in the list.
- When calling onPush() on the last wizard page the WizardBuilder wil close.

```dart
WizardBuilder(
  pages: [
    PageOne(),
    WizardBuilder(
      pages: [
        PageTwo(),
        WizardBuilder(
          pages: [
            PageTwo(closeOnNavigate: true),
            PageThree(),
          ],
        ),
        PageThree(closeOnNavigate: true)
      ],
    ),
    PageFour(),
  ],
);
```

## TODO

- [ ] option for showing back/close button on first page
- [x] correct android onbackpress button behavior
- [x] nested pages (or by [][] or by adding another Widgetbuilder)
- [ ] exposing page transistions
- [ ] ability to pass arguments/parameters to a page from the nextPage()
- [ ] create unit tests

## Issues

Please file any issues, bugs or feature requests as an issue on our [GitHub](https://github.com/baku-apps/wizard_builder/issues) page. Commercial support is available, you can contact us at <bart.kuipers@baku-apps.com>.

## Author

This WizardBuilder widget for Flutter is developed by [BaKu-apps](https://baku-apps.com).
