import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 41.40338, 2.17403

class LocationInput extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final LatLng _initial_pos = LatLng(41.40338, 2.17403);
  GoogleMapController _mapController;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
    controller.addMarker(MarkerOptions(
      position: _initial_pos,
    ));
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: _initial_pos,
        zoom: 17.0,
      ),
    ));
  }

  void _updateLocation() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(labelText: 'Location'),
          focusNode: _addressInputFocusNode,
        ),
        SizedBox(height: 10.0),
        SizedBox(
          width: 500.0,
          height: 300.0,
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            options: GoogleMapOptions(
              cameraPosition: CameraPosition(
                target: _initial_pos,
                zoom: 17.0,
              ),
              // trackCameraPosition: true,
              myLocationEnabled: true,
            ),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
              // Factory<OneSequenceGestureRecognizer>(
              //   () => ScaleGestureRecognizer(),
              // ),
            ].toSet(),
          ),
        ),
      ],
    );
  }
}
