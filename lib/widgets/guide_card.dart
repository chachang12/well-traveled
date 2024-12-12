// FILE: guide_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/guide_model.dart';
import '../screens/guide_screen.dart';

class GuideCard extends StatefulWidget {
  final GuideModel guide;

  GuideCard({required this.guide});

  @override
  _GuideCardState createState() => _GuideCardState();
}

class _GuideCardState extends State<GuideCard> {
  bool _isFavorite = false;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _favoriteCount = widget.guide.favoriteCount;
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      List<String> favoriteGuideIds = List<String>.from(userDoc['favoriteGuideIds'] ?? []);
      if (mounted) {
        setState(() {
          _isFavorite = favoriteGuideIds.contains(widget.guide.id);
        });
      }
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
      if (mounted) {
        setState(() {
          _favoriteCount--;
        });
      }
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
      if (mounted) {
        setState(() {
          _favoriteCount++;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuideScreen(guide: widget.guide),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Theme.of(context).cardColor,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.guide.coverImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200, // Define a fixed height for the image
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.guide.cityName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.guide.days.map((day) => day.partOfCity).join(' | '),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$_favoriteCount favorites',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  _isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  color: Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}