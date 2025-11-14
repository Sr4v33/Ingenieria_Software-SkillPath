// lib/domain/entities/learning/educational_content.dart
import 'package:equatable/equatable.dart';

class EducationalContent extends Equatable {
  final String title;
  final String content;
  final List<String> keyPoints;
  final String videoUrl;

  const EducationalContent({
    required this.title,
    required this.content,
    required this.keyPoints,
    this.videoUrl = '',
  });

  @override
  List<Object?> get props => [title, content, keyPoints, videoUrl];
}