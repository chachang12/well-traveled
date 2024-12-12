// FILE: user_guide_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/guide_model.dart';
import '../screens/edit_guide_screen.dart';

class UserGuideCard extends StatelessWidget {
  final GuideModel guide;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  UserGuideCard({required this.guide, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                imageUrl: guide.coverImageUrl,
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
                        guide.cityName,
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
                        guide.days.map((day) => day.partOfCity).join(' | '),
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
                        '${guide.favoriteCount} favorites',
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
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditGuideScreen(guide: guide),
                      ),
                    ).then((_) => onEdit());
                  },
                ),
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.trash,
                    color: Colors.white,
                  ),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}