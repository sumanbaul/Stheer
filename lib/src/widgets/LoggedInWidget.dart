import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stheer/src/helper/provider/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoggedInWidget extends StatelessWidget {
  //const LoggedInWidget({Key? key}) : super(key: key);

  //final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Color(0xffeeaeca),
        title: Text('Logged In',
            style: GoogleFonts.barlowSemiCondensed(
              fontSize: 24,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              //final provi = Provider.of<GoogleSignInProvider>(context, listen: GoogleSignInProvider.googleLogout());
              final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.googleLogout();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user!.displayName!,
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent),
            ),
            SizedBox(height: 22),
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user!.photoURL!),
            ),
            SizedBox(height: 10),
            Text(user!.email!),
            SizedBox(height: 10),
            //Text(user.metadata.lastSignInTime.day.toString())
            Text(user!.phoneNumber.toString()),
          ],
        ),
      ),
    );
  }
}
