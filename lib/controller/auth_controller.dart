

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whats_clone/model/auth_user.dart';

class Auth {

  static Auth _instance;

  final Firestore _firestore = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthUser _currentUser;

  static Auth getInstance() {

    if(_instance == null) _instance = Auth();
    return _instance;
  }


  login({email, password}) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return result.user != null;
    }catch(e){
      return false;
    }
  }

  logout() async {
    _clear();
    await _auth.signOut();
  }

  sign(Map<String, dynamic> userData) async {
    try{
      final result = await _auth.createUserWithEmailAndPassword(email: userData['email'], password: userData['password']);

      userData['id'] = result.user.uid;
      userData['contacts'] = [];
      userData.remove('password');

      await _firestore.collection('users').document().setData(userData);

    }catch(e){
      throw e;
    }

  }


  isLogged() async {
    return (await _auth.currentUser()) != null;
  }

  Future<AuthUser> getCurrentUser() async {
    if(await isLogged() && _currentUser == null){
      _currentUser = await _loadCurrentUser();
    }
    return _currentUser;
  }

  _loadCurrentUser() async {
    final user = await _auth.currentUser();
    final snap = await _firestore.collection('users').where('id', isEqualTo: user.uid).getDocuments();

    if(snap.documents.length <= 0) throw 'error';

    final userData = snap.documents[0].data;
    return AuthUser.fromData(userData);

  }

  _clear(){
    _currentUser = null;
    _instance = null;
  }



}

enum AuthError { EMAIL_ALREADY_EXISTS }