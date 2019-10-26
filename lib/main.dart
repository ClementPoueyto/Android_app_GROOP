import 'package:flutter/material.dart';
import 'Login.dart';
import 'Register.dart';
import 'package:flutter_groop/slide_from_right_page_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomePage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final db = Firestore.instance;
  String pseudo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2.5,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(80))),
                child: Center(
                  child: Text(
                    "Groop",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),
              Container(
                child: FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.black,
                  padding: EdgeInsets.all(10.0),
                  splashColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  onPressed: () {
                    isLogin();
                  },
                  child: Text(
                    "Se connecter",
                    style: TextStyle(fontSize: 25.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(10.0),
                splashColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                onPressed: () {
                  Navigator.push(
                      context, SlideFromRightPageRoute(widget: Register()));
                },
                child: Text(
                  "S'enregistrer",
                  style: TextStyle(
                    fontSize: 25.0,
                    decoration: TextDecoration.none,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  isLogin() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final isLogin = prefs.get('id');
        if (isLogin != null) {
          getSpUser();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Home(isLogin)));
        } else {
          Navigator.push(context, SlideFromRightPageRoute(widget: Login()));
        }
      }
    } on SocketException catch (_) {
      Toast.show("non connecté", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  getSpUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final id = prefs.get('id');
    await db.collection('users').document(id).get().then((DocumentSnapshot ds) {
      // use ds as a snapshot

      prefs.setString('pseudo', ds.data['pseudo']);
      prefs.setString('email', ds.data['email']);
      prefs.setString('photo', ds.data['photo']);

      prefs.setStringList('friends', ds.data['friends'].cast<String>());
      prefs.setStringList('events', ds.data['events'].cast<String>());
      prefs.setStringList('g1', ds.data['g1'].cast<String>());
      prefs.setStringList('g2', ds.data['g2'].cast<String>());
      prefs.setStringList('g3', ds.data['g3'].cast<String>());
      prefs.setStringList('myevent', ds.data['myevent'].cast<String>());
      Toast.show("Connecté en tant que " + ds.data['pseudo'], context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }
}
