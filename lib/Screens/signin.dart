import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:starsky/apis/api.dart';
// import 'package:rest_app/screens/signin.dart';

import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  GoogleSignInAccount? current_user;
  final fb = FacebookLogin();

  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? password;
  bool isLoading = false;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var reg = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  GoogleSignIn? _googleSignIn;
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    // getPref();
    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                    new AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
                    : Stack(children: <Widget>[
                  Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                                child: Image.asset(
                                  "assets/images/giraffe.png",
                                  height: 200,
                                  width: 200,
                                  alignment: Alignment.center,
                                )),
                            SizedBox(
                              height: 32,
                            ),
                            InkWell(
                              onTap: () {
                                signIn();
                                // print(_currentUser)   ;
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child:
                                Image.asset('assets/images/google.jpeg'),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            InkWell(
                              onTap: () {

                                signInfb();
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child:
                                Image.asset('assets/images/facebook.png'),
                              ),
                            ),
                          ]))
                ]))));
  }

  Future signIn() async {
    current_user = await GoogleSignInApi.login();
    if (current_user == null) {
    } else {
      signup(current_user!.displayName, current_user!.email);
    }
  }

  Future signInfb() async {
    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);

    switch (res.status) {
      case FacebookLoginStatus.success:
      // Logged in

      // Get profile data
        final profile = await fb.getUserProfile();


        // Get email (since we request email permission)
        final email = await fb.getUserEmail();
        signup(profile!.name, email);

        break;
    }
  }

  signup(name, email) async {
    setState(() {
      isLoading = true;
    });
    print("Calling");

    Map data = {'email': email, 'fullname': name};
    // print(data.toString());
    final response = await http.post(Uri.parse(URL_REGISTRATION),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: data,
        encoding: Encoding.getByName("utf-8"));

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      Map<String, dynamic> resposne = jsonDecode(response.body);
      if (!resposne['error']) {
        Map<String, dynamic> user = resposne['user'];
        //print(" User name ${user['data']}");
        savePref(1, name, email, user['user_id']);
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        // _scaffoldKey.currentState.showSnackBar(SnackBar(content:Text("${resposne['message']}")));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${resposne['error_msg']}")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please try again")));
    }
  }

  savePref(int value, String name, String email, int id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setInt("value", value);
    preferences.setString("name", name);
    preferences.setString("email", email);
    preferences.setString("id", id.toString());
    //preferences.commit();
  }
}

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();
  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
}
