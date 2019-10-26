import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:toast/toast.dart';
import 'package:flutter_groop/DetailFriendPage.dart';
import 'package:flutter_groop/Contact.dart';
import 'main.dart';

class Profil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProfilPage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilPage(title: 'ProfilPage'),
    );
  }
}

class ProfilPage extends StatefulWidget {
  ProfilPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  ProfilPageState createState() => ProfilPageState();
}

class ProfilPageState extends State<ProfilPage> {
  String pseudo, email, id, photo;
  List<String> friends, events, g1, g2, g3;
  final db = Firestore.instance;
  File _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
                  child: FutureBuilder(
                      future: getPseudo(),
                      initialData: "Loading text..",
                      builder:
                          (BuildContext context, AsyncSnapshot<String> text) {
                        String Pseudo = "";
                        if (text.data == null) {
                          return new CircularProgressIndicator(
                            value: null,
                            strokeWidth: 7.0,
                          );
                        } else {
                          Pseudo = text.data;
                        }
                        return Center(
                          child: Text(
                            Pseudo,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: Colors.white,
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      })),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: new EdgeInsets.all(8.0),
                child: new TextField(
                  onSubmitted: (input) => friendExist(input),
                  decoration: InputDecoration(
                    hintText: 'Ajouter des amis',
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: FlatButton(
                  onPressed: () {
                    getImage();
                  },
                  child: FutureBuilder(
                      future: getPhoto(),
                      initialData: null,
                      builder:
                          (BuildContext context, AsyncSnapshot<String> photoP) {
                        if (photoP.data != null) {
                          return CircleAvatar(
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
                                        photoP.data,
                                        fit: BoxFit.cover,
                                        width: 180,
                                        height: 180,
                                      ),
                              ),
                            ),
                          );
                        } else
                          return new CircularProgressIndicator(
                            value: null,
                            strokeWidth: 7.0,
                          );
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: RaisedButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    disabledColor: Colors.grey,
                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(10.0),
                    splashColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    onPressed: () {
                      logout();
                    },
                    child: Text(
                      'Se déconnecter',
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await db
        .collection('users')
        .document(prefs.getString('id'))
        .updateData({"token": ""});
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MyApp()),
    );
    prefs.clear();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 10);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
    uploadPicture(this.context);
  }

  Future uploadPicture(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fileName = prefs.getString("id");
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('profile/' + fileName + '.jpg');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    final ref =
        FirebaseStorage.instance.ref().child('profile/' + fileName + '.jpg');
// no need of the file extension, the name will do fine.
    var url = await ref.getDownloadURL();
    await Firestore.instance
        .collection('users')
        .document(prefs.getString("id"))
        .updateData({'photo': url});

    setState(() {
      prefs.setString('photo', url);
      Toast.show("Photo enregistrée", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    });
  }

  Future<String> getPseudo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pseudo = prefs.getString('pseudo');
    photo = prefs.getString('photo');
    return pseudo;
  }

  Future<String> getPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String chemin = prefs.getString('photo');

    return chemin;
  }

  Future<void> getId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id');
  }

  Future<void> friendExist(String query) async {
    if (query.compareTo(pseudo) != 0) {
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('pseudo', isEqualTo: query)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      //print(documents[0].toString());
      if (documents.length == 1) {
        String id = result.documents[0].reference.documentID;
        await db
            .collection('users')
            .document(id)
            .get()
            .then((DocumentSnapshot ds) {
          // use ds as a snapshot
          User user = User(
              1,
              ds.data['pseudo'],
              ds.data['photo'],
              id,
              ds.data['friends'].cast<String>(),
              ds.data['events'].cast<String>(),
              ds.data['g1'].cast<String>(),
              ds.data['g2'].cast<String>(),
              ds.data['g3'].cast<String>());
          //print(documents[0].data['pseudo']);
          Navigator.push(context,
              new MaterialPageRoute(builder: (context) => DetailFriend(user)));
        });
      } else {
        Toast.show("utilisateur inconnu", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    } else {
      Toast.show("toi", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }
}
