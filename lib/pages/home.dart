

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whats_clone/bloc/chats_bloc.dart';
import 'package:whats_clone/controller/UserController.dart';
import 'package:whats_clone/model/message.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Uats'),
        actions: _actions(context),
      ),
      body: _body(context),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue[800],
        foregroundColor: Colors.white,
        child: Icon(Icons.message),
        onPressed: (){

          Navigator.of(context).pushNamed('contact');
        },
      ),
    );
  }

  _logout(context) async {
    BlocProvider.getBloc<ChatBloc>().clearListeners();
    await UserController.getInstance().logout();
    Navigator.of(context).pushReplacementNamed('login');
  }


  _actions(context) => <Widget>[
    PopupMenuButton(
      icon: Icon(Icons.more_vert),
      onSelected: (value) async {
        await _logout(context);
      },

      itemBuilder: (context) => <PopupMenuEntry<String>>[
        PopupMenuItem(
          value: 'logout',
          child: Text('Sair'),
        )
      ]
    )
  ];

  _body(context){

    final chatBloc = BlocProvider.getBloc<ChatBloc>();
    return StreamBuilder(
      initialData: chatBloc.initialData(),
      stream: chatBloc.stream,
      builder: (context, snap){

        if(snap.hasData) {
          return _buildList(snap.data);
        }

        return Container();
      },
    );
  }


  _emptyChat(){
    return Column(

      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Image.asset('assets/images/emptyback.png'),
        ),
        Text('Sem mensagens por aqui...', textAlign: TextAlign.center, style: TextStyle(
            fontSize: 28
        ),),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Adicione contatos para enviar mensagens.', textAlign: TextAlign.center, style: TextStyle(
              fontSize: 18
          ),),
        ),


      ],
    );
  }


  _buildList(List<Chat> chatList){

    return ListView.separated(
      separatorBuilder: (context, index){
        return Divider(
          indent: 70,
          endIndent: 16,
          height: 5,
          color: Colors.black26,
          thickness: 0.8,
        );
      },
      itemCount: chatList.length,
      itemBuilder: (context, index){
        return _chatTile(context, chatList[index]);
      },
    );
  }


  _chatTile(context, Chat chat){

    return InkWell(
      onTap: (){
        Navigator.of(context).pushNamed('chat', arguments: {
          'user': chat.user
        });
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Text(chat.user.name[0]),
        ),
        title: Text(chat.user.name),
        subtitle: Text(chat.lastMessage.text ?? '', overflow: TextOverflow.ellipsis
          ,),
        trailing: Text(DateFormat('hh:mm a').format(chat.lastMessage.time), style: TextStyle(
          fontSize: 12
        ),),

      ),
    );
  }
}