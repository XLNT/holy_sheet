import 'package:flutter/material.dart';
import 'package:harusaki/harusaki.dart';
import 'package:holy_sheet/holy_sheet.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = Harusaki.controller(
      Harusaki.normal,
      value: 1.0,
      suggestedLowerBound: 0.0,
      suggestedUpperBound: 1.0,
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding.top;
    final _height = Tween<double>(
      begin: padding + kToolbarHeight,
      end: MediaQuery.of(context).size.height,
    );
    final contentHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.yellow,
        ),
        FadeTransition(
          opacity: _opacity,
          child: Container(
            color: Colors.black45,
          ),
        ),
        HolySheet(
          riseFrom: RiseFrom.Heaven,
          animationController: _controller,
          animationBuilder: (context, child) {
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: _height.transform(_controller.value).clamp(0.0, double.infinity),
                child: child,
              ),
            );
          },
          builder: (context) {
            final child = Container(
              color: Colors.purple,
              child: Column(
                children: <Widget>[
                  Container(color: Colors.red, height: 50),
                  Container(color: Colors.blue, height: 50),
                  Container(color: Colors.green, height: 50),
                ],
              ),
            );

            return ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: contentHeight,
                maxHeight: contentHeight,
                child: child,
              ),
            );
          },
        ),
      ],
    );
  }
}
