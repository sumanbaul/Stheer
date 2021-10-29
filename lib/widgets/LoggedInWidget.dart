import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notifoo/provider/google_sign_in.dart';
import 'package:notifoo/widgets/BottomBar.dart';
import 'package:provider/provider.dart';

class LoggedInWidget extends StatelessWidget {
  //const LoggedInWidget({Key? key}) : super(key: key);

  //final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logged In'),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () {
                //final provi = Provider.of<GoogleSignInProvider>(context, listen: GoogleSignInProvider.googleLogout());
                final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogout();
              },
              child: Text('Logout'))
        ],
      ),
      bottomNavigationBar: BottomBar.getBottomBar(context),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.displayName,
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent),
            ),
            SizedBox(height: 22),
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.photoURL),
            ),
            SizedBox(height: 10),
            Text(user.email),
            SizedBox(height: 10),
            //Text(user.metadata.lastSignInTime.day.toString())
            Text(user.phoneNumber.toString()),
          ],
        ),
      ),
    );
  }
}
