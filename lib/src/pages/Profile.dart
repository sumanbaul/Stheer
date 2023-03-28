import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:stheer/src/pages/SignIn.dart';
import 'package:stheer/src/widgets/LoggedInWidget.dart';

import '../helper/provider/google_sign_in.dart';

// class Profile extends StatefulWidget {
//   Profile({Key key, this.title}) : super(key: key);
//   //const Profile({Key key}) : super(key: key);
// final String title;

// }

class Profile extends StatefulWidget {
  Profile({Key? key, this.title}) : super(key: key);
  final String? title;
  //final User? user;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  GoogleSignInAccount? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: Topbar.getTopbar('Sign In'),
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong'),
            );
          } else if (snapshot.hasData) {
            return LoggedInWidget(
              logoutOnPressed: logOutOnPressed,
            );
          } else {
            return SignIn(
              signInOnPressed: signInOnPressed,
              user: _user,
            );
          }
        },
      ),
      //  bottomNavigationBar: BottomBar.getBottomBar(context),
    );
  }

  void signInOnPressed() async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    provider.googleLogin();
    //provider.googleSignIn;

    if (provider.user != null) {
      setState(() {
        _user = provider.user;
        //user = provider.user;
      });
    }
  }

  void logOutOnPressed() async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    setState(() {
      provider.googleLogout();
    });
  }
}
