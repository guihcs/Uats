

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:whats_clone/bloc/chats_bloc.dart';
import 'package:whats_clone/controller/UserController.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _key = GlobalKey<FormState>();

  final TextEditingController _emailField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _loginFail = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 50,
              child: _body(context),
            )
        ),
      ),
    );
  }

  _body(context) => Form(
    key: _key,
    child: Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.asset('assets/images/Uats_Logo.png', width: 140, height: 140,)
          ),
          Text('Uats', style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pacifico'
          ),),
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
              _login();
            },
            validator: (text) {
              if(_loginFail) return 'Email ou Senha inválidos.';
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 26.0),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0)
              ),
              onPressed: () async {
                if(!_isLoading) _login();
              },
              child: !_isLoading ? Padding(
                padding: EdgeInsets.all(12.0),
                child: Text('Entrar', style: TextStyle(
                  color: Colors.white
                ),),
              ) : _progressIndicator(),
            ),
          ),
          RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0)
            ),
            onPressed: !_isLoading ? (){
              Navigator.of(context).pushNamed('sign');
            } : null,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text('Cadastrar'),
            ),
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

  _login() async {
    setState(() {
      _loginFail = false;
      _isLoading = true;
    });

    if(await (await UserController.getInstance()).login(_emailField.text, _passwordField.text)){

      await UserController.getInstance();
      Navigator.of(context).pushNamedAndRemoveUntil('home', (route) => false);
    }else {
      setState(() {
        _loginFail = true;
        _isLoading = false;
        _key.currentState.validate();
      });
    }
  }
}
