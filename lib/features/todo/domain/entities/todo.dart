import 'package:equatable/equatable.dart';

enum TodoPriority { low, medium, high, urgent }

enum TodoCategory { personal, work, shopping, health, education, other }

class Todo extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final TodoPriority priority;
  final TodoCategory category;
  final List<String> tags;
  final String? userId;
  final bool isDeleted;
  final DateTime? deletedAt;

  const Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.priority = TodoPriority.medium,
    this.category = TodoCategory.personal,
    this.tags = const [],
    this.userId,
    this.isDeleted = false,
    this.deletedAt,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    TodoPriority? priority,
    TodoCategory? category,
    List<String>? tags,
    String? userId,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return dueDate!.isBefore(tomorrow) && dueDate!.isAfter(now);
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    createdAt,
    updatedAt,
    dueDate,
    priority,
    category,
    tags,
    userId,
    isDeleted,
    deletedAt,
  ];

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, description: $description, isCompleted: $isCompleted, createdAt: $createdAt, updatedAt: $updatedAt, dueDate: $dueDate, priority: $priority, category: $category, tags: $tags, userId: $userId, isDeleted: $isDeleted, deletedAt: $deletedAt)';
  }
}
