import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/pages/CartPage.dart';
import 'package:test_live_app/pages/ChatPage.dart';
import 'package:test_live_app/pages/HomePage.dart';
import 'package:test_live_app/pages/LivePage.dart';
import 'package:test_live_app/pages/LogInPage.dart';
import 'package:test_live_app/pages/RecentLivePage.dart';
import 'package:test_live_app/pages/Register.dart';
import 'package:test_live_app/pages/SplashPage.dart';
import 'package:test_live_app/pages/showFullImage.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // routes: {
    //   '/': (context) => SplashPage(),
    //   '/loginPage': (context) => LoginPage(),
    //   '/registerPage': (context) => RegisterPage(),
    //   '/homePage': (context) => HomePage(),
    //   '/listLivePage': (context) => ListLivePage(),
    //   '/ListRecentlyLivePage': (context) => ListRecentlyLivePage(),
    //   '/allChatPage': (context) => AllChatPage(),
    //   '/chatPage': (context) => ChatPage(),
    //   '/livePage': (context) => LivePage(),
    //   '/recentLivePage': (context) => RecentLivePage(),
    //   '/fullImageScreen': (context) => FullImageScreen(),
    //   '/foregroundLive': (context) => ForegroundLive(),
    //   '/backgroundLive': (context) => BackgroundLive(),
    //   '/recentForeground': (context) => RecentForegroundLive(),

    //   '/cartPage': (context) => CartPage(),
    // },

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashPage());
      case '/registerPage':
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case '/loginPage':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/homePage':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/chatPage':
        final ChatPage chatArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChatPage(
            title: chatArgs.title,
            channelName: chatArgs.channelName,
            username: chatArgs.username,
          ),
        );
      case '/fullImageScreen':
        final String imageArgs = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => FullImageScreen(
            image: imageArgs,
          ),
        );
      case '/livePage':
        final LivePage liveArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LivePage(
            title: liveArgs.title,
            channelName: liveArgs.channelName,
            username: liveArgs.username,
            userProfile: liveArgs.userProfile,
            liveUser: liveArgs.liveUser,
            role: ClientRole.Audience,
          ),
        );
      case '/recentLivePage':
        final RecentLivePage recentLiveArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => RecentLivePage(
            title: recentLiveArgs.title,
            channelName: recentLiveArgs.channelName,
            username: recentLiveArgs.username,
            userProfile: recentLiveArgs.userProfile,
            liveUser: recentLiveArgs.liveUser,
            role: ClientRole.Audience,
          ),
        );

      // case '/listLivePage':
      //   return MaterialPageRoute(builder: (_) => ListLivePage());
      // case '/listRecentlyLivePage':
      //   return MaterialPageRoute(builder: (_) => ListRecentlyLivePage());
      // case '/allChatPage':
      //   return MaterialPageRoute(builder: (_) => AllChatPage());

      case '/cartPage':
        return MaterialPageRoute(builder: (_) => CartPage());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        body: Center(
          child: Text('ERROR ROUTE!'),
        ),
      );
    });
  }
}
