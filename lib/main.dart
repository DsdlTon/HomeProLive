import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_live_app/services/notification.dart';

import 'package:test_live_app/pages/InitialPage.dart';
import 'package:test_live_app/providers/CategoryCardChange.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   PushNotificationsManager().init();
//   runApp(MyApp());
// }

void main() => runApp(MyApp());

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
        home: InitialPage(),
      ),
    );
  }
}
