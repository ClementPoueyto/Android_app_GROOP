import 'package:flutter/material.dart';
import 'Contact.dart';
import 'MyEvent.dart';
import 'Events.dart';
import 'Profil.dart';

class Home extends StatelessWidget {
  Home(this.myId);
  final String myId;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomePage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Home Page',
        myId: myId,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.myId}) : super(key: key);
  final String myId;
  final String title;

  @override
  MyHomePageState createState() => MyHomePageState(myId);
}

class MyHomePageState extends State<MyHomePage> {
  final String myId;
  MyHomePageState(this.myId);
  final PageController ctrl = PageController(
    initialPage: 2,
    viewportFraction: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(color: Colors.blue),
        child: PageView(
          scrollDirection: Axis.horizontal,
          controller: ctrl,
          children: <Widget>[
            Contact(),
            Profil(),
            Events(),
            MyEvent(myId),
          ],
        ),
      ),
    );
  }
}
