import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:test_live_app/controllers/api.dart';
import 'package:test_live_app/providers/TotalPriceProvider.dart';

class DeleteItemConfirmationDialog extends StatefulWidget {
  final String accessToken;
  final String cartItemSku;
  final List cartItem;
  final int index;

  const DeleteItemConfirmationDialog(
      {Key key, this.accessToken, this.cartItemSku, this.cartItem, this.index})
      : super(key: key);

  @override
  _DeleteItemConfirmationDialogState createState() =>
      _DeleteItemConfirmationDialogState();
}

class _DeleteItemConfirmationDialogState
    extends State<DeleteItemConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Row(
          children: <Widget>[
            deleteIcon(),
            dialogBody(),
          ],
        ),
      ),
    );
  }

  Widget deleteIcon() {
    return Expanded(
      flex: 2,
      child: Container(
        color: Colors.red,
        child: Center(
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }

  Widget dialogBody() {
    return Expanded(
      flex: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        color: Colors.red,
        child: Column(
          children: <Widget>[
            dialogTitle(),
            dialogButtonBar(),
          ],
        ),
      ),
    );
  }

  Widget dialogTitle() {
    return Expanded(
      flex: 2,
      child: Center(
        child: Text(
          'Are you sure to delete this Item?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget dialogButtonBar() {
    return Expanded(
      flex: 1,
      child: ButtonBar(
        children: <Widget>[
          noButton(),
          yesButton(),
        ],
      ),
    );
  }

  Widget yesButton() {
    return FlatButton(
      onPressed: () async {
        final headers = {
          "access-token": widget.accessToken,
        };
        final body = {
          "sku": widget.cartItemSku,
        };

        await CartService.removeItemInCart(headers, body);
        setState(() {
          widget.cartItem.removeAt(widget.index);
          int cartLen = widget.cartItem.length;
          Provider.of<TotalPriceProvider>(context, listen: false)
              .calculateTotalPrice(cartLen, widget.cartItem);
        });
        Navigator.of(context).popAndPushNamed('/cartPage');
        Fluttertoast.showToast(
          msg: "Deleted Success.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red[800],
          textColor: Colors.white,
          fontSize: 13.0,
        );

      },
      child: Text(
        'Yes',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget noButton() {
    return FlatButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        'No',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
