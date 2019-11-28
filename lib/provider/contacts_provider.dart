

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whats_clone/controller/auth_controller.dart';
import 'package:whats_clone/model/contact.dart';

class ContactProvider {


  static ContactProvider _instance;

  final Firestore _firestore = Firestore.instance;
  Auth _auth = Auth.getInstance();

  Map<String, Contact> _contactMap;
  List<Function> callbacks = [];

  static getInstance(){
    if(_instance == null) _instance = ContactProvider();
    return _instance;
  }

  onData(callback){
    callbacks.add(callback);
  }

  findContact(email) async {
    await _solveContacts();
    for (var contact in _contactMap.values) {
      if(contact.email == email) return contact;
    }

    final contact = await _loadContact('email', email);
    _contactMap[contact.id] = contact;
    return contact;
  }

  ///find contact and if exists add
  getContact(id) async {
    await _solveContacts();
    if(_contactMap.containsKey(id)){
      return _contactMap[id];
    } else {
      final contact = await _loadContact('id', id);

      if(contact != null){
        _contactMap[contact.id] = contact;
        return contact;
      }

      return null;
    }
  }

  getContacts() async {
    await _solveContacts();
    final contactList = _contactMap.values.toList();

    contactList.sort((c1, c2) => c1.name.toLowerCase().compareTo(c2.name.toLowerCase()));
    return contactList;
  }

  close(){
    _clear();
  }

  _solveContacts() async {
    if(_contactMap == null) _contactMap = await _loadContacts();
    else {
      final user = await _auth.getCurrentUser();
      if (user.contacts.length != _contactMap.length) _contactMap = await _loadContacts();
    }
  }

  _loadContact(key, value) async {
    final snap = await _firestore.collection('users').where(key, isEqualTo: value).getDocuments();

    if(snap.documents.length <= 0) return null;
    _updateContacts(snap.documents[0].data['id']);
    return Contact.fromData(snap.documents[0].data);
  }

  _loadContacts() async {
    final loadedContacts = Map<String, Contact>();

    final user = await _auth.getCurrentUser();

    final contacts = List.from(user.contacts);

    for (final id in contacts) {
      final snap = await _firestore.collection('users').where('id', isEqualTo: id).getDocuments();
      if(snap.documents.length <= 0) continue;

      final contact = Contact.fromData(snap.documents[0].data);

      loadedContacts[contact.id] = contact;
    }

    return loadedContacts;
  }

  _updateContacts(contactID) async {
    final user = await _auth.getCurrentUser();
    final snap = await _firestore.collection('users').where('id', isEqualTo: user.id).getDocuments();

    if(snap.documents.length <= 0) return;

    user.contacts.add(contactID);

    _firestore.collection('users').document(snap.documents[0].documentID).setData(user.toData());

  }

  _clear(){
    _contactMap = null;

    _instance = null;
  }



}