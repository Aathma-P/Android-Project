import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('user_profiles').doc(user.uid).get();

        // If the user doesn't exist in Firestore, add them
        if (!userDoc.exists) {
          await _firestore.collection('user_profiles').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'username': googleUser.displayName ?? 'User',
            'photoURL': user.photoURL ?? '',
            'createdAt': DateTime.now(),
          });
        }
      }

      return user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  // Sign Up with Email & Password
  Future<User?> signUpWithEmail(
      String email, String password, String username) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('user_profiles').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'username': username,
          'photoURL': '',
          'createdAt': DateTime.now(),
        });
      }

      return user;
    } catch (e) {
      print("Error signing up: $e");
      return null;
    }
  }

  // Sign In with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Get User Data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('user_profiles').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }
}

// Firestore Service for Hostel Data
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add Hostel Data to Firestore
  Future<void> addHostel(Map<String, dynamic> hostelData) async {
    try {
      await _firestore.collection('hostels').add(hostelData);
    } catch (e) {
      print("Error adding hostel to Firestore: $e");
      rethrow;
    }
  }

  // Fetch Hostels from Firestore
  Stream<QuerySnapshot> fetchHostels() {
    return _firestore.collection('hostels').snapshots();
  }

  // Get Specific Hostel by ID
  Future<DocumentSnapshot> getHostelById(String hostelId) async {
    try {
      return await _firestore.collection('hostels').doc(hostelId).get();
    } catch (e) {
      print("Error fetching hostel: $e");
      rethrow;
    }
  }

  // Update Hostel Data
  Future<void> updateHostel(String hostelId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('hostels').doc(hostelId).update(data);
    } catch (e) {
      print("Error updating hostel: $e");
      rethrow;
    }
  }

  // Delete Hostel
  Future<void> deleteHostel(String hostelId) async {
    try {
      await _firestore.collection('hostels').doc(hostelId).delete();
    } catch (e) {
      print("Error deleting hostel: $e");
      rethrow;
    }
  }
}
