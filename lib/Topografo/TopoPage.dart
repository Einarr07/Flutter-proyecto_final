import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: UbicacionPage()));
}

class UbicacionPage extends StatefulWidget {
  @override
  _UbicacionPageState createState() => _UbicacionPageState();
}

class _UbicacionPageState extends State<UbicacionPage> {
  late bool _locationEnabled;
  late LatLng _userLocation;
  late DatabaseReference _usuariosRef;

  @override
  void initState() {
    super.initState();
    _locationEnabled = false;
    _userLocation = LatLng(0, 0);
    _usuariosRef = FirebaseDatabase.instance.reference().child('usuarios');
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
        location.onLocationChanged.listen((LocationData locationData) {
          setState(() {
            _userLocation = LatLng(locationData.latitude!, locationData.longitude!);
          });
          _saveLocation(_userLocation);
        });
      } catch (e) {
        // Handle location error
        print('Error getting location: $e');
      }
    } else {
      setState(() {
        _userLocation = LatLng(0, 0);
      });
    }
  }

  void _saveLocation(LatLng location) {
  _usuariosRef.update({
    'activo': {
      'latitude': location.latitude,
      'longitude': location.longitude,
    },
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plataforma de Ubicación y Mapeo'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(0, 0), // Ubicación inicial (ecuador)
                zoom: 2,
              ),
              markers: _locationEnabled
                  ? {
                      Marker(
                        markerId: MarkerId('userLocation'),
                        position: _userLocation,
                        infoWindow: InfoWindow(title: 'Tu Ubicación'),
                      ),
                    }
                  : {},
            ),
          ),
        ],
      ),
    );
  }
}
