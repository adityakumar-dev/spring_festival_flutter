import 'package:firebase_database/firebase_database.dart';

class FirebaseController {
  static FirebaseDatabase database = FirebaseDatabase.instance;
  static DatabaseReference ref = database.ref();
}
