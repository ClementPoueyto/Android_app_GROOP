import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_groop/TheEvent.dart';

class Events extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventsPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventsPage(title: 'EventsPage'),
    );
  }
}

class EventsPage extends StatefulWidget {
  EventsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  EventsPageState createState() => EventsPageState();
}

class EventsPageState extends State<EventsPage> {
  List<MaterialColor> tabColor = [
    Colors.blue,
    Colors.grey,
    Colors.green,
    Colors.red
  ];
  final db = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: (SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 6,
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Events',
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
                SizedBox(height: 20),
                /////////////////////////////////////G1////////////////////////////////

                FutureBuilder(
                  future: _getEvents(),
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
                          return Container(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  // Box decoration takes a gradient
                                  gradient: (snapshot.data[index].photo == null)
                                      ? LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          stops: [0.1, 0.3, 0.6, 0.9],
                                          colors: [
                                            tabColor[index % 4][600],
                                            tabColor[index % 4][500],
                                            tabColor[index % 4][400],
                                            tabColor[index % 4][300],
                                          ],
                                        )
                                      : null,
                                  image: (snapshot.data[index].photo != null)
                                      ? DecorationImage(
                                          colorFilter: new ColorFilter.mode(
                                              Colors.white.withOpacity(0.4),
                                              BlendMode.dstATop),
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              snapshot.data[index].photo),
                                        )
                                      : null,
                                ),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.width / 4,
                                child: Center(
                                  child: ListTile(
                                    title: Text(
                                      snapshot.data[index].title,
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.black,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      snapshot.data[index].pseudo +
                                          "     -     " +
                                          snapshot.data[index].date,
                                      style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.black54,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => TheEvent(
                                                  snapshot.data[index].id,
                                                  index)));
                                    },
                                  ),
                                ),
                              ),
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

  Future<List<Event>> _getEvents() async {
    List<Event> events = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString("pseudo"));
    int i = 0;
    for (var u in prefs.getStringList('events')) {
      if (u.compareTo("") == 0) {
      } else {
        await db
            .collection('events')
            .document(u)
            .get()
            .then((DocumentSnapshot ds) {
          Event event = Event(
            i,
            u,
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
          i++;
          events.add(event);
        });
      }
    }
    return events;
  }
}

class Event {
  final int index;
  final String id;
  final String pseudo;
  final String title;
  final String date;
  final String time;
  final String photo;
  final String groop;
  final String description;
  final String place;
  final List<String> invites, present, missing;

  Event(
      this.index,
      this.id,
      this.pseudo,
      this.title,
      this.date,
      this.time,
      this.place,
      this.description,
      this.groop,
      this.photo,
      this.invites,
      this.present,
      this.missing);
}
