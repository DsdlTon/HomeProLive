import 'package:http/http.dart' as Http;
import 'package:dio/dio.dart';
import 'package:test_live_app/models/CheckOutRes.dart';
import 'package:test_live_app/models/Order.dart';
import 'package:test_live_app/models/ProductInOrder.dart';
import 'package:test_live_app/screens/Checkout.dart';
import 'dart:convert';
import '../models/Product.dart';
import '../models/User.dart';
import '../models/Cart.dart';
import '../models/Address.dart';

String baseUrl = "https://homeprolive-test.ml";
var dio = Dio();

class UserService {
  static Future createUserInDB(body) async {
    FormData formData = new FormData.fromMap(body);
    print(body);
    Response response;
    try {
      response = await dio.post("$baseUrl/auth/register", data: formData);
      print('message: ${response.statusCode}');
      return response.statusCode;
    } on DioError catch (e) {
      print('e res msg: ${e.response.statusMessage}');
      print('e res data: ${e.response.data}');
      return e.response.statusMessage.toString();
    }
  }

  static Future<User> login(username, password) async {
    print('enter loginAPI');
    final body = {
      "username": username,
      "password": password,
    };
    print(body);
    final response = await Http.post("$baseUrl/auth/login", body: body);
    print('enter loginAPI2');
    final String responseString = response.body;
    print('response.body: ${response.body}');
    return userFromJson(responseString);
  }
}

User userFromJson(String str) => User.fromJson(json.decode(str));
String userToJson(User data) => json.encode(data.toJson());

//--------------------------------------------------------------------------

class ProductService {
  static Future<Product> getProductDetail(sku) async {
    final response = await Http.get("$baseUrl/api/product/$sku");
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
    print('enter getProduct');
    Map<String, List<String>> data = {
      "sku_list": sku,
    };
    String body = json.encode(data);
    final response = await Http.post("$baseUrl/api/product/sku",
        headers: {"Content-Type": "application/json"}, body: body);
    List<dynamic> res = json.decode(response.body);
    return res;
  }
}

Product productFromJson(String str) => Product.fromJson(json.decode(str));
String productToJson(Product data) => json.encode(data.toJson());

// -------------------------------------------------------------------------

class CartService {
  static Future<Cart> getUserCart(headers) async {
    print('enter getUserCart');
    print('headers: $headers');
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
    int quantity;
    if (response.statusCode == 200) {
      if (res != null) {
        print('enter if');
        quantity = res["quantity"];
        print('quantity form server: $quantity');
      } else if (res == null) {
        print('enter else');
        quantity = 0;
      }
      print('Quantity is: $quantity');
      return quantity;
    } else {
      throw Exception(
          'Status: ${response.statusCode} Failed to Load Quantity Data!!!');
    }
  }

  static Future<bool> removeItemInCart(headers, body) async {
    print('Enter Remove Item In Cart');
    final response = await Http.post("$baseUrl/api/cart/remove",
        headers: headers, body: body);
    print('responseBody: ${response.body}');
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Status: ${response.statusCode} Failed to Delete Item!!!');
    }
  }
}

Cart cartFromJson(String responseString) =>
    Cart.fromJson(json.decode(responseString));
String cartToJson(Cart cart) => json.encode(cart.toJson());

// -------------------------------------------------------------------------

class AddressService {
  static Future<Address> addAddress(headers, body) async {
    print('Enter addAddress');
    final response =
        await Http.post("$baseUrl/api/address", headers: headers, body: body);
    print('responseBody: ${response.body}');
    if (response.statusCode == 200) {
      final String responseString = response.body;
      return Address.fromJson(json.decode(responseString));
    } else {
      throw Exception(
          'Status: ${response.statusCode} Failed to add Address!!!');
    }
  }

  static Future<List<Address>> getAllUserAddress(headers) async {
    print('Enter getAllUserAddress');
    final response = await Http.get("$baseUrl/api/address", headers: headers);
    print('addressResponse: ${response.body}');
    if (response.statusCode == 200) {
      final String responseString = response.body;
      List<dynamic> rawAddressList = json.decode(responseString);
      List<Address> listAddress = [];
      rawAddressList.forEach((element) {
        Address.fromJson(element);
        listAddress.add(Address.fromJson(element));
      });
      return listAddress;
    } else {
      throw Exception(
          'Status: ${response.statusCode} Failed to Load Address Data!!!');
    }
  }
}

String addressToJson(Address address) => json.encode(address.toJson());

// -------------------------------------------------------------------------

class OrderService {
  static Future checkout(body, headers) async {
    print('Enter checkout api');
    final response = await Http.post("$baseUrl/api/cart/checkout",
        body: body, headers: headers);
    print('checkout response: ${response.body}');
    if (response.statusCode == 200) {
      print('Checkout success');
      return true;
    } else {
      final String responseString = response.body;
      return checkoutResFromJson(responseString);
    }
  }

  static Future<ProductInOrder> getOrder(id, headers) async {
    print('Enter getOrder id$id');
    final response = await Http.get('$baseUrl/api/order/$id', headers: headers);
    print('getOrder response: ${response.body}');
    if (response.statusCode == 200) {
      final String responseString = response.body;
      return productInOrderFromJson(responseString);
    } else {
      throw Exception('Status: ${response.statusCode} getOrder Failed!!!');
    }
  }

  static Future<Order> getAllOrder(headers) async {
    print('Enter getAllOrder');
    final response = await Http.get("$baseUrl/api/order", headers: headers);
    print('getAllOrder Response: ${response.body}');
    if (response.statusCode == 200) {
      final String responseString = response.body;
      return orderFromJson(responseString);
    } else {
      throw Exception('Status: ${response.statusCode} getAllOrder Failed!!!');
    }
  }
}

CheckOutRes checkoutResFromJson(String responseString) {
  return CheckOutRes.fromJson(json.decode(responseString));
}

ProductInOrder productInOrderFromJson(String responseString) {
  return ProductInOrder.fromJson(json.decode(responseString));
}

Order orderFromJson(String responseString) {
  return Order.fromJson(json.decode(responseString));
}

String orderToJson(Cart cart) {
  return json.encode(cart.toJson());
}
