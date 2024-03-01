import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
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
  late Set<Polygon> _polygons;
  late List<LatLng> _polygonPoints;

  @override
  void initState() {
    super.initState();
    _locationEnabled = false;
    _userLocation = LatLng(0, 0);
    _polygons = Set<Polygon>();
    _polygonPoints = [];
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
    } else {
      setState(() {
        _userLocation = LatLng(0, 0);
      });
    }
  }

  void _addPolygonPoint(LatLng point) {
    _saveLocation(point);
    setState(() {
      _polygonPoints.add(point);
      if (_polygonPoints.length >= 3) {
        _updatePolygon();
      }
    });
  }

  void _updatePolygon() {
    setState(() {
      _polygons.clear();
      _polygons.add(
        Polygon(
          polygonId: PolygonId('polygon'),
          points: _polygonPoints,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.3),
        ),
      );
    });
  }

  double _calculatePolygonArea() {
    double area = 0;
    int j = _polygonPoints.length - 1;

    for (int i = 0; i < _polygonPoints.length; i++) {
      double xi = _polygonPoints[i].latitude * math.pi / 180;
      double yi = _polygonPoints[i].longitude * math.pi / 180;
      double xj = _polygonPoints[j].latitude * math.pi / 180;
      double yj = _polygonPoints[j].longitude * math.pi / 180;

      area += (xj + xi) * (yj - yi);
      j = i;
    }

    return (area.abs() / 2) * 6378137 * 6378137; // Radio medio de la Tierra al cuadrado
  }

  void _saveLocation(LatLng location) {
    final ref = FirebaseDatabase.instance.reference().child('locations');
    ref.push().set({
      'latitude': location.latitude,
      'longitude': location.longitude,
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
              polygons: _polygons,
              onTap: _addPolygonPoint,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _polygons.clear();
                      _polygonPoints.clear();
                    });
                  },
                  child: Text('Limpiar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    double area = _calculatePolygonArea();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Área del terreno'),
                          content: Text('El área del terreno es: $area'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Aceptar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Calcular Área'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
