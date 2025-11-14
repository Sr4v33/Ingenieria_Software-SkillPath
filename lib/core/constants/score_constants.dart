// lib/core/constants/score_constants.dart
class ScoreConstants {
  // Puntos por actividad
  static const int quizCompletionPoints = 50;
  static const int contentReadingPoints = 20;
  static const int streakBonusPoints = 10;
  static const int nodeCompletionPoints = 100;

  // Requisitos
  static const int minimumPassingPercentage = 70;

  // Cálculos
  static int calculateQuizScore(int correctAnswers, int totalQuestions) {
    if (totalQuestions == 0) return 0;
    double percentage = correctAnswers / totalQuestions;
    return (quizCompletionPoints * percentage).round();
  }
}