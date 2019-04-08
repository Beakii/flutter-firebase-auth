import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _user;
GoogleSignInAccount _gUser;

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void>signInWithGoogle(GoogleSignIn info);
  Future<String> currentUser();
  Future<void> signOut();
}

class Auth implements BaseAuth{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> signInWithGoogle(GoogleSignIn info) async{
    _user = info;
    _gUser = await info.signIn();
    GoogleSignInAuthentication googleAuth = await _gUser.authentication;
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );
    final FirebaseUser fbUser = await _firebaseAuth.signInWithCredential(credential);

    assert(_gUser.email != null);
    assert(_gUser.displayName != null);
    assert(!fbUser.isAnonymous);
    assert(await fbUser.getIdToken() != null);

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(fbUser.uid == currentUser.uid);
  }

  Future<String> currentUser() async{
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }

  Future<void> signOut() async{
    //print("Google User: $user has signed out of Firebase");
    _user.signOut();
    return _firebaseAuth.signOut();
  }
}