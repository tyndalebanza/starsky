import 'package:flutter/material.dart';

class add_page extends StatefulWidget {
  const add_page({Key? key}) : super(key: key);

  @override
  State<add_page> createState() => _add_pageState();
}

class _add_pageState extends State<add_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new_star');
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
