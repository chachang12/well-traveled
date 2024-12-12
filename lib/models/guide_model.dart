// FILE: guide_model.dart

class GuideModel {
  final String id;
  final String cityName;
  final String coverImageUrl;
  final List<DayPlan> days;
  final int favoriteCount;
  final String authorId; // Add authorId field

  GuideModel({
    required this.id,
    required this.cityName,
    required this.coverImageUrl,
    required this.days,
    required this.favoriteCount,
    required this.authorId, // Initialize authorId
  });

  factory GuideModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GuideModel(
      id: documentId,
      cityName: data['cityName'],
      coverImageUrl: data['coverImageUrl'],
      days: (data['days'] as List).map((day) => DayPlan.fromMap(day)).toList(),
      favoriteCount: data['favoriteCount'] ?? 0,
      authorId: data['authorId'] ?? '', // Provide default value for authorId
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cityName': cityName,
      'coverImageUrl': coverImageUrl,
      'days': days.map((day) => day.toMap()).toList(),
      'favoriteCount': favoriteCount,
      'authorId': authorId, // Add authorId to map
    };
  }
}

class DayPlan {
  final String partOfCity;
  final Meal breakfast;
  final Meal lunch;
  final Meal dinner;
  final String attraction;
  final List<String> shoppingList;

  DayPlan({
    required this.partOfCity,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.attraction,
    required this.shoppingList,
  });

  factory DayPlan.fromMap(Map<String, dynamic> data) {
    return DayPlan(
      partOfCity: data['partOfCity'],
      breakfast: Meal.fromMap(data['breakfast']),
      lunch: Meal.fromMap(data['lunch']),
      dinner: Meal.fromMap(data['dinner']),
      attraction: data['attraction'],
      shoppingList: List<String>.from(data['shoppingList']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partOfCity': partOfCity,
      'breakfast': breakfast.toMap(),
      'lunch': lunch.toMap(),
      'dinner': dinner.toMap(),
      'attraction': attraction,
      'shoppingList': shoppingList,
    };
  }
}

class Meal {
  final String name;

  Meal({required this.name});

  factory Meal.fromMap(Map<String, dynamic> data) {
    return Meal(
      name: data['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}