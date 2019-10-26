import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'message.dart';
import 'messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_groop/Contact.dart';
import 'package:flutter_groop/Events.dart';
import 'package:flutter_groop/DetailFriendPage.dart';

class MyEvent extends StatelessWidget {
  final String idEvent;
  final int index = 0;
  MyEvent(this.idEvent);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyEventPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyEventPage(
        title: 'MyEventPage',
        idEvent: idEvent,
        index: index,
      ),
    );
  }
}

class MyEventPage extends StatefulWidget {
  MyEventPage({Key key, this.title, this.idEvent, this.index})
      : super(key: key);
  final String title;
  final String idEvent;
  final int index;

  @override
  MyEventPageState createState() => MyEventPageState(idEvent, index);
}

class MyEventPageState extends State<MyEventPage> {
  File _image;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final db = Firestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _title = "", _place = "", _description = "", _pseudo = "";
  String _valueDate = '';
  String _valueTime = '';
  String _url;
  String groop = "g1";
  Color _colorg1 = Colors.black12,
      _colorg2 = Colors.black12,
      _colorg3 = Colors.green;
  final List<Message> messages = [];
  /////////

  final String idEvent;
  final int index;
  MyEventPageState(this.idEvent, this.index);
  List<String> invites, missing, present;
  Future<String> res;
  String here = "";
  String nothere = "";

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  Widget buildMessage(Message message) => ListTile(
        title: Text(message.title),
        subtitle: Text(message.body),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: FutureBuilder(
                  future: myEventDetails(),
                  initialData: [""],
                  builder: (BuildContext context,
                      AsyncSnapshot<List<String>> event) {
                    if (event.data.isEmpty) {
                      return Form(
                        key: _formKey,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height / 6,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(80))),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      "My Event",
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
                                  maxLines: 1,
                                  maxLength: 50,
                                  validator: (input) {
                                    if (input.isEmpty) {
                                      return 'Please enter title';
                                    }
                                    return null;
                                  },
                                  onSaved: (input) => _title = input,
                                  decoration:
                                      InputDecoration(labelText: "title"),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(10.0),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      IconButton(
                                          icon: Icon(Icons.calendar_today),
                                          onPressed: () {
                                            _selectDate();
                                          }),
                                      Text(
                                        _valueDate,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.access_time),
                                          onPressed: () {
                                            _selectTime();
                                          }),
                                      Text(
                                        _valueTime,
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(10.0),
                                child: TextFormField(
                                  validator: (input) {
                                    if (input.isEmpty) {
                                      return "empty field";
                                    }
                                    return null;
                                  },
                                  onSaved: (input) => _place = input,
                                  decoration:
                                      InputDecoration(labelText: "place"),
                                  maxLength: 50,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(10.0),
                                child: TextFormField(
                                  onSaved: (input) => _description = input,
                                  decoration:
                                      InputDecoration(labelText: "description"),
                                  maxLines: 10,
                                  maxLength: 500,
                                  minLines: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: IconButton(
                                      icon: Icon(Icons.brightness_3),
                                      color: _colorg3,
                                      disabledColor: Colors.grey,
                                      padding: EdgeInsets.all(10.0),
                                      splashColor: Colors.blueAccent,
                                      onPressed: () {
                                        _colorg1 = Colors.black12;
                                        _colorg2 = Colors.black12;
                                        _colorg3 = Colors.green;
                                        groop = "g1";
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: IconButton(
                                      icon: Icon(Icons.brightness_2),
                                      color: _colorg2,
                                      disabledColor: Colors.grey,
                                      padding: EdgeInsets.all(10.0),
                                      splashColor: Colors.blueAccent,
                                      onPressed: () {
                                        _colorg1 = Colors.black12;
                                        _colorg2 = Colors.green;
                                        _colorg3 = Colors.black12;
                                        groop = "g2";
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: IconButton(
                                      icon: Icon(Icons.brightness_1),
                                      color: _colorg1,
                                      disabledColor: Colors.grey,
                                      padding: EdgeInsets.all(10.0),
                                      splashColor: Colors.blueAccent,
                                      onPressed: () {
                                        _colorg1 = Colors.green;
                                        _colorg2 = Colors.black12;
                                        _colorg3 = Colors.black12;
                                        groop = "g3";
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                  icon: Icon(Icons.image),
                                  onPressed: () {
                                    getImage();
                                  }),
                              _image == null
                                  ? Text("")
                                  : SizedBox(
                                      width: 240,
                                      height: 180,
                                      child: Image.file(
                                        _image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: RaisedButton(
                                  color: Colors.blue,
                                  textColor: Colors.white,
                                  disabledColor: Colors.grey,
                                  disabledTextColor: Colors.black,
                                  padding: EdgeInsets.all(10.0),
                                  splashColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  onPressed: () {
                                    publish();
                                    sendNotification();
                                  },
                                  child: Text(
                                    "Publish",
                                    style: TextStyle(fontSize: 25.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    ///////////////////////////////////////////////////////////////////////////////////////////////
                    ///////////////////////////////////////////////////////////////////////////////////////////////

                    else {
                      return Container(
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
                                    height:
                                        MediaQuery.of(context).size.height / 6,
                                    decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(80))),
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
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color: Colors.transparent,
                                                  image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                          event.data.photo)),
                                                ),
                                              ),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    3,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    gradient: LinearGradient(
                                                        begin: FractionalOffset
                                                            .topCenter,
                                                        end: FractionalOffset
                                                            .bottomCenter,
                                                        colors: [
                                                          Colors.white
                                                              .withOpacity(0.0),
                                                          Colors.white
                                                              .withOpacity(0.6),
                                                          Colors.white
                                                              .withOpacity(1.0),
                                                        ],
                                                        stops: [
                                                          0.0,
                                                          0.8,
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
                                      height:
                                          MediaQuery.of(context).size.height /
                                              12,
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(80)),
                                      child: Center(
                                        child: Text(
                                          (event.data.time.compareTo("") == 0)
                                              ? event.data.date
                                              : event.data.date +
                                                  " à " +
                                                  event.data.time,
                                          style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .textScaleFactor *
                                                20,
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
                                      height:
                                          MediaQuery.of(context).size.height /
                                              12,
                                      decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(80)),
                                      child: Center(
                                        child: Text(
                                          event.data.place,
                                          style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .textScaleFactor *
                                                20,
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
                                          borderRadius:
                                              BorderRadius.circular(80)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Center(
                                          child: Text(
                                            event.data.description,
                                            style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .textScaleFactor *
                                                  20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10.0),
                                            child: Center(
                                              child: FutureBuilder(
                                                  future: getUsers("present"),
                                                  initialData: null,
                                                  builder: (BuildContext
                                                          context,
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
                                                        itemCount: snapshot
                                                            .data.length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Card(
                                                            child: ListTile(
                                                              leading:
                                                                  CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(snapshot
                                                                        .data[
                                                                            index]
                                                                        .photo),
                                                              ),
                                                              title: Text(
                                                                snapshot
                                                                    .data[index]
                                                                    .pseudo,
                                                                style:
                                                                    TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize:
                                                                      MediaQuery.of(context)
                                                                              .textScaleFactor *
                                                                          10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                DetailFriend(snapshot.data[index])));
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0),
                                            child: Center(
                                              child: FutureBuilder(
                                                  future: getUsers("missing"),
                                                  initialData: null,
                                                  builder: (BuildContext
                                                          context,
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
                                                        itemCount: snapshot
                                                            .data.length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Card(
                                                            child: ListTile(
                                                              leading:
                                                                  CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(snapshot
                                                                        .data[
                                                                            index]
                                                                        .photo),
                                                              ),
                                                              title: Text(
                                                                snapshot
                                                                    .data[index]
                                                                    .pseudo,
                                                                style:
                                                                    TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .black54,
                                                                  fontSize:
                                                                      MediaQuery.of(context)
                                                                              .textScaleFactor *
                                                                          10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                Navigator.push(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                DetailFriend(snapshot.data[index])));
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
                                  SizedBox(
                                    height: 30,
                                  ),
                                  RaisedButton(
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    disabledColor: Colors.grey,
                                    disabledTextColor: Colors.black,
                                    padding: EdgeInsets.all(10.0),
                                    splashColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    onPressed: () {
                                      deleteEvent();
                                    },
                                    child: Text(
                                      'Supprimer',
                                      style: TextStyle(fontSize: 25.0),
                                    ),
                                  ),
                                ],
                              ));
                            }
                          },
                        ),
                      );
                    }
                  }),
            ),
          ),
        ));
  }

  Future deleteEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> invites;
    await db
        .collection('events')
        .document(prefs.getString('id'))
        .get()
        .then((DocumentSnapshot ds) {
      invites = ds.data['invites'].cast<String>();
    });
    for (var u in invites) {
      List<String> events;
      List<String> events2 = [];
      await db
          .collection('users')
          .document(u)
          .get()
          .then((DocumentSnapshot ds) {
        events = ds.data['events'].cast<String>();
        for (var i in events) {
          if (i.compareTo(prefs.getString('id')) != 0) {
            events2.add(i);
          }
        }
      });
      await db.collection('users').document(u).updateData({'events': events2});
      prefs.setStringList('events', events2);
    }

    await prefs.setStringList('myevent', []);
    await db.collection('events').document(prefs.getString('id')).delete();
    await db
        .collection('users')
        .document(prefs.getString('id'))
        .updateData({'myevent': []});

    setState(() {});
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 10);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future<List<String>> myEventDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> myEvent = prefs.getStringList('myevent');
    return Future.value(myEvent);
  }

  Future<void> _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        initialDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 60)));
    if (picked != null) {
      String day = picked.toLocal().day.toString();
      String month = picked.toLocal().month.toString();
      if (picked.toLocal().day < 10) {
        day = "0" + picked.toLocal().day.toString();
      }
      if (picked.toLocal().month < 10) {
        month = "0" + picked.toLocal().month.toString();
      }
      setState(() => _valueDate =
          day + " : " + month + " : " + picked.toLocal().year.toString());
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      String hour = picked.hour.toString();
      String min = picked.minute.toString();
      if (picked.hour < 10) {
        hour = "0" + picked.hour.toString();
      }
      if (picked.minute < 10) {
        min = "0" + picked.minute.toString();
      }
      setState(() => _valueTime = hour + " : " + min);
    }
  }

  Future<void> sendEvent(List<String> invites, String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (var u in invites) {
      if (u.compareTo("") != 0) {
        DocumentSnapshot doc =
            await db.collection('users').document(u.toString()).get();
        List<String> events = doc.data['events'].cast<String>();
        List<String> event2 = []; //because of fixed length
        for (var i in events) {
          event2.add(i);
        }
        if (!event2.contains(id)) {
          event2.add(id);
        }
        await db.collection('users').document(u).updateData({"events": event2});
        await prefs.setStringList('events', event2);
      }
    }
  }

  Future uploadPicture(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fileName = prefs.getString("id");
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('events/' + fileName + '.jpg');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    final ref =
        FirebaseStorage.instance.ref().child('events/' + fileName + '.jpg');
// no need of the file extension, the name will do fine.
    _url = await ref.getDownloadURL();

    print("events Picture uploaded");
  }

  Future<void> publish() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      if (_valueDate.compareTo("") == 0) {
        Toast.show("Please select date", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      } else {
        print(_title +
            "/" +
            _valueDate +
            "/" +
            _valueTime +
            "/" +
            _place +
            "/" +
            _description +
            "/" +
            groop);

        try {
          if (_image != null) {
            await uploadPicture(context);
          }
          SharedPreferences prefs = await SharedPreferences.getInstance();
          _pseudo = prefs.getString("pseudo");
          List<String> invites;
          if (groop.compareTo("g1") == 0) {
            invites = prefs.getStringList(groop);
          }
          if (groop.compareTo("g2") == 0) {
            invites = prefs.getStringList("g1") + prefs.getStringList(groop);
          }
          if (groop.compareTo("g3") == 0) {
            invites = prefs.getStringList("g1") +
                prefs.getStringList("g2") +
                prefs.getStringList(groop);
          }

          List<String> myevent = [];
          myevent.add(prefs.get('id'));
          myevent.add(_title);
          myevent.add(_valueDate);
          myevent.add(_valueTime);
          myevent.add(_place);
          myevent.add(_description);
          myevent.add(groop);
          myevent.add(invites.toString());
          myevent.add(_url);
          myevent.add(_pseudo);
          prefs.setStringList('myevent', myevent);

          sendEvent(invites, prefs.get('id'));

          await db
              .collection('events')
              .document(prefs.getString('id'))
              .setData({
            'title': '$_title',
            'date': "$_valueDate",
            'time': '$_valueTime',
            'place': "$_place",
            'description': "$_description",
            'groop': groop,
            'invites': invites,
            'photo': _url,
            'pseudo': _pseudo,
            'missing': [],
            'present': [],
          });
          await db
              .collection('users')
              .document(prefs.getString('id'))
              .updateData({
            'myevent': myevent,
          });
        } catch (e) {
          Toast.show(e.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          print(e.message);
        }
      }
    }
  }

  Future sendNotification() async {
    final response = await Messaging.sendToAll(_title, _description, groop);
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
    // send key to your server to allow server to use
    // this token to send push notifications
  }

  //////////////////////////////////////////////////////////////////////////
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
