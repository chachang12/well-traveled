// FILE: create_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/guide_model.dart';
import '../providers/user_provider.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _cityNameController = TextEditingController();
  final List<TextEditingController> _partOfCityControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _breakfastControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _lunchControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _dinnerControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _attractionControllers = List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _shoppingControllers = List.generate(3, (_) => TextEditingController());
  File? _coverImage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Add listeners to the text controllers
    _cityNameController.addListener(_onFormFieldChanged);
    _partOfCityControllers.forEach((controller) => controller.addListener(_onFormFieldChanged));
    _breakfastControllers.forEach((controller) => controller.addListener(_onFormFieldChanged));
    _lunchControllers.forEach((controller) => controller.addListener(_onFormFieldChanged));
    _dinnerControllers.forEach((controller) => controller.addListener(_onFormFieldChanged));
    _attractionControllers.forEach((controller) => controller.addListener(_onFormFieldChanged));
    _shoppingControllers.forEach((controller) => controller.addListener(_onFormFieldChanged));
  }

  void _onFormFieldChanged() {
    setState(() {});
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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

    String coverImageUrl = '';
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

    GuideModel newGuide = GuideModel(
      id: '',
      cityName: _cityNameController.text,
      coverImageUrl: coverImageUrl,
      days: days,
      favoriteCount: 0,
      authorId: user.uid, // Ensure authorId is set
    );

    DocumentReference docRef = await FirebaseFirestore.instance.collection('guides').add(newGuide.toMap());
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'createdGuideIds': FieldValue.arrayUnion([docRef.id]),
    });

    // Clear the form
    _cityNameController.clear();
    _partOfCityControllers.forEach((controller) => controller.clear());
    _breakfastControllers.forEach((controller) => controller.clear());
    _lunchControllers.forEach((controller) => controller.clear());
    _dinnerControllers.forEach((controller) => controller.clear());
    _attractionControllers.forEach((controller) => controller.clear());
    _shoppingControllers.forEach((controller) => controller.clear());
    setState(() {
      _coverImage = null;
    });

    // Show a success message or navigate to another screen
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Guide created successfully!')));
  }

  @override
  void dispose() {
    // Dispose controllers and remove listeners
    _cityNameController.dispose();
    _partOfCityControllers.forEach((controller) => controller.dispose());
    _breakfastControllers.forEach((controller) => controller.dispose());
    _lunchControllers.forEach((controller) => controller.dispose());
    _dinnerControllers.forEach((controller) => controller.dispose());
    _attractionControllers.forEach((controller) => controller.dispose());
    _shoppingControllers.forEach((controller) => controller.dispose());
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Create Guide'),
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
                        ),
                        style: TextStyle(color: Colors.white),
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
                            labelText: 'Part of City',
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
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
                        Text('Meals', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                            labelText: 'Breakfast',
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
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
                            labelText: 'Lunch',
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
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
                            labelText: 'Dinner',
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                          style: TextStyle(color: Colors.white),
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
                          ),
                          style: TextStyle(color: Colors.white),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isFormValid() ? _submitGuide : null,
        child: Icon(Icons.check),
        backgroundColor: _isFormValid() ? Color.fromARGB(255, 51, 96, 108) : Colors.grey,
      ),
    );
  }
}