import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class InputLabel extends StatelessWidget {
  const InputLabel({super.key, required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 3),
            const Text('*',
                style: TextStyle(color: AppTheme.errorColor, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
