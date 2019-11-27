

import 'dart:async';
import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:whats_clone/model/message.dart';

class MessageBloc extends BlocBase {

  StreamController _controller = StreamController<List<Message>>.broadcast();
  List<Message> _messageList = [];

  MessageBloc();

  MessageBloc.random(){
    _messageList = List.generate(Random().nextInt(15), (i) => Message.random());
    _controller.add(_messageList);
  }

  initialData() => _getList();

  get stream => _controller.stream;

  get lastMessage {
    if(_messageList.length > 0) return _messageList.last;
    return null;
  }

  addMessage(Message message){
    _messageList.add(message);
    _controller.add(_getList());
  }

  void refresh(){
    _controller.add(_getList());
  }


  _getList(){
    _messageList.sort((m1, m2) => m1.time.compareTo(m2.time));
    return _messageList.reversed.toList();
  }

  @override
  void dispose(){
    super.dispose();
    _controller.close();
  }
}