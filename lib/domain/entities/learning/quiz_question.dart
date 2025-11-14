// lib/domain/entities/learning/quiz_question.dart
import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
  });

  bool isCorrect(int selectedAnswer) => selectedAnswer == correctAnswer;

  @override
  List<Object?> get props => [question, options, correctAnswer, explanation];
}