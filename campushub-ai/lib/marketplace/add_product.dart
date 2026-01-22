import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../cloudinary_service.dart'; // same one you already use

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final title = TextEditingController();
  final price = TextEditingController();
  final category = TextEditingController();
  final description = TextEditingController();

  File? image;
  bool uploading = false;

  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  Future submit() async {
    if (image == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pick an image")));
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    setState(() => uploading = true);

    final imageUrl = await uploadToCloudinary(image!);

    await FirebaseFirestore.instance.collection("marketplace").add({
      "title": title.text.trim(),
      "price": int.parse(price.text.trim()),
      "category": category.text.trim(),
      "description": description.text.trim(),
      "imageUrl": imageUrl,
      "sellerName": user.displayName ?? user.email,
      "sellerEmail": user.email,
      "active": true,
      "createdAt": FieldValue.serverTimestamp()
    });

    setState(() => uploading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [

            TextField(controller: title, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: price, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: category, decoration: const InputDecoration(labelText: "Category")),
            TextField(controller: description, decoration: const InputDecoration(labelText: "Description")),

            const SizedBox(height: 16),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                child: image == null
                    ? const Center(child: Text("Tap to pick image"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(image!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: uploading ? null : submit,
              child: uploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Post Product"),
            )
          ],
        ),
      ),
    );
  }
}