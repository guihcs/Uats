

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whats_clone/bloc/chats_bloc.dart';
import 'package:whats_clone/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  Map _args;
  TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    _args = ModalRoute.of(context).settings.arguments;


    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/telback.jpg'),
          fit: BoxFit.cover
        )
      ),
      child: FutureBuilder(
        future: BlocProvider.getBloc<ChatBloc>().getChat(_args['user'].id),
        builder: (context, snap){
          if(snap.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(snap.data.user.name),
              ),
              body: _body(context, snap.data),
              backgroundColor: Colors.transparent,
            );
          }
          return Center(
            child: CircularProgressIndicator(
              value: null,
            ),
          );
        },
      )
    );
  }

  _body(context, chat) => Stack(

    children: <Widget>[
      _foreground(chat)
    ],
  );

  _foreground(chat) => Column(

    children: <Widget>[
      StreamBuilder(
        initialData: chat.messageBloc.initialData(),
        stream: chat.messageBloc.stream,
        builder: (context, snap){
          return Expanded(
            child: _list(snap.data),
          );
        },
      ),
      Container(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: _input(chat),
        ),
      )
    ],
  );

  _list(List<Message> messageList){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        reverse: true,
        itemCount: messageList.length,
        itemBuilder: (context, index){
          return _chatTile(context, messageList[index], index + 1  < messageList.length ? messageList[index +1] : null);
        },
      ),
    );
  }

  _fab(chat) => Container(
    height: 50.0,
    width: 50.0,
    child: FittedBox(
      child: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () {
          RegExp regex = RegExp(r'^\s*$');
          if(regex.hasMatch(_inputController.text)) return;
          setState(() {
            ChatBloc chatBloc = BlocProvider.getBloc<ChatBloc>();
            chatBloc.sendMessage(chat.user.id, _inputController.text);
            chat = BlocProvider.getBloc<ChatBloc>().getChat(chat.user.id);
            _inputController.clear();
          });
        }
      ),
    ),
  );

  _input(chat){
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: 'Type message...',
                    border: InputBorder.none
                  ),
                ),
              ),
            ),
          ),
          _fab(chat)
        ],
      ),
    );
  }

  _chatTile(context, Message message, Message lastMessage){
    final bubbleMaxWidth = MediaQuery.of(context).size.width * 0.8;
    final bubbleMinWidth = MediaQuery.of(context).size.width * 0.3;

    return Container(
      padding: EdgeInsets.only(top: 5.0),
      alignment: _getAlignment(message.isFromMe),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth:  bubbleMaxWidth, minWidth: bubbleMinWidth),
        child: Bubble(
          elevation: 0.8,
          nip: _getNip(message, lastMessage),
          color: message.isFromMe ? Colors.purple[100] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: _getColumnCrossAlignment(message.isFromMe),
              children: <Widget>[
                _message(message),
                _timestamp(message)
              ],
            ),
          ),
        ),
      )
    );
  }



  _message(Message message){
    return Container(
      //alignment: Alignment.centerLeft,
      child: Text(
        message.text,
        style: TextStyle(

          fontSize: 16
      ),),
    );
  }

  _timestamp(Message message) => Text(DateFormat('hh:mm a').format(message.time), style: TextStyle(
      fontSize: 12
  ),);

  _getNip(Message message, Message lastMessage){

    if(lastMessage == null){
      return message.isFromMe ? BubbleNip.rightTop : BubbleNip.leftTop;
    } else if(lastMessage.isFromMe != message.isFromMe){
      return message.isFromMe ? BubbleNip.rightTop : BubbleNip.leftTop;
    }

    return null;
  }


  _getAlignment(bool isFromMe) => isFromMe ? Alignment.centerRight : Alignment.centerLeft;
  _getColumnCrossAlignment(bool isFromMe) => isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
}

