import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../style/app_style.dart';

Widget galleryBox(Function(String workshop)? onTap, QueryDocumentSnapshot doc) {
  final workshopName = doc["workshop"] as String;

  return InkWell(
    onTap: () {
      if (onTap != null) {
        onTap(workshopName);
      }
    },
    child: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for "workshop" (not clickable)
          Row(
            children: [
              Text(doc["workshop"], style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
              SizedBox(width: 10),
              Text("Long Press to delete", style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              )),
            ],
          ),
          // Container with a fixed 3x3 aspect ratio for the image (clickable)
          GestureDetector(
            onTap: () {
              if (onTap != null) {
                onTap(workshopName);
              }
            },
            child: Container(
              width: 120,
              height: 120,
              child: FutureBuilder<String?>(
                future: getImageUrlForCurrentUser(doc),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Icon(Icons.error_outline, size: 120);
                  } else if (snapshot.hasData) {
                    return Image.network(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  } else {
                    return Icon(Icons.image, size: 120);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



Future<String?> getImageUrlForCurrentUser(QueryDocumentSnapshot workshopDoc) async {
  // Access the "UserData" document and retrieve the "imageUrl" field
  String? imageUrl = workshopDoc.get(
      'imageUrl'); // these 2 lines creating error
  return imageUrl;
  // }
  // }
}
