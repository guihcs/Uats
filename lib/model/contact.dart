

class Contact {
  String _id;
  String _name;
  String _email;

  Contact(this._id, this._name, this._email);

  get name => _name;
  get id => _id;
  get email => _email;

  Contact.fromData(Map<String, dynamic> values){
    _id = values['id'];
    _name = values['name'];
    _email = values['email'];
  }

  @override
  String toString() {
    return 'User{_id: $_id, _name: $_name, _email: $_email}';
  }


}