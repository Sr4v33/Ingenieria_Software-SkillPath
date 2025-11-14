// lib/data/models/path_node_model.dart
import '../../domain/entities/learning/path_node.dart';
import '../../domain/entities/learning/node_status.dart';
import 'educational_content_model.dart';
import 'quiz_question_model.dart';

class PathNodeModel extends PathNode {
  const PathNodeModel({
    required String id,
    required String title,
    required String description,
    required NodeStatus status,
    required EducationalContentModel content,
    required List<QuizQuestionModel> questions,
    bool contentViewed = false,
    int? lastQuizScore,
    DateTime? completedAt,
  }) : super(
    id: id,
    title: title,
    description: description,
    status: status,
    content: content,
    questions: questions,
    contentViewed: contentViewed,
    lastQuizScore: lastQuizScore,
    completedAt: completedAt,
  );

  factory PathNodeModel.fromJson(Map<String, dynamic> json) {
    return PathNodeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: NodeStatus.values[json['status'] as int],
      content: EducationalContentModel.fromJson(
        json['educationalContent'] as Map<String, dynamic>,
      ),
      questions: (json['questions'] as List)
          .map((q) => QuizQuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      contentViewed: json['contentViewed'] as bool? ?? false,
      lastQuizScore: json['lastQuizScore'] as int?,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
      'educationalContent': (content as EducationalContentModel).toJson(),
      'questions': questions
          .map((q) => (q as QuizQuestionModel).toJson())
          .toList(),
      'contentViewed': contentViewed,
      'lastQuizScore': lastQuizScore,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }

  factory PathNodeModel.fromEntity(PathNode entity) {
    return PathNodeModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      content: EducationalContentModel.fromEntity(entity.content),
      questions: entity.questions
          .map((q) => QuizQuestionModel.fromEntity(q))
          .toList(),
      contentViewed: entity.contentViewed,
      lastQuizScore: entity.lastQuizScore,
      completedAt: entity.completedAt,
    );
  }
}