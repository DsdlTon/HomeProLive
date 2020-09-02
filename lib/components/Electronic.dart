import 'package:flutter/material.dart';

class Electronic extends StatefulWidget {
  @override
  _ElectronicState createState() => _ElectronicState();
}

class _ElectronicState extends State<Electronic> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.blue,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Text('Electronic'),
        ),
      ),
    );
  }
}
