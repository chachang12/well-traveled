// FILE: profile_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_model.dart';
import '../models/guide_model.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';
import 'favorites_screen.dart';
import '../widgets/user_guide_card.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserModel user = Provider.of<UserProvider>(context).user!;

    Future<void> _pickAndUploadImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}');
        final uploadTask = storageRef.putFile(File(pickedFile.path));

        final snapshot = await uploadTask.whenComplete(() => {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profilePictureUrl': downloadUrl,
        });

        Provider.of<UserProvider>(context, listen: false).setUser(
          UserModel(
            uid: user.uid,
            name: user.name,
            email: user.email,
            profilePictureUrl: downloadUrl,
            hometown: user.hometown,
            favoriteGuideIds: user.favoriteGuideIds,
            createdGuideIds: user.createdGuideIds,
            numberOfFavorites: user.numberOfFavorites,
          ),
        );
      }
    }

    Future<void> _deleteGuide(String guideId) async {
      await FirebaseFirestore.instance.collection('guides').doc(guideId).delete();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'createdGuideIds': FieldValue.arrayRemove([guideId]),
      });
      Provider.of<UserProvider>(context, listen: false).setUser(
        UserModel(
          uid: user.uid,
          name: user.name,
          email: user.email,
          profilePictureUrl: user.profilePictureUrl,
          hometown: user.hometown,
          favoriteGuideIds: user.favoriteGuideIds,
          createdGuideIds: user.createdGuideIds..remove(guideId),
          numberOfFavorites: user.numberOfFavorites,
        ),
      );
    }

    Future<void> _logout() async {
      await FirebaseAuth.instance.signOut();
      Provider.of<UserProvider>(context, listen: false).clearUser();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(onLogin: (user) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);
        })),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Profile'),
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF30454B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF30454B),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.white),
              title: Text('Edit Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                _pickAndUploadImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.white),
              title: Text('Favorite Guides', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Log Out', style: TextStyle(color: Colors.white)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          UserModel updatedUser = UserModel.fromFirebaseUser(FirebaseAuth.instance.currentUser!, snapshot.data!.data() as Map<String, dynamic>);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: updatedUser.profilePictureUrl.isNotEmpty
                      ? CachedNetworkImageProvider(updatedUser.profilePictureUrl)
                      : AssetImage('assets/default_profile.png') as ImageProvider,
                ),
                SizedBox(height: 20),
                Text(
                  updatedUser.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  updatedUser.hometown,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Guides',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${updatedUser.createdGuideIds.length}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 40),
                    Column(
                      children: [
                        Text(
                          'Favorites',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${updatedUser.numberOfFavorites}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: updatedUser.createdGuideIds.isEmpty
                      ? Center(
                          child: Text(
                            'No guides available.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: updatedUser.createdGuideIds.length,
                          itemBuilder: (context, index) {
                            String guideId = updatedUser.createdGuideIds[index];
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
                                return UserGuideCard(
                                  guide: guide,
                                  onEdit: () {
                                    // Handle edit action
                                  },
                                  onDelete: () {
                                    _deleteGuide(guideId);
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}