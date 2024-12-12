// FILE: user_model.dart

import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profilePictureUrl;
  final String hometown;
  final List<String> favoriteGuideIds;
  final List<String> createdGuideIds;
  final int numberOfFavorites;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.hometown,
    required this.favoriteGuideIds,
    required this.createdGuideIds,
    required this.numberOfFavorites,
  });

  factory UserModel.fromFirebaseUser(User user, Map<String, dynamic> data) {
    return UserModel(
      uid: user.uid,
      name: data['name'],
      email: user.email!,
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      hometown: data['hometown'] ?? '',
      favoriteGuideIds: List<String>.from(data['favoriteGuideIds'] ?? []),
      createdGuideIds: List<String>.from(data['createdGuideIds'] ?? []),
      numberOfFavorites: data['numberOfFavorites'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'hometown': hometown,
      'favoriteGuideIds': favoriteGuideIds,
      'createdGuideIds': createdGuideIds,
      'numberOfFavorites': numberOfFavorites,
    };
  }
}