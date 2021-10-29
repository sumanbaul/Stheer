import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notifoo/helper/provider/google_sign_in.dart';
import 'package:notifoo/widgets/BottomBar.dart';
import 'package:notifoo/widgets/Topbar.dart';
import 'package:provider/provider.dart';

class SignIn extends StatelessWidget {
  //SignIn({Key key, this.title}) : super(key: key);

  //final String title;
  //const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(58, 66, 86, 1.0),
      appBar: Topbar.getTopbar('Sign In'),
      bottomNavigationBar: BottomBar.getBottomBar(context),
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
              onPressed: () {
                final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogin();
              },
              label: Text('Sign Up With Google'),
              icon: FaIcon(FontAwesomeIcons.google, color: Colors.red),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                minimumSize: Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
