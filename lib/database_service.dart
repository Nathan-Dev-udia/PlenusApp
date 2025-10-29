import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  final DatabaseReference firebaseDatabase = FirebaseDatabase.instance.ref();

  // Create (update)
  Future<void> createData(String path, Map<String, dynamic> data) async {
    await firebaseDatabase.child(path).set(data);
  }

  // Read
  Future<DataSnapshot?> read({required String path}) async {
    final DatabaseReference ref = firebaseDatabase.ref.child(path);
    final DataSnapshot snapshot = await ref.get();
    return snapshot.exists ? snapshot : null;
  }

  // Update
  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = firebaseDatabase.ref.child(path);
    await ref.update(data);
  }

  // Delete
  Future<void> delete({required String path}) async {
    final DatabaseReference ref = firebaseDatabase.ref.child(path);
    await ref.remove();
  }

  /*
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> writeData(String path, Map<String, dynamic> data) async {
    await _dbRef.child(path).set(data);
  }

  Future<DataSnapshot> readData(String path) async {
    final snapshot = await _dbRef.child(path).get();
    return snapshot;
  }

  Future<void> updateData(String path, Map<String, dynamic> data) async {
    await _dbRef.child(path).update(data);
  }

  Future<void> deleteData(String path) async {
    await _dbRef.child(path).remove();
  }
}
*/
}
