import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_live_app/providers/CategoryCardChange.dart';
import 'package:test_live_app/utils/route_generator.dart';

final navigatorKey = new GlobalKey<NavigatorState>();
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext _) => CategoryChangeProvider(),
      child: MaterialApp(
        title: 'HomePro Live',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
