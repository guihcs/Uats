

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whats_clone/bloc/chats_bloc.dart';
import 'package:whats_clone/bloc/contacts_bloc.dart';
import 'package:whats_clone/controller/UserController.dart';
import 'package:whats_clone/pages/contact.dart';
import 'package:whats_clone/pages/chat.dart';
import 'package:whats_clone/pages/home.dart';
import 'package:whats_clone/pages/login.dart';
import 'package:whats_clone/pages/sign.dart';


void main() async {
  Intl.defaultLocale = 'en_US';
  UserController.getInstance();
  runApp(
    BlocProvider(
      blocs: [
        Bloc((i) => ChatBloc()),
        Bloc((i) => ContactsBloc())
      ],
      child: await _app()
    )
  );
}


_app() async => MaterialApp(
    title: 'Uats',
    initialRoute: await UserController.getInstance().isLogged() ? 'home' : 'login',
    routes: {
      'home': (context) => HomePage(),
      'chat': (context) => ChatPage(),
      'login': (context) => LoginPage(),
      'sign': (context) => SignPage(),
      'contact': (context) => ContactsPage()
    },


    theme: ThemeData(
        primaryColor: Colors.deepPurpleAccent[200],
        appBarTheme: AppBarTheme(
          color: Colors.deepPurpleAccent[200],
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.lightBlue[800],
          foregroundColor: Colors.white,
        )

    ),
  );
