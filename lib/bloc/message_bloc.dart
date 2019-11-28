

import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:whats_clone/model/message.dart';

class MessageBloc extends BlocBase {

  StreamController _controller = StreamController<List<Message>>.broadcast();
  Map<String, Message> _messageMap = {};
  Message _lastMessage;


  initialData() => _getList();

  get stream => _controller.stream;

  get lastMessage {
    return _lastMessage;
  }

  addMessage(Message message){
    if(lastMessage == null || lastMessage.time.compareTo(message.time) < 0) _lastMessage = message;

    if(_messageMap.containsKey(message.id)) return;

    _messageMap[message.id] = message;
    _controller.add(_getList());
  }


  _getList(){
    final messageList = _messageMap.values.toList();
    messageList.sort((m1, m2) => -m1.time.compareTo(m2.time));
    return messageList;
  }

  @override
  void dispose(){
    super.dispose();
    _controller.close();
  }
}