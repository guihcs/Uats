


import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:whats_clone/model/contact.dart';
import 'package:whats_clone/provider/contacts_provider.dart';

class ContactsBloc extends BlocBase {

  StreamController _controller = StreamController<List<Contact>>.broadcast();
  ContactProvider _contactProvider = ContactProvider.getInstance();

  initialData(){
    Future.microtask(() async {
      final contacts = await _contactProvider.getContacts();
      _controller.add(contacts);
    });
    return null;
  }

  get stream => _controller.stream;

  findUser(String email) async {
    return await _contactProvider.findContact(email);
  }

  @override
  void dispose(){
    super.dispose();
    _controller.close();
  }
}