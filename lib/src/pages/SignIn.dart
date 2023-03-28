import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stheer/src/helper/provider/google_sign_in.dart';
import 'package:stheer/src/widgets/Topbar.dart';
import 'package:provider/provider.dart';

class SignIn extends StatelessWidget {
  final GoogleSignInAccount? user;
  final void Function()? signInOnPressed; // Good

  //SignIn({Key key, this.title}) : super(key: key);

  //final String title;
  SignIn({
    Key? key,
    required this.user,
    required this.signInOnPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      //appBar: Topbar.getTopbar('Sign In'),
      //bottomNavigationBar: BottomBar.getBottomBar(context),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            FlutterLogo(size: 120),
            Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hey There, \nWelcome Back',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Login to your account',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Spacer(),
            ElevatedButton.icon(
              onPressed: signInOnPressed,
              // onPressed: () {
              //   final provider =
              //       Provider.of<GoogleSignInProvider>(context, listen: false);

              //   //Navigator.pushNamedAndRemoveUntil(context, newRoute)
              // },
              label: Text('Sign Up With Google'),
              icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
