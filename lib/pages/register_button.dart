import 'package:flutter/material.dart';
import 'participant_service.dart';

class RegisterButton extends StatelessWidget {
  final String activityId;
  final String email;

  const RegisterButton({required this.activityId, required this.email});

  @override
  Widget build(BuildContext context) {
    final participantService = ParticipantService();

    return FutureBuilder<bool>(
      future: participantService.isUserRegistered(activityId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            'Error al cargar el estado de inscripción.',
            style: TextStyle(color: Colors.red),
          );
        }

        final isRegistered = snapshot.data ?? false;

        return isRegistered
            ? Text(
                'Ya estás registrado en esta actividad.',
                style: TextStyle(color: Colors.green, fontSize: 16),
              )
            : ElevatedButton(
                onPressed: () async {
                  final result = await participantService.registerForActivity(
                    activityId,
                    email,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                },
                child: Text('Inscribirme'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              );
      },
    );
  }
}
