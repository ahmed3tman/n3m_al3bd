import 'package:flutter/material.dart';

import '../../data/jadwal_model.dart';
import '../../cubit/jadwal_cubit.dart';
import '../../cubit/jadwal_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jalees/core/share/widgets/gradient_background.dart';

class JadwalDetailScreen extends StatefulWidget {
  final JadwalModel model;
  final int index;
  final void Function(int row, int col, String value) onEditCell;
  final VoidCallback? onAddRow;
  final void Function(int rowIndex)? onDeleteRow;
  final void Function(int rowIndex)? onAddRowAt;
  final void Function(int colIndex)? onDeleteColumn;
  final void Function(int colIndex)? onAddColumnAt;

  const JadwalDetailScreen({
    super.key,
    required this.model,
    required this.index,
    required this.onEditCell,
    this.onAddRow,
    this.onDeleteRow,
    this.onAddRowAt,
    this.onDeleteColumn,
    this.onAddColumnAt,
  });

  @override
  State<JadwalDetailScreen> createState() => _JadwalDetailScreenState();
}

class _JadwalDetailScreenState extends State<JadwalDetailScreen> {
  late List<double> colWidths;
  // rows are fixed height; keep a single default row height
  final double _rowHeight = 56;
  final Map<String, TextEditingController> _controllers = {};
  late int _lastCols;
  late int _lastRows;

  @override
  void initState() {
    super.initState();
    colWidths =
        widget.model.colWidths != null &&
            widget.model.colWidths!.length == widget.model.cols
        ? List<double>.from(widget.model.colWidths!)
        : List<double>.filled(widget.model.cols, 120, growable: true);
    _lastCols = widget.model.cols;
    _lastRows = widget.model.rows;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  void _startResizeColumn(int c, DragUpdateDetails details) {
    setState(() {
      colWidths[c] = (colWidths[c] + details.delta.dx).clamp(60.0, 800.0);
    });
  }

  // rows fixed; no row resize

  Widget _buildCell(int r, int c, JadwalModel model) {
    final key = '$r:$c';
    final existing = _controllers[key];
    if (existing == null) {
      final ctrl = TextEditingController(text: model.cells[r][c]);
      ctrl.addListener(() {
        try {
          context.read<JadwalCubit>().editCell(widget.index, r, c, ctrl.text);
        } catch (_) {}
      });
      _controllers[key] = ctrl;
    } else {
      // keep controller text in sync if model changed externally
      final newText = model.cells[r][c];
      if (existing.text != newText) existing.text = newText;
    }

    final controller = _controllers[key]!;

    return Container(
      width: colWidths[c],
      height: _rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.98,
          heightFactor: 0.96,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              // larger inner white rounded box, centered
              color: Colors.white.withOpacity(0.96),
              padding: EdgeInsets.zero,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                textAlignVertical: TextAlignVertical.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontFamily: 'GeneralFont'),
                expands: true,
                maxLines: null,
                minLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(title: Text(widget.model.name)),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: InteractiveViewer(
          panEnabled: true,
          scaleEnabled: true,
          constrained: false,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 16.0,
                ),
                child: BlocBuilder<JadwalCubit, JadwalState>(
                  builder: (context, state) {
                    final model = state.tables.length > widget.index
                        ? state.tables[widget.index]
                        : widget.model;

                    // If the table dimensions changed (due to add/delete row/col),
                    // resize our width/height arrays and reset controllers to avoid
                    // index errors and stale keys.
                    if (_lastCols != model.cols) {
                      if (colWidths.length < model.cols) {
                        colWidths.addAll(
                          List<double>.filled(
                            model.cols - colWidths.length,
                            120,
                          ),
                        );
                      } else if (colWidths.length > model.cols) {
                        colWidths.removeRange(model.cols, colWidths.length);
                      }
                      _lastCols = model.cols;
                      // controllers must be rebuilt because column indices shifted
                      for (final c in _controllers.values) {
                        c.dispose();
                      }
                      _controllers.clear();
                    }

                    // rows are fixed height; only columns are dynamic
                    if (_lastRows != model.rows) {
                      _lastRows = model.rows;
                      for (final c in _controllers.values) {
                        c.dispose();
                      }
                      _controllers.clear();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // header with column action buttons
                        Row(
                          children: [
                            const SizedBox(width: 28),
                            for (var c = 0; c < model.cols; c++)
                              Container(
                                width: colWidths[c],
                                height: 36,
                                alignment: Alignment.center,
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'add',
                                      child: Text('أضف عمود بعد'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('احذف العمود'),
                                    ),
                                  ],
                                  onSelected: (v) {
                                    if (v == 'add') {
                                      widget.onAddColumnAt?.call(c + 1);
                                    } else if (v == 'delete') {
                                      widget.onDeleteColumn?.call(c);
                                    }
                                  },
                                  child: const Icon(Icons.more_horiz, size: 16),
                                ),
                              ),
                          ],
                        ),

                        // data rows
                        for (var r = 0; r < model.rows; r++)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // small row action button at start of row
                              Column(
                                children: [
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'add',
                                        child: Text('أضف صف بعد'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('احذف الصف'),
                                      ),
                                    ],
                                    onSelected: (v) {
                                      if (v == 'add') {
                                        widget.onAddRowAt?.call(r + 1);
                                      } else if (v == 'delete') {
                                        widget.onDeleteRow?.call(r);
                                      }
                                    },
                                    child: Container(
                                      width: 28,
                                      height: _rowHeight,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.more_vert,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // cells for this row
                              for (var c = 0; c < model.cols; c++)
                                Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    _buildCell(r, c, model),
                                    // vertical drag handle for column
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      width: 8,
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onHorizontalDragUpdate: (d) =>
                                            _startResizeColumn(c, d),
                                        onHorizontalDragEnd: (_) {
                                          // persist the last column width
                                          final w = colWidths[c].clamp(
                                            60.0,
                                            800.0,
                                          );
                                          context
                                              .read<JadwalCubit>()
                                              .updateColumnWidth(
                                                widget.index,
                                                c,
                                                w,
                                              );
                                        },
                                        child: MouseRegion(
                                          cursor:
                                              SystemMouseCursors.resizeColumn,
                                          child: Container(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // rows are fixed height now; no vertical resizer
                                  ],
                                ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
