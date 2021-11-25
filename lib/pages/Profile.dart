import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/helper/provider/google_sign_in.dart';
import 'package:notifoo/pages/SignIn.dart';
import 'package:notifoo/widgets/BottomBar.dart';
import 'package:notifoo/widgets/LoggedInWidget.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:provider/provider.dart';

// class Profile extends StatefulWidget {
//   Profile({Key key, this.title}) : super(key: key);
//   //const Profile({Key key}) : super(key: key);
// final String title;

// }

class Profile extends StatefulWidget {
  Profile({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
            return LoggedInWidget();
          } else {
            return SignIn();
          }
        },
      ),
      //  bottomNavigationBar: BottomBar.getBottomBar(context),
    );
  }
}
