import 'package:flutter/material.dart';
import 'Contact.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_groop/Home.dart';

class DetailFriend extends StatelessWidget {
  final User user;
  DetailFriend(this.user);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomePage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DetailFriendPage(
        title: 'Flutter Demo Home Page',
        user: this.user,
      ),
    );
  }
}

class DetailFriendPage extends StatefulWidget {
  DetailFriendPage({Key key, this.title, this.user}) : super(key: key);
  final User user;
  final String title;

  @override
  DetailFriendPageState createState() => DetailFriendPageState(user);
}

class DetailFriendPageState extends State<DetailFriendPage> {
  final User user;
  File _image;

  DetailFriendPageState(this.user);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          child: Icon(Icons.close),
          onPressed: () {
            goHome();
          },
        ),
        resizeToAvoidBottomPadding: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 6,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Text(
                      user.pseudo,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.blue,
                    child: ClipOval(
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: (_image != null)
                            ? Image.file(
                                _image,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                user.photo,
                                fit: BoxFit.cover,
                                width: 180,
                                height: 180,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  child: FutureBuilder(
                    future: isFriendWith(),
                    initialData: null,
                    builder: (BuildContext context, AsyncSnapshot<bool> res) {
                      if (res.data == true) {
                        return RaisedButton(
                          color: Colors.red,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          splashColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          onPressed: () {
                            removeFriend();
                          },
                          child: Text(
                            "Supprimer",
                            style: TextStyle(fontSize: 25.0),
                          ),
                        );
                      } else {
                        return RaisedButton(
                          color: Colors.green,
                          textColor: Colors.white,
                          padding: EdgeInsets.all(10.0),
                          splashColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          onPressed: () {
                            addFriend();
                          },
                          child: Text(
                            "Ajouter",
                            style: TextStyle(fontSize: 25.0),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<String> getPhoto() async {
    String chemin = user.photo;
    print(chemin);

    return chemin;
  }

  Future<bool> isFriendWith() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> friends = prefs.getStringList('friends');

    for (String u in friends) {
      if (u.compareTo(user.id) == 0) {
        return Future.value(true);
      }
    }
    return Future.value(false);
  }

  Future goHome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => Home(id)),
    );
  }

  Future addFriend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('friends');
    List<String> listg3 = prefs.getStringList('g3');

    list.add(user.id);
    listg3.add(user.id);
    prefs.setStringList('friends', list);
    prefs.setStringList('g3', listg3);

    await Firestore.instance
        .collection('users')
        .document(prefs.getString("id"))
        .updateData({'friends': list, 'g3': listg3});
    setState(() {});
  }

  Future removeFriend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('friends');
    List<String> listg3 = prefs.getStringList('g3');
    List<String> listg2 = prefs.getStringList('g2');
    List<String> listg1 = prefs.getStringList('g1');

    list.remove(user.id);
    listg3.remove(user.id);
    listg2.remove(user.id);
    listg1.remove(user.id);

    prefs.setStringList('friends', list);
    prefs.setStringList('g3', listg3);
    prefs.setStringList('g2', listg2);
    prefs.setStringList('g1', listg1);
    await Firestore.instance
        .collection('users')
        .document(prefs.getString("id"))
        .updateData(
            {'friends': list, 'g3': listg3, 'g2': listg2, 'g1': listg1});
    setState(() {});
  }
}
