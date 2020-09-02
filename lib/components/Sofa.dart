import 'package:flutter/material.dart';

class Sofa extends StatefulWidget {
  @override
  _SofaState createState() => _SofaState();
}

class _SofaState extends State<Sofa> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.blue,
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Text('Sofa'),
        ),
      ),
    );
  }
}
