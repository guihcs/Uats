

class AuthUser {
  String _id;
  String _name;
  String _email;
  List<dynamic> _contacts;

  get name => _name;
  get id => _id;
  get email => _email;
  get contacts => _contacts;

  AuthUser.fromData(Map<String, dynamic> values){
    final list = [];
    list.addAll(values['contacts']);
    _id = values['id'];
    _name = values['name'];
    _email = values['email'];
    _contacts = list;
  }

  toData() => {
    'id': id,
    'name': name,
    'email': email,
    'contacts': contacts
  };


  @override
  String toString() {
    return 'User{_id: $_id, _name: $_name, _email: $_email}';
  }
}