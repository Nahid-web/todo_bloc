import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.isCompleted,
    required super.createdAt,
    required super.updatedAt,
    super.dueDate,
    super.priority = TodoPriority.medium,
    super.category = TodoCategory.personal,
    super.tags = const [],
    super.userId,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      dueDate:
          json['dueDate'] != null
              ? DateTime.parse(json['dueDate'] as String)
              : null,
      priority: TodoPriority.values.firstWhere(
        (e) => e.name == (json['priority'] as String? ?? 'medium'),
        orElse: () => TodoPriority.medium,
      ),
      category: TodoCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String? ?? 'personal'),
        orElse: () => TodoCategory.personal,
      ),
      tags: List<String>.from(json['tags'] as List? ?? []),
      userId: json['userId'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt:
          json['deletedAt'] != null
              ? DateTime.parse(json['deletedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'category': category.name,
      'tags': tags,
      'userId': userId,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      isCompleted: todo.isCompleted,
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
      dueDate: todo.dueDate,
      priority: todo.priority,
      category: todo.category,
      tags: todo.tags,
      userId: todo.userId,
      isDeleted: todo.isDeleted,
      deletedAt: todo.deletedAt,
    );
  }

  factory TodoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TodoModel(
      id: doc.id,
      title: data['title'] as String,
      description: data['description'] as String,
      isCompleted: data['isCompleted'] as bool,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      dueDate:
          data['dueDate'] != null
              ? (data['dueDate'] as Timestamp).toDate()
              : null,
      priority: TodoPriority.values.firstWhere(
        (e) => e.name == (data['priority'] as String? ?? 'medium'),
        orElse: () => TodoPriority.medium,
      ),
      category: TodoCategory.values.firstWhere(
        (e) => e.name == (data['category'] as String? ?? 'personal'),
        orElse: () => TodoCategory.personal,
      ),
      tags: List<String>.from(data['tags'] as List? ?? []),
      userId: data['userId'] as String?,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt:
          data['deletedAt'] != null
              ? (data['deletedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'priority': priority.name,
      'category': category.name,
      'tags': tags,
      'userId': userId,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  @override
  TodoModel copyWith({
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
    return TodoModel(
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
}
