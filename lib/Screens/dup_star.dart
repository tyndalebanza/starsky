import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:starsky/apis/api.dart';

class dup_star extends StatefulWidget {
  const dup_star({Key? key}) : super(key: key);

  @override
  State<dup_star> createState() => _dup_starState();
}

class _dup_starState extends State<dup_star> {
  String? user_id;

  String? username;

  String? podcast_id;

  // At the beginning, we fetch the first 20 posts
  int _page = 1;

  // There is next page or not
  bool _hasNextPage = true;

  // Used to display loading indicators when _firstLoad function is running
  bool _isFirstLoadRunning = false;

  // Used to display loading indicators when _loadMore function is running
  bool _isLoadMoreRunning = false;

  // This holds the posts fetched from the server
  List _posts = [];

  String? star_name;

  // The controller for the ListView
  late ScrollController _controller;

  void _firstLoad() async {
    setState(() {
      _isFirstLoadRunning = true;
    });
    try {
      final res = await http.get(Uri.parse(URL_GET_DUPLICATE_STAR +
          "?page=" +
          _page.toString() +
          "&star=" +
          star_name!));
      setState(() {
        var response = json.decode(res.body);
        _posts = response;
      });
      // print(_posts);
    } catch (err) {
      print(err.toString());
    }

    setState(() {
      _isFirstLoadRunning = false;
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;

      star_name = arguments['star_name'];

      _firstLoad();
    });

    _controller = new ScrollController()..addListener(_loadMore);
  }

  @override
  void dispose() {
    _controller.removeListener(_loadMore);
    super.dispose();
  }

  void _loadMore() async {
    if (_hasNextPage == true &&
        _isFirstLoadRunning == false &&
        _isLoadMoreRunning == false &&
        _controller.position.extentAfter < 300) {
      setState(() {
        _isLoadMoreRunning = true; // Display a progress indicator at the bottom
      });
      _page += 1; // Increase _page by 1
      try {
        final res = await http.get(Uri.parse(URL_GET_DUPLICATE_STAR +
            "?page=" +
            _page.toString() +
            "&star=" +
            star_name!));
        var response = json.decode(res.body);
        final List fetchedPosts = response;
        if (fetchedPosts.length > 0) {
          setState(() {
            _posts.clear();
            _posts.addAll(fetchedPosts);
          });
        } else {
          // This means there is no more data
          // and therefore, we will not send another GET request
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch (err) {
        print('Something went wrong!');
      }

      setState(() {
        _isLoadMoreRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //final  Map<String, Object>rcvdData = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: _isFirstLoadRunning
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 0.0, top: 24.0),
            child: cancelSection,
          ),
          SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: messageSection(),
          ),
          SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView.builder(

              controller: _controller,
              itemCount: _posts.length,
              itemBuilder: (_, index) => GestureDetector(
                onTap: () {
                  // Navigator.pushReplacementNamed(context, "/star_home", arguments: {'star_id':_posts[index]['star_id']});
                },
                child: Card(
                  margin: EdgeInsets.all(10),
                  child: Column(children: [
                    starSection(index),
                    SizedBox(
                      height: 10,
                    )
                  ]),
                ),
              ),
            ),
          ),

          // when the _loadMore function is running
          if (_isLoadMoreRunning == true)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 40),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                  new AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
            ),

          // When nothing else to load
        ],
      ),
    );
  }

  Widget cancelSection = Row(
    mainAxisAlignment: MainAxisAlignment.start,
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
    ],
  );

  Widget messageSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              textAlign: TextAlign.center,
              'Please select from the list below.',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget submitSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
            child: Stack(children: [
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: InkWell(
                  onTap: () {
                    //Navigator.pushReplacementNamed(context, "/province",arguments: {"village_name" :
                   // village_name});
                  },
                  child: Text(
                    "ADD NEW VILLAGE",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                            color: Colors.white, fontSize: 16, letterSpacing: 1)),
                  ),
                ),
              ),
              // Positioned(child: (isLoading)?Center(child: Container(height:26,width: 26,child: CircularProgressIndicator(backgroundColor: Colors.grey,valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),))):Container(),right: 30,bottom: 0,top: 0,),
            ])),
      ],
    );
  }

  Widget starSection(index) {
    return Row(children: [
      Expanded (
        flex:1,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: _posts[index]['image'] != null
                ? Image.network(_posts[index]['image'],
                width: 100, height: 100, fit: BoxFit.cover)
                : Image.asset('assets/images/camera.png')),
      ),
      Expanded (
        flex:2 ,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                _posts[index]['star_name'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
          ],
        ),
      )
    ]);
  }
}
