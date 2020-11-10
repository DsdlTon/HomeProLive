import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:test_live_app/screens/CartPage.dart';
import 'package:test_live_app/screens/ChatPage.dart';
import 'package:test_live_app/screens/Checkout.dart';
import 'package:test_live_app/screens/HomePage.dart';
import 'package:test_live_app/screens/ItemInOrder.dart';
import 'package:test_live_app/screens/LivePage.dart';
import 'package:test_live_app/screens/LogInPage.dart';
import 'package:test_live_app/screens/OrderList.dart';
import 'package:test_live_app/screens/RecentLivePage.dart';
import 'package:test_live_app/screens/Register.dart';
import 'package:test_live_app/screens/SplashPage.dart';
import 'package:test_live_app/screens/createNewAddress.dart';
import 'package:test_live_app/screens/selectedAddress.dart';
import 'package:test_live_app/widgets/showFullImage.dart';
import 'package:test_live_app/screens/ProductDetailPage.dart';

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
        // final HomePage homeArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => HomePage(),
        );
      case '/chatPage':
        final ChatPage chatArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ChatPage(
            title: chatArgs.title,
            liveAdmin: chatArgs.liveAdmin,
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
            liveAdmin: liveArgs.liveAdmin,
            adminProfile: liveArgs.adminProfile,
            appId: liveArgs.appId,
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
            liveAdmin: recentLiveArgs.liveAdmin,
            adminProfile: recentLiveArgs.adminProfile,
            appId: recentLiveArgs.appId,
            pathVideo: recentLiveArgs.pathVideo,
            view: recentLiveArgs.view,
            role: ClientRole.Audience,
          ),
        );

      case '/cartPage':
        return MaterialPageRoute(builder: (_) => CartPage());
      case '/productDetailPage':
        final ProductDetailPage productDetailArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductDetailPage(
            sku: productDetailArgs.sku,
            channelName: productDetailArgs.channelName,
          ),
        );
      case '/checkoutPage':
        final CheckOutPage checkoutArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CheckOutPage(
            totalPrice: checkoutArgs.totalPrice,
          ),
        );
      case '/selectedAddressPage':
        final SelectedAddressPage selectedAddressArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SelectedAddressPage(
            totalPrice: selectedAddressArgs.totalPrice,
          ),
        );
      case '/newAddressPage':
        final NewAddressPage newAddressArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => NewAddressPage(
            totalPrice: newAddressArgs.totalPrice,
          ),
        );
      case '/orderListPage':
        return MaterialPageRoute(builder: (_) => OrderListPage());
      case '/itemInOrder':
        final ItemInOrder itemInOrderArgs = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ItemInOrder(
            orderId: itemInOrderArgs.orderId,
            index: itemInOrderArgs.index,
          ),
        );
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
