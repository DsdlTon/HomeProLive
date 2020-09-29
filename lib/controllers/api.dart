import 'package:http/http.dart' as Http;
import 'dart:convert';
import '../models/Product.dart';
import '../models/User.dart';
import '../models/Cart.dart';

String baseUrl = "https://188.166.189.84";

class UserService {
  static Future<bool> createUserInDB(body) async {
    final response = await Http.post("$baseUrl/auth/register", body: body);
    print('createUser: ${response.body}');
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Status: ${response.statusCode}');
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
      throw Exception(
          'Status: ${response.statusCode} Failed to Load Product Data!!!');
    }
  }

  static Future<List<dynamic>> getProduct(sku) async {
    print('ENTER GETALLPRODUCT');
    Map<String, List<String>> data = {
      "sku_list": sku,
    };
    String body = json.encode(data);
    print('skuObj: $body');
    final response = await Http.post(
      "$baseUrl/api/product/sku",
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    print('response: ${response.body}');
    print('responseType: ${json.decode(response.body).runtimeType}');
    List<dynamic> res = json.decode(response.body);
    print('response after decode: $res');
    print('response after decode Type: ${res.runtimeType}');
    return res;
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
      throw Exception(
          'Status: ${response.statusCode} Failed to Load Cart Data!!!');
    }
  }

  static Future<bool> addToCart(headers, body) async {
    print('Enter Add to Cart');
    final response =
        await Http.post("$baseUrl/api/cart/add", headers: headers, body: body);
    print('responseBody: ${response.body}');
    if (response.statusCode == 200) {
      final String responseString = response.body;
      cartFromJson(responseString);
      return true;
    } else {
      throw Exception(
          'Status: ${response.statusCode} Failed to Load Cart Data!!!');
    }
  }

  static Future<int> getItemQuantity(headers, body) async {
    print('Enter Get Item Quantity');
    final response =
        await Http.post("$baseUrl/api/cart/item", headers: headers, body: body);
    print('responseBody: ${response.body}');
    Map res = json.decode(response.body);
    if (response.statusCode == 200) {
      if (res != null) {
        print('enter if');
        print(res.runtimeType);
        int quantity = res["quantity"];
        print('quantity form server: $quantity');
        return quantity;
      } else if (res == null) {
        print('enter else');
        int quantity = 0;
        return quantity;
      }
    } else {
      throw Exception(
          'Status: ${response.statusCode} Failed to Load Quantity Data!!!');
    }
  }
}

Cart cartFromJson(String responseString) {
  return Cart.fromJson(json.decode(responseString));
}

String cartToJson(Cart cart) {
  return json.encode(cart.toJson());
}
