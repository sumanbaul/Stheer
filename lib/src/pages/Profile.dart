import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:notifoo/main.dart';
import 'package:notifoo/src/pages/SignIn.dart';
import 'package:notifoo/src/pages/habit_tracker.dart';
import 'package:notifoo/src/widgets/LoggedInWidget.dart';
import '../helper/provider/google_sign_in.dart';
import '../helper/user_database.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, this.title}) : super(key: key);
  final String? title;
  //final User? user;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  GoogleSignInAccount? _user;
  UserDatabase db = UserDatabase();
  final _myBox = Hive.box("User_Database");

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
            // db.getUserStatusFirstTime();
            // if (db.isUserLogginInFirstTime) {
            //   db.putUserStatusFirstTime();
            //   Navigator.pushNamed(context, '/');
            //   return Container();
            // } else {

            return LoggedInWidget(
              logoutOnPressed: logOutOnPressed,
            );
            // }
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
    provider.googleLogin().then((value) {
      setState(() {
        _user = provider.user;
      });

      //print("suman" + value);
    });
    //provider.googleSignIn;

    if (_user != null) {
      // Navigator.pushNamed(context, '/');
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));

      // setState(() {
      //   _user = provider.user;
      //   //user = provider.user;
      // });
    }
  }

  void logOutOnPressed() async {
    final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
    db.putUserStatusOnLogout();
    setState(() {
      provider.googleLogout();
    });
  }
}
