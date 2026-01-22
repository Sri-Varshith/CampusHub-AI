import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PulseAdmin extends StatefulWidget {
  const PulseAdmin({super.key});

  @override
  State<PulseAdmin> createState() => _PulseAdminState();
}

class _PulseAdminState extends State<PulseAdmin> {
  final q = TextEditingController();
  final a = TextEditingController();
  final b = TextEditingController();

  Future submit() async {
    if (q.text.isEmpty || a.text.isEmpty || b.text.isEmpty) return;

    await FirebaseFirestore.instance.collection("pulse_polls").add({
      "question": q.text,
      "optionA": a.text,
      "optionB": b.text,
      "countA": 0,
      "countB": 0,
      "createdAt": FieldValue.serverTimestamp(),
      "active": true
    });

    q.clear();
    a.clear();
    b.clear();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Poll Published")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Campus Poll")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(controller: q, decoration: const InputDecoration(labelText: "Question")),
            const SizedBox(height: 12),

            TextField(controller: a, decoration: const InputDecoration(labelText: "Option A")),
            const SizedBox(height: 12),

            TextField(controller: b, decoration: const InputDecoration(labelText: "Option B")),
            const SizedBox(height: 24),

            ElevatedButton(onPressed: submit, child: const Text("Publish Poll"))
          ],
        ),
      ),
    );
  }
}