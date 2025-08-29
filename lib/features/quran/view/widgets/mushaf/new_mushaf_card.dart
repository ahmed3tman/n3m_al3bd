import 'package:flutter/material.dart';

class NewMushafCard extends StatelessWidget {
  final VoidCallback? onTap;

  const NewMushafCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 120,
            height: 200,
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add),
                SizedBox(height: 8),
                Text('ختمة جديدة'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
