import 'package:hive/hive.dart';

import '../../core/helper.dart';

part 'calorie_entry.g.dart';

@HiveType(typeId: 1)
class CalorieEntry extends HiveObject {
  static const List<String> MEALTYPES = ['Breakfast', 'Lunch', 'Dinner'];

  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int calories;

  @HiveField(3)
  final String? mealType;

  @HiveField(4)
  final String? note;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  bool isDeleted;

  @HiveField(8)
  bool isSynced;

  CalorieEntry({
    required this.id,
    required this.date,
    required this.calories,
    this.mealType,
    this.note,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  }) : createdAt = createdAt ?? DateTime.now().toUtc(),
       updatedAt = updatedAt ?? DateTime.now().toUtc(),
       isDeleted = isDeleted ?? false,
       isSynced = isSynced ?? true;

  CalorieEntry copyWith({
    String? id,
    DateTime? date,
    int? calories,
    String? mealType,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return CalorieEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory CalorieEntry.fromJson(Map<String, dynamic> json) => CalorieEntry(
    id: json['id'],
    date: parseDate(json['date']),
    calories: json['calories'],
    mealType: json['mealType'],
    note: json['note'],
    createdAt: parseDate(json['createdAt']),
    updatedAt: parseDate(json['updatedAt']),
    isDeleted: json['isDeleted'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'calories': calories,
    'mealType': mealType,
    'note': note,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'isDeleted': isDeleted,
  };
}
