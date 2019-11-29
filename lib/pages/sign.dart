

import 'package:flutter/material.dart';
import 'package:whats_clone/controller/auth_controller.dart';


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
  bool _isLoading = false;
  bool _signError = false;

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
              if(!emailExp.hasMatch(text)) return 'Email inválido.';
              else if(_signError) return 'Este email já está sendo usado.';
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

            validator: (text){
              if(text.length < 6) return 'A senha deve conter no mínimo 6 caracteres.';
              return null;
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
      _isLoading = true;
    });

    if(_key.currentState.validate()){
      final userData = <String, dynamic>{
        'email': _emailField.text,
        'password': _passwordField.text,
        'name': _nameField.text
      };

      try{
        await Auth.getInstance().sign(userData);

        Navigator.of(context).pushNamedAndRemoveUntil('home', (route) => false);
      }catch(e){
        print(e);
        setState(() {
          _signError = true;
          _isLoading = false;
          _key.currentState.validate();
          _signError = false;
        });
      }


    }else {
      setState(() {
        _signError = true;
        _isLoading = false;
        _key.currentState.validate();
        _signError = false;
      });
    }
  }
}
