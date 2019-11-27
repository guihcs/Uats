

import 'package:flutter/material.dart';
import 'package:whats_clone/controller/UserController.dart';
import 'package:whats_clone/model/message.dart';


class SignPage extends StatefulWidget {
  @override
  _SignPageState createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  final _key = GlobalKey<FormState>();

  final TextEditingController _nameField = TextEditingController();
  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _loginFail = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _appBar(context),
      body: SingleChildScrollView(
          child: Container(
              height: MediaQuery.of(context).size.height - 180,
              child: _body(context)
          )
      ),
    );
  }


  _appBar(context) => AppBar(
    title: Text('Cadastrar'),
  );

  _body(context) => Form(
    key: _key,
    child: Padding(
      padding: const EdgeInsets.only(left: 26.0, right: 26.0, bottom: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[

          TextFormField(
            enabled: !_isLoading,
            controller: _nameField,
            focusNode: _nameFocus,
            decoration: InputDecoration(
              labelText: 'Nome'
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (text){
              _nameFocus.unfocus();
              FocusScope.of(context).requestFocus(_emailFocus);
            },
          ),
          TextFormField(
            enabled: !_isLoading,
            controller: _emailField,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email'
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (text){
              _emailFocus.unfocus();
              FocusScope.of(context).requestFocus(_passwordFocus);
            },
            validator: (text){
              RegExp emailExp = RegExp(r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
              if(!emailExp.hasMatch(text)) return 'Email must be valid';
              return null;
            },
          ),
          TextFormField(
            enabled: !_isLoading,
            controller: _passwordField,
            focusNode: _passwordFocus,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Senha',
              suffixIcon: InkWell(
                onTap: (){
                  setState(() {

                    _obscurePassword = !_obscurePassword;
                  });
                },
                child: Icon(Icons.remove_red_eye),
              )
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (text){
              _submit();
            },
          ),

          RaisedButton(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: !_isLoading ? Text('Confirmar') : _progressIndicator(),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0)
            ),
            onPressed: () {
              _submit();
            },
          )
        ],
      ),
    ),
  );


  _progressIndicator() => SizedBox(
    width: 15,
    height: 15,
    child: CircularProgressIndicator(
      value: null,
    ),
  );


  _submit() async {
    setState(() {
      _loginFail = false;
      _isLoading = true;
    });
    if(_key.currentState.validate()){
      User user = User(null, _nameField.text, _emailField.text);
      if(await UserController.getInstance().sign(user, _passwordField.text)){

        Navigator.of(context).pushNamedAndRemoveUntil('home', (route) => false);
      }
    }else {
      setState(() {
        _loginFail = true;
        _isLoading = false;
        _key.currentState.validate();
      });
    }
  }
}
