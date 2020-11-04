import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/models/Address.dart';
import 'package:test_live_app/screens/Checkout.dart';
import 'package:test_live_app/screens/createNewAddress.dart';

class SelectedAddressPage extends StatefulWidget {
  final double totalPrice;

  const SelectedAddressPage({Key key, this.totalPrice}) : super(key: key);

  @override
  _SelectedAddressPageState createState() => _SelectedAddressPageState();
}

class _SelectedAddressPageState extends State<SelectedAddressPage> {
  List<Address> addressList = [];
  var headers;
  int defaultLocation;

  Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken');
    return accessToken;
  }

  readDefaultLocationInPref() async {
    print('read default location as Index');
    final prefs = await SharedPreferences.getInstance();
    defaultLocation = prefs.getInt('defaultLocationIndex');

    return defaultLocation;
  }

  saveDefaultLocationToPref() async {
    print('save new defaultLocation as Index');
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('defaultLocationIndex', defaultLocation);
  }

  removeDefaultLocationInPref() async {
    print('remove old defaultLocation as Index');
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('defaultLocationIndex');
  }

  @override
  void initState() {
    readDefaultLocationInPref().then((defaultLocation) {
      setState(() {
        defaultLocation = this.defaultLocation;
        print('This is defaultLocation Index: $defaultLocation');
      });
    });

    getAccessToken().then((accesstoken) {
      setState(() {
        headers = {"access-token": accesstoken};
      });
    });
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
            print('totalPrice: ${widget.totalPrice}');
            Navigator.pushReplacementNamed(
              context,
              '/checkoutPage',
              arguments: CheckOutPage(
                totalPrice: widget.totalPrice,
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Select your Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            addressLoader(),
            addNewAddressBtn(),
          ],
        ),
      ),
    );
  }

  Widget addressLoader() {
    return Container(
      child: FutureBuilder(
        future: AddressService.getAllUserAddress(headers),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return addressPanel(snapshot);
          } else {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget addressPanel(snapshot) {
    return Container(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        controller: new ScrollController(keepScrollOffset: false),
        itemCount: snapshot.data.length,
        itemBuilder: (context, index) {
          return addressCard(snapshot, index);
        },
      ),
    );
  }

  Widget addressCard(snapshot, index) {
    return GestureDetector(
      onTap: () {
        if (defaultLocation != null) {
          removeDefaultLocationInPref();
        }
        setState(() {
          defaultLocation = index;
          print('defaultLocation: index $defaultLocation');
        });
        saveDefaultLocationToPref();
        Navigator.pushReplacementNamed(
          context,
          '/checkoutPage',
          arguments: CheckOutPage(
            totalPrice: widget.totalPrice,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 2.5),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '${snapshot.data[index].firstname} ${snapshot.data[index].lastname}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                defaultLocation == index ? defaultLocationTag() : Container(),
              ],
            ),
            SizedBox(height: 5),
            Text(
              '${snapshot.data[index].phone}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              '${snapshot.data[index].homeNo} หมู่ที่${snapshot.data[index].moo} ${snapshot.data[index].villageCondoname} ห้องเลขที่${snapshot.data[index].roomNo} ชั้น${snapshot.data[index].floor} ถนน${snapshot.data[index].street} ซอย ${snapshot.data[index].soi} เขต/อำเภอ ${snapshot.data[index].district} แขวง/ตำบล ${snapshot.data[index].subDistrict} ${snapshot.data[index].province}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget defaultLocationTag() {
    return Text(
      '   [Use this Location]',
      style: TextStyle(
        color: Colors.blue[800],
        fontSize: 12,
      ),
    );
  }

  Widget addNewAddressBtn() {
    return GestureDetector(
      onTap: () {
        print('Tap add new Address');
        Navigator.pushReplacementNamed(
          context,
          '/newAddressPage',
          arguments: NewAddressPage(
            totalPrice: widget.totalPrice,
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.08,
        margin: EdgeInsets.symmetric(vertical: 3),
        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Add new Address',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
            Icon(Icons.add, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
