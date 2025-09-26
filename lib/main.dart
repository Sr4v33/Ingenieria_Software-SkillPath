import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'job_vacancy.dart';
import 'job_service.dart';
import 'job_detail_screen.dart';

void main() {
  runApp(SkillsPathApp());
}

class SkillsPathApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skills Path',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Iniciar con Home seleccionado
  final ProgressManager _progressManager = ProgressManager();

  // Se necesita un método para pasar el progressManager a las pantallas
  List<Widget> _screens() {
    return [
      JobsScreen(),
      HomeScreen(progressManager: _progressManager),
      LeaderboardScreen(progressManager: _progressManager),
      ProfileScreen(progressManager: _progressManager),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screens = _screens();

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey[500],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              activeIcon: Icon(Icons.work),
              label: 'Empleos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Ranking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// --- Modelos de Datos y Lógica de Negocio ---

// Enumeraciones para los estados de los nodos
enum NodeStatus {
  locked,    // Nodo bloqueado (gris)
  active,    // Nodo activo - siguiente a completar (bandera)
  completed, // Nodo completado (chulo)
  first      // Primer nodo (bombilla)
}

// Sistema de puntuación
class ScoreSystem {
  static const int QUIZ_COMPLETION_POINTS = 50;
  static const int CONTENT_READING_POINTS = 20;
  static const int STREAK_BONUS_POINTS = 10;
  static const int NODE_COMPLETION_POINTS = 100;

  static int calculateQuizScore(int correctAnswers, int totalQuestions) {
    double percentage = correctAnswers / totalQuestions;
    return (QUIZ_COMPLETION_POINTS * percentage).round();
  }
}

// Modelo para contenido educativo
class EducationalContent {
  final String title;
  final String content;
  final List<String> keyPoints;
  final String videoUrl;

  EducationalContent({
    required this.title,
    required this.content,
    required this.keyPoints,
    this.videoUrl = '',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'keyPoints': keyPoints,
    'videoUrl': videoUrl,
  };

  factory EducationalContent.fromJson(Map<String, dynamic> json) => EducationalContent(
    title: json['title'],
    content: json['content'],
    keyPoints: List<String>.from(json['keyPoints']),
    videoUrl: json['videoUrl'] ?? '',
  );
}

// Modelo mejorado para los nodos del camino
class PathNode {
  final int id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final EducationalContent educationalContent;
  NodeStatus status;
  bool contentViewed;
  int? lastQuizScore;
  DateTime? completedAt;

  PathNode({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.educationalContent,
    required this.status,
    this.contentViewed = false,
    this.lastQuizScore,
    this.completedAt,
  });

  IconData get icon {
    switch (status) {
      case NodeStatus.first: return Icons.lightbulb;
      case NodeStatus.active: return Icons.flag;
      case NodeStatus.completed: return Icons.check;
      case NodeStatus.locked: return Icons.lock;
    }
  }

  Color get backgroundColor {
    switch (status) {
      case NodeStatus.first:
      case NodeStatus.active: return Colors.blue[600]!;
      case NodeStatus.completed: return Colors.green[600]!;
      case NodeStatus.locked: return Colors.grey[400]!;
    }
  }

  Color get iconColor {
    switch (status) {
      case NodeStatus.first:
      case NodeStatus.active:
      case NodeStatus.completed: return Colors.white;
      case NodeStatus.locked: return Colors.grey[600]!;
    }
  }

  bool get isClickable => status != NodeStatus.locked;
  bool get canTakeQuiz => contentViewed && (status == NodeStatus.first || status == NodeStatus.active);

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'questions': questions.map((q) => q.toJson()).toList(),
    'educationalContent': educationalContent.toJson(),
    'status': status.index, 'contentViewed': contentViewed,
    'lastQuizScore': lastQuizScore,
    'completedAt': completedAt?.millisecondsSinceEpoch,
  };

  factory PathNode.fromJson(Map<String, dynamic> json) => PathNode(
    id: json['id'], title: json['title'], description: json['description'],
    questions: (json['questions'] as List).map((q) => QuizQuestion.fromJson(q)).toList(),
    educationalContent: EducationalContent.fromJson(json['educationalContent']),
    status: NodeStatus.values[json['status']],
    contentViewed: json['contentViewed'] ?? false,
    lastQuizScore: json['lastQuizScore'],
    completedAt: json['completedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['completedAt']) : null,
  );
}

// Modelo mejorado para las preguntas del quiz
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
  });

  Map<String, dynamic> toJson() => {
    'question': question, 'options': options,
    'correctAnswer': correctAnswer, 'explanation': explanation,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    question: json['question'],
    options: List<String>.from(json['options']),
    correctAnswer: json['correctAnswer'],
    explanation: json['explanation'] ?? '',
  );
}

// Modelo para estadísticas del usuario
class UserStats {
  int totalPoints;
  int streak;
  int totalNodesCompleted;
  DateTime lastActivity;
  Map<String, int> skillScores;

  UserStats({
    this.totalPoints = 0, this.streak = 0, this.totalNodesCompleted = 0,
    DateTime? lastActivity, Map<String, int>? skillScores,
  }) : this.lastActivity = lastActivity ?? DateTime.now(),
        this.skillScores = skillScores ?? {};

  Map<String, dynamic> toJson() => {
    'totalPoints': totalPoints, 'streak': streak,
    'totalNodesCompleted': totalNodesCompleted,
    'lastActivity': lastActivity.millisecondsSinceEpoch,
    'skillScores': skillScores,
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalPoints: json['totalPoints'] ?? 0, streak: json['streak'] ?? 0,
    totalNodesCompleted: json['totalNodesCompleted'] ?? 0,
    lastActivity: json['lastActivity'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['lastActivity'])
        : DateTime.now(),
    skillScores: Map<String, int>.from(json['skillScores'] ?? {}),
  );
}

// Gestor de progreso del usuario con persistencia
class ProgressManager {
  static final ProgressManager _instance = ProgressManager._internal();
  factory ProgressManager() => _instance;
  ProgressManager._internal();

  List<PathNode> _nodes = [];
  UserStats _userStats = UserStats();
  bool _isLoaded = false;

  List<PathNode> get nodes => _nodes;
  UserStats get userStats => _userStats;

  Future<void> _ensureLoaded() async {
    if (!_isLoaded) {
      await loadProgress();
    }
  }

  Future<void> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nodesJson = prefs.getString('nodes');
      if (nodesJson != null) {
        final nodesList = jsonDecode(nodesJson) as List;
        _nodes = nodesList.map((node) => PathNode.fromJson(node)).toList();
      } else {
        _initializeNodes();
      }
      final statsJson = prefs.getString('userStats');
      if (statsJson != null) {
        _userStats = UserStats.fromJson(jsonDecode(statsJson));
      }
    } catch (e) {
      print('Error al cargar progreso: $e');
      _initializeNodes();
    } finally {
      _isLoaded = true;
    }
  }

  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nodesJson = jsonEncode(_nodes.map((n) => n.toJson()).toList());
      await prefs.setString('nodes', nodesJson);
      final statsJson = jsonEncode(_userStats.toJson());
      await prefs.setString('userStats', statsJson);
    } catch (e) {
      print('Error al guardar progreso: $e');
    }
  }

  void _initializeNodes() {
    _nodes = [
      PathNode(
        id: 1, title: "Introducción",
        description: "Aprende los fundamentos de las habilidades blandas y su importancia.",
        status: NodeStatus.first,
        educationalContent: EducationalContent(
          title: "Fundamentos de Habilidades Blandas",
          content: "Las habilidades blandas son competencias interpersonales, sociales y emocionales que determinan cómo nos relacionamos. A diferencia de las habilidades técnicas, son transferibles y aplicables en cualquier industria. Incluyen comunicación, trabajo en equipo, liderazgo, y son tan importantes como las habilidades técnicas.",
          keyPoints: ["Son competencias interpersonales", "Son transferibles", "Incluyen comunicación, liderazgo, etc.", "Son cruciales en el mundo laboral actual"],
        ),
        questions: [
          QuizQuestion(question: "¿Qué son las habilidades blandas?", options: ["Técnicas", "Interpersonales", "Académicas", "Certificaciones"], correctAnswer: 1, explanation: "Se centran en la interacción humana."),
          QuizQuestion(question: "¿Por qué son importantes?", options: ["Solo para gerentes", "Mejoran colaboración y productividad", "No son importantes", "Solo para ventas"], correctAnswer: 1, explanation: "Son esenciales para cualquier rol."),
        ],
      ),
      PathNode(
        id: 2, title: "Comunicación Efectiva",
        description: "Desarrolla comunicación clara, asertiva y empática.",
        status: NodeStatus.locked,
        educationalContent: EducationalContent(
          title: "Comunicación Efectiva en el Trabajo",
          content: "La comunicación efectiva es la base de las relaciones profesionales exitosas. Implica transmitir ideas claramente, escuchar activamente y adaptar el mensaje a la audiencia. La escucha activa, la comunicación asertiva y el feedback constructivo son claves.",
          keyPoints: ["Va más allá de hablar", "La escucha activa es fundamental", "La comunicación asertiva es clave", "El feedback constructivo fomenta el crecimiento"],
        ),
        questions: [
          QuizQuestion(question: "¿Qué es la escucha activa?", options: ["Escuchar con distracciones", "Prestar atención completa", "Interrumpir", "Escuchar ideas principales"], correctAnswer: 1, explanation: "Requiere dedicar toda nuestra atención."),
          QuizQuestion(question: "¿Qué es la comunicación asertiva?", options: ["Ser agresivo", "Evitar conflictos", "Expresar opiniones con respeto", "Nunca opinar"], correctAnswer: 2, explanation: "Permite expresar pensamientos de manera directa y respetuosa."),
        ],
      ),
      PathNode(
        id: 3, title: "Trabajo en Equipo",
        description: "Aprende a colaborar, resolver conflictos y contribuir al éxito grupal.",
        status: NodeStatus.locked,
        educationalContent: EducationalContent(
          title: "Colaboración y Trabajo en Equipo",
          content: "El trabajo en equipo efectivo implica colaboración genuina, comunicación abierta y un compromiso compartido con los objetivos del grupo. Roles claros, objetivos definidos y una buena resolución de conflictos son cruciales.",
          keyPoints: ["Va más allá de trabajar juntos", "Roles y objetivos claros son esenciales", "Los conflictos deben ser constructivos", "La confianza mutua es la base"],
        ),
        questions: [
          QuizQuestion(question: "¿Cuál es la clave del trabajo en equipo?", options: ["Competir", "Trabajar solo", "Comunicación y objetivos compartidos", "Decisiones unilaterales"], correctAnswer: 2, explanation: "Se basa en la comunicación transparente y el compromiso compartido."),
        ],
      ),
      PathNode(
        id: 4, title: "Liderazgo",
        description: "Desarrolla liderazgo, toma de decisiones y motivación de equipos.",
        status: NodeStatus.locked,
        educationalContent: EducationalContent(
          title: "Liderazgo y Desarrollo de Equipos",
          content: "El liderazgo efectivo no es sobre autoridad, sino sobre inspirar, guiar y empoderar. Un buen líder escucha, delega, y crea un ambiente de crecimiento. La inteligencia emocional es fundamental.",
          keyPoints: ["Es inspirar y empoderar", "Los buenos líderes escuchan", "La inteligencia emocional es fundamental", "Saber delegar es clave"],
        ),
        questions: [
          QuizQuestion(question: "¿Qué caracteriza a un buen líder?", options: ["Controlar todo", "Inspirar y empoderar", "Decidir solo", "No dar feedback"], correctAnswer: 1, explanation: "Inspira confianza y empodera a su equipo."),
        ],
      ),
      PathNode(
        id: 5, title: "Meta Final",
        description: "¡Felicidades! Has completado tu ruta de desarrollo.",
        status: NodeStatus.locked,
        educationalContent: EducationalContent(
          title: "Celebrando tu Éxito",
          content: "Has completado exitosamente tu ruta de desarrollo. Las competencias adquiridas te servirán en cualquier entorno profesional. Recuerda que el desarrollo de habilidades es un proceso continuo.",
          keyPoints: ["Has completado tu desarrollo", "Son competencias aplicables en cualquier entorno", "El desarrollo es un proceso continuo", "Aplica lo aprendido"],
        ),
        questions: [],
      ),
    ];
    _userStats = UserStats(); // Reinicia estadísticas también
  }

  Future<void> markContentAsViewed(int nodeId) async {
    await _ensureLoaded();
    final nodeIndex = _nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex != -1 && !_nodes[nodeIndex].contentViewed) {
      _nodes[nodeIndex].contentViewed = true;
      _userStats.totalPoints += ScoreSystem.CONTENT_READING_POINTS;
      _userStats.lastActivity = DateTime.now();
      await saveProgress();
    }
  }

  Future<void> completeNode(int nodeId, bool quizPassed, {int? quizScore}) async {
    await _ensureLoaded();
    final nodeIndex = _nodes.indexWhere((n) => n.id == nodeId);
    if (nodeIndex != -1 && _nodes[nodeIndex].status != NodeStatus.completed) {
      if (quizPassed) {
        _nodes[nodeIndex].status = NodeStatus.completed;
        _nodes[nodeIndex].completedAt = DateTime.now();
        _nodes[nodeIndex].lastQuizScore = quizScore;

        _userStats.totalPoints += ScoreSystem.NODE_COMPLETION_POINTS;
        if (quizScore != null) {
          _userStats.totalPoints += ScoreSystem.calculateQuizScore(
              (quizScore / 100 * _nodes[nodeIndex].questions.length).round(),
              _nodes[nodeIndex].questions.length);
        }
        _userStats.totalNodesCompleted++;
        _userStats.lastActivity = DateTime.now();

        final skillName = _nodes[nodeIndex].title;
        _userStats.skillScores[skillName] = quizScore ?? 0;

        _unlockNextNode(nodeIndex);
      }
      await saveProgress();
    }
  }

  void _unlockNextNode(int currentIndex) {
    if (currentIndex + 1 < _nodes.length) {
      final nextNode = _nodes[currentIndex + 1];
      if (nextNode.status == NodeStatus.locked) {
        nextNode.status = NodeStatus.active;
      }
    }
  }

  double get progressPercentage {
    if (_nodes.isEmpty) return 0.0;
    final totalLearnableNodes = _nodes.length - 1;
    if (totalLearnableNodes <= 0) return 0.0;
    final completedNodes = _nodes.where((n) => n.status == NodeStatus.completed).length;
    return completedNodes / totalLearnableNodes;
  }

  int get completedNodesCount => _nodes.where((n) => n.status == NodeStatus.completed).length;
  int get totalLearnableNodes => _nodes.length - 1;

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoaded = false;
    await _ensureLoaded();
  }
}

// --- Widgets de la Interfaz de Usuario ---

// Pantalla de Inicio
class HomeScreen extends StatefulWidget {
  final ProgressManager progressManager;
  HomeScreen({required this.progressManager});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await widget.progressManager.loadProgress();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reset() async {
    await widget.progressManager.resetProgress();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Reiniciar Progreso"),
                    content: Text("¿Estás seguro de que quieres borrar todo tu progreso? Esta acción no se puede deshacer."),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
                      TextButton(onPressed: () {
                        _reset();
                        Navigator.pop(context);
                      }, child: Text("Reiniciar")),
                    ],
                  ),
                );
              },
              child: Icon(Icons.info_outline, color: Colors.blue[700]),
            ),
            SizedBox(width: 8),
            Text('¡Añade tu LinkedIn!', style: TextStyle(color: Colors.blue[700], fontSize: 18, fontWeight: FontWeight.w600)),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.amber[700], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('${widget.progressManager.userStats.totalPoints}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tu Progreso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                        Text('${widget.progressManager.completedNodesCount}/${widget.progressManager.totalLearnableNodes}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: widget.progressManager.progressPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: LearningPath(
                      progressManager: widget.progressManager,
                      onNodeCompleted: () => setState(() {}),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(bottom: 20, right: 20, child: PlantWidget(progressManager: widget.progressManager)),
        ],
      ),
    );
  }
}

// Widget del camino de aprendizaje
class LearningPath extends StatelessWidget {
  final ProgressManager progressManager;
  final VoidCallback onNodeCompleted;

  LearningPath({required this.progressManager, required this.onNodeCompleted});

  @override
  Widget build(BuildContext context) {
    final nodes = progressManager.nodes;
    return Column(
      children: [
        SizedBox(height: 20),
        ...nodes.asMap().entries.map((entry) {
          int index = entry.key;
          PathNode node = entry.value;
          bool isLast = index == nodes.length - 1;
          return Column(
            children: [
              PathNodeWidget(
                node: node,
                onTap: () {
                  if (node.isClickable) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => NodeDetailScreen(node: node, progressManager: progressManager, onNodeCompleted: onNodeCompleted),
                    )).then((_) => onNodeCompleted());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Completa los nodos anteriores para desbloquear este.'), backgroundColor: Colors.orange),
                    );
                  }
                },
              ),
              if (!isLast) PathConnector(isActive: node.status != NodeStatus.locked),
            ],
          );
        }).toList(),
        SizedBox(height: 100),
      ],
    );
  }
}

// Widget de un nodo individual
class PathNodeWidget extends StatelessWidget {
  final PathNode node;
  final VoidCallback onTap;

  PathNodeWidget({required this.node, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: node.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: node.isClickable ? [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 2, blurRadius: 8, offset: Offset(0, 4))] : null,
            ),
            child: Icon(node.icon, color: node.iconColor, size: 32),
          ),
          SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(maxWidth: 120),
            child: Text(
              node.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: node.isClickable ? Colors.grey[800] : Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}

// Conector entre nodos
class PathConnector extends StatelessWidget {
  final bool isActive;
  PathConnector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4, height: 60,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: isActive ? [Colors.blue[400]!, Colors.blue[600]!] : [Colors.grey[300]!, Colors.grey[400]!],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Widget de la planta (Gamificación)
class PlantWidget extends StatelessWidget {
  final ProgressManager progressManager;
  PlantWidget({required this.progressManager});

  @override
  Widget build(BuildContext context) {
    final totalPoints = progressManager.userStats.totalPoints;
    IconData plantIcon;
    Color plantColor;

    if (totalPoints >= 500) {
      plantIcon = Icons.local_florist;
      plantColor = Colors.pinkAccent;
    } else if (totalPoints >= 200) {
      plantIcon = Icons.eco;
      plantColor = Colors.green[600]!;
    } else if (totalPoints >= 50) {
      plantIcon = Icons.grass;
      plantColor = Colors.lightGreen;
    } else {
      plantIcon = Icons.energy_savings_leaf;
      plantColor = Colors.green[300]!;
    }

    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (context) => AlertDialog(
          title: Row(children: [Icon(plantIcon, color: plantColor), SizedBox(width: 8), Text('Mi Planta')]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estado: ${_getPlantStatus(totalPoints)}'),
              SizedBox(height: 8),
              Text('Puntos totales: $totalPoints'),
              SizedBox(height: 12),
              LinearProgressIndicator(value: (totalPoints % 200) / 200.0, backgroundColor: Colors.grey[300], valueColor: AlwaysStoppedAnimation<Color>(plantColor)),
              SizedBox(height: 4),
              Text('Siguiente nivel en ${200 - (totalPoints % 200)} puntos', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Cerrar'))],
        ));
      },
      child: Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: plantColor, width: 3),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 2, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Icon(plantIcon, color: plantColor, size: 28),
      ),
    );
  }

  String _getPlantStatus(int points) {
    if (points >= 500) return '¡En plena floración!';
    if (points >= 200) return 'Creciendo fuerte';
    if (points >= 50) return 'Brotando';
    return 'Germinando';
  }
}

// Pantalla de Detalle del Nodo (Contenido Educativo)
class NodeDetailScreen extends StatefulWidget {
  final PathNode node;
  final ProgressManager progressManager;
  final VoidCallback onNodeCompleted;

  NodeDetailScreen({required this.node, required this.progressManager, required this.onNodeCompleted});
  @override
  _NodeDetailScreenState createState() => _NodeDetailScreenState();
}

class _NodeDetailScreenState extends State<NodeDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isQuizButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _isQuizButtonEnabled = widget.node.contentViewed;

    // Añadimos un listener para el scroll (para contenido largo)
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Si _isQuizButtonEnabled ya es true, no hacemos nada
      if (_isQuizButtonEnabled) return;

      // Si el contenido no necesita scroll (maxScrollExtent es 0),
      // significa que ya es completamente visible.
      if (_scrollController.position.maxScrollExtent == 0) {
        // Habilitamos el botón y marcamos el contenido como visto
        _enableButtonAndMarkAsRead();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Lógica para contenido largo
  void _onScroll() {
    if (_isQuizButtonEnabled) return; // Si ya está habilitado, no hacer nada más

    // Si el usuario ha llegado casi al final del contenido
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      _enableButtonAndMarkAsRead();
    }
  }

  void _enableButtonAndMarkAsRead() {
    if (mounted && !_isQuizButtonEnabled) {
      setState(() {
        _isQuizButtonEnabled = true;
      });
      widget.progressManager.markContentAsViewed(widget.node.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡+${ScoreSystem.CONTENT_READING_POINTS} puntos por leer!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.node.status == NodeStatus.completed) {
      return _buildCompletedNodeScreen(context);
    }
    return _buildActiveNodeScreen(context);
  }

  Widget _buildActiveNodeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.node.title), backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.node.educationalContent.title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text(widget.node.educationalContent.content, style: TextStyle(fontSize: 16, height: 1.6)),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Puntos Clave:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                  SizedBox(height: 12),
                  ...widget.node.educationalContent.keyPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(children: [
                      Icon(Icons.check_circle_outline, color: Colors.blue[600], size: 18),
                      SizedBox(width: 8),
                      Expanded(child: Text(point, style: TextStyle(fontSize: 14))),
                    ]),
                  )),
                ],
              ),
            ),
            SizedBox(height: 100), // Espacio para el botón flotante
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        color: Colors.white,
        child: ElevatedButton(
          onPressed: _isQuizButtonEnabled ? () {
            if (widget.node.questions.isNotEmpty) {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => QuizScreen(node: widget.node, progressManager: widget.progressManager, onNodeCompleted: widget.onNodeCompleted),
              ));
            } else {
              widget.progressManager.completeNode(widget.node.id, true);
              widget.onNodeCompleted();
              Navigator.pop(context);
            }
          } : null,
          child: Text(widget.node.questions.isNotEmpty ? 'Ir al Cuestionario' : 'Completar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300], // Color cuando está deshabilitado
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedNodeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.node.title), backgroundColor: Colors.green[600], foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green[200]!)),
              child: Row(children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 30),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¡Nodo Completado!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700])),
                      if (widget.node.lastQuizScore != null)
                        Text('Puntuación: ${widget.node.lastQuizScore}%', style: TextStyle(fontSize: 16, color: Colors.green[600])),
                    ],
                  ),
                ),
              ]),
            ),
            SizedBox(height: 24),
            Text('Resumen: ${widget.node.educationalContent.title}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Has completado exitosamente este módulo.', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

// Pantalla del Cuestionario
class QuizScreen extends StatefulWidget {
  final PathNode node;
  final ProgressManager progressManager;
  final VoidCallback onNodeCompleted;

  QuizScreen({required this.node, required this.progressManager, required this.onNodeCompleted});
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  late List<int?> selectedAnswers;
  bool quizCompleted = false;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    selectedAnswers = List.filled(widget.node.questions.length, null);
  }

  void selectAnswer(int answerIndex) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = answerIndex;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < widget.node.questions.length - 1) {
      setState(() => currentQuestionIndex++);
    } else {
      completeQuiz();
    }
  }

  void completeQuiz() {
    correctAnswers = 0;
    for (int i = 0; i < widget.node.questions.length; i++) {
      if (selectedAnswers[i] == widget.node.questions[i].correctAnswer) {
        correctAnswers++;
      }
    }
    double percentage = correctAnswers / widget.node.questions.length;
    bool passed = percentage >= 0.7;
    int quizScore = (percentage * 100).round();

    widget.progressManager.completeNode(widget.node.id, passed, quizScore: quizScore);
    widget.onNodeCompleted();

    setState(() => quizCompleted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return _buildQuizResultScreen();
    }
    final question = widget.node.questions[currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(title: Text('Quiz: ${widget.node.title}'), backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Pregunta ${currentQuestionIndex + 1} de ${widget.node.questions.length}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600])),
            SizedBox(height: 32),
            Text(question.question, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedAnswers[currentQuestionIndex] == index;
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => selectAnswer(index),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[50] : Colors.white,
                          border: Border.all(color: isSelected ? Colors.blue[600]! : Colors.grey[300]!, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(children: [
                          Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: isSelected ? Colors.blue[600]! : Colors.grey[400]!),
                          SizedBox(width: 12),
                          Expanded(child: Text(question.options[index], style: TextStyle(fontSize: 16))),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: selectedAnswers[currentQuestionIndex] != null ? nextQuestion : null,
                child: Text(currentQuestionIndex == widget.node.questions.length - 1 ? 'Finalizar Cuestionario' : 'Siguiente'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizResultScreen() {
    double percentage = correctAnswers / widget.node.questions.length;
    bool passed = percentage >= 0.7;
    return Scaffold(
      appBar: AppBar(title: Text('Cuestionario Completo'), backgroundColor: passed ? Colors.green[600] : Colors.red[600], foregroundColor: Colors.white, automaticallyImplyLeading: false),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(passed ? Icons.check_circle_outline : Icons.highlight_off, color: passed ? Colors.green[600] : Colors.red[600], size: 80),
              SizedBox(height: 24),
              Text(passed ? '¡Felicitaciones!' : 'Sigue Intentando', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Tu puntuación: ${(percentage * 100).round()}%', style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),
              Text(passed ? '¡Has aprobado y desbloqueado el siguiente nivel!' : 'Necesitas al menos 70% para aprobar.', textAlign: TextAlign.center),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Cierra la pantalla del quiz y la de detalle del nodo, volviendo al home
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text('Volver al Inicio'),
                  style: ElevatedButton.styleFrom(backgroundColor: passed ? Colors.green[600] : Colors.blue[600], foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JobsScreen extends StatefulWidget {
  @override
  _JobsScreenState createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  late Future<List<JobVacancy>> _vacanciesFuture;
  final JobService _jobService = JobService();

  @override
  void initState() {
    super.initState();
    _vacanciesFuture = _jobService.fetchVacancies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacantes Disponibles'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<JobVacancy>>(
        future: _vacanciesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron vacantes.'));
          }

          final vacancies = snapshot.data!;
          return ListView.builder(
            itemCount: vacancies.length,
            itemBuilder: (context, index) {
              final vacancy = vacancies[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 3,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Icon(Icons.work, color: Colors.blue[700]),
                  title: Text(vacancy.title, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(vacancy.company, style: TextStyle(color: Colors.grey[800])),
                      SizedBox(height: 5),
                      Text(vacancy.location),
                      SizedBox(height: 8),
                      Text(vacancy.salary, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.green[700])),
                    ],
                  ),
                  onTap: () {
                    // HUF25: Navegación a la pantalla de detalles
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailScreen(vacancy: vacancy),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  final ProgressManager progressManager;
  LeaderboardScreen({required this.progressManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ranking'), backgroundColor: Colors.blue[600], foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue[600]!, Colors.blue[800]!]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Puntos', '${progressManager.userStats.totalPoints}', Icons.star),
                  _buildStat('Posición', '#1', Icons.emoji_events), // Placeholder
                  _buildStat('Racha', '${progressManager.userStats.streak} Días', Icons.local_fire_department), // Placeholder
                ],
              ),
            ),
            SizedBox(height: 24),
            Text("Tabla de Clasificación (Próximamente)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 8),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white70)),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final ProgressManager progressManager;
  ProfileScreen({required this.progressManager});

  @override
  Widget build(BuildContext context) {
    final stats = progressManager.userStats;
    final progress = progressManager.progressPercentage;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sección de Información del Usuario ---
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue[600],
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Candidato Aspirante',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Desarrollando habilidades blandas',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // --- Estadísticas rápidas ---
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Nodos Completados',
                    '${progressManager.completedNodesCount}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  // NUEVO: Se utiliza el nuevo widget para la barra de progreso
                  child: _buildProgressStatCard(
                    'Progreso Total',
                    progress, // Se pasa el valor de progreso (ej. 0.5 para 50%)
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // --- Puntajes por Habilidad ---
            Text(
              'Puntajes por Habilidad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            if (stats.skillScores.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.school, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 12),
                    Text(
                      'Aún no has completado ninguna habilidad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...stats.skillScores.entries.map((entry) => Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _getScoreColor(entry.value).withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getScoreColor(entry.value),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(entry.value),
                      ),
                    ),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  // --- Widget para las tarjetas de estadísticas (sin cambios) ---
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // --- NUEVO: Widget específico para la tarjeta de progreso ---
  Widget _buildProgressStatCard(String title, double progress, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // --- Lógica para colorear el puntaje (sin cambios) ---
  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}