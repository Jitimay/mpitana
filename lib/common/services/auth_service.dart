// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Get current user
//   User? get currentUser => _auth.currentUser;

//   // Stream of auth state changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   // Sign in with email and password
//   Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       return await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Register with email and password
//   Future<UserCredential> registerWithEmailAndPassword(
//       String email, String password, String fullName, String phoneNumber) async {
//     try {
//       // Create user with email and password
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // Add user details to Firestore
//       await _firestore.collection('users').doc(userCredential.user!.uid).set({
//         'fullName': fullName,
//         'email': email,
//         'phoneNumber': phoneNumber,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       // Update display name
//       await userCredential.user!.updateDisplayName(fullName);

//       return userCredential;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }

//   // Reset password
//   Future<void> resetPassword(String email) async {
//     await _auth.sendPasswordResetEmail(email: email);
//   }

//   // Get user details from Firestore
//   Future<Map<String, dynamic>?> getUserDetails() async {
//     if (currentUser == null) return null;
    
//     try {
//       DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
//       return doc.data() as Map<String, dynamic>?;
//     } catch (e) {
//       return null;
//     }
//   }

//   // Update user profile
//   Future<void> updateUserProfile({
//     String? fullName,
//     String? phoneNumber,
//     String? photoURL,
//   }) async {
//     if (currentUser == null) return;

//     try {
//       Map<String, dynamic> updateData = {};
      
//       if (fullName != null && fullName.isNotEmpty) {
//         updateData['fullName'] = fullName;
//         await currentUser!.updateDisplayName(fullName);
//       }
      
//       if (phoneNumber != null && phoneNumber.isNotEmpty) {
//         updateData['phoneNumber'] = phoneNumber;
//       }
      
//       if (photoURL != null && photoURL.isNotEmpty) {
//         updateData['photoURL'] = photoURL;
//         await currentUser!.updatePhotoURL(photoURL);
//       }
      
//       if (updateData.isNotEmpty) {
//         await _firestore.collection('users').doc(currentUser!.uid).update(updateData);
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
