// FILE: guide_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/guide_model.dart';
import '../models/user_model.dart';

class GuideScreen extends StatefulWidget {
  final GuideModel guide;

  GuideScreen({required this.guide});

  @override
  _GuideScreenState createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _author;
  bool _isFavorite = false;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAuthor();
    _checkIfFavorite();
    _favoriteCount = widget.guide.favoriteCount;
  }

  Future<void> _loadAuthor() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.guide.authorId).get();
    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        _author = UserModel.fromFirebaseUser(FirebaseAuth.instance.currentUser!, userDoc.data() as Map<String, dynamic>);
      });
    }
  }

  Future<void> _checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      List<String> favoriteGuideIds = List<String>.from(userDoc['favoriteGuideIds'] ?? []);
      setState(() {
        _isFavorite = favoriteGuideIds.contains(widget.guide.id);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    DocumentReference guideRef = FirebaseFirestore.instance.collection('guides').doc(widget.guide.id);
    DocumentReference authorRef = FirebaseFirestore.instance.collection('users').doc(widget.guide.authorId);

    if (_isFavorite) {
      await userRef.update({
        'favoriteGuideIds': FieldValue.arrayRemove([widget.guide.id]),
      });
      await guideRef.update({
        'favoriteCount': FieldValue.increment(-1),
      });
      await authorRef.update({
        'numberOfFavorites': FieldValue.increment(-1),
      });
      setState(() {
        _favoriteCount--;
      });
    } else {
      await userRef.update({
        'favoriteGuideIds': FieldValue.arrayUnion([widget.guide.id]),
      });
      await guideRef.update({
        'favoriteCount': FieldValue.increment(1),
      });
      await authorRef.update({
        'numberOfFavorites': FieldValue.increment(1),
      });
      setState(() {
        _favoriteCount++;
      });
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guide'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Trip'),
            Tab(text: 'Day 1'),
            Tab(text: 'Day 2'),
            Tab(text: 'Day 3'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('City Name', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                        widget.guide.cityName,
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 16),
                      if (_author != null) ...[
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: _author!.profilePictureUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(_author!.profilePictureUrl)
                                  : AssetImage('assets/default_profile.png') as ImageProvider,
                            ),
                            SizedBox(width: 10),
                            Text(
                              _author!.name,
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                      ],
                      Text('Cover Image', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      CachedNetworkImage(
                        imageUrl: widget.guide.coverImageUrl,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                              color: Colors.white,
                            ),
                            onPressed: _toggleFavorite,
                          ),
                          Text(
                            '$_favoriteCount favorites',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Part of City', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          widget.guide.days[index].partOfCity,
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Meals', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Breakfast: ${widget.guide.days[index].breakfast.name}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Text('Lunch: ${widget.guide.days[index].lunch.name}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        SizedBox(height: 8),
                        Text('Dinner: ${widget.guide.days[index].dinner.name}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Attraction', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          widget.guide.days[index].attraction,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 8),
                        Text('Shopping', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                          widget.guide.days[index].shoppingList.join(', '),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}