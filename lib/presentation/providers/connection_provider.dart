import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectionStatusProvider = StreamProvider<bool>((ref) {
  return FirebaseDatabase.instance.ref('.info/connected').onValue.map(
    (event) => event.snapshot.value as bool? ?? false,
  );
});
