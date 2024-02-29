import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginaAdmin extends StatefulWidget {
  @override
  _PaginaAdminState createState() => _PaginaAdminState();
}

class _PaginaAdminState extends State<PaginaAdmin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario eliminado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar usuario: $e')),
      );
    }
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
            Text('Eliminar Usuario', style: TextStyle(fontSize: 20)),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      return ListTile(
                        title: Text(doc['email']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteUser(doc.id),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
