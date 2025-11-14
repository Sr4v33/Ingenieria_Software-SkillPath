// lib/domain/entities/learning/path_node.dart
import 'package:equatable/equatable.dart';
import 'node_status.dart';
import 'educational_content.dart';
import 'quiz_question.dart';

class PathNode extends Equatable {
  final String id;
  final String title;
  final String description;
  final NodeStatus status;
  final EducationalContent content;
  final List<QuizQuestion> questions;
  final bool contentViewed;
  final int? lastQuizScore;
  final DateTime? completedAt;

  const PathNode({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.content,
    required this.questions,
    this.contentViewed = false,
    this.lastQuizScore,
    this.completedAt,
  });

  // Getters de lógica de negocio
  bool get canTakeQuiz => contentViewed && status.isActive;
  bool get isClickable => !status.isLocked;

  // Métodos de dominio
  PathNode markContentAsViewed() {
    return PathNode(
      id: id,
      title: title,
      description: description,
      status: status,
      content: content,
      questions: questions,
      contentViewed: true,
      lastQuizScore: lastQuizScore,
      completedAt: completedAt,
    );
  }

  PathNode complete({required int quizScore}) {
    return PathNode(
      id: id,
      title: title,
      description: description,
      status: NodeStatus.completed,
      content: content,
      questions: questions,
      contentViewed: contentViewed,
      lastQuizScore: quizScore,
      completedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    content,
    questions,
    contentViewed,
    lastQuizScore,
    completedAt,
  ];
}