import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:starsky/apis/api.dart';

class new_star extends StatefulWidget {
  const new_star({Key? key}) : super(key: key);

  @override
  State<new_star> createState() => _new_starState();
}

class _new_starState extends State<new_star> {
  final nameController = TextEditingController();
  bool isLoading = false;

  List _posts = [];

  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoading
              ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                  )))
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 0.0, top: 24.0),
                child: cancelSection(),
              ),
              SizedBox(
                height: 16,
              ),
              nameSection(),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cancelSection() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          return IconButton(
            icon: Icon(Icons.close),
            iconSize: 36,
            onPressed: () {
              Navigator.pop(context);
            },
          );
        }),
        Text(
          'Name of Star',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          iconSize: 36,
          onPressed: () {
            if (nameController.text.isEmpty) {
              // _scaffoldKey.currentState!.showSnackBar(SnackBar(content:Text("Please Enter User Name")));
              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                  content: Text("Please enter the name of the Star")));
              return;
            }
            checkDuplicate(nameController.text);
          },
        ),
      ],
    );
  }

  Widget nameSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              maxLines: null,
              maxLength: 100,
              decoration: InputDecoration(
                counterText: '',
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red)),
                border: OutlineInputBorder(),
                hintText: 'Enter the name of the Star',
              ),
            ),
          ),
        ),
      ],
    );
  }

  checkDuplicate(starname) async
  {
    setState(() {
      isLoading = true;
    });

    try {

      final res =
      await http.get(Uri.parse(URL_GET_DUPLICATE_STAR + "?page=1&star=" + starname));
      setState(() {
        var response = json.decode(res.body);
        _posts = response;
      });
    } catch (err) {
      print(err.toString());

    }

    if (_posts.length == 0) {
      postStar(starname);
      //Navigator.pushReplacementNamed(context, "/newstarhome",arguments: {"star_name" :
      //starname});

    } else {
      Navigator.pushReplacementNamed(context, "/dup_star",arguments: {"star_name" :
      starname});
    }

  }

  postStar(star_name) async
  {
    setState(() {
      isLoading = true;
    });

    Map data = {
      'star_name': star_name
    };
    // print(data.toString());
    final response = await http.post(
        Uri.parse(URL_POST_STAR),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded"
        },


        body: data,
        encoding: Encoding.getByName("utf-8")
    );

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      Map<String, dynamic>resposne = jsonDecode(response.body);
      if (!resposne['error']) {
        Map<String, dynamic>star = resposne['result'];
        print(star['star_id']);
        // Navigator.pushReplacementNamed(context, "/star_home", arguments: {'star_id':star['star_id']});

      } else {
        // _scaffoldKey.currentState.showSnackBar(SnackBar(content:Text("${resposne['message']}")));
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${resposne['error_msg']}")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please try again")));
    }
  }


}
