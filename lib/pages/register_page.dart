import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String age = '';
  String phone = '';
  String email = '';
  String password = '';
  String role = 'volunteer'; // Rol predeterminado
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E2A47), // Fondo azul oscuro
      appBar: AppBar(
        backgroundColor: Color(0xFF1E2A47),
        title: Text(
          'Registro',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navegar hacia atrás
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crear una cuenta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A47),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Campo Nombre
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Nombre completo'),
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese su nombre' : null,
                      onChanged: (value) => name = value.trim(),
                    ),
                    SizedBox(height: 8),

                    // Campo Edad
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Edad'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese su edad' : null,
                      onChanged: (value) => age = value.trim(),
                    ),
                    SizedBox(height: 8),

                    // Campo Teléfono
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Teléfono'),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese su número de teléfono' : null,
                      onChanged: (value) => phone = value.trim(),
                    ),
                    SizedBox(height: 8),

                    // Campo Email
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Correo electrónico'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Ingrese un correo válido' : null,
                      onChanged: (value) => email = value.trim(),
                    ),
                    SizedBox(height: 8),

                    // Campo Contraseña
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) => value!.length < 6
                          ? 'La contraseña debe tener al menos 6 caracteres'
                          : null,
                      onChanged: (value) => password = value.trim(),
                    ),
                    SizedBox(height: 16),

                    // Campo Rol
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: InputDecoration(labelText: 'Selecciona tu rol'),
                      items: [
                        DropdownMenuItem(value: 'volunteer', child: Text('Voluntario')),
                        DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          role = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Botón Registrar
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => isLoading = true);
                                try {
                                  final user = await AuthService()
                                      .registerWithEmailAndPassword(
                                    email,
                                    password,
                                    role,
                                  );

                                  // Guardar información adicional en Firestore
                                  if (user != null) {
                                    await AuthService().addUserDetails(
                                      uid: user.uid,
                                      name: name,
                                      age: age,
                                      phone: phone,
                                    );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Usuario registrado con éxito.'),
                                      ),
                                    );
                                    Navigator.pushReplacementNamed(context, '/login');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error al registrar el usuario. Intente nuevamente.'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error inesperado: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E2A47),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Registrarse',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
