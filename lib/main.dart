import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

Future<void> loginWithEmailAndPassword() async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: "test@test.de",
      password: "supersecurepassword",
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('Kein Benutzer für diese E-Mail gefunden.');
    } else if (e.code == 'wrong-password') {
      print('Falsches Passwort für diesen Benutzer angegeben.');
    }
  }
}

Future<void> registerwithEmailAndPassword() async {
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: "test@test.de",
      password: "supersecurepassword",
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('Das angegebene Passwort ist zu schwach.');
    } else if (e.code == 'email-already-in-use') {
      print('Für diese E-Mail existiert bereits ein Konto.');
    }
  } catch (e) {
    print(e);
  }
}

void checkLoginStatus() {
  FirebaseAuth auth = FirebaseAuth.instance;
  auth.authStateChanges().listen((User? user) {
    if (user == null) {
      print('Benutzer ist derzeit abgemeldet.');
    } else {
      print('Benutzer ist eingeloggt mit der Email ${user.email}');
    }
  });
}

Future<UserCredential?> signInWithGoogle() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  // Check if user is null
  if (googleUser == null) {
    print('Google Sign In wurde abgebrochen.');
    return null;
  }
  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

Future<void> signOutGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  await googleSignIn.signOut();
  print("User Signed Out");
}

Future<void> signOutEmailPassword() async {
  await FirebaseAuth.instance.signOut();
  print("Benutzer hat sich bei Firebase abgemeldet");
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: loginWithEmailAndPassword, child: Text("Login")),
            ElevatedButton(onPressed: registerwithEmailAndPassword, child: Text("Register")),
            ElevatedButton(onPressed: checkLoginStatus, child: Text("CheckLoginState")),
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(onPressed: signInWithGoogle, child: Text("Google Sign In")),
            ),
            ElevatedButton(onPressed: signOutGoogle, child: Text("Google Sign Out")),
          ],
        )),
      ),
    );
  }
}
