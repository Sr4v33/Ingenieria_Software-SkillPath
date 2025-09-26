// job_vacancy.dart

class JobVacancy {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String detailsUrl; // URL para acceder a los detalles

  JobVacancy({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.detailsUrl,
  });

  // Factory constructor para crear una instancia desde un mapa JSON
  factory JobVacancy.fromJson(Map<String, dynamic> json) {
    // Extraemos la ciudad y el país, y los unimos.
    final city = json['city']?['name'] ?? 'N/A';
    final country = json['country']?['name'] ?? '';
    final location = '$city, $country';

    // Construimos la URL completa para los detalles del empleo
    final slug = json['slug'] ?? '';
    final detailsUrl = 'https://www.magneto365.com/co/empleo/$slug';

    return JobVacancy(
      title: json['name'] ?? 'N/A',
      company: json['company']?['name'] ?? 'Confidencial',
      location: location,
      salary: json['salaryRange']?['name'] ?? 'No especificado',
      detailsUrl: detailsUrl,
    );
  }
}