import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:starsky/Screens/signin.dart';
import 'package:starsky/Screens/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>  {
  // This widget is the root of your application.

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Auth',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ),
        routes: <String, WidgetBuilder>{
          '/home': (BuildContext context) => new Home(),

        },
        home: (_loginStatus==1)?Home():Signin()

    );
  }

  int _loginStatus = 0 ;
  // bool _isLoading = true ;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _loginStatus = preferences.getInt("value")!;
      // _isLoading = false ;


    });
  }


}
