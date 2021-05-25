import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn;

  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();

  TextEditingController _emailSignUpController = TextEditingController();
  TextEditingController _passwordSignUpController = TextEditingController();

  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Authentication Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text("Anonymous Login"),
              onPressed: _signInAnonymously,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: Text("Email/Password Sign Up"),
                  onPressed: _signUpForm,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                  ),
                ),
                ElevatedButton(
                  child: Text("Email/Password Sign In"),
                  onPressed: _signInForm,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.redAccent,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              child: Text("Sign in with Google"),
              onPressed: _signInWithGoogle,
            ),
          ],
        ),
      ),
    );
  }

  void _signInAnonymously() async {
    UserCredential res = await auth.signInAnonymously();

    User user = res.user;
    print(user);
    print(user.uid);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Successful Login.\n${user.uid}"),
    ));
  }

  void _signUpForm() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text("Sign Up New User"),
            ),
            content: Form(
              key: _signUpFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailSignUpController,
                    validator: (val) {
                      if (val.isEmpty || val == null) {
                        return "Enter any email...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your email",
                    ),
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: _passwordSignUpController,
                    validator: (val) {
                      if (val.isEmpty || val == null) {
                        return "Enter any password...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  _emailSignUpController.clear();
                  _passwordSignUpController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_signUpFormKey.currentState.validate()) {
                    _signUpFormKey.currentState.save();

                    _signUpWithEmailAndPassword(email, password);
                  }

                  _emailSignUpController.clear();
                  _passwordSignUpController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Sign Up"),
              ),
            ],
          );
        });
  }

  void _signInForm() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text("Sign In User"),
            ),
            content: Form(
              key: _signInFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailSignUpController,
                    validator: (val) {
                      if (val.isEmpty || val == null) {
                        return "Enter any email...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        email = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your email",
                    ),
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: _passwordSignUpController,
                    validator: (val) {
                      if (val.isEmpty || val == null) {
                        return "Enter any password...";
                      }
                      return null;
                    },
                    onSaved: (val) {
                      setState(() {
                        password = val;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () {
                  _emailSignUpController.clear();
                  _passwordSignUpController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_signInFormKey.currentState.validate()) {
                    _signInFormKey.currentState.save();

                    _signInWithEmailAndPassword(email, password);
                  }

                  _emailSignUpController.clear();
                  _passwordSignUpController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Sign In"),
              ),
            ],
          );
        });
  }

  void _signUpWithEmailAndPassword(String email, String pass) async {
    try {
      UserCredential res = await auth.createUserWithEmailAndPassword(
          email: email, password: pass);

      User user = res.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Successful Signed Up.\n${user.uid}"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Signed Up Failed..."),
        ));
      }
    } on FirebaseAuthException catch (e) {
      print("EXCEPTION: $e");
      print("MESSAGE: ${e.message}");
      print("CODE: ${e.code}");
    }
  }

  void _signInWithEmailAndPassword(String email, String pass) async {
    try {
      UserCredential res =
          await auth.signInWithEmailAndPassword(email: email, password: pass);

      User user = res.user;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Successful Signed In.\n${user.uid}"),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Signed In Failed..."),
        ));
      }
    } on FirebaseAuthException catch (e) {
      print("EXCEPTION: $e");
      print("MESSAGE: ${e.message}");
      print("CODE: ${e.code}");
    }
  }

  void _signOut() async {
    User user = auth.currentUser;

    if (user != null) {
      await auth.signOut();
      await googleSignIn.signOut();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Successful Signed Out...\n${user.uid}"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("User not signed in yet..."),
      ));
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      googleSignIn = GoogleSignIn();
    });

    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      User user = userCredential.user;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Successful sign in...\n${user.uid} - ${user.displayName} - ${user.email} - ${user.photoURL}"),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      print("${e.code}");
      print("${e.message}");
    }
  }
}
