


import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:whats_clone/controller/UserController.dart';
import 'package:whats_clone/model/message.dart';

class ContactsBloc extends BlocBase {

  StreamController _controller = StreamController<List<User>>.broadcast();
  UserController _userController = UserController.getInstance();

  initialData() => _userController.getUsers();

  get stream => _controller.stream;

  findUser(String email) async {
    return await _userController.loadFromEmail(email);
  }

  @override
  void dispose(){
    super.dispose();
    _controller.close();
  }
}