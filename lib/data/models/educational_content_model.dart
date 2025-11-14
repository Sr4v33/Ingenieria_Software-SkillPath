// lib/data/models/educational_content_model.dart
import '../../domain/entities/learning/educational_content.dart';

class EducationalContentModel extends EducationalContent {
  const EducationalContentModel({
    required String title,
    required String content,
    required List<String> keyPoints,
    String videoUrl = '',
  }) : super(
    title: title,
    content: content,
    keyPoints: keyPoints,
    videoUrl: videoUrl,
  );

  factory EducationalContentModel.fromJson(Map<String, dynamic> json) {
    return EducationalContentModel(
      title: json['title'] as String,
      content: json['content'] as String,
      keyPoints: List<String>.from(json['keyPoints'] as List),
      videoUrl: json['videoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'keyPoints': keyPoints,
      'videoUrl': videoUrl,
    };
  }

  factory EducationalContentModel.fromEntity(EducationalContent entity) {
    return EducationalContentModel(
      title: entity.title,
      content: entity.content,
      keyPoints: entity.keyPoints,
      videoUrl: entity.videoUrl,
    );
  }
}