import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timelist_journal/model/journal.dart';
import 'package:timelist_journal/utils/date_helper.dart';

// Firestore Storage Manager
// Part of TIMELIST JOURNAL (by Logan Giese)

class FirestoreBackend {
  // Collection names
  static const _users = 'users';
  static const _journals = 'journals';

  // Mapping values
  static const _isFavorite = 'isFavorite';
  static const _date = 'date';
  static const _items = 'items';

  // Get all Journals within a specified date range
  static Future<List<Journal>> getJournals({String userId, DateTime startDate, DateTime endDate}) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference ref = db.collection(_users).doc(userId).collection(_journals);
    return ref
      .where(_date, isGreaterThanOrEqualTo: startDate)
      .where(_date, isLessThanOrEqualTo: endDate)
      .get()
      .then((querySnapshot) {
        return querySnapshot.docs.map((doc) =>
          Journal(
            id: doc.id,
            isFavorite: doc[_isFavorite],
            date: toDateTime(doc[_date]),
            items: Journal.convertItemMap(doc[_items])
          )
        ).toList();
      });
  }

  // Create a new Journal and insert it into the DB
  static Future<Journal> insertJournal({String userId, DateTime date}) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return db.collection(_users).doc(userId).collection(_journals).add({
      _isFavorite: false,
      _date: date,
      _items: []
    }).then((doc) {
      // Construct a new Journal with the generated ID
      return Journal(
        id: doc.id,
        isFavorite: false,
        date: date,
        items: []
      );
    });
  }

  // Update the data for a Journal in the DB
  static Future<void> updateJournal({String userId, Journal journal}) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return db.collection(_users).doc(userId).collection(_journals).doc(journal.id).update({
      _isFavorite: journal.isFavorite,
      // Don't update the date (it should be constant for the journal)
      _items: journal.getMappedItems()
    });
  }

  // Delete a specific Journal from the DB
  static Future<void> removeJournal({String userId, Journal journal}) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    return db.collection(_users).doc(userId).collection(_journals).doc(journal.id).delete();
  }
}
