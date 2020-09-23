import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/screens/CartPage.dart';
import 'package:test_live_app/screens/ChatPage.dart';
import 'package:test_live_app/screens/HomePage.dart';
import 'package:test_live_app/screens/LivePage.dart';
import 'package:test_live_app/screens/LogInPage.dart';
import 'package:test_live_app/screens/RecentLivePage.dart';
import 'package:test_live_app/screens/Register.dart';
import 'package:test_live_app/screens/SplashPage.dart';
import 'package:test_live_app/widgets/showFullImage.dart';
import 'package:test_live_app/screens/ProductDetail.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
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
      case '/cartPage':
        return MaterialPageRoute(builder: (_) => CartPage());
      case '/productDetailPage':
        return MaterialPageRoute(builder: (_) => ProductDetailPage());

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
