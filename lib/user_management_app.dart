import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserManagementApp extends StatefulWidget {
  @override
  _UserManagementAppState createState() => _UserManagementAppState();
}

class _UserManagementAppState extends State<UserManagementApp> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addUser() async {
    try {
      await _firestore.collection('Usuarios').add({
        'name': 'New User',
        'email': 'newuser@example.com',
        'age': 25,
        'password': 'password123',
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Usuario agregado.'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al agregar usuario.'),
      ));
    }
  }

  Future<void> _updateUser(BuildContext context, String docId, Map<String, dynamic> currentData) async {
    final _nameController = TextEditingController(text: currentData['name']);
    final _emailController = TextEditingController(text: currentData['email']);
    final _ageController = TextEditingController(text: currentData['age'].toString());
    final _passwordController = TextEditingController(text: currentData['password']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Correo'),
                ),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Edad'),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore.collection('Usuarios').doc(docId).update({
                    'name': _nameController.text,
                    'email': _emailController.text,
                    'age': int.tryParse(_ageController.text) ?? currentData['age'],
                    'password': _passwordController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Usuario actualizado.'),
                  ));
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error al actualizar usuario.'),
                  ));
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(String docId) async {
    try {
      await _firestore.collection('Usuarios').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Usuario eliminado.'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar usuario.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Usuarios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay usuarios registrados.'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(userData['name'] ?? 'Sin nombre'),
                  subtitle: Text(userData['email'] ?? 'Sin email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _updateUser(context, user.id, userData),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        child: Icon(Icons.add),
        tooltip: 'Agregar Usuario',
      ),
    );
  }
}