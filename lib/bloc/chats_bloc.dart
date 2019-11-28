import 'dart:async';

import 'package:whats_clone/model/chat.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:whats_clone/model/contact.dart';
import 'package:whats_clone/model/message.dart';
import 'package:whats_clone/provider/contacts_provider.dart';
import 'package:whats_clone/provider/message_provider.dart';


class ChatBloc extends BlocBase{

  StreamController _controller = StreamController.broadcast();

  ContactProvider _contactProvider;
  MessageProvider _messageProvider;

  Map<String, Chat> _chatMap;
  bool _isLoading = false;
  bool _initialized = false;

  initialize(){
    if(!_initialized) {
      _contactProvider = ContactProvider.getInstance();
      _messageProvider = MessageProvider.getInstance();
      _initialized = true;
      _messageProvider.onData((List<Message> messages) async {
        if(_chatMap == null) _chatMap = {};
        for (var message in messages) {
          final contact = await _contactProvider.getContact(message.partnerID);
          Chat chat = startChat(contact);
          chat.addMessage(message);
        }

        refresh();
      });
    }
  }

  initialData() {
    if(_chatMap == null){
      if(!_isLoading){
        _isLoading = true;
        Future.microtask(() async {
          final messages = await _messageProvider.loadAll();
          if(_chatMap == null) _chatMap = {};
          for (Message message in messages) {
            final contact = await _contactProvider.getContact(message.partnerID);
            Chat chat = startChat(contact);
            chat.addMessage(message);
          }

          refresh();
          _isLoading = false;
        });
      }


      return null;
    }

    return _getList();
  }


  sendMessage(contactID, messageData){

    Message message = Message(
      date: DateTime.now(),
      data: messageData['data'],
      isFromMe: true,
      partnerID: contactID
    );

    _messageProvider.send(contactID, message);
  }

  startChat(Contact contact){
    if(_chatMap == null) initialData();
    if(!_chatMap.containsKey(contact.id)) _chatMap[contact.id] = Chat(contact);
    return _chatMap[contact.id];
  }

  get stream => _controller.stream;

  refresh() => _controller.add(_getList());

  _getList(){
    if(_chatMap == null) return null;
    final list = <Chat>[];
    list.addAll(_chatMap.values.toList());

    if(list.length > 0) list.sort((c1, c2){
      if(c1.lastMessage == null && c2.lastMessage != null) return -1;
      else if(c2.lastMessage == null && c1.lastMessage != null) return 1;
      else if(c1.lastMessage == null && c2.lastMessage == null) return 0;

      return -c1.lastMessage.time.compareTo(c2.lastMessage.time);
    });
    return list;
  }

  close(){
    _chatMap = null;
    _initialized = false;
  }

  @override
  void dispose(){
    super.dispose();
    _controller.close();

  }
}
