import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pulse_admin.dart';

class PulseHome extends StatefulWidget {
  const PulseHome({super.key});

  @override
  State<PulseHome> createState() => _PulseHomeState();
}

class _PulseHomeState extends State<PulseHome> {

  final Map<String, String> voted = {}; // pollId -> A or B

  int safeInt(Map d, String k) {
    final v = d[k];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Pulse"),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PulseAdmin()),
              );
            },
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("pulse_polls")
            .where("active", isEqualTo: true)
            .snapshots(),

        builder: (context, snap) {

          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No polls found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>;

              final countA = safeInt(d, "countA") + safeInt(d, "count A");
              final countB = safeInt(d, "countB");

              final total = countA + countB;

              int percent(int v) =>
                  total == 0 ? 0 : ((v / total) * 100).toInt();

              final userVote = voted[doc.id];

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(0.08),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(d["question"] ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),

                    const SizedBox(height: 16),

                    _voteBtn(doc.id, "A", d["optionA"], countA, percent(countA), userVote),
                    const SizedBox(height: 12),
                    _voteBtn(doc.id, "B", d["optionB"], countB, percent(countB), userVote),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _voteBtn(String id, String key, String? text,
      int count, int percent, String? userVote) {

    final isSelected = userVote == key;
    final isDisabled = userVote != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.indigo),
        color: isSelected ? Colors.indigo.withOpacity(0.15) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: isDisabled
            ? null
            : () async {
                setState(() {
                  voted[id] = key;
                });

                final field = key == "A" ? "count A" : "countB";

                await FirebaseFirestore.instance
                    .collection("pulse_polls")
                    .doc(id)
                    .update({
                  field: count + 1
                });
              },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(child: Text(text ?? "")),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isDisabled
                    ? Text("$percent%",
                        key: ValueKey(percent))
                    : const Text("Vote",
                        key: ValueKey("vote")),
              )
            ],
          ),
        ),
      ),
    );
  }
}