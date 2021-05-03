import 'package:timelist_journal/model/journal.dart';
import 'firestore_backend.dart';
import 'auth.dart';

// Service Controller
// Part of TIMELIST JOURNAL (by Logan Giese)

class ServiceController {

  //---AUTH SERVICES---

  static Future<String> createAccount(String email, String password) {
    return Auth.createAccountWithEmailAndPassword(email: email, password: password);
  }

  static Future<String> signIn(String email, String password) {
    return Auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signOut() {
    return Auth.signOut();
  }

  static String getUserId() {
    return Auth.getUserId();
  }

  static bool isSignedIn() {
    return Auth.isSignedIn();
  }

  //---STORAGE SERVICES---

  static Future<List<Journal>> getJournals(DateTime start, DateTime end) {
    return FirestoreBackend.getJournals(userId: getUserId(), startDate: start, endDate: end);
  }

  static Future<Journal> addJournal(DateTime date) {
    return FirestoreBackend.insertJournal(userId: getUserId(), date: date);
  }

  static Future<void> updateJournal(Journal journal) {
    return FirestoreBackend.updateJournal(userId: getUserId(), journal: journal);
  }

  static Future<void> deleteJournal(Journal journal) {
    return FirestoreBackend.removeJournal(userId: getUserId(), journal: journal);
  }

}
