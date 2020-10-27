import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/ListItem.dart';
import '../controllers/api.dart';

class NewAddressPage extends StatefulWidget {
  @override
  _NewAddressPageState createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  final _formKey = GlobalKey<FormState>();
  String _accessToken;

  String firstName,
      lastName,
      phone,
      type,
      homeNo,
      roomNo,
      village,
      moo,
      soi,
      floor,
      street,
      province,
      district,
      subDistrict;

  List<DropdownMenuItem<ListItem>> _dropdownMenuItems;
  ListItem _selectedItem;

  List<ListItem> _dropdownItems = [
    ListItem(1, "Single House"),
    ListItem(2, "Town House"),
    ListItem(3, "Condominium"),
    ListItem(4, "Commercial Builder"),
    ListItem(5, "Others"),
  ];

  int _keyboardVisibilitySubscriberId;
  bool _keyboardState;
  KeyboardVisibilityNotification _keyboardVisibility =
      KeyboardVisibilityNotification();

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    setState(() {
      _accessToken = accessToken;
    });
    return _accessToken;
  }

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  void validateInputs() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      final headers = {
        "access-token": _accessToken,
      };
      final body = {
        "firstname": firstName,
        "lastname": lastName,
        "phone": phone,
        "type": type,
        "homeNo": homeNo,
        "roomNo": roomNo,
        "village_condoname": village,
        "moo": moo,
        "soi": soi,
        "floor": floor,
        "street": street,
        "province": province,
        "district": district,
        "sub_district": subDistrict,
      };

      print('headers: $headers');
      print('body: $body');
      AddressService.addAddress(headers, body).then((address) {
        print('address: ${address.firstname}');
        if (address.firstname.isNotEmpty) {
          Fluttertoast.showToast(
            msg: "Add new Address Success.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.blue[800],
            textColor: Colors.white,
            fontSize: 13.0,
          );
        }
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void initState() {
    getAccessToken();
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    // _selectedItem = _dropdownMenuItems[0].value;
    _keyboardState = _keyboardVisibility.isKeyboardVisible;
    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        setState(() {
          _keyboardState = visible;
          if (_keyboardState != true) {
            setState(() {
              FocusScope.of(context).unfocus();
            });
          }
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        automaticallyImplyLeading: false,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              colors: [
                Colors.blue[600],
                Colors.blue[700],
                Colors.blue[800],
                Colors.blue[800],
              ],
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Create New Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  fnameTextFormField(),
                  lnameTextFormField(),
                ],
              ),
              phoneTextFormField(),
              typeTextFormField(),
              Row(
                children: <Widget>[
                  homeNoTextFormField(),
                  roomNoTextFormField(),
                ],
              ),
              villageTextFormField(),
              Row(
                children: <Widget>[
                  mooTextFormField(),
                  soiTextFormField(),
                  floorTextFormField(),
                ],
              ),
              streetTextFormField(),
              provinceTextFormField(),
              districtTextFormField(),
              subDistrictTextFormField(),
              addAddressButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget addAddressButton() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      padding: EdgeInsets.all(8),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      color: Colors.white,
      child: GestureDetector(
        onTap: () {
          print('Tap addAddressButton');
          validateInputs();
        },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(3)),
            child: Center(
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            )),
      ),
    );
  }

  Widget fnameTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Firstname',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                keyboardType: TextInputType.text,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set ชื่อ',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  firstName = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget lnameTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Lastname',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                keyboardType: TextInputType.text,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set นามสกุล',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  lastName = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget phoneTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Tel',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set หมายเลขโทรศัพท์',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  phone = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget typeTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Home Type',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: DropdownButtonFormField(
              decoration: InputDecoration(
                enabledBorder: InputBorder.none,
                errorStyle: TextStyle(
                  fontSize: 10.0,
                  height: 0.1,
                ),
              ),
              hint: Text('ประเภทที่อยู่อาศัย'),
              style: TextStyle(fontSize: 12, color: Colors.black),
              value: _selectedItem,
              items: _dropdownMenuItems,
              validator: (value) {
                if (value == null) {
                  return "field required";
                } else {
                  return null;
                }
              },
              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                  type = _selectedItem.name.trim();
                  print(type.runtimeType);
                  print(type);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget homeNoTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Home No.',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set บ้านเลขที่',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  homeNo = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget roomNoTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Room No.',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set เลขห้อง',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  roomNo = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget villageTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Village/Condo Name',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set ชื่อหมู่บ้าน/คอนโด',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  village = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mooTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width * 0.32,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Moo',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set หมู่ที่',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  moo = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget soiTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width * 0.32,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Soi',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set ซอย',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  soi = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget floorTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width * 0.33,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Floor',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set ชั้น',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  floor = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget streetTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Street',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set ถนน',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  street = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget provinceTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Province',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set จังหวัด',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  province = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget districtTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'District',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set เขต/อำเภอ',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  district = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget subDistrictTextFormField() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: <Widget>[
          Text(
            'Sub-District',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Container(
              child: TextFormField(
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  errorStyle: TextStyle(
                    fontSize: 10.0,
                    height: 0.1,
                  ),
                  hintText: 'set แขวง/ตำบล',
                  hintStyle: TextStyle(fontSize: 11),
                ),
                onSaved: (String value) {
                  subDistrict = value.trim();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "field required";
                  } else {
                    return null;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
