import 'package:flutter/material.dart';
import 'package:timelist_journal/pages/sign_in_account_page.dart';
import 'create_account_page.dart';

// Opening Page
// Part of TIMELIST JOURNAL (by Logan Giese)

class OpeningPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Timelist Journal", style: Theme.of(context).textTheme.headline3),
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(
                child: Text('Create Account', style: Theme.of(context).accentTextTheme.button),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => CreateAccountPage())),
                color: Theme.of(context).accentColor,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                child: Text('Sign In', style: Theme.of(context).textTheme.button),
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => SignInAccountPage())),
              ),
            ],
          ),
        ],
      )
    );
  }
}
