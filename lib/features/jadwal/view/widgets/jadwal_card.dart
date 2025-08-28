import 'package:flutter/material.dart';

import '../../data/jadwal_model.dart';

class JadwalCard extends StatelessWidget {
  final JadwalModel model;
  final VoidCallback onOpen;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const JadwalCard({
    super.key,
    required this.model,
    required this.onOpen,
    this.onRename,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    model.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onRename,
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Preview: first row only to keep card compact
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(color: Colors.grey.shade700),
                  children: [
                    if (model.rows > 0)
                      TableRow(
                        children: List.generate(model.cols, (c) {
                          final text = model.cells[0][c];
                          return Container(
                            constraints: const BoxConstraints(
                              minWidth: 80,
                              minHeight: 40,
                            ),
                            // ensure a light background for cells (avoid dark/black)
                            color: Theme.of(
                              context,
                            ).cardColor.withOpacity(0.02),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            alignment: Alignment.centerRight,
                            child: Text(
                              text.isEmpty ? '-' : text,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: text.isEmpty
                                    ? Colors.grey
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
