import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whats_clone/controller/UserController.dart';
import 'package:whats_clone/model/message.dart';
import 'package:bloc_pattern/bloc_pattern.dart';


class ChatBloc extends BlocBase{

  UserController _userController;
  StreamController _controller;
  Map<String, Chat> _chatMap = {};
  Firestore _firestore = Firestore.instance;

  StreamSubscription _inSubscription, _outSubscription;
  bool _loaded = false;

  ChatBloc(){
    _userController = UserController.getInstance();
    _controller = StreamController<List<Chat>>.broadcast();
    _chatMap = {};
  }

  startupLoad() async {

    _userController = UserController.getInstance();
    _controller = StreamController<List<Chat>>.broadcast();
    _chatMap = {};

    if(!_loaded) {
      final inDocs = (await Firestore.instance.collection('messages')
          .where('to', isEqualTo: _userController.userID).getDocuments())
          .documents;

      final outDocs = (await Firestore.instance.collection('messages')
          .where('from', isEqualTo: _userController.userID).getDocuments())
          .documents;

      for (var doc in inDocs) {
        await _addStartupMessage(doc.data);
      }

      for (var doc in outDocs) {
        await _addStartupMessage(doc.data);
      }

      _loaded = true;

      _setupListeners();
    }
  }


  _addStartupMessage(Map data) async {

    final date = DateTime.parse(data['time']);

    bool isFromMe = data['from'] == _userController.userID;
    String userID = isFromMe ? data['to'] : data['from'];

    Message message = Message(data['text'], isFromMe, date);
    await addMessage(userID, message);
  }
  
  _setupListeners() async {
    try{
      _inSubscription = Firestore.instance.collection('messages')
      .where('to', isEqualTo: _userController.userID).
      snapshots().listen(_onData);

      _outSubscription = Firestore.instance.collection('messages')
      .where('from', isEqualTo: _userController.userID).
      snapshots().listen(_onData);

    }catch(e){
      print(e);
    }
  }

  clearListeners() {
    _inSubscription?.cancel();
    _outSubscription?.cancel();
    _loaded = false;
  }

  _onData(QuerySnapshot snap){
    for (var doc in snap.documents) {

      final data = doc.data;

      final date = DateTime.parse(data['time']);

      bool isFromMe = data['from'] == _userController.userID;
      String userID = isFromMe ? data['to'] : data['from'];



      if(_chatMap[userID] != null &&
          _chatMap[userID].lastMessage != null &&
          _chatMap[userID].lastMessage.time.compareTo(date) >= 0) continue;

      Message message = Message(data['text'], isFromMe, date);
      addMessage(userID, message);
    }

    _controller.add(_getList());
  }

  _getList(){
    final chatList = _chatMap.values.toList();
    chatList.sort((c1, c2) => -1 * c1.lastMessage.time.compareTo(c2.lastMessage.time));
    return chatList;
  }

  initialData() => _getList();

  get stream => _controller.stream;

  addMessage(String userID, Message message) async {

    if(_chatMap.containsKey(userID)){
      _chatMap[userID].addMessage(message);
    }else {
      User user = await _userController.getContact(userID);
      _chatMap[userID] = Chat(user);
      _chatMap[userID].addMessage(message);
      _controller.add(_getList());
    }
  }

  sendMessage(String userID, String text){


    _firestore.collection('messages').document().setData({
      'to': userID,
      'from': _userController.userID,
      'text': text,
      'time': DateTime.now().toIso8601String()
    });
//    addMessage(userID, message);
  }

  refresh(user) async {
    _controller.add(_getList());
    _chatMap[user].refresh();

  }
  
  getChat(user) async {
    if(_chatMap.containsKey(user)){
      
      Future.delayed(Duration(milliseconds: 200), (){
        refresh(user);
      });
      
      return _chatMap[user];
    }else {
      return Chat(await _userController.getContact(user));
    }
  }

  @override
  void dispose(){
    super.dispose();
    _controller.close();

  }
}
