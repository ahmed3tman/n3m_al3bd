import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/share/widgets/custom_text_field.dart';
import '../../../../core/utils/number_converter.dart';

class WirdInputDialog extends StatefulWidget {
  final int currentAmount;
  final Function(int) onSave;

  const WirdInputDialog({
    super.key,
    required this.currentAmount,
    required this.onSave,
  });

  @override
  State<WirdInputDialog> createState() => _WirdInputDialogState();
}

class _WirdInputDialogState extends State<WirdInputDialog> {
  late TextEditingController _pageController;
  int? _selectedJuz;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(
      text: widget.currentAmount > 0 ? widget.currentAmount.toString() : '',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updatePagesFromJuz(int? juz) {
    if (juz != null) {
      setState(() {
        _selectedJuz = juz;
        // Assuming 1 Juz = 20 pages
        _pageController.text = (juz * 20).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تسجيل الورد اليومي',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w500, // Thinner title
            color: primaryColor,
            fontFamily: 'GeneralFont',
          ),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Page Input
              CustomTextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                labelText: 'عدد الصفحات',
                hintText: 'اكتب عدد الصفحات',
                prefixIcon: Icon(
                  Icons.menu_book,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
                onChanged: (value) {
                  // Reset Juz selection if user manually types
                  if (_selectedJuz != null) {
                    setState(() {
                      _selectedJuz = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Juz Dropdown
              Text(
                'أو اختر بالجزء:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400, // Regular weight
                  color: primaryColor,
                  fontFamily: 'GeneralFont',
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedJuz,
                    hint: Text(
                      'اختر الجزء',
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurfaceColor.withOpacity(0.5),
                        fontWeight: FontWeight.w300, // Light weight
                        fontFamily: 'GeneralFont',
                      ),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                    isExpanded: true,
                    items: List.generate(30, (index) {
                      final juzNumber = index + 1;
                      return DropdownMenuItem(
                        value: juzNumber,
                        child: Text(
                          'الجزء $juzNumber'.toArabicNumbers,
                          style: TextStyle(
                            color: onSurfaceColor,
                            fontWeight: FontWeight.w400, // Regular weight
                            fontFamily: 'GeneralFont',
                          ),
                        ),
                      );
                    }),
                    onChanged: _updatePagesFromJuz,
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    widget.onSave(0); // Reset/Cancel Wird
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'إلغاء الورد',
                    style: TextStyle(
                      fontWeight: FontWeight.w500, // Thinner than bold
                      fontFamily: 'GeneralFont',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(
                      fontWeight: FontWeight.w500, // Thinner than bold
                      fontFamily: 'GeneralFont',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final pages = int.tryParse(_pageController.text) ?? 0;
                    widget.onSave(pages);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF81B29A), // Sage green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'حفظ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500, // Thinner than bold
                      fontSize: 16,
                      fontFamily: 'GeneralFont',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
