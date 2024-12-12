// FILE: favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../models/guide_model.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../widgets/guide_card.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Guides'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            UserModel updatedUser = UserModel.fromFirebaseUser(FirebaseAuth.instance.currentUser!, snapshot.data!.data() as Map<String, dynamic>);
            if (updatedUser.favoriteGuideIds.isEmpty) {
              return Center(
                child: Text(
                  'No favorite guides available.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: updatedUser.favoriteGuideIds.length,
              itemBuilder: (context, index) {
                String guideId = updatedUser.favoriteGuideIds[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('guides').doc(guideId).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: Text('Guide not found.'));
                    }
                    GuideModel guide = GuideModel.fromMap(snapshot.data!.data() as Map<String, dynamic>, guideId);
                    return GuideCard(
                      guide: guide,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}