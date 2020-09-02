import 'package:flutter/material.dart';

class Desks extends StatefulWidget {
  @override
  _DesksState createState() => _DesksState();
}

class _DesksState extends State<Desks> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.blue,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Text('Desks'),
        ),
      ),
    );
  }
}
