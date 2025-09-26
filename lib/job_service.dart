// job_service.dart

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'job_vacancy.dart'; // Asegúrate de que la ruta sea correcta

class JobService {
  final String _baseUrl = 'https://www.magneto365.com/co/empleos';

  // fetchVacancies() no cambia, déjala como estaba en la respuesta anterior.
  Future<List<JobVacancy>> fetchVacancies() async {
    // ... (El código de esta función de la respuesta anterior se mantiene igual)
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        dom.Document document = parser.parse(response.body);
        final List<dom.Element> jobCards = document.querySelectorAll('div.mg_job_card_desktop_magneto-ui-card-jobs_container_1dxqo');
        if (jobCards.isEmpty) {
          throw Exception('No se encontraron tarjetas de empleo con el selector actual. La estructura de la página pudo haber cambiado.');
        }
        final List<JobVacancy> vacancies = [];
        for (var card in jobCards) {
          final titleElement = card.querySelector('a.mg_job_card_desktop_magneto-ui-card-jobs_a_1dxqo');
          final title = titleElement?.text.trim() ?? 'Título no disponible';
          final detailsUrl = titleElement?.attributes['href'] ?? '';
          final companyString = card.querySelector('h3.mg_job_card_desktop_magneto-ui-card-jobs_text_1dxqo')?.text.trim() ?? 'Empresa no disponible';
          final company = companyString.split('|').first.trim();
          final paragraphs = card.querySelectorAll('p.mg_job_card_desktop_magneto-ui-card-jobs_text_1dxqo');
          final salary = paragraphs.isNotEmpty ? paragraphs[0].text.trim() : 'Salario no especificado';
          final location = paragraphs.length > 1 ? paragraphs[1].text.trim() : 'Ubicación no especificada';
          vacancies.add(
            JobVacancy(
              title: title,
              company: company,
              location: location,
              salary: salary,
              detailsUrl: detailsUrl.startsWith('http') ? detailsUrl : 'https://www.magneto365.com$detailsUrl',
            ),
          );
        }
        return vacancies;
      } else {
        throw Exception('Error al cargar la página de empleos (Código: ${response.statusCode}).');
      }
    } catch (e) {
      throw Exception('Ocurrió un error al obtener las vacantes: $e');
    }
  }


  // --- FUNCIÓN ACTUALIZADA ---
  // HUF25: Obtiene los detalles de manera estructurada
  Future<Map<String, String>> fetchVacancyDetails(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        dom.Document document = parser.parse(response.body);

        // Contenedor principal de los detalles
        final detailCard = document.querySelector('div.mg_job_detail_card_magneto-ui-job-detail-card_12ovn');

        if (detailCard == null) {
          return {'error': 'No se pudo encontrar el contenedor de detalles.'};
        }

        // Función auxiliar para extraer el contenido de una sección (ej. "Responsabilidades")
        String extractSection(String title) {
          final element = detailCard.querySelectorAll('strong').firstWhere(
                (el) => el.text.trim().contains(title),
            orElse: () => dom.Element.html('<div></div>'), // Devuelve un elemento vacío si no lo encuentra
          );
          // El contenido suele estar en el elemento <ul> que sigue al <strong>
          final content = element.nextElementSibling?.outerHtml;
          return content ?? '';
        }

        // Extraer la descripción principal (párrafo inicial)
        final description = detailCard.querySelector('p')?.outerHtml ?? 'No disponible.';

        return {
          'description': description,
          'responsibilities': extractSection('Responsabilidades'),
          'requirements': extractSection('Requerimientos'),
        };
      } else {
        throw Exception('Error al cargar los detalles (Código: ${response.statusCode}).');
      }
    } catch (e) {
      throw Exception('Ocurrió un error al obtener los detalles: $e');
    }
  }
}