import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        actions: [TextButton(onPressed: () {}, child: Text('Logout'))],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Profile'),
            SizedBox(height: 32),
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(user.photoURL),
            )
          ],
        ),
      ),
    );
  }
}
