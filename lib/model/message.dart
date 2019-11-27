
import 'dart:math';

import 'package:whats_clone/bloc/message_bloc.dart';

class Message {

  String _message;
  bool _isFromMe;
  DateTime _dateTime;

  Message(this._message, this._isFromMe, this._dateTime);

  get text => _message;
  get isFromMe => _isFromMe;
  get time => _dateTime;

  Message.random(){
    _message = 'Random message: ${Random().nextInt(15)}';
    _isFromMe = Random().nextBool();
  }

  @override
  String toString() {
    return 'Message{_message: $_message, _isFromMe: $_isFromMe, _dateTime: $_dateTime}';
  }


}


class Chat {
  
  User _user;
  MessageBloc _messageBloc;

  Chat(this._user){
    _messageBloc = MessageBloc();
  }

  Chat.random(){
    _user = User.random();   
    _messageBloc = MessageBloc.random();    
  }

  MessageBloc get messageBloc => _messageBloc;
  get user => _user;

  

  addMessage(Message message){
    _messageBloc.addMessage(message);
  }

  refresh() async {
    _messageBloc.refresh();
  }

  get lastMessage => messageBloc.lastMessage;
}

class User {
  String _id;
  String _name;
  String _email;

  User(this._id, this._name, this._email);

  get name => _name;
  get id => _id;
  get email => _email;

  User.fromJson(Map<String, dynamic> values){
    _id = values['id'];
    _name = values['name'];
    _email = values['email'];
  }

  User.random(){
    _name = 'Cleiton ${Random().nextInt(15)}';
  }

  @override
  String toString() {
    return 'User{_id: $_id, _name: $_name, _email: $_email}';
  }


}