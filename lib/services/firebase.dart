import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new document
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).add(data);
    } catch (e) {
      log('Error adding document: $e');
    }
  }

  // Get a stream of documents
  Stream<QuerySnapshot> getDocuments(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Update a document
  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      log('Firebase Service -> Error updating document: $e');
    }
  }

  // Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      log('Firebase Service -> Error deleting document: $e');
    }
  }

  // Get a single document
  Future<DocumentSnapshot> getDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).get();
  }

  // Query documents
  Stream<QuerySnapshot> queryDocuments(
    String collection, {
    required String field,
    required dynamic isEqualTo,
  }) {
    return _firestore
        .collection(collection)
        .where(field, isEqualTo: isEqualTo)
        .snapshots();
  }

  // Add a document with a specific ID
  Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      log('Firebase Service -> Error setting document: $e');
    }
  }

  // Perform a transaction
  Future<void> performTransaction(
      String collection, String docId, int incrementBy) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot =
            await transaction.get(_firestore.collection(collection).doc(docId));
        if (!snapshot.exists) {
          throw Exception("Document does not exist!");
        }
        int newCount =
            (snapshot.data() as Map<String, dynamic>)['count'] + incrementBy;
        transaction.update(snapshot.reference, {'count': newCount});
      });
    } catch (e) {
      log('Firebase Service -> Error performing transaction: $e');
    }
  }

  // Batch write
  Future<void> batchWrite(
      List<Map<String, dynamic>> documents, String collection) async {
    WriteBatch batch = _firestore.batch();

    for (var doc in documents) {
      DocumentReference docRef = _firestore.collection(collection).doc();
      batch.set(docRef, doc);
    }

    try {
      await batch.commit();
    } catch (e) {
      log('Firebase Service -> Error performing batch write: $e');
    }
  }
}
