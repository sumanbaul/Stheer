import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignInAccount? _user;

  GoogleSignInAccount? get user => _user;

  Future googleLogin() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? user = result.user;

      if (result.user != null) {
        //
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => HomePage()));
        //return result;
      }
    } catch (e) {
      print(e.toString());
    }

    notifyListeners();
  }

  bool isLogged() {
    try {
      final user = auth.currentUser;
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future googleLogout() async {
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }
}
