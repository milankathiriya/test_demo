import 'package:chirag_firebase_app/screens/auth.dart';
import 'package:chirag_firebase_app/screens/cf_db_page.dart';
import 'package:chirag_firebase_app/screens/rt_db_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

/*
Ch.13

Publish Code to GitHub
- What is GitHub?
- Installation of Git
- Creating GitHub Account
- Create first GitHub Repository
- Push first App on GitHub
- Grab Project from GitHub
* */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp defaultApp = await Firebase.initializeApp();

  /*
    1. Initialize your git inside your directory.
        git init

    2. Perform add operation on specific files/directories.
        git add filename
          or
        git add .

    3. Perform staging/indexing
        git commit -m "commit name/change name"

    4. Publish/Push
        syntax: git push -u origin branch_name
        example: git push -u origin master

    5. Clonning/Download
        git clone remote_adrress
  */

  runApp(
    MaterialApp(
      routes: {
        '/': (context) => HomePage(),
        'auth': (context) => AuthPage(),
        'rt_db': (context) => RTDBPage(),
        'cf_db': (context) => CFDBPage(),
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase App"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Authentication"),
              onPressed: () {
                Navigator.of(context).pushNamed('auth');
              },
            ),
            ElevatedButton(
              child: Text("Realtime Database"),
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('rt_db');
              },
            ),
            ElevatedButton(
              child: Text("Cloud Firestore Database"),
              style: ElevatedButton.styleFrom(
                primary: Colors.amber,
                onPrimary: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('cf_db');
              },
            ),
          ],
        ),
      ),
    );
  }
}
