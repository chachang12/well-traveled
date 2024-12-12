// FILE: edit_guide_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/guide_model.dart';

class EditGuideScreen extends StatefulWidget {
  final GuideModel guide;

  EditGuideScreen({required this.guide});

  @override
  _EditGuideScreenState createState() => _EditGuideScreenState();
}

class _EditGuideScreenState extends State<EditGuideScreen> {
  final TextEditingController _cityNameController = TextEditingController();
  final List<TextEditingController> _partOfCityControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _breakfastControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _lunchControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _dinnerControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _attractionControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _shoppingControllers = List.generate(3, (_) => TextEditingController());
  File? _coverImage;

  @override
  void initState() {
    super.initState();
    _cityNameController.text = widget.guide.cityName;
    for (int i = 0; i < 3; i++) {
      _partOfCityControllers[i].text = widget.guide.days[i].partOfCity;
      _breakfastControllers[i].text = widget.guide.days[i].breakfast.name;
      _lunchControllers[i].text = widget.guide.days[i].lunch.name;
      _dinnerControllers[i].text = widget.guide.days[i].dinner.name;
      _attractionControllers[i].text = widget.guide.days[i].attraction;
      _shoppingControllers[i].text = widget.guide.days[i].shoppingList.join(', ');
    }
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  bool _isFormValid() {
    return _cityNameController.text.isNotEmpty &&
        _partOfCityControllers.every((controller) => controller.text.isNotEmpty) &&
        _breakfastControllers.every((controller) => controller.text.isNotEmpty) &&
        _lunchControllers.every((controller) => controller.text.isNotEmpty) &&
        _dinnerControllers.every((controller) => controller.text.isNotEmpty) &&
        _attractionControllers.every((controller) => controller.text.isNotEmpty) &&
        _shoppingControllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _submitGuide() async {
    if (!_isFormValid()) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String coverImageUrl = widget.guide.coverImageUrl;
    if (_coverImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child('guide_covers/${user.uid}_${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = storageRef.putFile(_coverImage!);
      final snapshot = await uploadTask.whenComplete(() => {});
      coverImageUrl = await snapshot.ref.getDownloadURL();
    }

    List<DayPlan> days = [];
    for (int i = 0; i < 3; i++) {
      days.add(DayPlan(
        partOfCity: _partOfCityControllers[i].text,
        breakfast: Meal(name: _breakfastControllers[i].text),
        lunch: Meal(name: _lunchControllers[i].text),
        dinner: Meal(name: _dinnerControllers[i].text),
        attraction: _attractionControllers[i].text,
        shoppingList: _shoppingControllers[i].text.split(',').map((item) => item.trim()).toList(),
      ));
    }

    GuideModel updatedGuide = GuideModel(
      id: widget.guide.id,
      cityName: _cityNameController.text,
      coverImageUrl: coverImageUrl,
      days: days,
      favoriteCount: widget.guide.favoriteCount,
      authorId: widget.guide.authorId,
    );

    await FirebaseFirestore.instance.collection('guides').doc(widget.guide.id).update(updatedGuide.toMap());

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Guide'),
      ),
      body: Padding(
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
                  Text('City Name', style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _cityNameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[700],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text('Cover Image', style: TextStyle(color: Colors.white, fontSize: 16)),
                  SizedBox(height: 8),
                  _coverImage == null
                      ? ElevatedButton(
                          onPressed: _pickCoverImage,
                          child: Text('Upload Cover Image'),
                        )
                      : Image.file(_coverImage!),
                ],
              ),
            ),
            SizedBox(height: 16),
            ...List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Part of City', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _partOfCityControllers[index],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Part of City',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text('Breakfast', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _breakfastControllers[index],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Breakfast',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text('Lunch', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _lunchControllers[index],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Lunch',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text('Dinner', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _dinnerControllers[index],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Dinner',
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text('Attraction', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _attractionControllers[index],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text('Shopping List (comma separated)', style: TextStyle(color: Colors.white, fontSize: 16)),
                    SizedBox(height: 8),
                    TextField(
                      controller: _shoppingControllers[index],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[700],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isFormValid() ? _submitGuide : null,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}