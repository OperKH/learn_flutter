import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../models/locationCoordinates.dart';

class LocationInput extends StatefulWidget {
  final Function _setParentState;
  final LocationCoordinates _coordinates;

  LocationInput(this._setParentState, [this._coordinates]);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final TextEditingController _locationTextCtrl = TextEditingController();

  Location _location = Location();
  String _locationPermissionError;
  GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
  }

  _getLocation() async {
    Map<String, double> location;
    try {
      bool per = await _location.hasPermission();
      print('Location Has Permission: $per');
      location = await _location.getLocation();
      if (mounted) {
        setState(() {
          _locationPermissionError = null;
        });
      }
    } on PlatformException catch (e) {
      String error = 'Unknown Error';
      print('Location Error Code: ${e.code}');
      if (e.code == 'PERMISSION_DENIED' ||
          e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Location Permission denied - please enable it from the app settings';
      }
      if (mounted) {
        setState(() {
          _locationPermissionError = error;
        });
      }
    } catch (e) {
      print(e);
    }
    return location;
  }

  @override
  void dispose() {
    _mapController.removeListener(_onMapChanged);
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _mapController = controller;
    });
    _mapController.addListener(_onMapChanged);
    LatLng position;
    if (widget._coordinates == null) {
      final Map<String, double> location = await _getLocation();
      if (location != null) {
        position = LatLng(location['latitude'], location['longitude']);
      }
    } else {
      position =
          LatLng(widget._coordinates.latitude, widget._coordinates.longitude);
    }
    await _mapController.updateMapOptions(
      GoogleMapOptions(
        cameraPosition: CameraPosition(
          target: position,
          zoom: 17.0,
        ),
      ),
    );
  }

  void _onMapChanged() async {
    if (_mapController.isCameraMoving) return;
    final LatLng position = _mapController.cameraPosition.target;
    widget._setParentState(
      LocationCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
    _locationTextCtrl.text = '${position.latitude}, ${position.longitude}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _locationTextCtrl,
          decoration: InputDecoration(labelText: 'Location'),
          enabled: false,
        ),
        SizedBox(height: 10.0),
        SizedBox(
          height: 300.0,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              GoogleMap(
                onMapCreated: _onMapCreated,
                options: GoogleMapOptions(
                  trackCameraPosition: true,
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
              Positioned(
                bottom: 148.0,
                child: Icon(
                  Icons.location_on,
                  color: Colors.red[700],
                  size: 32.0,
                ),
              ),
            ],
          ),
        ),
        _locationPermissionError == null
            ? Container()
            : Text(
                _locationPermissionError,
                style: TextStyle(color: Colors.red),
              )
      ],
    );
  }
}
