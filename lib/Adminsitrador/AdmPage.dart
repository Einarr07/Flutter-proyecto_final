import 'package:flutter/material.dart';

class PaginaAdmin extends StatefulWidget {
  const PaginaAdmin({Key? key}) : super(key: key);

  @override
  _PaginaTopografoState createState() => _PaginaTopografoState();
}

class _PaginaTopografoState extends State<PaginaAdmin> {
  String latitude = '';
  String longitude = '';

  void getCurrentCoordinates() {
    // Lógica para obtener coordenadas
    setState(() {
      latitude = 'nueva_latitud'; // Reemplaza con valor real
      longitude = 'nueva_longitud'; // Reemplaza con valor real
    });
  }

  void openGoogleMaps() {
    // Lógica para abrir Google Maps
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.blue,
            child: Text(
              'ADMINSITRADOR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      getCurrentCoordinates();
                    },
                    child: Text('Obtener Ubicación'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Coordenadas de la Ubicación',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  ListTile(
                    title: Text('Latitud'),
                    trailing: Text(
                      '$latitude',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ListTile(
                    title: Text('Longitud'),
                    trailing: Text(
                      '$longitude',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      openGoogleMaps();
                    },
                    child: Text('Ubicación en Google Maps'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    /*return Scaffold(
      appBar: AppBar(
        title: Text('Mi Ubicación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                getCurrentCoordinates();
              },
              child: Text('Obtener Ubicación'),
            ),
            SizedBox(height: 16),
            Text(
              'Coordenadas de la Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            ListTile(
              title: Text('Latitud'),
              trailing: Text(
                '$latitude',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ListTile(
              title: Text('Longitud'),
              trailing: Text(
                '$longitude',
                style: TextStyle(color: Colors.red),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                openGoogleMaps();
              },
              child: Text('Ubicación en Google Maps'),
            ),
          ],
        ),
      ),
    );*/
  }
}
