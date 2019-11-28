

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whats_clone/controller/auth_controller.dart';
import 'package:whats_clone/model/message.dart';

class MessageProvider {

  static MessageProvider _instance;

  final Firestore _firestore = Firestore.instance;
  Auth _auth = Auth.getInstance();

  List<Function> _callbacks = [];
  StreamSubscription subTo, subFrom;


  static getInstance() {

    if(_instance == null) {
      _instance = MessageProvider();
      _instance._initialize();
    }

    return _instance;
  }

  _initialize() async {
    final userID = (await _auth.getCurrentUser()).id;

    subTo = _firestore.collection('messages').where('to', isEqualTo: userID).snapshots().listen((snap){

      for (var call in _callbacks) {
        call(_load(userID, snap.documents));
      }
    });

    subFrom = _firestore.collection('messages').where('from', isEqualTo: userID).snapshots().listen((snap){
      for (var call in _callbacks) {
        call(_load(userID, snap.documents));
      }
    });
  }

  onData(callback){
    _callbacks.add(callback);
  }

  send(id, Message message) async {

    final userID = (await _auth.getCurrentUser()).id;

    final data = {
      'time': DateTime.now().toIso8601String(),
      'to': message.isFromMe ? id : userID,
      'from': message.isFromMe ? userID : id,
      'data': message.data
    };

    await _firestore.collection('messages').document().setData(data);

  }

  loadAll() async {

    final userID = (await _auth.getCurrentUser()).id;

    final snap1 = await _firestore.collection('messages').where('to', isEqualTo: userID).getDocuments();
    final snap2 = await _firestore.collection('messages').where('from', isEqualTo: userID).getDocuments();
    final documents = [];

    documents.addAll(snap1.documents);
    documents.addAll(snap2.documents);

    return _load(userID, documents);
  }




  List<Message> _load(userID, documents){
    final result = <Message>[];

    for (var document in documents) {
      final data = document.data;

      final id = document.documentID;
      final isFromMe = data['from'] == userID;
      final time = DateTime.parse(data['time']);
      final partnerID = isFromMe ? data['to'] : data['from'];
      final messageData = data['data'];

      result.add(Message(
          id: id,
          isFromMe: isFromMe,
          data: messageData,
          date: time,
          partnerID: partnerID
      ));

    }


    return result;
  }




  close(){
    subTo.cancel();
    subFrom.cancel();

    _callbacks = [];
    _instance = null;
  }


}