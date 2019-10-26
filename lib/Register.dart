import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() => runApp(Register());

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RegisterPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyRegisterPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyRegisterPage extends StatefulWidget {
  MyRegisterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyRegisterPageState createState() => MyRegisterPageState();
}

class MyRegisterPageState extends State<MyRegisterPage> {
  String id;
  FirebaseUser user;
  final db = Firestore.instance;
  String idFcm;

  String _email, _password, _password2, _pseudo;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TextEditingController pwdController = new TextEditingController();

  final databaseReference =
      FirebaseDatabase.instance.reference().child("users");

  @override
  Widget build(BuildContext context) {
    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken().then((token) {
      idFcm = token;
    });
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(80))),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "S'enregistrer",
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
                      if (input.isEmpty) {
                        return 'Entrez un pseudo';
                      }
                      return null;
                    },
                    onSaved: (input) => _pseudo = input,
                    decoration: InputDecoration(labelText: "Pseudo"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (input) {
                      if (!input.contains('@')) {
                        return "Mauvais Email";
                      }
                      return null;
                    },
                    onSaved: (input) => _email = input,
                    decoration: InputDecoration(labelText: "Email"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (input) {
                      if (input.isNotEmpty) {
                        if (input.length < 6) {
                          return "Mot de passe contient moins de 6 caractères";
                        }
                        return null;
                      }
                      return "Mot de passe vide";
                    },
                    controller: pwdController,
                    obscureText: true,
                    onSaved: (input) => _password = input,
                    decoration: InputDecoration(labelText: "Mot de passe"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextFormField(
                    validator: (input) {
                      if (input.compareTo(pwdController.text) != 0) {
                        return "Mots de passe differents";
                      } else
                        return null;
                    },
                    obscureText: true,
                    onSaved: (input) => _password2 = input,
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
                    signUp();
                  },
                  child: Text(
                    "S'enregistrer",
                    style: TextStyle(fontSize: 25.0),
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
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: Text(
                    "Se connecter",
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
      ),
    );
  }

  Future<bool> doesNameAlreadyExist() async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('pseudo', isEqualTo: _pseudo)
        .limit(1)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;

    return documents.length == 1;
  }

  Future<void> signUp() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      if (await doesNameAlreadyExist() == true) {
        Toast.show("pseudo déjà existant", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        try {
          user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _email, password: _password))
              .user;
          user.sendEmailVerification();
          id = user.uid;
          createData();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Login()));
        } catch (e) {
          Toast.show(e.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          print(e.message);
        }
      }
    }
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
    // send key to your server to allow server to use
    // this token to send push notifications
  }

  void createData() async {
    print(id);

    await db.collection('users').document('$id').setData({
      'token': '$idFcm',
      'pseudo': '$_pseudo',
      'email': "$_email",
      'photo':
          'https://firebasestorage.googleapis.com/v0/b/groop-flutter.appspot.com/o/profile%2Ficone.jpg?alt=media&token=6121d6fc-e02e-4cb1-8607-46d2b843585c',
      'friends': [],
      'events': [],
      'g1': [],
      'g2': [],
      'g3': [],
      'myevent': [],
    });
  }
}
