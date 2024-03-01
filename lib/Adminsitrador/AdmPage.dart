import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class PaginaAdmin extends StatefulWidget {
  @override
  _PaginaAdminState createState() => _PaginaAdminState();
}

class _PaginaAdminState extends State<PaginaAdmin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late DatabaseReference _usuariosRef;
  GoogleMapController? _mapController;
  Location _location = Location();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _usuariosRef = FirebaseDatabase.instance.reference().child('usuarios');
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Agregar el usuario a Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(userCredential.user!.uid).set({
        'email': email,
        'activo': true, // Puedes establecer el usuario como activo por defecto
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario creado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear usuario: $e')),
      );
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario eliminado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
  }

  Future<void> toggleUserActiveStatus(String uid, bool isActive) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'activo': isActive,
      });

      // Si el usuario se activa, actualizar su ubicación en tiempo real
      if (isActive) {
        final user = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
        final location = user.data()!['activo'];
        await _usuariosRef.update({
          'activo': {
            'latitude': location['latitude'],
            'longitude': location['longitude'],
          },
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado de usuario actualizado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar estado de usuario: $e')),
      );
    }
  }

  double _calculatePolygonArea(Set<Marker> markers) {
    if (markers.length < 3) return 0;

    final List<LatLng> points = markers.map((marker) => marker.position).toList();
    double area = 0;

    for (int i = 0; i < points.length; i++) {
      final LatLng point1 = points[i];
      final LatLng point2 = points[(i + 1) % points.length];
      area += (point1.latitude + point2.latitude) * (point1.longitude - point2.longitude);
    }

    return area.abs() / 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Administración de Usuarios')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agregar Usuario', style: TextStyle(fontSize: 20)),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                signUpWithEmailAndPassword(_emailController.text, _passwordController.text);
                _emailController.clear();
                _passwordController.clear();
              },
              child: Text('Agregar'),
            ),
            SizedBox(height: 20),
            Text('Activar/Inavilitar o eliminar un usuario', style: TextStyle(fontSize: 20)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').where('activo', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final email = doc.get('email');
                      final activo = doc.get('activo');

                      if (email != null) {
                        return ListTile(
                          title: Text(email),
                          subtitle: Text(activo ? 'Activo' : 'Inactivo'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.toggle_on),
                                onPressed: () => toggleUserActiveStatus(doc.id, !activo),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => deleteUser(doc.id),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return SizedBox(); // O cualquier otro widget para manejar el caso sin email
                      }
                    }).toList(),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            SizedBox(height: 20),
            Text('Visualización de Posición', style: TextStyle(fontSize: 20)),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(0, 0),
                  zoom: 15,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onTap: (LatLng position) {
                  setState(() {
                    _markers.add(
                      Marker(
                        markerId: MarkerId(position.toString()),
                        position: position,
                      ),
                    );
                  });
                },
                markers: _markers,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final area = _calculatePolygonArea(_markers);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Área del polígono: $area')));
                  },
                  child: Text('Calcular Área'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _markers.clear();
                    });
                  },
                  child: Text('Limpiar Puntos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
