// FILE: home_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import '../models/user_model.dart';
import '../models/guide_model.dart';
import '../widgets/guide_card.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Home'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trending Guides 2024 🔥',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('guides').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No guides available.'));
                  }
                  List<GuideModel> guides = snapshot.data!.docs.map((doc) {
                    if (doc.data() != null) {
                      return GuideModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                    } else {
                      return null;
                    }
                  }).where((guide) => guide != null).cast<GuideModel>().toList();
                  return ListView.builder(
                    itemCount: guides.length,
                    itemBuilder: (context, index) {
                      return GuideCard(
                        guide: guides[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}