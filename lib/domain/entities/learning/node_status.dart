// lib/domain/entities/learning/node_status.dart
enum NodeStatus {
  locked,
  first,
  active,
  completed;

  bool get isLocked => this == NodeStatus.locked;
  bool get isActive => this == NodeStatus.active || this == NodeStatus.first;
  bool get isCompleted => this == NodeStatus.completed;
  bool get isFirst => this == NodeStatus.first;
}