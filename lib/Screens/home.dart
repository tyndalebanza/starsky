import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:starsky/Screens/add_page.dart';
import 'package:starsky/Screens/fav_page.dart';
import 'package:starsky/Screens/front_page.dart';
import 'package:starsky/Screens/profile_page.dart';
import 'package:starsky/Screens/search_page.dart';



class Home extends StatefulWidget {


  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    front_page(),
    search_page(),
    add_page(),
    fav_page(),
    profile_page()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          unselectedItemColor: Colors.grey[500],
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label:"",
                backgroundColor: Colors.white
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label:"",
                backgroundColor: Colors.white
            ),

            BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                label:"",

                backgroundColor: Colors.white
            ),

            BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label:"",
                backgroundColor: Colors.white
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label:"",
              backgroundColor: Colors.white,
            ),
          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.red,
          iconSize: 40,
          onTap: _onItemTapped,
          elevation: 5
      ),
    );
  }
}