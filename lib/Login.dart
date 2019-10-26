import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'Register.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(Login());

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoginPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyLoginPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyLoginPageState createState() => MyLoginPageState();
}

class MyLoginPageState extends State<MyLoginPage> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  String idFcm;
  final db = Firestore.instance;
  List<String> _eventsL, _friendsL, _g1, _g2, _g3, _myevent;
  String _emailL, _passwordL, _photoL, _pseudoL, _idL;
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken().then((token) {
      print(token);
      idFcm = token;
    });
    return Scaffold(
      body: Form(
        key: _formKey2,
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(80))),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Se connecter',
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: TextFormField(
                      validator: (input) {
                        if (input.isNotEmpty) {
                          if (!input.contains('@')) {
                            return "Mauvais Email";
                          }
                          return null;
                        }
                        return "Email vide";
                      },
                      onSaved: (input) => _emailL = input,
                      decoration: InputDecoration(labelText: "Email"),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    child: TextFormField(
                      validator: (input) {
                        if (input.isNotEmpty) {
                          return null;
                        }
                        return "Mot de passe vide";
                      },
                      obscureText: true,
                      onSaved: (input) => _passwordL = input,
                      decoration: InputDecoration(labelText: "Mot de passe"),
                    ),
                  ),
                  SizedBox(height: 30),
                  RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(10.0),
                    splashColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    onPressed: () {
                      signIn();
                    },
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                          fontSize: 25.0,
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Calibre-Semibold"),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(10.0),
                    splashColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: Text(
                      "S'enregistrer",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  addStringToSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pseudo', _pseudoL);
    prefs.setString('email', _emailL);
    prefs.setString('photo', _photoL);
    prefs.setStringList('friends', _friendsL);
    prefs.setStringList('events', _eventsL);
    prefs.setStringList('g1', _g1);
    prefs.setStringList('g2', _g2);
    prefs.setStringList('g3', _g3);
    prefs.setString('id', _idL);
    prefs.setStringList('myevent', _myevent);
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
    // send key to your server to allow server to use
    // this token to send push notifications
  }

  Future getData() async {
    await db.collection('users').document('$_idL').updateData({"token": idFcm});
    await db
        .collection('users')
        .document('$_idL')
        .get()
        .then((DocumentSnapshot ds) {
      // use ds as a snapshot

      _emailL = ds.data['email'];
      _pseudoL = ds.data['pseudo'];
      _photoL = ds.data['photo'];

      _g1 = ds.data['g1'].cast<String>();
      _g2 = ds.data['g2'].cast<String>();
      _g3 = ds.data['g3'].cast<String>();
      _myevent = ds.data['myevent'].cast<String>();

      _friendsL = ds.data['friends'].cast<String>();
      _eventsL = ds.data['events'].cast<String>();
    });
    await addStringToSP();
    Toast.show("connecté en tant que " + _pseudoL, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  Future<void> signIn() async {
    if (_formKey2.currentState.validate()) {
      _formKey2.currentState.save();

      try {
        FirebaseUser user = (await FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: _emailL, password: _passwordL))
            .user;
        if (user.isEmailVerified) {
          _idL = user.uid;
          print(_idL);
          await getData();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Home(_idL)));
        } else {
          Toast.show("Email non verifié, vérifiez les spams", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      } catch (e) {
        Toast.show("erreur", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }
  }
}
