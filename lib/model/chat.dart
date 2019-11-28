

import 'package:whats_clone/bloc/message_bloc.dart';

import 'contact.dart';
import 'message.dart';

class Chat {

  Contact _contact;
  MessageBloc _messageBloc;

  Chat(this._contact){
    _messageBloc = MessageBloc();
  }


  MessageBloc get messageBloc => _messageBloc;
  get contact => _contact;



  addMessage(Message message){
    _messageBloc.addMessage(message);
  }

  get lastMessage => messageBloc.lastMessage;
}
