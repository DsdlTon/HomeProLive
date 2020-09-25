import 'package:http/http.dart' as Http;
import 'dart:convert';
import '../models/Product.dart';
import '../models/User.dart';
import '../models/Cart.dart';

String baseUrl = "https://188.166.189.84"; // /api/cart

class UserService {
  static Future<bool> createUserInDB(body) async {
    final response = await Http.post("$baseUrl/auth/register", body: body);
    print('createUser: ${response.body}');
    if (response.statusCode == 200) {
      return true;
    } else {
      print('responseCode: ${response.statusCode}');
      return false;
    }
  }

  static Future<User> login(body) async {
    final response = await Http.post("$baseUrl/auth/login", body: body);
    final String responseString = response.body;
    return userFromJson(responseString);
  }
}

User userFromJson(String str) => User.fromJson(json.decode(str));
String userToJson(User data) => json.encode(data.toJson());

//--------------------------------------------------------------------------

class ProductService {
  static Future<Product> getProductDetail(id) async {
    final response = await Http.get("$baseUrl/api/product/{$id}");
    print('PRODUCTDETAILS RESPONSE: ${response.body}');
    if (response.statusCode == 200) {
      final String responseString = response.body;
      return productFromJson(responseString);
    } else {
      throw Exception('Failed to Load Product Data!!!');
    }
  }
}

Product productFromJson(String str) => Product.fromJson(json.decode(str));
String productToJson(Product data) => json.encode(data.toJson());

// -------------------------------------------------------------------------

class CartService {
  static Future<Cart> getUserCart(headers) async {
    final response = await Http.get("$baseUrl/api/cart", headers: headers);
    print('cartResponse: ${response.body}');
    if (response.statusCode == 200) {
      final String responseString = response.body;
      return cartFromJson(responseString);
    } else {
      throw Exception('Failed to Load Cart Data!!!');
    }
  }

  static Future<bool> addToCart(headers, body) async {
    final response =
        await Http.post("$baseUrl/api/cart/add", headers: headers, body: body);
        
  }
}

Cart cartFromJson(String responseString) {
  return Cart.fromJson(json.decode(responseString));
}

String cartToJson(Cart cart) {
  return json.encode(cart.toJson());
}
