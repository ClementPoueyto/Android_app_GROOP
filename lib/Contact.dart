import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DetailFriendPage.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomePage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ContactPage(title: 'Home Page'),
    );
  }
}

class ContactPage extends StatefulWidget {
  ContactPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  final db = Firestore.instance;

  Future<List<User>> _getUsers(String G) async {
    List<User> users = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int i = 0;
    if (prefs.getStringList(G) != [""]) {
      for (var u in prefs.getStringList(G)) {
        if (u.compareTo("") == 0) {
        } else {
          await db
              .collection('users')
              .document('$u')
              .get()
              .then((DocumentSnapshot ds) {
            User user = User(
                i,
                ds.data['pseudo'],
                ds.data['photo'],
                u,
                ds.data['friends'].cast<String>(),
                ds.data['events'].cast<String>(),
                ds.data['g1'].cast<String>(),
                ds.data['g2'].cast<String>(),
                ds.data['g3'].cast<String>());
            i++;
            users.add(user);
          });
        }
      }
      return users;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: (SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 6,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius:
                          BorderRadius.only(bottomLeft: Radius.circular(80))),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Mes Groops',
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
                SizedBox(height: 10),
                /////////////////////////////////////G1////////////////////////////////
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 20,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(80)),
                    child: Center(
                      child: Text(
                        "G1",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                FutureBuilder(
                  future: _getUsers('g1'),
                  initialData: null,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Container(
                        child: Center(
                          child: new CircularProgressIndicator(
                            value: null,
                            strokeWidth: 6.0,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_downward),
                                onPressed: () {
                                  upDowUser(
                                      'g1', 'g2', snapshot.data[index].id);
                                },
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(snapshot.data[index].photo),
                              ),
                              title: Text(
                                snapshot.data[index].pseudo,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => DetailFriend(
                                            snapshot.data[index])));
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),

                //////////////////////////G2////////////////////////////////
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 20,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(80)),
                    child: Center(
                      child: Text(
                        "G2",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                FutureBuilder(
                  future: _getUsers("g2"),
                  initialData: null,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Container(
                        child: Center(
                          child: new CircularProgressIndicator(
                            value: null,
                            strokeWidth: 6.0,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  children: <Widget>[
                                    IconButton(
                                      icon: Icon(Icons.arrow_upward),
                                      onPressed: () {
                                        upDowUser('g2', 'g1',
                                            snapshot.data[index].id);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.arrow_downward),
                                      onPressed: () {
                                        upDowUser('g2', 'g3',
                                            snapshot.data[index].id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(snapshot.data[index].photo),
                              ),
                              title: Text(
                                snapshot.data[index].pseudo,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Colors.black54,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => DetailFriend(
                                            snapshot.data[index])));
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                ///////////////////////////////////////////////////G3//////////////////////////////////
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 20,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(80)),
                    child: Center(
                      child: Text(
                        "G3",
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                FutureBuilder(
                  future: _getUsers("g3"),
                  initialData: null,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return Container(
                        child: Center(
                          child: new CircularProgressIndicator(
                            value: null,
                            strokeWidth: 6.0,
                          ),
                        ),
                      );
                    } else {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_upward),
                                onPressed: () {
                                  upDowUser(
                                      'g3', 'g2', snapshot.data[index].id);
                                },
                              ),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(snapshot.data[index].photo),
                              ),
                              title: Text(
                                snapshot.data[index].pseudo,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Colors.black26,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => DetailFriend(
                                            snapshot.data[index])));
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Future upDowUser(String from, String to, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(from);
    list.remove(id);
    List<String> list2 = prefs.getStringList(to);
    list2.add(id);
    prefs.setStringList(from, list);
    prefs.setStringList(to, list2);

    await Firestore.instance
        .collection('users')
        .document(prefs.getString("id"))
        .updateData({from: list, to: list2});
    setState(() {});
  }
}

class User {
  final int index;
  final String id;
  final String pseudo;
  final String photo;
  final List<String> events;
  final List<String> friends;
  final List<String> g1, g2, g3;

  User(this.index, this.pseudo, this.photo, this.id, this.friends, this.events,
      this.g1, this.g2, this.g3);
}

/*ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red,
                  ),
                  title: Text(snapshot.data[index].pseudo),
                  onTap: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) =>
                                DetailFriend(snapshot.data[index])));
                  },
                );*/
