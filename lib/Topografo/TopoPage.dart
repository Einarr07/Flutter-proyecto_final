import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UbicacionPage extends StatefulWidget {
  @override
  _UbicacionPageState createState() => _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  late bool _locationEnabled;
  late LatLng _userLocation;

  @override
  void initState() {
    super.initState();
    _locationEnabled = false;
    _userLocation = LatLng(0, 0);
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _locationEnabled = true;
    });
    _updateLocation(true);
  }

  Future<void> _updateLocation(bool enableLocation) async {
    if (enableLocation) {
      try {
        Location location = Location();
        LocationData locationData = await location.getLocation();
        setState(() {
          _userLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
        });
      } catch (e) {
        // Handle location error
        print('Error getting location: $e');
      }
    }
  }

  @override

  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Topografos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('¿Quieres activar la ubicación?'),
            ElevatedButton(
              onPressed: () async {
                bool enableLocation = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Activar Ubicación'),
                      content: Text('¿Quieres activar la ubicación?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('Sí'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text('No'),
                        ),
                      ],
                    );
                  },
                );

                if (enableLocation) {
                  _checkLocationPermission();
                }
              },
              child: Text('Activar Ubicación'),
            ),
            if (_locationEnabled)
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _userLocation,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('userLocation'),
                      position: _userLocation,
                      infoWindow: InfoWindow(title: 'Tu Ubicación'),
                    ),
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
