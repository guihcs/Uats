


import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whats_clone/model/message.dart';

class UserController {

  static UserController _instance;


  final Firestore _firestore = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, User> _userMap = {};
  User _user;

  List<dynamic> _contacts = [];


  static UserController getInstance(){
    if(_instance == null) _instance = UserController();
    return _instance;
  }

  loadContacts(contacts) async {

    for (var contactID in contacts) {
      final documentList = (await _firestore.collection('users').where('id', isEqualTo: contactID).getDocuments()).documents;

      if(documentList.length > 0){
        _userMap[contactID] = User.fromJson(documentList[0].data);
      }

    }

  }

  _getUserData(user) async {

    if(user != null) {
      final queryResult = (await _firestore
          .collection('users')
          .where('id', isEqualTo: user.uid)
          .getDocuments()).documents;

      if (queryResult.length > 0) {
        final userData = queryResult[0].data;
        _contacts = userData['contacts'];
        _user = User.fromJson(userData);
        return true;
      }
    }
    return false;
  }

  getContact(String key) async {
    if(_userMap.containsKey(key)) {
      return _userMap[key];
    }
    final contact = await loadFromID(key);
    if(contact != null){
      addUser(key, contact);
      return contact;
    }
    return null;
  }

  loadFromID(String id) async {
    final documents = (await _firestore
        .collection('users')
        .where('id', isEqualTo: id)
        .getDocuments()).documents;

    if(documents.length > 0){
      final user = User.fromJson(documents[0].data);
      addUser(id, user);
      return user;
    }

    return null;
  }

  loadFromEmail(String email) async {
    final documents = (await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments()).documents;

    if(documents.length > 0){
      final user = User.fromJson(documents[0].data);
      addUser(user.id, user);
      return user;
    }

    return null;
  }

  addUser(String key, User user) async {
    _userMap[key] = user;

    final documents = (await _firestore
        .collection('users')
        .where('id', isEqualTo: userID)
        .getDocuments()).documents;

    if(documents.length > 0){
      final docData = documents[0].data;
      docData['contacts'] = _userMap.keys.toList();
      _firestore.collection('users').document(documents[0].documentID).setData(docData);
    }
  }

  get userID => _user.id;

  getUsers(){

    final userList = _userMap.values.toList();
    userList.sort((u1, u2) => u1.name.toLowerCase().compareTo(u2.name.toLowerCase()));
    return userList;
  }

  login(email, password) async {
    try{
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);

      if(result.user != null){
        await _getUserData(result.user);
        await loadContacts(_contacts);
        return true;
      }
    }catch(e){
      return false;
    }

    return false;

  }

  sign(User user, String password) async {

    final result = await _auth.createUserWithEmailAndPassword(email: user.email, password: password);
    if(result.user != null){

      await _firestore.collection('users').document().setData({
        'id': result.user.uid,
        'name': user.name,
        'email': user.email,
        'contacts': []
      });

      await _getUserData(result.user);
      await loadContacts(_contacts);

      return true;

    }

    return false;
  }



  isLogged() async {

    return (await _auth.currentUser()) != null;

  }


  logout() async {
    _user = null;
    _contacts = [];
    _userMap = {};
    await _auth.signOut();
  }


}