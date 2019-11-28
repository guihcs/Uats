

class Message {

  String _id;
  String _data;
  bool _isFromMe;
  DateTime _dateTime;
  String _partnerID;

  Message({data, isFromMe, date, partnerID, id}){
    _id = id;
    _data = data;
    _isFromMe = isFromMe;
    _dateTime = date;
    _partnerID = partnerID;
  }

  get id => _id;
  get data => _data;
  get isFromMe => _isFromMe;
  get time => _dateTime;
  get partnerID => _partnerID;


  @override
  String toString() {
    return 'Message{_message: $_data, _isFromMe: $_isFromMe, _dateTime: $_dateTime}';
  }


}



