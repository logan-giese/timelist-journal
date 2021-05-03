import 'package:flutter/material.dart';
import '../services/service_controller.dart';
import '../utils/string_validator.dart';
import 'home_page.dart';

// Sign In Page
// Part of TIMELIST JOURNAL (by Logan Giese)

class SignInAccountPage extends StatefulWidget {
  @override
  _SignInAccountPageState createState() => _SignInAccountPageState();
}

class _SignInAccountPageState extends State<SignInAccountPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _pwController = TextEditingController();

  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage, style: TextStyle(color: Colors.red),), // Error message
              TextFormField(
                controller: _emailController,
                validator: validateEmailAddress,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _pwController,
                validator: validatePassword,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              RaisedButton(
                child: Text('Sign In', style: Theme.of(context).accentTextTheme.button),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    String errText = await ServiceController.signIn(_emailController.text, _pwController.text);
                    if (errText != null) {
                      setState(() {
                        _errorMessage = errText;
                      });
                    } else {
                      // Signed in successfully
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
                    }
                  }
                },
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }
}
