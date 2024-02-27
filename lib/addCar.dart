import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'notes_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import './pages/register_page.dart';
import './pages/login_page.dart';

class addCar extends StatefulWidget {
  @override
  _addCarState createState() => _addCarState();
}

class _addCarState extends State<addCar> {
  XFile? _selectedImage;
  String? imageUrl;
  final carNameController = TextEditingController();
  final firestore = FirebaseFirestore.instance;
  // Store Car Image
  final storageRef = FirebaseStorage.instance.ref();
  bool _imagePicked = false;
  String userEmail = '';
  TextEditingController emailController = TextEditingController();

  Future<void> _pickImage() async {
    if(_imagePicked) {
      return;
    }
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if(pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
        _imagePicked = true;
      });

    }
  }

  Future<String?> uploadImageToStorage(XFile image) async {
    final imageFile = File(image.path);
    final imageRef = FirebaseStorage.instance.ref().child('car_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      // upload the image to Firebase Storage
      await imageRef.putFile(imageFile);

      final imageUrl = await imageRef.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // display image
  Widget _buildSelectedImage() {
    if(_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        width: 100.0,
        height: 100.0,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            // Handle the back button press
            Navigator.of(context).pop();
          },
        ),
        title: Text('Add Car', style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24.0,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        ),
        backgroundColor: Colors.grey[300],
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(

              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Add a Car',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Car Name',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: carNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your Car Name',
                            hintStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            prefixIcon: Icon(
                              Icons.car_repair,
                              color: Colors.black,
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Photos:', style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],


                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Column(
                                children: [
                                  if (_selectedImage != null)
                                    _buildSelectedImage(),
                                  if (_selectedImage == null)
                                    TextButton(
                                      onPressed: _pickImage,

                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Select Photos',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Roboto',
                                            fontSize: 22.0,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(right:16.0,top: 20,bottom: 20),
                    child: Center(
                      child: TextButton(
                        onPressed: () async {
                          if (carNameController.text.isEmpty) {
                            // Show a SnackBar with an error message for empty carName
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter your car name.'),
                              ),
                            );
                            return;
                          }

                          // Check if a photo has been selected
                          if (_selectedImage == null) {
                            // Show a SnackBar with an error message for no selected image
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select an image of your car.'),
                              ),
                            );
                            return;
                          }
                          String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
                          imageUrl = await uploadImageToStorage(_selectedImage!);

                          QuerySnapshot emailQuery = await FirebaseFirestore.instance.collection('UserData').where('email', isEqualTo: userEmail).get();

                          if(emailQuery.docs.isNotEmpty) {
                            if (_selectedImage != null) {
                              // Upload the selected image to storage using the uploadImageToStorage function

                              if (imageUrl != null) {
                                // Handle the case where the image was uploaded successfully
                                print('Uploaded image URL: $imageUrl');

                                // You can also perform any other actions here after the image is uploaded.
                              } else {
                                // Handle the case where there was an error uploading the image
                                print('Failed to upload the image.');
                              }
                            } else {
                              // Handle the case where no image is selected
                              print('No image selected.');
                            }

                            DocumentSnapshot userDocument = emailQuery.docs.first;
                            Map<String, dynamic> userData = userDocument.data() as Map<String, dynamic>;


                            if(userData.containsKey("email") && !userData.containsKey("carName")) {
                              DocumentReference userDocRef = emailQuery.docs.first.reference;
                              await userDocRef.update({
                                'carName': carNameController.text,
                                'imageUrl': imageUrl,
                              });
                            } else if(userData.containsKey("email") && userData.containsKey("carName") && userData.containsKey("imageUrl")) {
                              FirebaseFirestore.instance.collection("UserData").add(
                                  {
                                    "email": userEmail,
                                    "carName": carNameController.text,
                                    "imageUrl": imageUrl,
                                  });
                            }

                          } else {
                            if (_selectedImage != null) {
                              // Upload the selected image to storage using the uploadImageToStorage function

                              if (imageUrl != null) {
                                // Handle the case where the image was uploaded successfully
                                print('Uploaded image URL: $imageUrl');

                                // You can also perform any other actions here after the image is uploaded.
                              } else {
                                // Handle the case where there was an error uploading the image
                                print('Failed to upload the image.');
                              }
                            } else {
                              // Handle the case where no image is selected
                              print('No image selected.');
                            }
                            await FirebaseFirestore.instance.collection('UserData').add({
                              'email': userEmail,
                              'carName': carNameController.text,
                              'imageUrl': imageUrl,
                            });
                          };
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NotesScreen()),
                          );
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black, // Background color
                          padding: EdgeInsets.all(20.0), // Padding to expand the button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0), // Border radius of 20
                          ),
                          minimumSize: Size(300,50),
                        ),
                        child: Text("Save Car", style: TextStyle(color: Colors.white, fontFamily: 'Roboto', fontSize: 18)),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
        ),

      backgroundColor: Colors.grey[300],
    );
  }
}
