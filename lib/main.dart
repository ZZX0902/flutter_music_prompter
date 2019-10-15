import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'temporaryData.dart';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer _timer;
  int _currentIndex = 20;
  List<int> randomIndexList = List();

  double oneUnit = MediaQueryData.fromWindow(window).size.width / 375;
  PageController _pagecontroller =
  PageController(initialPage: 20, viewportFraction: 0.11);
  List<String> questionPrompt = List();



  void initState(){
    super.initState();
    int min = 0;
    int max = rollingHintTemporaryData.length - 1;
    for (int i = 0; i < 150; i++) {
      int randomNum = (min + (Random().nextInt(max - min)));
      randomIndexList.add(randomNum);
    }

    for (int i = 0; i < randomIndexList.length; i++) {
      questionPrompt.add(rollingHintTemporaryData[randomIndexList[i]]);

    }
    _setTimer();
  }
  _setTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (_) {
      _pagecontroller.animateToPage(_currentIndex + 1,
          duration: Duration(milliseconds: 800), curve: Curves.ease);
    });
  }
  Widget myPageView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.depth == 0 &&
            notification is ScrollStartNotification) {
          if (notification.dragDetails != null) {
            _timer?.cancel();
          }
        } else if (notification is ScrollEndNotification) {
          _timer?.cancel();
          _setTimer();
        }
        return true;
      },
      child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Color.fromARGB(0, 161, 161, 161),
                Color.fromARGB(255, 161, 161, 161),
                Color.fromARGB(0, 161, 161, 161),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ).createShader(Offset.zero & bounds.size);
          },
          blendMode: BlendMode.dstIn,
          child: PageView.builder(
            itemBuilder: ((context, index) {
              return Container(
                width: oneUnit * 375,
                height: oneUnit * 35,
                alignment: Alignment.center,
                child: Text(
                  questionPrompt[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: index == _currentIndex
                          ? Color.fromARGB(255, 255, 255, 255)
                          : Color.fromARGB(255, 161, 161, 161),
                      fontSize:
                      index == _currentIndex ? 19 : 18),
                ),
              );
            }),
            onPageChanged: (curreyIndex) {
              int newIndex;

              if (curreyIndex == questionPrompt.length - 1) {
                newIndex = -1;
                _currentIndex = questionPrompt.length - 1;
                Future.delayed(Duration(seconds: 1), () {
                  _currentIndex = newIndex;
                });
              } else {
                newIndex = curreyIndex;
                _currentIndex = newIndex;
              }
              setState(() {});
            },
            controller: _pagecontroller,
            itemCount: questionPrompt.length,
            scrollDirection: Axis.vertical,
          )),
    );
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
       child: Container(
           margin: EdgeInsets.only(
               top: oneUnit * 25, bottom: oneUnit * 133),
           width: oneUnit * 375,
           height: oneUnit * 250,
           alignment: Alignment.topCenter,
           child: myPageView()) ,
      )
    );
  }
}

