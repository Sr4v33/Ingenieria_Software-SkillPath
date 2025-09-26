import 'package:flutter/material.dart';

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
  int _selectedIndex = 1; // Start with Home selected
  final ProgressManager _progressManager = ProgressManager();

  final List<Widget> _screens = [
    JobsScreen(),
    HomeScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
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
              label: 'Jobs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Leaderboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Enumeraciones para los estados de los nodos
enum NodeStatus {
  locked,    // Nodo bloqueado (gris)
  active,    // Nodo activo - siguiente a completar (bandera)
  completed, // Nodo completado (chulo)
  first      // Primer nodo (bombilla)
}

// Modelo para los nodos del camino
class PathNode {
  final int id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  NodeStatus status;

  PathNode({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.status,
  });

  // Obtener el ícono según el estado
  IconData get icon {
    switch (status) {
      case NodeStatus.first:
        return Icons.lightbulb;
      case NodeStatus.active:
        return Icons.flag;
      case NodeStatus.completed:
        return Icons.check;
      case NodeStatus.locked:
        return Icons.lock;
    }
  }

  // Obtener color según el estado
  Color get backgroundColor {
    switch (status) {
      case NodeStatus.first:
      case NodeStatus.active:
        return Colors.blue[600]!;
      case NodeStatus.completed:
        return Colors.green[600]!;
      case NodeStatus.locked:
        return Colors.grey[400]!;
    }
  }

  Color get iconColor {
    switch (status) {
      case NodeStatus.first:
      case NodeStatus.active:
      case NodeStatus.completed:
        return Colors.white;
      case NodeStatus.locked:
        return Colors.grey[600]!;
    }
  }

  // Verificar si el nodo es clickeable
  bool get isClickable {
    return status == NodeStatus.first ||
        status == NodeStatus.active ||
        status == NodeStatus.completed;
  }
}

// Modelo para las preguntas del quiz
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer; // Índice de la respuesta correcta

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

// Gestor de progreso del usuario
class ProgressManager {
  static final ProgressManager _instance = ProgressManager._internal();
  factory ProgressManager() => _instance;
  ProgressManager._internal();

  List<PathNode> _nodes = [];

  // Inicializar los nodos con datos de ejemplo
  List<PathNode> get nodes {
    if (_nodes.isEmpty) {
      _initializeNodes();
    }
    return _nodes;
  }

  void _initializeNodes() {
    _nodes = [
      PathNode(
        id: 1,
        title: "Introducción",
        description: "Aprende los fundamentos de las habilidades blandas y su importancia en el entorno laboral.",
        status: NodeStatus.first,
        questions: [
          QuizQuestion(
            question: "¿Cuál es la característica principal de las habilidades blandas?",
            options: [
              "Son habilidades técnicas específicas",
              "Son habilidades interpersonales y de comunicación",
              "Son conocimientos académicos",
              "Son certificaciones profesionales"
            ],
            correctAnswer: 1,
          ),
          QuizQuestion(
            question: "¿Por qué son importantes las habilidades blandas en el trabajo?",
            options: [
              "Solo para puestos gerenciales",
              "Para mejorar la colaboración y productividad",
              "No son importantes",
              "Solo para trabajos de ventas"
            ],
            correctAnswer: 1,
          ),
        ],
      ),
      PathNode(
        id: 2,
        title: "Comunicación Efectiva",
        description: "Desarrolla habilidades de comunicación clara, asertiva y empática.",
        status: NodeStatus.locked,
        questions: [
          QuizQuestion(
            question: "¿Qué es la escucha activa?",
            options: [
              "Escuchar mientras haces otras tareas",
              "Prestar atención completa y responder apropiadamente",
              "Interrumpir frecuentemente",
              "Solo escuchar las ideas principales"
            ],
            correctAnswer: 1,
          ),
          QuizQuestion(
            question: "¿Cuál es una característica de la comunicación asertiva?",
            options: [
              "Ser agresivo para obtener lo que quieres",
              "Evitar conflictos a toda costa",
              "Expresar opiniones de manera respetuosa y directa",
              "Nunca dar tu opinión"
            ],
            correctAnswer: 2,
          ),
        ],
      ),
      PathNode(
        id: 3,
        title: "Trabajo en Equipo",
        description: "Aprende a colaborar efectivamente, resolver conflictos y contribuir al éxito grupal.",
        status: NodeStatus.locked,
        questions: [
          QuizQuestion(
            question: "¿Cuál es la clave del trabajo en equipo exitoso?",
            options: [
              "Competir con los compañeros",
              "Trabajar solo para evitar conflictos",
              "Comunicación abierta y objetivos compartidos",
              "Dejar que una persona tome todas las decisiones"
            ],
            correctAnswer: 2,
          ),
        ],
      ),
      PathNode(
        id: 4,
        title: "Liderazgo",
        description: "Desarrolla habilidades de liderazgo, toma de decisiones y motivación de equipos.",
        status: NodeStatus.locked,
        questions: [
          QuizQuestion(
            question: "¿Qué caracteriza a un buen líder?",
            options: [
              "Controlar todos los aspectos del trabajo",
              "Inspirar y empoderar a otros",
              "Tomar todas las decisiones solo",
              "Evitar dar feedback"
            ],
            correctAnswer: 1,
          ),
        ],
      ),
      PathNode(
        id: 5,
        title: "Meta Final",
        description: "¡Felicitaciones! Has completado tu ruta de desarrollo de habilidades blandas.",
        status: NodeStatus.locked,
        questions: [], // No hay quiz para la meta final
      ),
    ];
  }

  // Completar un nodo y actualizar el progreso
  void completeNode(int nodeId, bool quizPassed) {
    final nodeIndex = _nodes.indexWhere((node) => node.id == nodeId);
    if (nodeIndex != -1) {
      if (quizPassed) {
        _nodes[nodeIndex].status = NodeStatus.completed;
        _unlockNextNode(nodeIndex);
      }
      // Si no pasó el quiz, el nodo mantiene su estado actual
    }
  }

  // Desbloquear el siguiente nodo
  void _unlockNextNode(int currentNodeIndex) {
    if (currentNodeIndex + 1 < _nodes.length) {
      final nextNode = _nodes[currentNodeIndex + 1];
      if (nextNode.status == NodeStatus.locked) {
        nextNode.status = NodeStatus.active;
      }
    }
  }

  // Obtener el progreso total (porcentaje completado)
  double get progressPercentage {
    final completedNodes = _nodes.where((node) => node.status == NodeStatus.completed).length;
    return completedNodes / _nodes.length;
  }

  // Obtener cantidad de nodos completados
  int get completedNodesCount {
    return _nodes.where((node) => node.status == NodeStatus.completed).length;
  }
}

// Pantalla principal - Home con el camino de aprendizaje
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProgressManager _progressManager = ProgressManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            SizedBox(width: 8),
            Text(
              'Add your LinkedIn!',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Icon(Icons.notifications_outlined, color: Colors.blue[700]),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Barra de progreso
              Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tu Progreso',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '${_progressManager.completedNodesCount}/${_progressManager.nodes.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _progressManager.progressPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: LearningPath(
                      progressManager: _progressManager,
                      onNodeCompleted: () {
                        setState(() {}); // Actualizar UI cuando se complete un nodo
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Planta en la esquina inferior derecha
          Positioned(
            bottom: 100,
            right: 20,
            child: PlantWidget(),
          ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NodeDetailScreen(
                          node: node,
                          progressManager: progressManager,
                          onNodeCompleted: onNodeCompleted,
                        ),
                      ),
                    );
                  } else {
                    // Mostrar mensaje para nodos bloqueados
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Completa los nodos anteriores para desbloquear este.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
              ),
              if (!isLast) PathConnector(isActive: node.status != NodeStatus.locked),
            ],
          );
        }).toList(),
        SizedBox(height: 100), // Espacio para la navegación inferior
      ],
    );
  }
}

// Widget individual del nodo
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: node.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: node.isClickable ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ] : null,
            ),
            child: Icon(
              node.icon,
              color: node.iconColor,
              size: 32,
            ),
          ),
          SizedBox(height: 8),
          Container(
            constraints: BoxConstraints(maxWidth: 120),
            child: Text(
              node.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: node.isClickable ? Colors.grey[800] : Colors.grey[500],
              ),
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
      width: 4,
      height: 60,
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isActive ? [
            Colors.blue[400]!,
            Colors.blue[600]!,
          ] : [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Widget de la planta (gamificación)
class PlantWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue[700],
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.eco,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

// Pantalla de detalle del nodo
class NodeDetailScreen extends StatelessWidget {
  final PathNode node;
  final ProgressManager progressManager;
  final VoidCallback onNodeCompleted;

  NodeDetailScreen({
    required this.node,
    required this.progressManager,
    required this.onNodeCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Si el nodo está completado, mostrar resumen
    if (node.status == NodeStatus.completed) {
      return _buildCompletedNodeScreen(context);
    }

    // Si el nodo está activo o es el primero, mostrar contenido
    return _buildActiveNodeScreen(context);
  }

  Widget _buildCompletedNodeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(node.title),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Nodo Completado!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Resumen: ${node.title}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              node.description,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 24),
            Text(
              'Has completado exitosamente este módulo. El contenido de esta habilidad ya forma parte de tu perfil profesional.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveNodeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(node.title),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (node.status == NodeStatus.first)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber[600], size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '¡Comienza tu ruta de aprendizaje!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              node.title,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              node.description,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contenido del Módulo:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Conceptos fundamentales\n'
                        '• Ejemplos prácticos\n'
                        '• Estrategias de aplicación\n'
                        '• Casos de estudio',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: node.questions.isNotEmpty ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        node: node,
                        progressManager: progressManager,
                        onNodeCompleted: onNodeCompleted,
                      ),
                    ),
                  );
                } : () {
                  // Para nodos sin quiz (como la meta final)
                  progressManager.completeNode(node.id, true);
                  onNodeCompleted();
                  Navigator.pop(context);
                },
                child: Text(
                  node.questions.isNotEmpty ? 'Comenzar Evaluación' : 'Completar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla del quiz
class QuizScreen extends StatefulWidget {
  final PathNode node;
  final ProgressManager progressManager;
  final VoidCallback onNodeCompleted;

  QuizScreen({
    required this.node,
    required this.progressManager,
    required this.onNodeCompleted,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
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
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      completeQuiz();
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void completeQuiz() {
    // Calcular respuestas correctas
    correctAnswers = 0;
    for (int i = 0; i < widget.node.questions.length; i++) {
      if (selectedAnswers[i] == widget.node.questions[i].correctAnswer) {
        correctAnswers++;
      }
    }

    setState(() {
      quizCompleted = true;
    });

    // Determinar si pasó el quiz (necesita al menos 70% correcto)
    double percentage = correctAnswers / widget.node.questions.length;
    bool passed = percentage >= 0.7;

    // Actualizar el progreso
    widget.progressManager.completeNode(widget.node.id, passed);
    widget.onNodeCompleted();
  }

  @override
  Widget build(BuildContext context) {
    if (quizCompleted) {
      return _buildQuizResultScreen();
    }

    final question = widget.node.questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / widget.node.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.node.title}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de progreso del quiz
            Row(
              children: [
                Text(
                  'Pregunta ${currentQuestionIndex + 1} de ${widget.node.questions.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                Text(
                  '${((progress) * 100).round()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              minHeight: 6,
            ),
            SizedBox(height: 32),

            // Pregunta
            Text(
              question.question,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            SizedBox(height: 24),

            // Opciones
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
                          border: Border.all(
                            color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.blue[600] : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? Colors.blue[600]! : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Botones de navegación
            Row(
              children: [
                if (currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: previousQuestion,
                      child: Text('Anterior'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.blue[600]!),
                      ),
                    ),
                  ),
                if (currentQuestionIndex > 0) SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedAnswers[currentQuestionIndex] != null
                        ? nextQuestion
                        : null,
                    child: Text(
                      currentQuestionIndex == widget.node.questions.length - 1
                          ? 'Finalizar Quiz'
                          : 'Siguiente',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
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
      appBar: AppBar(
        title: Text('Resultados del Quiz'),
        backgroundColor: passed ? Colors.green[600] : Colors.red[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Ocultar botón de retroceso
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: passed ? Colors.green[600] : Colors.red[600],
                shape: BoxShape.circle,
              ),
              child: Icon(
                passed ? Icons.check : Icons.close,
                color: Colors.white,
                size: 60,
              ),
            ),
            SizedBox(height: 24),
            Text(
              passed ? '¡Felicitaciones!' : '¡Inténtalo de nuevo!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: passed ? Colors.green[700] : Colors.red[700],
              ),
            ),
            SizedBox(height: 16),
            Text(
              passed
                  ? 'Has completado exitosamente el módulo de ${widget.node.title}'
                  : 'Necesitas al menos 70% para aprobar. ¡No te desanimes, puedes intentarlo nuevamente!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '$correctAnswers',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                      Text('Correctas', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${widget.node.questions.length - correctAnswers}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                      Text('Incorrectas', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${(percentage * 100).round()}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                      Text('Puntuación', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Regresar a la pantalla principal
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  passed ? 'Continuar Ruta' : 'Volver al Inicio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: passed ? Colors.green[600] : Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            if (!passed) ...[
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Reiniciar el quiz
                    setState(() {
                      currentQuestionIndex = 0;
                      selectedAnswers = List.filled(widget.node.questions.length, null);
                      quizCompleted = false;
                      correctAnswers = 0;
                    });
                  },
                  child: Text(
                    'Intentar de Nuevo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.blue[600]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Pantallas placeholder para las otras secciones
class JobsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobs'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Próximamente',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aquí encontrarás ofertas de trabajo\nrelevantes para tus habilidades',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProgressManager progressManager = ProgressManager();

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Estadísticas del usuario
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Tu Progreso',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${progressManager.completedNodesCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Completados',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${(progressManager.progressPercentage * 100).round()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Progreso',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${progressManager.completedNodesCount * 50}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Puntos',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'Próximamente',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Aquí podrás comparar tu progreso\ncon otros usuarios',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ProgressManager progressManager = ProgressManager();
    final completedNodes = progressManager.nodes
        .where((node) => node.status == NodeStatus.completed)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del usuario
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
                    'Usuario Demo',
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

            // Estadísticas rápidas
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
                  child: _buildStatCard(
                    'Progreso Total',
                    '${(progressManager.progressPercentage * 100).round()}%',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Habilidades completadas
            Text(
              'Habilidades Desarrolladas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            if (completedNodes.isEmpty)
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
                    SizedBox(height: 8),
                    Text(
                      '¡Comienza tu ruta de aprendizaje!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...completedNodes.map((node) => Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            node.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Completado exitosamente',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.star, color: Colors.amber),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

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
}