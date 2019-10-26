import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_groop/Events.dart';
import 'package:flutter_groop/Contact.dart';
import 'package:flutter_groop/DetailFriendPage.dart';

class TheEvent extends StatelessWidget {
  final String idEvent;
  final int index;
  TheEvent(this.idEvent, this.index);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TheEventPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TheEventPage(
        title: 'TheEventPage',
        idEvent: idEvent,
        index: index,
      ),
    );
  }
}

class TheEventPage extends StatefulWidget {
  TheEventPage({Key key, this.title, this.idEvent, this.index})
      : super(key: key);
  final String title;
  final String idEvent;
  final int index;

  @override
  TheEventPageState createState() => TheEventPageState(idEvent, index);
}

class TheEventPageState extends State<TheEventPage> {
  final idEvent;
  final index;
  TheEventPageState(this.idEvent, this.index);
  final db = Firestore.instance;
  String groop = "";
  List<String> invites, missing, present;
  Future<String> res;
  String here = "";
  String nothere = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.close),
        onPressed: () {
          Navigator.push(
              context, new MaterialPageRoute(builder: (context) => Events()));
        },
      ),
      resizeToAvoidBottomPadding: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: FutureBuilder(
              future: TheEventDetails(),
              initialData: null,
              builder: (BuildContext context, AsyncSnapshot event) {
                if (event.data == null) {
                  return Container(
                    child: Center(
                      child: new CircularProgressIndicator(
                        value: null,
                        strokeWidth: 6.0,
                      ),
                    ),
                  );
                } else {
                  return Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: MediaQuery.of(context).size.height / 6,
                        decoration: BoxDecoration(color: Colors.blue),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              event.data.title,
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
                      (event.data.photo != null)
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              // Box decoration takes a gradient
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image:
                                              NetworkImage(event.data.photo)),
                                    ),
                                  ),
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height / 3,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        gradient: LinearGradient(
                                            begin: FractionalOffset.topCenter,
                                            end: FractionalOffset.bottomCenter,
                                            colors: [
                                              Colors.white.withOpacity(0.0),
                                              Colors.white.withOpacity(0.5),
                                              Colors.white.withOpacity(1.0),
                                            ],
                                            stops: [
                                              0.0,
                                              0.7,
                                              1.0
                                            ])),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 12,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(80)),
                          child: Center(
                            child: Text(
                              (event.data.time.compareTo("") == 0)
                                  ? event.data.date
                                  : event.data.date + " à " + event.data.time,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor * 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 12,
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(80)),
                          child: Center(
                            child: Text(
                              event.data.place,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).textScaleFactor * 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(80)),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Center(
                              child: Text(
                                event.data.description,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).textScaleFactor *
                                          20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder<String>(
                          future: isHere(),
                          initialData: "",
                          builder: (BuildContext context,
                              AsyncSnapshot<String> event) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: IconButton(
                                    icon: (event.data.compareTo("yes") == 0)
                                        ? Icon(Icons.check_circle)
                                        : Icon(Icons.check_circle_outline),
                                    iconSize: (event.data.compareTo("yes") == 0)
                                        ? 35
                                        : 30,
                                    color: Colors.green,
                                    disabledColor: Colors.grey,
                                    padding: EdgeInsets.all(10.0),
                                    splashColor: Colors.blueAccent,
                                    onPressed:
                                        (event.data.compareTo("yes") == 0)
                                            ? () {}
                                            : () {
                                                answerYes();
                                                setState(() {});
                                              },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: IconButton(
                                    icon: (event.data.compareTo("no") == 0)
                                        ? Icon(Icons.remove_circle)
                                        : Icon(Icons.remove_circle_outline),
                                    iconSize: (event.data.compareTo("no") == 0)
                                        ? 35
                                        : 30,
                                    color: Colors.red,
                                    disabledColor: Colors.grey,
                                    padding: EdgeInsets.all(10.0),
                                    splashColor: Colors.blueAccent,
                                    onPressed: (event.data.compareTo("no") == 0)
                                        ? () {}
                                        : () {
                                            answerNo();
                                            setState(() {});
                                          },
                                  ),
                                ),
                              ],
                            );
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Center(
                                  child: FutureBuilder(
                                      future: getUsers("present"),
                                      initialData: null,
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.data == null) {
                                          return Container(
                                            child: Center(
                                              child:
                                                  new CircularProgressIndicator(
                                                value: null,
                                                strokeWidth: 6.0,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Card(
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                            .data[index].photo),
                                                  ),
                                                  title: Text(
                                                    snapshot.data[index].pseudo,
                                                    style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: Colors.black54,
                                                      fontSize: MediaQuery.of(
                                                                  context)
                                                              .textScaleFactor *
                                                          10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                DetailFriend(
                                                                    snapshot.data[
                                                                        index])));
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Center(
                                  child: FutureBuilder(
                                      future: getUsers("missing"),
                                      initialData: null,
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.data == null) {
                                          return Container(
                                            child: Center(
                                              child:
                                                  new CircularProgressIndicator(
                                                value: null,
                                                strokeWidth: 6.0,
                                              ),
                                            ),
                                          );
                                        } else {
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Card(
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(snapshot
                                                            .data[index].photo),
                                                  ),
                                                  title: Text(
                                                    snapshot.data[index].pseudo,
                                                    style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: Colors.black54,
                                                      fontSize: MediaQuery.of(
                                                                  context)
                                                              .textScaleFactor *
                                                          10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                DetailFriend(
                                                                    snapshot.data[
                                                                        index])));
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      }),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<List<User>> getUsers(String val) async {
    List<User> users = [];
    List<String> present;
    await db
        .collection('events')
        .document(idEvent)
        .get()
        .then((DocumentSnapshot ds) {
      present = ds.data[val].cast<String>();
    });
    int i = 0;
    if (present != [""]) {
      for (var u in present) {
        if (u.compareTo("") == 0) {
        } else {
          await db
              .collection('users')
              .document(u)
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

  Future<String> isHere() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String val = prefs.getString('id');
    await db
        .collection('events')
        .document(idEvent)
        .get()
        .then((DocumentSnapshot ds) {
      present = ds.data['present'].cast<String>();
      missing = ds.data['missing'].cast<String>();
    });
    for (var u in present) {
      if (u.compareTo(val) == 0) {
        return "yes";
      }
    }
    for (var u in missing) {
      if (u.compareTo(val) == 0) {
        return "no";
      }
    }
    return "";
  }

  Future<void> answerYes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id');
    List<String> no;
    List<String> no2 = [];
    List<String> yes;
    List<String> yes2 = [];
    await db
        .collection('events')
        .document(idEvent)
        .get()
        .then((DocumentSnapshot ds) {
      no = ds.data['missing'].cast<String>();
      yes = ds.data['present'].cast<String>();
    });
    for (var i in no) {
      if (i.compareTo(id) != 0) {
        no2.add(i);
      }
    }
    for (var i in yes) {
      yes2.add(i);
    }
    yes2.add(id);
    await db.collection('events').document(idEvent).updateData({
      'present': yes2,
      'missing': no2,
    });
  }

  Future<void> answerNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = await prefs.getString('id');
    List<String> no;
    List<String> no2 = [];
    List<String> yes;
    List<String> yes2 = [];
    await db
        .collection('events')
        .document(idEvent)
        .get()
        .then((DocumentSnapshot ds) {
      no = ds.data['missing'].cast<String>();
      yes = ds.data['present'].cast<String>();
    });
    for (var i in no) {
      no2.add(i);
    }
    no2.add(id);
    for (var i in yes) {
      if (i.compareTo(id) != 0) {
        yes2.add(i);
      }
    }
    await db.collection('events').document(idEvent).updateData({
      'present': yes2,
      'missing': no2,
    });
  }

  Future<Event> TheEventDetails() async {
    Event event;
    await db
        .collection('events')
        .document(idEvent)
        .get()
        .then((DocumentSnapshot ds) {
      event = Event(
        index,
        idEvent,
        ds.data['pseudo'],
        ds.data['title'],
        ds.data['date'],
        ds.data['time'],
        ds.data['place'],
        ds.data['description'],
        ds.data['groop'],
        ds.data['photo'],
        ds.data['invites'].cast<String>(),
        ds.data['present'].cast<String>(),
        ds.data['missing'].cast<String>(),
      );
    });
    return event;
  }
}
