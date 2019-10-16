# holy_sheet

A Flutter sheet & panel widget that's good as hell.

Use it to build something like:

- Spotify's currently playing sheet
- Material Bottom Sheet, but from the top of the screen
- Apple's NFC / Apple Pay modals
- Google Maps' scrollable detail views

HolySheet respects the following conventions:

1. The sheet is always modal.
2. The sheet is always draggable.
3. The sheet passes its constraints to its child, which it then (by default) translates with a custom layout.
4. The sheet expects that all scrollable areas within itself respect the gesture arena and declare defeat when reasonable.

## TODO

- simple methods for controlling the sheet using a non-sibling gesture recognizer
  - i.e., making the background of the modal draggable
- make sure it handles google maps-style cascading

## Install

```yml
dependencies:
  holy_sheet: ^0.0.1
```

## Usage

```dart
import 'package:holy_sheet/holy_sheet.dart';

// see exampe/lib/main.dart for details

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = Harusaki.controller(
      Harusaki.normal,
      value: 1.0,
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding.top;
    final headerHeight = padding + kToolbarHeight;
    final contentHeight = MediaQuery.of(context).size.height - kToolbarHeight - headerHeight;
    final _height = Tween<double>(
      begin: headerHeight,
      end: headerHeight + contentHeight,
    );


    return Stack(
      children: <Widget>[
        // the background
        Container(
          color: Colors.yellow,
        ),
        // the darkening background
        FadeTransition(
          opacity: _opacity,
          child: Container(
            color: Colors.black45,
          ),
        ),
        // the sheet layer
        HolySheet(
          // use the `.normal` SpringDescription
          description: Harusaki.normal,
          // descend from the top
          riseFrom: RiseFrom.Heaven,
          animationController: _controller,
          // a custom animation for entrance/exit
          animationBuilder: (context, child) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: _height.transform(_controller.value).clamp(0.0, double.infinity),
                child: child,
              ),
            );
          },
          // the contents of the sheet
          builder: (context) {
            // a simple layout for showing the different layers
            // it uses a Material as the primary background
            return Material(
              elevation: 1,
              color: Theme.of(context).bottomSheetTheme.backgroundColor,
              // then clips the content within an overflow box
              child: ClipRect(
                child: OverflowBox(
                  minHeight: headerHeight,
                  maxHeight: headerHeight + contentHeight,
                  alignment: Alignment.topCenter,
                  // which is a purple back layer
                  child: Container(
                    color: Colors.purple,
                    child: Column(
                      // and some simple containers that illustrate the dimensions of the device
                      children: <Widget>[
                        Container(color: Colors.red, height: padding),
                        Container(color: Colors.blue, height: kToolbarHeight),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}



```
