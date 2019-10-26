import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Messaging {
  static final Client client = Client();

  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"
  static const String serverKey =
      'AAAA-p6or_Q:APA91bH-WRb8zQOlnzVrYiJKmEshPKfDyvP5UqM5QJMKLLANg6Lvguz_41XMsfxRnWIT_8WN9GSLfEgT_-V2DKd14YbYiv5-V8uc1Jpd2I-QzXSN7q89wG6Jq-4zs1KQKLr5fcs-JBlT';

  static Future<Response> sendToAll(
      String title, String body, String groop) async {
    final db = Firestore.instance;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> g = prefs.getStringList(groop);
    for (var id in g) {
      await db
          .collection('users')
          .document(id)
          .get()
          .then((DocumentSnapshot ds) {
        String fcm = ds.data['token'];
        if (fcm.compareTo("") != 0) {
          sendToId(title: title, body: body, id: fcm);
        }
      });
    }
  }

  static Future<Response> sendToId(
          {@required String title,
          @required String body,
          @required String id}) =>
      sendTo(title: title, body: body, fcmToken: id);

  static Future<Response> sendTo({
    @required String title,
    @required String body,
    @required String fcmToken,
  }) =>
      client.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          'notification': {'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
          },
          'to': '$fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );
}
