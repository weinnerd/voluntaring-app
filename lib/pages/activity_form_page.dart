import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';

class ActivityFormPage extends StatefulWidget {
  final Activity? activity; 
  const ActivityFormPage({Key? key, this.activity}) : super(key: key);

  @override
  _ActivityFormPageState createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;
  DateTime? dateTime;
  String? category;
  String? location;
  int? maxVolunteers;
  String status = 'En curso'; 

  final List<String> categories = [
    'Educación',
    'Salud',
    'Medio Ambiente',
    'Cultura',
    'Nueva',
  ];

  final List<String> cities = [
    'Bogotá',
    'Medellín',
    'Cali',
    'Barranquilla',
    'Cartagena',
    'Bucaramanga',
    'Pereira',
    'Manizales',
    'Santa Marta',
    'Cúcuta',
  ];

  final List<String> statuses = ['En curso', 'Finalizada', 'Cancelada'];

  @override
  void initState() {
    super.initState();
    if (widget.activity != null) {
      title = widget.activity?.title ?? '';
      description = widget.activity?.description ?? '';
      dateTime = widget.activity?.dateTime ?? DateTime.now();
      category = widget.activity?.category;
      location = widget.activity?.location ?? '';
      maxVolunteers = widget.activity?.maxVolunteers ?? 0;
      status = widget.activity?.status ?? 'En curso';
    } else {
      dateTime = DateTime.now();
    }
  }

  Future<void> _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      final newActivity = Activity(
        id: widget.activity?.id ?? '',
        title: title!,
        description: description!,
        dateTime: dateTime!,
        location: location!,
        category: category!,
        maxVolunteers: maxVolunteers!,
        status: status,
      );

      try {
        if (widget.activity != null) {
          await FirestoreService().updateActivity(newActivity);
        } else {
          await FirestoreService().addActivity(newActivity);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la actividad: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A47),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A47),
        title: Text(
          widget.activity != null ? 'Editar Actividad' : 'Nueva Actividad',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
               
                TextFormField(
                  initialValue: title,
                  decoration: InputDecoration(
                    labelText: 'Título',
                    labelStyle: const TextStyle(color: Color(0xFF1E2A47)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF1E2A47)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Por favor, ingrese un título' : null,
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 16),

                
                TextFormField(
                  initialValue: description,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: const TextStyle(color: Color(0xFF1E2A47)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF1E2A47)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor, ingrese una descripción'
                      : null,
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: category,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: const TextStyle(color: Color(0xFF1E2A47)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF1E2A47)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor, seleccione una categoría' : null,
                ),
                const SizedBox(height: 16),

                
                DropdownButtonFormField<String>(
                  value: location,
                  decoration: InputDecoration(
                    labelText: 'Ubicación',
                    labelStyle: const TextStyle(color: Color(0xFF1E2A47)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF1E2A47)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      location = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Por favor, seleccione una ubicación' : null,
                ),
                const SizedBox(height: 16),

               
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    labelStyle: const TextStyle(color: Color(0xFF1E2A47)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF1E2A47)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                
                TextFormField(
                  initialValue: maxVolunteers != null
                      ? maxVolunteers.toString()
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Máximo de Voluntarios',
                    labelStyle: const TextStyle(color: Color(0xFF1E2A47)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF1E2A47)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor, ingrese un número válido'
                      : null,
                  onChanged: (value) => maxVolunteers = int.tryParse(value),
                ),
                const SizedBox(height: 16),

                
                ElevatedButton(
                  onPressed: _saveActivity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2A47),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    widget.activity != null
                        ? 'Guardar Cambios'
                        : 'Crear Actividad',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
