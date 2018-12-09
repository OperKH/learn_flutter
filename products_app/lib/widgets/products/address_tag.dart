import 'package:flutter/material.dart';

class AddressTag extends StatelessWidget {
  final String address;

  AddressTag(this.address);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Icon(Icons.location_on, size: 18.0),
          SizedBox(width: 3.0),
          Text(address),
        ],
      ),
    );
  }
}
