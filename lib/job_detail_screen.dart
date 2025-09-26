// job_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart'; // Importar paquete
import 'job_vacancy.dart';
import 'job_service.dart';

class JobDetailScreen extends StatefulWidget {
  final JobVacancy vacancy;

  JobDetailScreen({required this.vacancy});

  @override
  _JobDetailScreenState createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Future<Map<String, String>> _detailsFuture;
  final JobService _jobService = JobService();

  @override
  void initState() {
    super.initState();
    _detailsFuture = _jobService.fetchVacancyDetails(widget.vacancy.detailsUrl);
  }

  // --- FUNCIÓN PARA EL BOTÓN "APLICAR" ---
  Future<void> _launchURL(String url) async {
    // Imprime la URL en la consola para verificar que es correcta
    print('Intentando abrir la URL: $url');

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Muestra un error más informativo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el enlace: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Vacante'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      // --- BOTÓN FLOTANTE PARA APLICAR ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _launchURL(widget.vacancy.detailsUrl);
        },
        label: Text('Aplicar a la Vacante'),
        icon: Icon(Icons.open_in_new),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // Padding inferior para el botón
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.vacancy.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(widget.vacancy.company, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            SizedBox(height: 8),
            Text(widget.vacancy.location, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            Divider(height: 30, thickness: 1),

            FutureBuilder<Map<String, String>>(
              future: _detailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error al cargar detalles: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.containsKey('error')) {
                  return Text('No se encontraron detalles adicionales.');
                }

                final details = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Descripción General', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Html(data: details['description']),

                    if (details['responsibilities']!.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text('Responsabilidades', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Html(data: details['responsibilities']),
                    ],

                    if (details['requirements']!.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text('Requerimientos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Html(data: details['requirements']),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}