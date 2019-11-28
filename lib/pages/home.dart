

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whats_clone/bloc/chats_bloc.dart';
import 'package:whats_clone/controller/auth_controller.dart';
import 'package:whats_clone/model/chat.dart';
import 'package:whats_clone/provider/contacts_provider.dart';
import 'package:whats_clone/provider/message_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BlocProvider.getBloc<ChatBloc>().initialize();
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
        onPressed: () async {
          final contact = await Navigator.of(context).pushNamed('contact');

          if(contact == null) return;

          final chat = BlocProvider.getBloc<ChatBloc>().startChat(contact);
          Navigator.of(context).pushNamed('chat', arguments: {
            'chat': chat
          });
        },
      ),
    );
  }

  _logout(context) async {

    BlocProvider.getBloc<ChatBloc>().close();
    MessageProvider.getInstance().close();
    ContactProvider.getInstance().close();

    await Auth.getInstance().logout();
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

    return StreamBuilder(
      initialData: BlocProvider.getBloc<ChatBloc>().initialData(),
      stream: BlocProvider.getBloc<ChatBloc>().stream,
      builder: (context, snap){

        if(snap.hasData) {
          if(snap.data.length > 0) return _buildList(snap.data);
          else return _emptyChat();
        }


        return Center(
          child: CircularProgressIndicator(
            value: null,
          ),
        );
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
          'chat': chat
        });
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Text(chat.contact.name[0]),
        ),
        title: Text(chat.contact.name),
        subtitle: Text(chat.lastMessage.data ?? '', overflow: TextOverflow.ellipsis
          ,),
        trailing: Text(DateFormat('hh:mm a').format(chat.lastMessage.time), style: TextStyle(
          fontSize: 12
        ),),

      ),
    );
  }
}